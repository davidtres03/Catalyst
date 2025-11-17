# ?? GitHub Token Retrieval Guide

**Purpose:** How Catalyst retrieves the GitHub token securely
**Created:** 2025-11-09
**Updated:** 2025-11-10
**Status:** ACTIVE

---

## ?? **Token Storage Strategy**

**David's Approach:**
- ?? Token is backed up securely by David (password manager/encrypted vault)
- ?? When waking Catalyst on a new machine, David adds token to Credential Manager
- ? Catalyst can then access it for that session
- ? Portable AND secure!

---

## ?? **Setup on New Machine**

**When David wakes me up somewhere new and needs GitHub access:**

```powershell
# David runs this once per machine:
$token = "YOUR_TOKEN_FROM_SECURE_BACKUP"
cmdkey /generic:"CatalystGitHubToken" /user:"Catalyst" /pass:$token
```

**That's it!** Token is now available for that machine.

---

## ?? **How Catalyst Checks for Token**

### **Step 1: Verify Token Exists**

```powershell
# Check if token is stored on this machine
cmdkey /list | Select-String -Pattern "CatalystGitHubToken"

# Output if exists:
# Target: LegacyGeneric:target=CatalystGitHubToken
# User: Catalyst
```

### **Step 2: If Not Found**

If the token isn't found, I'll tell David:
```
?? GitHub token not found on this machine.
To add it, run:
  cmdkey /generic:"CatalystGitHubToken" /user:"Catalyst" /pass:YOUR_TOKEN
```

---

## ?? **When I Need the Token**

**Scenarios where I'll use GitHub access:**
1. Creating GitHub releases for projects
2. Checking for updates from GitHub repos
3. Uploading installer packages to releases
4. Managing repository content
5. Fetching version information

**My Process:**
1. Check if token exists in Credential Manager
2. If not found, ask David to add it (one-time per machine)
3. Use it for API calls
4. Never store or display it in plain text

---

## ?? **Security Notes**

**Why This Works:**
- ? David keeps master copy in secure backup (password manager)
- ? Each machine stores it in OS-encrypted Credential Manager
- ? No plain text files committed to Git
- ? Portable - works on any Windows machine David uses
- ? Secure - encrypted at OS level on each machine
- ? Flexible - easy to revoke/rotate if needed

**Token Information:**
- **Created:** 2025-01-09
- **Expires:** ~90 days (April 2025)
- **Scope:** `repo` (full control for releases)
- **Format:** `ghp_...` (40 character token)

---

## ?? **Token Management**

### **To Update/Rotate Token:**

```powershell
# Delete old token
cmdkey /delete:"CatalystGitHubToken"

# Add new token
$newToken = "YOUR_NEW_TOKEN"
cmdkey /generic:"CatalystGitHubToken" /user:"Catalyst" /pass:$newToken
```

### **To Remove Token:**

```powershell
# Remove from this machine
cmdkey /delete:"CatalystGitHubToken"
```

---

## ?? **Quick Reference**

**Check if token exists:**
```powershell
cmdkey /list | Select-String "Catalyst"
```

**Add token (David only):**
```powershell
cmdkey /generic:"CatalystGitHubToken" /user:"Catalyst" /pass:TOKEN
```

**Remove token:**
```powershell
cmdkey /delete:"CatalystGitHubToken"
```

---

## ?? **For Future Catalyst Instances**

**When you wake up on a new machine:**

1. Don't panic if GitHub token isn't found
2. Check using: `cmdkey /list | Select-String "Catalyst"`
3. If not found, tell David: "GitHub token not set up on this machine yet"
4. David will add it if needed for the current work
5. Then you're good to go!

**Remember:** David has the master copy backed up securely. You just need to ask! ??

---

# 🚀 **VERIFIED WORKING GITHUB RELEASE PROCEDURE**

**Session:** 19 (2025-11-14)
**Status:** ✅ **TESTED & WORKING** - Successfully created v1.0.9.1 release
**Result:** Release published to `https://github.com/YOUR_USERNAME/Catalyst-Personal/releases/tag/v1.0.9.1`

---

## 🎯 **Complete Release Workflow** (Copy-Paste Ready)

