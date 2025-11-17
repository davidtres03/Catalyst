# Windows Installer Patterns: Production Deployment & Updates

## Overview

Comprehensive patterns for building, deploying, and updating Windows applications through the installer ecosystem. Derived from production experience with version management, migration handling, and upgrade detection.

## 1. Version Management Architecture

### The Synchronization Problem

**Issue**: Application version numbers scattered across multiple projects create inconsistencies during updates.

```
YourProject.csproj:           Version 1.0.9.1
YourProject.Installer.csproj: Version 1.0.9.6  ❌ MISMATCH
WindowsService.csproj:             Version 1.0.9.2
DemoLauncher.csproj:               Version 1.0.9.4
```

**Impact on Upgrades**:
- Installer writes 1.0.9.6 to Windows Registry
- Application binary is 1.0.9.1
- Windows detects: Registry (1.0.9.6) > Binary (1.0.9.1) = **DOWNGRADE**
- Triggers automatic rollback on next uninstall/reinstall

### Solution: Centralized Version Source

**Pattern**: Single source of truth with cross-project synchronization.

**Approach 1: Linked Version File** (Recommended)
```xml
<!-- Directory.Build.props (root) -->
<Project>
  <PropertyGroup>
    <MajorVersion>1</MajorVersion>
    <MinorVersion>0</MinorVersion>
    <BuildVersion>9</BuildVersion>
    <RevisionVersion>7</RevisionVersion>
    <AssemblyVersion>$(MajorVersion).$(MinorVersion).$(BuildVersion).$(RevisionVersion)</AssemblyVersion>
    <FileVersion>$(MajorVersion).$(MinorVersion).$(BuildVersion).$(RevisionVersion)</FileVersion>
  </PropertyGroup>
</Project>

<!-- All .csproj files inherit this -->
```

**Approach 2: Build Script Synchronization** (PowerShell)
```powershell
# Sync-Versions.ps1
$newVersion = "1.0.9.7"

# Update all csproj files
Get-ChildItem -Recurse -Filter "*.csproj" | ForEach-Object {
    $xml = [xml](Get-Content $_.FullName)
    $xml.Project.PropertyGroup.Version = $newVersion
    $xml.Save($_.FullName)
}

# Verify synchronization
Get-ChildItem -Recurse -Filter "*.csproj" | ForEach-Object {
    $xml = [xml](Get-Content $_.FullName)
    Write-Host "$($_.Name): $($xml.Project.PropertyGroup.Version)"
}
```

### Registry vs. Binary Version Matching

**Critical Pattern**: Application must write its own version to Registry during installation.

```csharp
// InstallationService.cs (runs during install)
public class InstallationService
{
    public void WriteRegistryVersion(string version)
    {
        const string registryPath = @"SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AppName_*";
        using (var key = Registry.LocalMachine.OpenSubKey(registryPath, writable: true))
        {
            if (key != null)
            {
                // CRITICAL: Use application's AssemblyVersion, not installer's
                key.SetValue("DisplayVersion", version);
                key.SetValue("InstallDate", DateTime.Now.ToString("yyyyMMdd"));
            }
        }
    }
}
```

**Why This Matters**:
- Windows reads DisplayVersion from Registry (not from binary)
- If DisplayVersion > Installed binary version = Rollback triggers
- Solution: Application writes ITS OWN version during install
- All projects must have identical version numbers

## 2. Database Migration in Production Deployments

### The Missing Bundle Problem

**Issue**: Database schema migration requires Entity Framework Core migration bundle, but bundle isn't included in installer package.

**Symptom**:
```
⚠️ Warning: Migration bundle couldn't be found - database will be created 
with default schema
```

**Consequence**: Existing data lost, application in unknown state.

### Solution: Self-Contained Migration Bundles

**What is a Migration Bundle?**
- Single executable file containing all Entity Framework migrations
- Self-contained: No EF Core or .NET runtime dependency
- Executable independently: Can run migrations before app starts
- Generated at build time: Includes all migrations up to that version

**Generation Process**:
```bash
# From Data/Migrations directory
dotnet ef migrations bundle --force --self-contained -r win-x64 -o efbundle.exe

# Produces: efbundle.exe (46MB for typical schema with 50+ migrations)
```

**Key Parameters**:
- `--force`: Overwrite existing bundle
- `--self-contained`: Includes .NET runtime
- `-r win-x64`: Runtime identifier (Windows 64-bit)
- `-o efbundle.exe`: Output filename

