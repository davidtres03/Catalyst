# GitHub Release Procedure

**Category:** Deployment / Release Management
**Difficulty:** Intermediate
**Last Updated:** November 17, 2025
**Source:** YourProject v1.1.0.0 Release

---

## Overview

Complete step-by-step procedure for creating GitHub releases using the automated build and release scripts.

---

## Prerequisites

**Tools Required:**
- Git Bash (comes with Git for Windows)
- .NET 8.0 SDK
- Entity Framework Core tools
- GitHub CLI (`gh`)
- PowerShell CredentialManager module

**Setup (One-Time):**

```powershell
# Install GitHub CLI
winget install GitHub.cli

# Install CredentialManager
Install-Module CredentialManager -Force -AllowClobber

# Store GitHub token
$token = "ghp_your_github_personal_access_token_here"
New-StoredCredential -Target "CatalystGitHubToken" -UserName "github" -Password $token -Persist LocalMachine

# Verify token stored
Get-StoredCredential -Target "CatalystGitHubToken"
```

**GitHub Token Permissions:**
- `repo` (Full control of private repositories)
- `workflow` (Update GitHub Actions workflows)
- `write:packages` (Upload packages)

---

## Procedure

### Step 1: Update Version Number

**File:** `YourProject.Installer/YourProject.Installer.csproj`

1. Open file in editor:
   ```bash
   code YourProject.Installer/YourProject.Installer.csproj
   ```

2. Locate `<Version>` tag (around line 17):
   ```xml
   <Version>1.0.9.50</Version>
   ```

3. Update to new version:
   ```xml
   <Version>1.1.0.0</Version>
   ```

4. Save file (Ctrl+S)

**Verification:**
```bash
grep '<Version>' YourProject.Installer/YourProject.Installer.csproj
# Should output: <Version>1.1.0.0</Version>
```

---

### Step 2: Build Installer Package

**Command:**
```bash
cd /c/Catalyst/Catalyst-Personal/YourProject-Source
./build.sh
```

**What Happens:**
1. ✅ Extracts version from csproj
2. ✅ Cleans previous build directory
3. ✅ Builds web application (Release mode)
4. ✅ Builds Installer.exe (self-contained)
5. ✅ Builds Upgrader.exe (self-contained)
6. ✅ Creates migrations bundle (efbundle.exe)
7. ✅ Packages everything into ZIP
8. ✅ Verifies package integrity

**Expected Output:**
```
📌 Version: 1.1.0.0
🧹 Cleaning previous build...
🔨 Building web application...
✅ Application build complete (62M)
🔨 Building installer...
✅ Installer build complete
🔨 Building upgrader...
✅ Upgrader build complete
🔨 Creating migrations bundle...
✅ Migrations bundle created
📦 Creating ZIP package...
✅ Package created: YourProject-Installer-v1.1.0.0.zip
   Size: 141M (147292272 bytes)
   Files: 931
🔍 Verifying package integrity...
✅ Package verification passed

✅ BUILD COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Package: YourProject-Installer-v1.1.0.0.zip
📊 Size: 141 MB (147,292,272 bytes)
📁 Files: 931 total
⏱️  Build Time: ~45 seconds
✅ Verification: PASSED
```

**Troubleshooting:**

**Error: "Version not found"**
- **Cause:** `<Version>` tag missing or malformed
- **Solution:** Verify tag exists in csproj file

**Error: "Build failed" during publish**
- **Cause:** Compilation errors in code
- **Solution:** Review error messages, fix code issues, retry

**Error: "Package verification failed"**
- **Cause:** ZIP corruption during creation
- **Solution:** Delete `temp_build/` and `Packages/`, retry build

---

### Step 3: Verify Package Contents

**Command:**
```bash
unzip -l Packages/YourProject-Installer-v1.1.0.0.zip | less
```

**Expected Structure:**
```
Application/
  ├── YourProject.dll
  ├── appsettings.json
  ├── wwwroot/
  └── ... (161 files)

Installer/
  ├── YourProject.Installer.exe
  ├── ... (runtime dependencies)

Upgrader/
  ├── YourProject.Upgrader.exe
  ├── ... (runtime dependencies)

efbundle.exe

README.md
LICENSE
```

**Critical Files to Verify:**
- ✅ `Application/YourProject.dll` exists
- ✅ `Installer/YourProject.Installer.exe` exists
- ✅ `Upgrader/YourProject.Upgrader.exe` exists ⚠️ **MUST BE PRESENT**
- ✅ `efbundle.exe` exists
- ✅ `README.md` and `LICENSE` exist

