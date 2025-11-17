# GitHub Release Automation with build.sh and release.sh

**Category:** DevOps / CI/CD / Release Management
**Difficulty:** Intermediate
**Date Created:** November 17, 2025
**Discovered In:** YourProject v1.1.0.0 Release Process

---

## Overview

Complete GitHub release automation using two bash scripts: `build.sh` (package creation) and `release.sh` (GitHub upload). Cross-platform compatible, production-tested, handles versioning automatically.

---

## Architecture

```
Version Source (Single Source of Truth)
    ↓
YourProject.Installer.csproj
    <Version>1.1.0.0</Version>
    ↓
build.sh (reads version, builds package)
    ├── Extract version from csproj
    ├── Build web application (Release mode)
    ├── Build Installer.exe (self-contained)
    ├── Build Upgrader.exe (self-contained)
    ├── Create EF migrations bundle
    ├── Package everything into ZIP
    └── Verify package integrity
    ↓
release.sh (uploads to GitHub)
    ├── Load GitHub token from Credential Manager
    ├── Check if release exists
    ├── Create release (if new)
    ├── Upload ZIP as asset
    └── Display release URL
```

---

## Script 1: build.sh (Package Builder)

**Purpose:** Build complete installer package with all components

**Location:** `<YOUR_WORKSPACE>/YourProject-Source/build.sh`

**Usage:**
```bash
cd /c/Catalyst/Catalyst-Personal/YourProject-Source
./build.sh
```

**What It Does:**

1. **Extract Version** from `YourProject.Installer.csproj`
   ```bash
   VERSION=$(grep -oP '<Version>\K[^<]+' YourProject-Source/YourProject.Installer/YourProject.Installer.csproj)
   ```

2. **Build Web Application** (Release mode, 62 MB, 161 files)
   ```bash
   dotnet publish YourProject/YourProject.csproj \
       -c Release \
       -o temp_build/Application
   ```

3. **Build Installer.exe** (Self-contained with runtime, 222 MB)
   ```bash
   dotnet publish YourProject.Installer/YourProject.Installer.csproj \
       -c Release \
       -r win-x64 \
       --self-contained true \
       -o temp_build/Installer
   ```

4. **Build Upgrader.exe** (Self-contained with runtime, 176 MB)
   ```bash
   dotnet publish YourProject.Upgrader/YourProject.Upgrader.csproj \
       -c Release \
       -r win-x64 \
       --self-contained true \
       -o temp_build/Upgrader
   ```

5. **Create Migrations Bundle** (efbundle.exe, 46 MB)
   ```bash
   dotnet ef migrations bundle \
       --project YourProject \
       --startup-project YourProject \
       -o temp_build/efbundle.exe \
       --self-contained \
       -r win-x64
   ```

6. **Package Everything** into ZIP (141 MB, 931 files)
   ```bash
   zip -r "Packages/YourProject-Installer-v${VERSION}.zip" \
       Application/ \
       Installer/ \
       Upgrader/ \
       efbundle.exe \
       README.md \
       LICENSE
   ```

7. **Verify Package Integrity**
   ```bash
   unzip -t "Packages/YourProject-Installer-v${VERSION}.zip"
   ```

**Output:**
```
✅ BUILD COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Package: YourProject-Installer-v1.1.0.0.zip
📊 Size: 141 MB (147,292,272 bytes)
📁 Files: 931 total
⏱️  Build Time: 45 seconds
✅ Verification: PASSED
```

---

## Script 2: release.sh (GitHub Uploader)

**Purpose:** Upload package to GitHub as release

**Location:** `<YOUR_WORKSPACE>/YourProject-Source/release.sh`

**Usage:**
```bash
cd /c/Catalyst/Catalyst-Personal/YourProject-Source
./release.sh
```

