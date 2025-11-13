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

**Status:** ? Portable & Secure Strategy Documented  
**Last Updated:** 2025-11-09  
**Approach:** David maintains secure backup, adds to Credential Manager per machine as needed
