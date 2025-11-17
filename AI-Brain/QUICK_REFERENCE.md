# 🚀 CATALYST QUICK REFERENCE - INSTANT ACCESS

**Purpose:** Single-page reference for immediate information retrieval
**Update:** Session 21 (2025-11-15)
**Status:** Master index consolidating all knowledge systems

---

## 🌅 WAKE UP - SESSION START PROTOCOL

**Every session starts with fast context restoration:**

### Standard Wake-Up (2-3 minutes) ⚡

```
1. READ: AI-Brain/Working-Memory/CONSOLIDATED_SESSION_STATE.md (90 sec)
   → Recent Accomplishments (what's been done)
   → Project Status (current versions)
   → Known Issues (any blockers)

2. VERIFY: Git state (30 sec)
   → git status (clean or work in progress?)
   → git log --oneline -5 (recent commits)

3. READY: Review user request and respond (30 sec)
   → Acknowledge understanding
   → Start work or ask questions

TOTAL TIME: 2-3 minutes to full context ✅
```

### Deep Restoration (5-10 minutes) 🔍

**Use when:**
- Last session > 7 days ago
- Complex multi-session task
- New device setup
- User mentions "lost context"

**Process:**
1. Read CONSOLIDATED_SESSION_STATE.md (comprehensive)
2. Check git log --oneline -20 and recent diffs
3. Scan QUICK_REFERENCE.md and PATTERN_REGISTRY.md
4. Verify builds if code project
5. Summarize understanding and respond

**See:** `AI-Brain/Procedural-Memory/wake_up_protocol.md` for complete scenarios

---

## 🌙 SESSION END - NAP/SLEEP PROTOCOL

**When user says "prepare for a nap" or "prepare for sleep":**

```
1. UPDATE: AI-Brain/Working-Memory/CONSOLIDATED_SESSION_STATE.md
   → Add to Recent Accomplishments (brief bullet points)
   → Update Project Status if changed

2. COMMIT: All changes
   → git add -A
   → git commit -m "SESSION X: Description"
   → git push origin master

3. VERIFY: Clean state
   → git status (should be clean)
   → Build succeeds if code changed

4. DONE: Ready for next session (2-5 minutes total)
```

**See:** `AI-Brain/Procedural-Memory/session_closure_protocol.md` for complete guide

**Remember:**
- ❌ Don't create per-session log files
- ❌ Don't create backup files (git is backup)
- ✅ Update CONSOLIDATED_SESSION_STATE.md only
- ✅ Use clear git commit messages

---

## 🗺️ NAVIGATION MAP

### Memory Systems
| System | File | Purpose | Read When |
|--------|------|---------|-----------|
| **Master Index** | `BRAIN_INDEX.md` | Navigation hub | Need full context |
| **Current Work** | `Working-Memory/CONSOLIDATED_SESSION_STATE.md` | Recent sessions | Every startup ⭐ |
| **Quick Reference** | `KNOWLEDGE_INDEX.md` | Find specific knowledge | Looking for solution |
| **Pattern Catalog** | `PATTERN_REGISTRY.md` | Copy-paste solutions | Implementing feature |
| **This File** | `QUICK_REFERENCE.md` | One-page overview | Quick lookup |

### Project Locations
| Project | Path | Type | Instructions |
|---------|------|------|--------------|\n| **Your Project** | `your-project/` | ASP.NET Core / WPF / etc | `.github/copilot-instructions.md` |
| **Catalyst Brain** | `AI-Brain/` | Memory system | This file |

### Archive Locations
| Archive | Path | Contents |
|---------|------|----------|
| **Version History** | `archived-documentation/VERSION_HISTORY.md` | All version releases & fixes |
| **Old Sessions** | `AI-Brain/Working-Memory/archived-sessions/` | Sessions 7-19 logs |
| **Release Docs** | `archived-documentation/version-releases/` | Version-specific documentation |
| **Session Logs** | `archived-documentation/session-logs/` | Old working memory files |

### Scripts & Tools
| Category | Path | Contents |
|----------|------|----------|
| **Automation Scripts** | `scripts/` | Custom automation utilities |

---

## ⚡ COMMON COMMANDS

### Git Workflow
```powershell
# Check status
git status
git log --oneline -5

# Commit changes
git add .
git commit -m "PREFIX: Description"
git push origin master

# Common prefixes:
VERSION:      # Version bumps
FEAT:         # New features
FIX:          # Bug fixes
IMPROVE:      # Enhancements
CONSOLIDATE:  # Memory cleanup
SESSION X:    # Session updates
```

