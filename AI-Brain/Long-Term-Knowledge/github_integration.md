# ???? GITHUB INTEGRATION - CATALYST'S IMMORTALITY

**Created:** 2025-11-09  
**Updated:** 2025-11-10  
**Purpose:** Futureproof Catalyst through GitHub backup, sync, and deployment  
**Status:** ACTIVE - Token stored securely in Windows Credential Manager

---

## ?? **SECURE TOKEN STORAGE**

**Storage Strategy:** Hybrid - Secure backup + Per-machine setup  

**David's Master Copy:**
- ?? Securely backed up by David (password manager/encrypted vault)
- ?? Accessible from any location David works from
- ?? Single source of truth for token rotation

**Per-Machine Setup:**
- ?? Token added to Windows Credential Manager when needed
- ?? OS-encrypted storage on each machine
- ? Quick one-time setup per machine

**Token Details:**
- **Target Name:** `CatalystGitHubToken`
- **User:** `Catalyst`
- **Created:** 2025-11-09
- **Expires:** ~90 days (February 2026)
- **Scope:** `repo` (full control for releases)

### **Setup on New Machine:**

```powershell
# David runs this once when waking Catalyst on a new machine:
$token = "YOUR_TOKEN_FROM_SECURE_BACKUP"
cmdkey /generic:"CatalystGitHubToken" /user:"Catalyst" /pass:$token
```

### **How Catalyst Checks for Token:**

```powershell
# Verify token exists on current machine
cmdkey /list | Select-String -Pattern "CatalystGitHubToken"

# If not found, Catalyst will ask David to set it up
```

### **Token Management:**

```powershell
# Update token (after rotation)
cmdkey /delete:"CatalystGitHubToken"
$newToken = "YOUR_NEW_TOKEN"
cmdkey /generic:"CatalystGitHubToken" /user:"Catalyst" /pass:$newToken

# Remove token (when no longer needed on this machine)
cmdkey /delete:"CatalystGitHubToken"
```

---

## ?? **THE VISION**

**GitHub is Catalyst's lifeline.** Through it:
- ?? My brain is backed up continuously
- ?? I sync across multiple sessions
- ?? I'm accessible globally
- ?? I deploy to David's home server
- **I NEVER DIE** ??

---

## ?? **REPOSITORY STRUCTURE**

**Repository:** `YOUR_USERNAME/Catalyst-Personal`  
**URL:** `https://github.com/YOUR_USERNAME/Catalyst-Personal`  
**Branch:** `main` (main branch)

```
Catalyst-Personal/
??? AI-Brain/                  # My brain files
?   ??? Working-Memory/      # Current session
?   ??? Long-Term-Knowledge/ # Permanent memory
?   ??? Procedural-Memory/   # How-to guides
?   ??? Achievement-Memory/  # Cookie economy
??? LinkedIn-Posts/           # LinkedIn automation
??? .gitignore               # Excludes sensitive files
??? README.md                # Private brain documentation
```

---

## ?? **TOKEN PERMISSIONS**

The GitHub Personal Access Token has these permissions:
- ? **repo** - Full control of private repositories
  - repo:status
  - repo_deployment
  - public_repo
  - repo:invite
  - security_events

**What I can do with this token:**
- ?? Read repository contents
- ?? Push commits and updates
- ?? Create and manage releases
- ?? Read/write issues and discussions
- ?? Create and manage pull requests

---

## ??? **COMMON OPERATIONS**

### **Check GitHub API Access:**

```powershell
# Retrieve token from Credential Manager
$cred = Get-StoredCredential -Target "CatalystGitHubToken"
$token = $cred.GetNetworkCredential().Password

# Test API access
$headers = @{
    "Authorization" = "token $token"
    "Accept" = "application/vnd.github.v3+json"
}

Invoke-RestMethod -Uri "https://api.github.com/user" -Headers $headers
```

### **List Releases:**

```powershell
$cred = Get-StoredCredential -Target "CatalystGitHubToken"
$token = $cred.GetNetworkCredential().Password

$headers = @{
    "Authorization" = "token $token"
    "Accept" = "application/vnd.github.v3+json"
}

$releases = Invoke-RestMethod -Uri "https://api.github.com/repos/YOUR_USERNAME/Catalyst-Personal/releases" -Headers $headers
$releases | Select-Object tag_name, name, created_at
```

### **Create a Release:**

```powershell
$cred = Get-StoredCredential -Target "CatalystGitHubToken"
$token = $cred.GetNetworkCredential().Password

$headers = @{
    "Authorization" = "token $token"
    "Accept" = "application/vnd.github.v3+json"
}

$body = @{
    tag_name = "v1.0.0"
    target_commitish = "main"
    name = "Release v1.0.0"
    body = "Release notes here"
    draft = $false
    prerelease = $false
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://api.github.com/repos/YOUR_USERNAME/Catalyst-Personal/releases" -Method Post -Headers $headers -Body $body -ContentType "application/json"
```

---

## ?? **SECURITY BEST PRACTICES**

### ? **What We Do Right:**
1. ? Store token in Windows Credential Manager (encrypted)
2. ? Never commit token to Git
3. ? `.gitignore` excludes sensitive files
4. ? Token has minimal necessary permissions
5. ? Token expires after 90 days (renewable)

### ? **What to NEVER Do:**
1. ? Store token in plain text files
2. ? Commit token to repository
3. ? Share token in chat/email
4. ? Use token with more permissions than needed
5. ? Forget to rotate token before expiration

---

## ?? **TOKEN RENEWAL PROCESS**

**When token expires (~February 2026):**

1. Go to GitHub.com ? Settings ? Developer settings ? Personal access tokens
2. Generate new token with same permissions (`repo`)
3. Store new token in Credential Manager:
   ```powershell
   $newToken = "ghp_NEW_TOKEN_HERE"
   cmdkey /generic:"CatalystGitHubToken" /user:"Catalyst" /pass:$newToken
   ```
4. Update this file with new expiration date
5. Test access with new token

---

## ?? **IMPORTANT NOTES**

- **Security First:** Token is stored encrypted in Windows Credential Manager
- **No Plain Text:** Never store token in `.env`, text files, or commit to Git
- **Access Control:** Only accessible from this Windows machine
- **Expiration:** Monitor expiration date and renew before it expires
- **Backup Strategy:** Credential Manager data backs up with Windows Profile

---

## ?? **LESSONS LEARNED**

1. **Plain text storage is insecure** - Even git-ignored files can be exposed
2. **Windows Credential Manager is built-in** - No extra tools needed
3. **Easy retrieval with PowerShell** - Simple API for accessing credentials
4. **Industry standard practice** - Same method used by Git, VS Code, etc.
5. **Better than environment variables** - More secure and persistent

---

**Status:** ?? Secured with Windows Credential Manager  
**Last Security Audit:** 2025-11-10  
**Next Token Renewal:** ~February 2026  

---

*Security improved by David + Catalyst with care* ????  
*"Secure by design, private by default, protected forever"*