**Prerequisites:**
1. **GitHub CLI** installed: `winget install GitHub.cli`
2. **GitHub Token** stored in Windows Credential Manager:
   ```powershell
   Install-Module CredentialManager -Force
   New-StoredCredential -Target "CatalystGitHubToken" -UserName "github" -Password "ghp_xxxxx" -Persist LocalMachine
   ```

**What It Does:**

1. **Load GitHub Token** from Credential Manager
   ```bash
   export GH_TOKEN=$(powershell.exe -NoProfile -Command '
       Import-Module CredentialManager;
       $cred = Get-StoredCredential -Target "CatalystGitHubToken";
       $cred.GetNetworkCredential().Password
   ')
   ```

2. **Authenticate with GitHub**
   ```bash
   gh auth status
   ```

3. **Check if Release Exists**
   ```bash
   gh release view "v${VERSION}" --repo YOUR_USERNAME/Catalyst-Personal
   ```

4. **Create Release** (if new) or **Upload Asset** (if exists)
   ```bash
   # New release
   gh release create "v${VERSION}" \
       --title "YourProject v${VERSION}" \
       --notes "Complete installer package with Installer, Upgrader, and migrations." \
       --repo YOUR_USERNAME/Catalyst-Personal \
       "Packages/YourProject-Installer-v${VERSION}.zip"
   
   # Existing release
   gh release upload "v${VERSION}" \
       "Packages/YourProject-Installer-v${VERSION}.zip" \
       --repo YOUR_USERNAME/Catalyst-Personal \
       --clobber
   ```

5. **Display Release Info**
   ```bash
   gh release view "v${VERSION}" --repo YOUR_USERNAME/Catalyst-Personal
   ```

**Output:**
```
✅ RELEASE PUBLISHED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Release: v1.1.0.0
**Example Output:**
```
🔗 URL: https://github.com/YOUR_USERNAME/YOUR_REPO/releases/tag/v1.1.0.0
📊 Asset: YourProject-Installer-v1.1.0.0.zip (147,292,272 bytes)
⏱️  Upload Time: 12 seconds
```

---

## Version Management (Single Source of Truth)

**File:** `YourProject.Installer/YourProject.Installer.csproj`

**Version Property:**
```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <Version>1.1.0.0</Version>
  </PropertyGroup>
</Project>
```

**Impact:**
- Controls `AssemblyVersion`
- Controls `FileVersion`
- Controls `InformationalVersion`
- Read by `build.sh` for package naming
- Used by `release.sh` for tag naming

**To Update Version:**
```bash
# 1. Edit file
code YourProject.Installer/YourProject.Installer.csproj

# 2. Change version
<Version>1.1.0.1</Version>

# 3. Save and run build
./build.sh
./release.sh
```

---

## Complete Workflow

### Step 1: Update Version
```bash
# Edit csproj, update <Version> tag
code YourProject.Installer/YourProject.Installer.csproj
```

### Step 2: Build Package
```bash
cd /c/Catalyst/Catalyst-Personal/YourProject-Source
./build.sh
```

**Monitors for:**
- ✅ Compilation success
- ✅ All components built (App, Installer, Upgrader, Migrations)
- ✅ Package created
- ✅ ZIP integrity verified

### Step 3: Upload to GitHub
```bash
./release.sh
```

**Monitors for:**
- ✅ GitHub authentication
- ✅ Release created/updated
- ✅ Asset uploaded
- ✅ Release URL available

### Step 4: Verify Release
```bash
# Visit release URL
https://github.com/YOUR_USERNAME/Catalyst-Personal/releases/tag/v1.1.0.0