### Including Bundle in Installer Package

**Pattern 1: Direct File Inclusion**
```xml
<!-- YourProject.Installer.csproj -->
<ItemGroup>
  <None Include="..\migrations\efbundle.exe" 
         CopyToOutputDirectory="PreserveNewest" />
</ItemGroup>
```

**Pattern 2: Verify Bundle Exists Pre-Build**
```xml
<Target Name="VerifyMigrationBundle" BeforeTargets="Build">
  <Error Condition="!Exists('..\migrations\efbundle.exe')" 
         Text="Migration bundle not found. Run: dotnet ef migrations bundle --force --self-contained -r win-x64" />
</Target>
```

**Pattern 3: Publish with Bundle**
```csharp
// PublishInstallerPackage.ps1
$sourceBundle = "...\migrations\efbundle.exe"
$destBundle = "...\bin\Release\net8.0-windows\migrations\efbundle.exe"

# Ensure destination directory exists
New-Item -ItemType Directory -Path (Split-Path $destBundle) -Force | Out-Null

# Copy bundle to output
Copy-Item $sourceBundle $destBundle -Force
Write-Host "✓ Migration bundle included in package"
```

### Executing Migrations During Installation

**Pattern: Pre-Application Database Setup**
```csharp
// InstallationService.cs
public class InstallationService
{
    public async Task ApplyMigrationsAsync(string bundlePath)
    {
        if (!File.Exists(bundlePath))
        {
            Logger.Warn($"Migration bundle not found: {bundlePath}");
            return;
        }

        try
        {
            // Get connection string from installed app config
            var connectionString = GetInstalledConnectionString();
            
            // Execute bundle (runs all pending migrations)
            var process = new ProcessStartInfo
            {
                FileName = bundlePath,
                Arguments = $"--connection \"{connectionString}\"",
                UseShellExecute = false,
                RedirectStandardOutput = true,
                CreateNoWindow = true
            };

            using (var p = Process.Start(process))
            {
                var output = await p.StandardOutput.ReadToEndAsync();
                p.WaitForExit();
                
                if (p.ExitCode == 0)
                {
                    Logger.Info("Database migrations applied successfully");
                }
                else
                {
                    Logger.Error($"Migration failed: {output}");
                }
            }
        }
        catch (Exception ex)
        {
            Logger.Error($"Error applying migrations: {ex.Message}");
            // Continue anyway - app can create tables if needed
        }
    }
}
```

### Versioning Migrations

**Pattern: Link Migration Version to App Version**
```csharp
// Migrations/20251115120000_Version1097_AddApiConfigurationTables.cs
public partial class Version1097_AddApiConfigurationTables : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        // Create ApiConfigurations table
        // This migration corresponds to app version 1.0.9.7
    }
}
```

**Benefit**: Easy to trace which app version introduced which schema changes.

## 3. GitHub Release & Upgrade Detection

### Release Structure

**Pattern**: Semantic versioning with GitHub Releases as distribution channel.

```
Tag: v1.0.9.7
Release: Release 1.0.9.7 - [Description]
Assets:
  - YourProject-Installer-v1.0.9.7.zip (21MB)
  - CHANGELOG.md
  - SHA256_CHECKSUMS
```

**Critical Pattern**: GitHub Releases ≠ Git Tags
- Git tag: Just a git marker (version control only)
- GitHub Release: Includes assets, notes, distribution endpoint
- GitHub API: `/repos/owner/repo/releases` returns releases (not just tags)

### Upgrade Detection Flow

```
┌─────────────────────────────────────┐
│ Installed App (1.0.9.2)             │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ GitHubReleaseService                │
│ Queries: /repos/owner/repo/releases │
│ Looks for: latest release           │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ GitHub API Response                 │
│ Release: v1.0.9.7 (latest)          │
│ Assets: [installer-v1.0.9.7.zip]    │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ UpgradeDetectionService             │
│ Compare: 1.0.9.2 < 1.0.9.7 ✓        │
│ Result: UPDATE AVAILABLE            │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ User sees: "UPDATE AVAILABLE"       │
│ Clicks: UPGRADE button              │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ Download installer from GitHub      │
│ Execute installer                   │
│ Apply migrations with efbundle.exe  │
│ Update registry to 1.0.9.7          │
│ No rollback (versions now match)    │
└─────────────────────────────────────┘
```

### Publication Pattern (GitHub CLI)

