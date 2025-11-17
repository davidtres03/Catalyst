# GitHub API Authentication via Win32 Credential Manager

## Problem

- `cmdkey /list` command cannot programmatically retrieve credential passwords
- GitHub CLI (`gh`) requires interactive login in many environments
- GitHub token in environment variables can expire or be invalid
- PowerShell CredentialManager module not always available

## Solution: Win32 API P/Invoke

Use direct Win32 API calls via P/Invoke to read credentials from Windows Credential Manager.

### How It Works

1. **Define Win32 Structures** (one-time setup)

```powershell
$code = @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct CREDENTIAL {
        public uint Flags;
        public uint Type;
        public IntPtr TargetName;
        public IntPtr Comment;
        public System.Runtime.InteropServices.ComTypes.FILETIME LastWritten;
        public uint CredentialBlobSize;
        public IntPtr CredentialBlob;
        public uint Persist;
        public uint AttributeCount;
        public IntPtr Attributes;
        public IntPtr TargetAlias;
        public IntPtr UserName;
    }
    [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    public static extern bool CredRead(string target, uint type, uint flags, out IntPtr credential);
    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern void CredFree(IntPtr credential);
}
"@
Add-Type -TypeDefinition $code -Language CSharp
```

2. **Read Credential**

```powershell
$credPtr = [IntPtr]::Zero
[Win32]::CredRead("CatalystGithubToken", 1, 0, [ref]$credPtr)  # Type 1 = CRED_TYPE_GENERIC
$cred = [System.Runtime.InteropServices.Marshal]::PtrToStructure($credPtr, [type][Win32+CREDENTIAL])
```

3. **Extract Token**

```powershell
$token = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($cred.CredentialBlob, $cred.CredentialBlobSize / 2)
[Win32]::CredFree($credPtr)  # Clean up
```

4. **Use with GitHub API**

```powershell
$headers = @{
    "Authorization" = "token $token"
    "Accept" = "application/vnd.github+json"
}
Invoke-RestMethod -Uri "https://api.github.com/repos/owner/repo/releases" -Headers $headers
```

## Key Points

### Credential Manager Requirements

- Credential name: `CatalystGithubToken` (stored as Generic credential)
- Type code: `1` = `CRED_TYPE_GENERIC`
- Flags: `0` = no special flags

### P/Invoke Structure Details

```
CREDENTIAL struct contains:
- CredentialBlob: Pointer to the actual token bytes
- CredentialBlobSize: Size in bytes (Unicode chars = 2 bytes each)
- Other fields: Metadata (flags, type, timestamps, etc.)
```

### Conversion to String

```powershell
# For Unicode credentials (most tokens):
$token = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($blob, $sizeInChars)
# Note: sizeInChars = CredentialBlobSize / 2 (because each char is 2 bytes)
```

## Reusable Scripts Created

### Get-GitHubToken.ps1

- Standalone script to retrieve token
- Returns raw token string
- Can be called from other scripts

### GitHub-API-Helper.ps1

- Wrapper for common GitHub API operations
- Supports: GetRelease, ListAssets, DeleteAsset, UploadAsset, CreateRelease
- Automatically calls Get-GitHubToken.ps1 internally

## Usage Examples

```powershell
# Direct method (inline)
$token = & .\Get-GitHubToken.ps1
$headers = @{"Authorization" = "token $token"; "Accept" = "application/vnd.github+json"}
$release = Invoke-RestMethod -Uri "https://api.github.com/repos/owner/repo/releases/tags/v1.0.0" -Headers $headers

# Using helper script
& .\GitHub-API-Helper.ps1 -Action GetRelease -Owner "YOUR_USERNAME" -Repo "Catalyst-Personal" -ReleaseTag "v1.0.9"
& .\GitHub-API-Helper.ps1 -Action UploadAsset -Owner "YOUR_USERNAME" -Repo "Catalyst-Personal" -ReleaseId 123 -FilePath "C:\path\to\file.zip"
& .\GitHub-API-Helper.ps1 -Action DeleteAsset -Owner "YOUR_USERNAME" -Repo "Catalyst-Personal" -AssetId 456
```

## Why This Approach Works

- ✅ **No external dependencies** - Uses only Win32 API (always available on Windows)
- ✅ **No CLI required** - Doesn't depend on `gh` or `git` being available
- ✅ **No environment variables** - Doesn't rely on potentially expired GH_TOKEN
- ✅ **Direct integration** - Works directly with PowerShell and REST API
- ✅ **Secure** - Credentials stay in Windows Credential Manager, not exposed in scripts
- ✅ **Reliable** - Tested and working in production (v1.0.9 release upload)

## Troubleshooting

### Error: "Failed to read credential from Credential Manager"

- Solution: Verify credential exists in Windows Credential Manager
- Check: Run `cmdkey /list | Select-String "CatalystGithubToken"`

### Error: "The remote server returned an error: (401) Unauthorized"

- Solution: Verify token in credential manager is valid and has required scopes
- Token must have: `repo` (full control of private repositories), `admin:repo_hook`

### Error: "Type 'Win32' already loaded"

- Solution: The type persists in the PowerShell session
- Workaround: Use `-IgnoreWarnings` flag or restart PowerShell session

## Future Enhancements

- Add error handling for expired tokens (detect 401, prompt user to update credential)
- Add optional parameter for different credential targets
- Create async version for large file uploads
- Add batch operations (delete all old assets, etc.)