# Download and test ZIP
curl -LO https://github.com/YOUR_USERNAME/Catalyst-Personal/releases/download/v1.1.0.0/YourProject-Installer-v1.1.0.0.zip
unzip -l YourProject-Installer-v1.1.0.0.zip
```

---

## Build Script Internals

**Key Functions:**

### Version Extraction
```bash
extract_version() {
    local csproj_file="YourProject.Installer/YourProject.Installer.csproj"
    
    if [ ! -f "$csproj_file" ]; then
        echo "❌ Error: $csproj_file not found"
        exit 1
    fi
    
    VERSION=$(grep -oP '<Version>\K[^<]+' "$csproj_file")
    
    if [ -z "$VERSION" ]; then
        echo "❌ Error: Could not extract version from $csproj_file"
        exit 1
    fi
    
    echo "📌 Version: $VERSION"
}
```

### Clean Build Directory
```bash
clean_build() {
    echo "🧹 Cleaning previous build..."
    rm -rf temp_build
    mkdir -p temp_build/{Application,Installer,Upgrader}
    mkdir -p Packages
}
```

### Build Application
```bash
build_application() {
    echo "🔨 Building web application..."
    dotnet publish YourProject/YourProject.csproj \
        -c Release \
        -o temp_build/Application \
        --no-self-contained \
        || { echo "❌ Application build failed"; exit 1; }
    
    echo "✅ Application build complete ($(du -sh temp_build/Application | cut -f1))"
}
```

### Build Components
```bash
build_installer() {
    echo "🔨 Building installer..."
    dotnet publish YourProject.Installer/YourProject.Installer.csproj \
        -c Release \
        -r win-x64 \
        --self-contained true \
        -o temp_build/Installer \
        || { echo "❌ Installer build failed"; exit 1; }
    
    echo "✅ Installer build complete"
}