```powershell
# Publish-Release-1.0.9.7.ps1
param(
    [string]$Owner = "YOUR_USERNAME",
    [string]$Repo = "Catalyst-Personal",
    [string]$Version = "1.0.9.7",
    [string]$InstallerPath = "./YourProject-Installer-v1.0.9.7.zip"
)

# 1. Create git tag
Write-Host "Creating git tag v$Version..."
git tag -a "v$Version" -m "Release v$Version"
git push origin "v$Version"

# 2. Create GitHub Release
Write-Host "Creating GitHub Release..."
$releaseNotes = @"
# Release v$Version

## Features
- Unified API Configuration System with AES-256 encryption
- Database migration bundle integration
- Enhanced upgrade detection

## What's Changed
- New ApiConfiguration table for credential storage
- All projects synchronized to version $Version
- Migration bundle (efbundle.exe) included in installer

## Installation
1. Download YourProject-Installer-v$Version.zip
2. Extract and run installer
3. Migrations applied automatically
4. Registry updated to $Version

See CHANGELOG.md for complete details.
"@

gh release create "v$Version" `
    --repo "$Owner/$Repo" `
    --notes "$releaseNotes" `
    --title "Release v$Version"

# 3. Upload installer asset
Write-Host "Uploading installer..."
gh release upload "v$Version" "$InstallerPath" `
    --repo "$Owner/$Repo" `
    --clobber

Write-Host "✓ Release v$Version published successfully"
```

## 4. Common Pitfalls & Solutions

### Pitfall 1: Version Mismatch on Upgrade
**Problem**: Different project versions cause rollback  
**Solution**: Synchronize all versions via Directory.Build.props  
**Verification**: Build script checks all .csproj files match before publish

### Pitfall 2: Migration Bundle Missing
**Problem**: No schema changes applied, database broken  
**Solution**: Include efbundle.exe in installer, execute pre-application startup  
**Verification**: Installer logs migration execution success/failure

### Pitfall 3: GitHub Release Not Published
**Problem**: Git tag exists but release has no assets → installer can't download  
**Solution**: Publish script creates release AND uploads asset  
**Verification**: `gh release view v1.0.9.7` shows assets

### Pitfall 4: Registry DisplayVersion Incorrect
**Problem**: Windows sees Registry version ≠ Binary version → triggers rollback  
**Solution**: Application writes its own version to Registry during install  
**Verification**: Registry check: `Get-ItemProperty HKLM:\SOFTWARE\...\DisplayVersion`

## 5. Production Checklist

```markdown
## Pre-Release Checklist

- [ ] All project versions synchronized (check Directory.Build.props or all .csproj files)
- [ ] Migration bundle generated: `dotnet ef migrations bundle --force --self-contained -r win-x64`
- [ ] Migration bundle included in installer package
- [ ] Installer .csproj includes bundle copy directive
- [ ] Build produces installer with embedded bundle
- [ ] Test install on clean machine - no "bundle not found" warning
- [ ] Verify registry DisplayVersion matches application version
- [ ] Create git tag: `git tag -a v1.0.9.7 -m "Release v1.0.9.7"`
- [ ] Push tag: `git push origin v1.0.9.7`
- [ ] Create GitHub Release with assets: `gh release create v1.0.9.7 installer.zip`
- [ ] Verify GitHub API returns release: `curl https://api.github.com/repos/owner/repo/releases/latest`
- [ ] Test upgrade from previous version - should download and apply successfully
- [ ] Verify no rollback occurs after upgrade (check event logs)

## Post-Release Verification

- [ ] Installed app displays correct version in UI
- [ ] Registry shows correct DisplayVersion
- [ ] Database schema updated (check migration logs)
- [ ] No "Update Available" shown immediately after upgrade
- [ ] User can upgrade again in future versions
```

## Key Patterns Summary

| Pattern | Purpose | Key Point |
|---------|---------|-----------|
| Centralized Versioning | Prevent version mismatch | Use Directory.Build.props |
| Self-Contained Bundles | Deploy DB migrations | Generate at build time |
| Registry Write | Windows compatibility | App writes its own version |
| GitHub Releases | Update distribution | Release ≠ Tag (must include assets) |
| Upgrade Detection | User notification | Compare versions, download from releases |
| Pre-Install Migration | Data safety | Execute before app starts |

---

**Core Lesson**: Windows installer deployment requires meticulous version synchronization, database migration handling, and GitHub integration. Each piece must work perfectly for seamless upgrades.