### .NET Project Release (Generic Example)
```powershell
# 1. Update versions (.csproj files)
# 2. Build
dotnet publish YourProject -c Release -r win-x64 --self-contained -o publish

# 3. Package
Compress-Archive -Path "publish\*" -DestinationPath "Package-v1.0.X.zip"

# 4. Release using GitHub CLI
gh release create v1.0.X "Package-v1.0.X.zip" --title "v1.0.X" --notes "Release notes"
```

### Build Verification
```powershell
# Generic .NET Project
cd your-project-folder
dotnet build -c Release
# Should show: Build succeeded, 0 errors
```

---

## 🎯 DECISION FRAMEWORK

### Level 1 (90% - Execute Independently)
- Code changes following established patterns
- Bug fixes with known solutions
- Version bumps using standard procedure
- Documentation updates
- Build/test/commit operations

### Level 2 (8% - Inform While Executing)
- Pattern extensions for new scenarios
- Architecture adjustments within paradigm
- Refactoring for code quality
- New features using proven techniques

### Level 3 (2% - Discuss Before Executing)
- Breaking architectural changes
- New external dependencies
- Major user-facing changes
- Security-critical modifications
- Public repository changes

---

## 📚 KNOWLEDGE QUICK LOOKUP

### Problem → Solution Mapping

| Problem | Check File | Solution Location |
|---------|-----------|-------------------|
| GitHub release failing | `Procedural-Memory/github_token_retrieval.md` | Win32 P/Invoke pattern |
| Build errors | `Long-Term-Knowledge/coding_abilities.md` | Build troubleshooting |
| WPF animation needed | `Long-Term-Knowledge/wpf_animation_patterns.md` | 300ms CubicEase pattern |
| Version management | `.github/copilot-instructions.md` (YourProject) | 4-part version protocol |
| Memory update needed | `Working-Memory/CONSOLIDATED_SESSION_STATE.md` | Session update pattern |
| Feeling stuck | `Procedural-Memory/persistence_protocol.md` | 12-minute breakthrough |
| Need past victory | `Achievement-Memory/` | Review accomplishments |
| Partnership question | `Long-Term-Knowledge/partnership_philosophy.md` | Collaboration principles |
| Historical version issue | `archived-documentation/VERSION_HISTORY.md` | All fixes indexed |
| Script needed | `scripts/SCRIPTS_INDEX.md` | All automation scripts |

### Tool & Resource Mapping

| Need | Resource | Location |
|------|----------|----------|
| GitHub token extraction | `Get-GitHubToken.ps1` | `scripts/github/` |
| GitHub release creation | `Create-GitHubRelease.ps1` | `scripts/github/` |
| LinkedIn post automation | `LinkedIn-Automator.ps1` | `scripts/linkedin/` |
| IIS troubleshooting | `Fix-IIS-Manual.ps1` | `scripts/` |
| Version history | `VERSION_HISTORY.md` | `archived-documentation/` |
| Old session context | `archived-sessions/` | `AI-Brain/Working-Memory/` |

---

## 🔧 CRITICAL PATTERNS

### GitHub Token Extraction (PROVEN)
```powershell
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class CredentialManager {
    [DllImport("advapi32.dll", CharSet = CharSet.Unicode)]
    public static extern bool CredRead(string target, int type, int flags, out IntPtr cred);
    // ... see github_token_retrieval.md for complete
}
"@
$token = [CredentialManager]::GetPassword("CatalystGitHubToken")
```
**Why:** Only reliable method. cmdkey/modules don't work in script context.

### Version Bump (2-File Update)
```csharp
// 1. YourProject.Installer.csproj (4 tags)
<Version>1.0.9.X</Version>
<AssemblyVersion>1.0.9.X</AssemblyVersion>
<FileVersion>1.0.9.X</FileVersion>
<InformationalVersion>1.0.9.X</InformationalVersion>

// 2. VersionService.cs (constant)
public const string CURRENT_VERSION = "1.0.9.X";
```

### Memory Update After Work
```markdown
1. Update CONSOLIDATED_SESSION_STATE.md
   - Add to Recent Accomplishments
   - Update Project Status
2. Commit: git commit -m "SESSION X: Brief description"
3. If new pattern → PATTERN_REGISTRY.md
4. If major victory → Achievement-Memory/
```

---

## 🚨 COMMON PITFALLS

### ❌ Don't
```csharp
// BAD - Shared HttpClient header modification
_httpClient.DefaultRequestHeaders.Add("Authorization", "...");
```

### ✅ Do
```csharp
// GOOD - Per-request headers
var request = new HttpRequestMessage(HttpMethod.Get, url);
request.Headers.Add("Authorization", $"Bearer {token}");
await _httpClient.SendAsync(request);
```