**If Upgrader Missing:**
- **Stop immediately** - package incomplete
- Review build.sh output for errors in Upgrader build step
- Delete `temp_build/` and retry

---

### Step 4: Upload to GitHub

**Command:**
```bash
./release.sh
```

**What Happens:**
1. ✅ Loads GitHub token from Credential Manager
2. ✅ Authenticates with GitHub CLI
3. ✅ Checks if release v1.1.0.0 already exists
4. ✅ Creates new release (if doesn't exist)
5. ✅ Uploads ZIP as release asset
6. ✅ Displays release URL

**Expected Output:**
```
🔑 Loading GitHub token from Credential Manager...
✅ GitHub token loaded

🔐 Authenticating with GitHub...
**✅ Authenticated as YOUR_USERNAME**

📦 Found package: YourProject-Installer-v1.1.0.0.zip (141M)

🔍 Checking if release v1.1.0.0 exists...
❌ Release does not exist

🚀 Creating new release v1.1.0.0...
✅ Release created

📤 Uploading asset...
✅ Asset uploaded

✅ RELEASE PUBLISHED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Release: v1.1.0.0
**Output:**
```
🔗 URL: https://github.com/YOUR_USERNAME/YOUR_REPO/releases/tag/v1.1.0.0
📊 Asset: YourProject-Installer-v1.1.0.0.zip (147,292,272 bytes)
⏱️  Upload Time: ~12 seconds
```

**Troubleshooting:**

**Error: "Not authenticated with GitHub"**
- **Cause:** Token not loaded or invalid
- **Solution:** Re-run credential storage from prerequisites

**Error: "Release already exists"**
- **Not an error** - Script uploads as additional asset
- Previous asset overwritten with `--clobber` flag

**Error: "Package not found"**
- **Cause:** build.sh not run or failed
- **Solution:** Run build.sh first

---

### Step 5: Verify Release

**Open Release URL:**
```
https://github.com/YOUR_USERNAME/Catalyst-Personal/releases/tag/v1.1.0.0
```

**Check:**
1. ✅ Release title: "YourProject v1.1.0.0"
2. ✅ Asset present: "YourProject-Installer-v1.1.0.0.zip"
3. ✅ Asset size: ~147 MB
4. ✅ Release notes populated
5. ✅ Tag: "v1.1.0.0"

**Download and Test:**
```bash
# Download
curl -LO https://github.com/YOUR_USERNAME/Catalyst-Personal/releases/download/v1.1.0.0/YourProject-Installer-v1.1.0.0.zip

# Verify contents
unzip -l YourProject-Installer-v1.1.0.0.zip | grep -E "(Installer.exe|Upgrader.exe|efbundle.exe)"

# Should output:
# ... Installer/YourProject.Installer.exe
# ... Upgrader/YourProject.Upgrader.exe
# ... efbundle.exe
```

**If Any Component Missing:**
- **Delete release** (gh release delete v1.1.0.0)
- **Fix build.sh** (ensure all components built)
- **Retry from Step 2**

---

### Step 6: Update Documentation

**Files to Update:**

1. **CHANGELOG.md**
   ```bash
   code CHANGELOG.md
   ```
   
   Add entry:
   ```markdown
   ## [1.1.0.0] - 2025-11-17
   
   ### Added
   - Dual AI backend integration (Ollama + Claude)
   - Cloudinary AI image transformations
   - Configuration caching system
   
   ### Fixed
   - Service lifetime issues (IServiceScopeFactory pattern)
   - Disposed DbContext errors
   - Configuration reload from database
   ```

2. **README.md**
   ```bash
   code README.md
   ```
   
   Update version badge:
   ```markdown
   ![Version](https://img.shields.io/badge/version-1.1.0.0-blue)
   ```

3. **Release Notes File**
   ```bash
   code RELEASE_NOTES_1.1.0.0.md
   ```
   
   Create detailed release notes (see template below)

**Commit Documentation:**
```bash
git add CHANGELOG.md README.md RELEASE_NOTES_1.1.0.0.md
git commit -m "docs: Update documentation for v1.1.0.0"
git push
```

---

## Release Notes Template

**File:** `RELEASE_NOTES_1.1.0.0.md`

```markdown
# YourProject v1.1.0.0

**Release Date:** November 17, 2025

## 🎉 Major Features

### Dual AI Backend Integration
- Ollama (local, privacy-focused)
- Claude AI (cloud, high-quality)
- Intelligent request routing
- Fallback handling

### Cloudinary AI Image Optimization
- 7 AI transformations (auto quality, format, color, etc.)
- 93% file size reduction
- CDN caching
- Responsive images

### Architecture Improvements
- IServiceScopeFactory pattern for service lifetimes
- Configuration caching (30-second TTL)
- Manual cache invalidation
- Robust error handling

## 🐛 Bug Fixes

1. Disposed DbContext errors (Singleton → Scoped conflict)
2. Configuration not reloading from database
3. AI service initialization race conditions
4. Cloudinary URL generation errors
5. Backend registration persistence issues
6. Request routing failures
7. Cache invalidation not working

## 📦 Installation

1. Download `YourProject-Installer-v1.1.0.0.zip`
2. Extract to desired location
3. Run `Installer/YourProject.Installer.exe`
4. Follow installation wizard

## 🔧 Upgrading from v1.0.9.50

1. Run `Upgrader/YourProject.Upgrader.exe`
2. Point to existing installation
3. Upgrader handles migrations automatically

## 📋 Requirements

- Windows 10/11 (x64)
- .NET 8.0 Runtime (included in self-contained build)
- SQL Server 2019+ or LocalDB

## 🔗 Links

- [GitHub Repository](https://github.com/YOUR_USERNAME/YOUR_REPO)
- [Documentation](https://github.com/YOUR_USERNAME/YOUR_REPO/wiki)
- [Issue Tracker](https://github.com/YOUR_USERNAME/YOUR_REPO/issues)
```

---

## Quick Reference Card

**Complete Release in 4 Commands:**

```bash
# 1. Update version
code YourProject.Installer/YourProject.Installer.csproj
# Change <Version>1.0.9.50</Version> to <Version>1.1.0.0</Version>

# 2. Build package
./build.sh

# 3. Upload to GitHub
./release.sh

# 4. Verify
unzip -l Packages/YourProject-Installer-v1.1.0.0.zip | grep -E "(Installer|Upgrader|efbundle)"
```

**Total Time:** ~2 minutes (75 seconds build + verify)

---

## Rollback Procedure

**If release has issues:**

```bash
# 1. Delete GitHub release
gh release delete v1.1.0.0 --yes --repo YOUR_USERNAME/YOUR_REPO

# 2. Delete local package
rm Packages/YourProject-Installer-v1.1.0.0.zip

# 3. Revert version in csproj
code YourProject.Installer/YourProject.Installer.csproj
# Change back to previous version

# 4. Rebuild and re-release
./build.sh
./release.sh
```

---

## Checklist

**Before Release:**
- [ ] Version updated in csproj
- [ ] CHANGELOG.md updated
- [ ] All tests passing
- [ ] Code committed to main branch
- [ ] No uncommitted changes

**During Release:**
- [ ] build.sh completes successfully
- [ ] Package verification passed
- [ ] All components present (App, Installer, Upgrader, Migrations)
- [ ] release.sh uploads successfully
- [ ] Release URL accessible

**After Release:**
- [ ] Download and verify ZIP integrity
- [ ] Test installer on clean machine
- [ ] Test upgrader from previous version
- [ ] Update documentation
- [ ] Announce release (if public)

---

## Common Issues

### Issue: Upgrader.exe Missing from Package
**Symptom:** ZIP doesn't contain `Upgrader/` directory
**Cause:** build.sh Upgrader step failed silently
**Solution:** Review build.sh output, ensure dotnet publish Upgrader succeeds

### Issue: "Version 1.0.9.50" in Built Files
**Symptom:** Built files show old version despite csproj update
**Cause:** Cached build artifacts
**Solution:** Delete `temp_build/`, `bin/`, `obj/` directories, rebuild

### Issue: Release Upload Stalls
**Symptom:** release.sh hangs at "Uploading asset..."
**Cause:** Network issues, GitHub API rate limiting
**Solution:** Cancel (Ctrl+C), wait 5 minutes, retry

### Issue: "Release already exists" Error
**Symptom:** Cannot create release
**Cause:** Tag already exists (maybe from previous attempt)
**Solution:** Script handles automatically with `--clobber`, or manually delete old release first

---

## References

- `build.sh` - Build automation script
- `release.sh` - GitHub upload script
- `YourProject.Installer.csproj` - Version source of truth
- Session 22: Release Automation Victory

**Related Procedures:**
- Service Lifetime Troubleshooting
- AI Backend Configuration
- Build Process