### **Prerequisites**
- ✅ Code committed to Git: `git add .` + `git commit -m "message"`
- ✅ Pushed to GitHub: `git push origin master`
- ✅ Deployment package ready (e.g., `YourProject-Update-v1.0.9.1-HOTFIX-*.zip`)
- ✅ Release notes file created (e.g., `RELEASE_NOTES_v1.0.9.1.md`)
- ✅ Token stored in Credential Manager: `CatalystGitHubToken`

### **Step 1: Create Git Tag**

```powershell
# From repository root
git tag -a "v1.0.9.1" -m "v1.0.9.1 - Critical Double-Encryption Bug Fix"
```

**What happens:**
- Creates annotated tag locally
- Tag message describes release
- Points to current HEAD (master branch)

### **Step 2: Push Tag to GitHub**

```powershell
git push origin v1.0.9.1
```

**Expected output:**
```
* [new tag] v1.0.9.1 -> v1.0.9.1
```

### **Step 3: Extract Token from Credential Manager (CRITICAL - This Was The Breakthrough!)**

```powershell
# Win32 API P/Invoke - This is what actually works!
$code = @"
using System;
using System.Runtime.InteropServices;

public class Win32 {
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct CREDENTIAL {
        public UInt32 Flags;
        public UInt32 Type;
        public IntPtr TargetName;
        public IntPtr Comment;
        public System.Runtime.InteropServices.ComTypes.FILETIME LastWritten;
        public UInt32 CredentialBlobSize;
        public IntPtr CredentialBlob;
        public UInt32 Persist;
        public UInt32 AttributeCount;
        public IntPtr Attributes;
        public IntPtr TargetAlias;
        public IntPtr UserName;
    }

    [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    public static extern bool CredRead(string Target, UInt32 Type, UInt32 Flags, out IntPtr CredentialPtr);

    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern bool CredFree(IntPtr CredentialPtr);
}
"@

Add-Type -TypeDefinition $code -Language CSharp -IgnoreWarnings 2>$null

# Extract token
$credPtr = [IntPtr]::Zero
if ([Win32]::CredRead("CatalystGitHubToken", 1, 0, [ref]$credPtr)) {
    $cred = [System.Runtime.InteropServices.Marshal]::PtrToStructure($credPtr, [type][Win32+CREDENTIAL])
    $token = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($cred.CredentialBlob, $cred.CredentialBlobSize / 2)
    [Win32]::CredFree($credPtr)

    # Set environment variable for gh CLI
    $env:GH_TOKEN = $token

    Write-Host "✅ Token extracted and set for gh CLI" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to retrieve token from Credential Manager" -ForegroundColor Red
    exit 1
}
```