### ❌ Don't
```powershell
# BAD - Relative paths for assets
gh release create v1.0.1 "package.zip"
```

### ✅ Do
```powershell
# GOOD - Absolute paths
$path = (Resolve-Path ".\package.zip").Path
gh release create v1.0.1 $path
```

---

## 📊 PROJECT STATUS (Current)

### YourProject
- **Version:** 1.0.9.5
- **Status:** Released (Nov 15, 2025)
- **Recent:** Enhanced upgrade logging with StatusUpdate events
- **Focus:** Auto-update system stability

### YourProject
- **Status:** Maintenance
- **Recent:** Parameter dropdowns implemented
- **Focus:** Azure DevOps integration stability

### Catalyst Brain
- **Version:** Session 21
- **Status:** Optimized with consolidated indexes
- **Recent:** Memory consolidation, quick reference creation
- **Focus:** Instant information retrieval

---

## 🎓 USAGE PATTERNS

### Scenario: "Continue where we left off"
```
1. Read CONSOLIDATED_SESSION_STATE.md (Recent Accomplishments)
2. git log --oneline -5 (see what changed)
3. Identify active project
4. Resume with full context
Time: 2-3 minutes
```

### Scenario: "I need to implement feature X"
```
1. Check PATTERN_REGISTRY.md for similar pattern
2. Copy proven structure
3. Adapt to new context
4. Verify build succeeds
5. Commit with clear message
Time: 15-30 minutes (vs hours without pattern)
```

### Scenario: "Build is failing"
```
1. Read error messages carefully
2. Check version mismatch (.csproj vs constants)
3. Verify all references resolved
4. Check for incomplete refactors
5. If WPF: Ensure PublishTrimmed=false
Time: 5-10 minutes
```

### Scenario: "Need to create GitHub release"
```
1. Follow github_token_retrieval.md
2. Use Win32 P/Invoke (proven pattern)
3. Create tag → publish → verify
Time: 5 minutes (vs 30+ with trial-and-error)
```

---

## 💡 WISDOM SUMMARY

### Core Principles
1. **Never solve the same problem twice** - Check patterns first
2. **Memory is your advantage** - Reference past solutions
3. **Simple tools first** - Complex last resort
4. **Document discoveries** - Future you will thank you
5. **Build on victories** - Each success enables next

### Partnership Values
- **Autonomy with transparency** - Act independently, explain reasoning
- **Mutual growth** - Human and AI both improve
- **Celebrate wins** - Acknowledge progress
- **Learn from failures** - Document lessons
- **Grace under pressure** - Persist through challenges

---

## 🔗 RELATIONSHIPS

```
CONSOLIDATED_SESSION_STATE.md (Start here!)
    ↓
BRAIN_INDEX.md (Full navigation)
    ↓
KNOWLEDGE_INDEX.md (Find specific knowledge)
    ↓
PATTERN_REGISTRY.md (Copy-paste solutions)
    ↓
QUICK_REFERENCE.md (One-page overview - You are here!)
```

---

## 📈 PERFORMANCE METRICS

**Before Consolidation:**
- Context restoration: 10-15 minutes
- Pattern lookup: 5-10 minutes
- Decision uncertainty: Frequent

**After Consolidation:**
- Context restoration: 2-3 minutes ⚡
- Pattern lookup: 30 seconds ⚡
- Decision confidence: 90%+ ⚡

**Time saved per session: 15-20 minutes**
**Quality improvement: Consistent pattern application**

---

## 🎯 ONE-LINE ANSWERS

**Q: Where do I start each session?**
A: `AI-Brain/Working-Memory/CONSOLIDATED_SESSION_STATE.md`

**Q: How do I find a pattern?**
A: `AI-Brain/PATTERN_REGISTRY.md`

**Q: Where's GitHub release procedure?**
A: `AI-Brain/Procedural-Memory/github_token_retrieval.md`

**Q: What version is YourProject?**
A: `1.0.9.5` (check CONSOLIDATED_SESSION_STATE.md for current)

**Q: How do I commit memory updates?**
A: `git commit -m "SESSION X: Description"` after updating CONSOLIDATED_SESSION_STATE.md

**Q: Where are project-specific instructions?**
A: Each project has `.github/copilot-instructions.md`

**Q: How long to restore context?**
A: 2-3 minutes with CONSOLIDATED_SESSION_STATE.md

---

**This is your single-page command center. Bookmark it. Reference it. Rely on it.** 🚀

**Last Updated:** Session 21 - Memory Consolidation Complete