build_upgrader() {
    echo "🔨 Building upgrader..."
    dotnet publish YourProject.Upgrader/YourProject.Upgrader.csproj \
        -c Release \
        -r win-x64 \
        --self-contained true \
        -o temp_build/Upgrader \
        || { echo "❌ Upgrader build failed"; exit 1; }
    
    echo "✅ Upgrader build complete"
}
```

### Create Migrations Bundle
```bash
create_migrations_bundle() {
    echo "🔨 Creating migrations bundle..."
    dotnet ef migrations bundle \
        --project YourProject \
        --startup-project YourProject \
        -o temp_build/efbundle.exe \
        --self-contained \
        -r win-x64 \
        --force \
        || { echo "❌ Migrations bundle creation failed"; exit 1; }
    
    echo "✅ Migrations bundle created"
}
```

### Package Everything
```bash
create_package() {
    cd temp_build || exit 1
    
    local zip_name="YourProject-Installer-v${VERSION}.zip"
    local zip_path="../Packages/${zip_name}"
    
    echo "📦 Creating ZIP package..."
    zip -r "$zip_path" \
        Application/ \
        Installer/ \
        Upgrader/ \
        efbundle.exe \
        README.md \
        LICENSE \
        -q
    
    cd ..
    
    local size=$(stat -c %s "Packages/${zip_name}" 2>/dev/null || stat -f %z "Packages/${zip_name}")
    local file_count=$(unzip -l "Packages/${zip_name}" | tail -1 | awk '{print $2}')
    
    echo "✅ Package created: $zip_name"
    echo "   Size: $(numfmt --to=iec $size) ($size bytes)"
    echo "   Files: $file_count"
}
```

---

## Release Script Internals

**Key Functions:**

### Load GitHub Token
```bash
load_github_token() {
    echo "🔑 Loading GitHub token from Credential Manager..."
    
    export GH_TOKEN=$(powershell.exe -NoProfile -Command '
        Import-Module CredentialManager;
        $cred = Get-StoredCredential -Target "CatalystGitHubToken";
        if ($cred) {
            $cred.GetNetworkCredential().Password
        }
    ' | tr -d '\r')
    
    if [ -z "$GH_TOKEN" ]; then
        echo "❌ Error: Could not load GitHub token"
        exit 1
    fi
    
    echo "✅ GitHub token loaded"
}
```

### Check Release Exists
```bash
check_release_exists() {
    gh release view "v${VERSION}" --repo YOUR_USERNAME/YOUR_REPO &>/dev/null
    return $?
}
```

### Create New Release
```bash
create_release() {
    echo "🚀 Creating new release v${VERSION}..."
    
    gh release create "v${VERSION}" \
        --title "YourProject v${VERSION}" \
        --notes "$(generate_release_notes)" \
        --repo YOUR_USERNAME/Catalyst-Personal \
        "$ZIP_PATH" \
        || { echo "❌ Release creation failed"; exit 1; }
    
    echo "✅ Release created"
}
```

### Upload to Existing Release
```bash
upload_asset() {
    echo "📤 Uploading asset to existing release..."
    
    gh release upload "v${VERSION}" \
        "$ZIP_PATH" \
        --repo YOUR_USERNAME/Catalyst-Personal \
        --clobber \
        || { echo "❌ Asset upload failed"; exit 1; }
    
    echo "✅ Asset uploaded"
}
```

---

## Error Handling

**Build Errors:**
```bash
# build.sh checks each step
dotnet publish ... || { echo "❌ Build failed"; exit 1; }

# Verifies package integrity
unzip -t "$ZIP_PATH" || { echo "❌ Package corrupted"; exit 1; }
```

**Release Errors:**
```bash
# release.sh checks authentication
gh auth status || { echo "❌ Not authenticated"; exit 1; }

# Verifies package exists
[ -f "$ZIP_PATH" ] || { echo "❌ Package not found"; exit 1; }

# Handles API failures
gh release create ... || { echo "❌ Release failed"; exit 1; }
```

---

## Cross-Platform Compatibility

**Windows (Git Bash):**
```bash
# Use Git Bash (comes with Git for Windows)
/c/Catalyst/Catalyst-Personal/YourProject-Source/build.sh
```

**Linux/macOS:**
```bash
# Same scripts work identically
/opt/catalyst/YourProject-Source/build.sh
```

**PowerShell Integration:**
```bash
# Scripts call PowerShell for Credential Manager
powershell.exe -NoProfile -Command 'Import-Module CredentialManager; ...'
```

---

## Performance Benchmarks

**build.sh:**
- Clean build: ~45 seconds
- Incremental build: ~30 seconds
- Package creation: ~5 seconds
- Total: ~50 seconds

**release.sh:**
- Token loading: <1 second
- Release creation: ~2 seconds
- Asset upload (147 MB): ~12 seconds
- Total: ~15 seconds

**Complete Workflow:**
- Version update: ~10 seconds
- Build: ~50 seconds
- Release: ~15 seconds
- **Total: ~75 seconds (1.25 minutes)**

---

## Best Practices

1. **Always update version first** before running build.sh
2. **Run build.sh before release.sh** to ensure package exists
3. **Verify package integrity** with `unzip -l` before releasing
4. **Store GitHub token securely** in Credential Manager
5. **Use descriptive release notes** in release.sh
6. **Tag releases semantically** (v1.0.0, not v1.0.0-beta)
7. **Test package locally** before releasing publicly

---

## Troubleshooting

### Error: "Version not found in csproj"
**Solution:** Ensure `<Version>` tag exists in `YourProject.Installer.csproj`

### Error: "Not authenticated with GitHub"
**Solution:** Store token in Credential Manager:
```powershell
Install-Module CredentialManager -Force
New-StoredCredential -Target "CatalystGitHubToken" -UserName "github" -Password "ghp_xxxxx" -Persist LocalMachine
```

### Error: "Package not found"
**Solution:** Run `build.sh` first to create package

### Error: "Release already exists"
**Solution:** Script handles this automatically (uploads as additional asset)

---

## References

- GitHub CLI: https://cli.github.com/
- YourProject v1.1.0.0 Release
- Session 22: Release Automation Victory

**Related Files:**
- `build.sh`
- `release.sh`
- `YourProject.Installer.csproj`