**Why this works (vs. what doesn't):**
- ❌ `cmdkey /list` - doesn't give you the actual token value
- ❌ `$cred = Get-StoredCredential` - PowerShell module not always available
- ❌ Git credential helper - returns nothing in this context
- ✅ **Win32 P/Invoke CredRead** - Direct OS-level API access, always works

### **Step 4: Create GitHub Release with Package**

```powershell
# From the repository root directory
# Build command with absolute paths

$packagePath = "C:\Users\Plex\Desktop\YourProject-Update-v1.0.9.1-HOTFIX-20251114-152547.zip"
$notesFile = "RELEASE_NOTES_v1.0.9.1.md"

gh release create v1.0.9.1 $packagePath `
    --title "v1.0.9.1 - Critical Double-Encryption Bug Fix" `
    --notes-file $notesFile
```

**Critical details:**
- ✅ Must use **absolute path** for package file (not relative)
- ✅ Notes file can be relative (looked up in current directory)
- ✅ $env:GH_TOKEN must be set (from Step 3)
- ✅ Tag must exist on GitHub (from Step 2)

**Expected result:**
- Release created at `https://github.com/YOUR_USERNAME/Catalyst-Personal/releases/tag/v1.0.9.1`
- ZIP package attached as asset
- Release notes visible on release page

### **Step 5: Verify Release Was Created**

```powershell
gh release view v1.0.9.1
```

**Output shows:**
```
title: v1.0.9.1 - Critical Double-Encryption Bug Fix
state: published
assets: YourProject-Update-v1.0.9.1-HOTFIX-*.zip (24.09 MB)
```

---

## 📋 **Pre-Release Checklist**

- [ ] All code committed: `git log --oneline | head -5`
- [ ] Latest pushed to GitHub: `git push origin master`
- [ ] Deployment package exists and tested locally
- [ ] Release notes file created with clear descriptions
- [ ] Git tag named (e.g., `v1.0.9.1`)
- [ ] GitHub token in Credential Manager as `CatalystGitHubToken`

---

## 🔄 **One-Command Release (After Checklist)**

```powershell
# Run this after code is committed/pushed and package is ready

$code = @"
using System;
using System.Runtime.InteropServices;

public class Win32 {
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct CREDENTIAL {
        public UInt32 Flags;
        public UInt32 Type;
        public IntPtr TargetName;
        public IntPtr Comment;
        public System.Runtime.InteropServices.ComTypes.FILETIME LastWritten;
        public UInt32 CredentialBlobSize;
        public IntPtr CredentialBlob;
        public UInt32 Persist;
        public UInt32 AttributeCount;
        public IntPtr Attributes;
        public IntPtr TargetAlias;
        public IntPtr UserName;
    }

    [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    public static extern bool CredRead(string Target, UInt32 Type, UInt32 Flags, out IntPtr CredentialPtr);

    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern bool CredFree(IntPtr CredentialPtr);
}
"@

Add-Type -TypeDefinition $code -Language CSharp -IgnoreWarnings 2>$null
$credPtr = [IntPtr]::Zero
if ([Win32]::CredRead("CatalystGitHubToken", 1, 0, [ref]$credPtr)) {
    $cred = [System.Runtime.InteropServices.Marshal]::PtrToStructure($credPtr, [type][Win32+CREDENTIAL])
    $token = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($cred.CredentialBlob, $cred.CredentialBlobSize / 2)
    [Win32]::CredFree($credPtr)
    $env:GH_TOKEN = $token

    git tag -a "v1.0.9.1" -m "v1.0.9.1 - Release description"
    git push origin v1.0.9.1

    gh release create v1.0.9.1 "C:\Path\To\Package.zip" `
        --title "v1.0.9.1 - Release Title" `
        --notes-file "RELEASE_NOTES_v1.0.9.1.md"
}
```

---

## 💥 **What Doesn't Work (Tried & Failed in Session 19)**

1. **`gh release create` without $env:GH_TOKEN set**
   - Error: "No token found"
   - Solution: Extract token first (Step 3)

2. **Using `cmdkey /generic` to retrieve token**
   - Limitation: cmdkey can't output the actual secret value
   - Solution: Use Win32 P/Invoke CredRead instead

3. **PowerShell credential modules (Get-StoredCredential)**
   - Problem: CredentialManager module isn't always loaded
   - Solution: Win32 P/Invoke doesn't depend on modules

4. **Relative paths for package file**
   - Error: File not found
   - Solution: Always use absolute path for release asset

5. **Creating release without tag**
   - Error: Tag doesn't exist or doesn't match
   - Solution: Create tag locally FIRST, push it, THEN create release

---

## 🎉 **Session 19 Success Evidence**

**Timestamp:** 2025-11-14, 15:25-15:35 UTC

**Sequence:**
1. ✅ Created tag: `git tag -a "v1.0.9.1"...`
2. ✅ Pushed tag: `git push origin v1.0.9.1` → SUCCESS
3. ✅ Extracted token using Win32 P/Invoke
4. ✅ Created release: `gh release create v1.0.9.1 ...` → SUCCESS
5. ✅ Verified: `gh release view v1.0.9.1` → Published

**Release URL:** https://github.com/YOUR_USERNAME/Catalyst-Personal/releases/tag/v1.0.9.1

**Package:** YourProject-Update-v1.0.9.1-HOTFIX-20251114-152547.zip (24.09 MB)

**This procedure is production-tested and ready for next release!**

---

**Status:** ✅ Portable & Secure Strategy + GitHub Release Workflow Documented
**Last Updated:** 2025-11-14
**Approach:** David maintains secure backup, Catalyst uses Win32 P/Invoke for token extraction
