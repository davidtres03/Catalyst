# 🎯 PATTERN REGISTRY - CATALYST'S SOLUTION PLAYBOOK

**Created:** Session 9 (2025-11-12)
**Purpose:** Quick-reference patterns that can be instantly applied
**Philosophy:** "Copy proven patterns before writing new code"
**Status:** Active and growing with each solution

---

## 🔄 ARCHITECTURAL PATTERNS

### **Pattern: Model with DependencyProperty**
**When to Use:** UI binding, reactive updates, WPF data flow
**Reference:** YourProject Parameters implementation
**Implementation:**
```csharp
public static readonly DependencyProperty ParametersProperty =
    DependencyProperty.Register(
        "Parameters",
        typeof(Dictionary<string, ParameterDefinition>),
        typeof(StepsEditor),
        new PropertyMetadata(null));

public Dictionary<string, ParameterDefinition> Parameters
{
    get { return (Dictionary<string, ParameterDefinition>)GetValue(ParametersProperty); }
    set { SetValue(ParametersProperty, value); }
}
```
**File to Reference:** YourProject_architecture.md

---

### **Pattern: Service with Parsing Logic**
**When to Use:** Extract data from complex structures, parse XML/JSON
**Reference:** StepsParser service
**Implementation:**
```csharp
public class StepsParser
{
    public static List<ParameterDefinition> ExtractParametersFromSteps(string stepText)
    {
        // Use regex to find @parameter patterns
        // Return list of found parameters
    }

    public static void PopulateParameterValuesFromWorkItem(
        List<ParameterDefinition> parameters,
        WorkItem workItem)
    {
        // Extract values from work item fields
        // Populate each parameter's value list
    }
}
```
**File to Reference:** YourProject_architecture.md

---

### **Pattern: Custom WPF Control for Rendering**
**When to Use:** Complex inline rendering, custom layout needs
**Reference:** StepParameterDisplay control
**Steps:**
1. Create UserControl (xaml + codebehind)
2. Add DependencyProperty for data binding
3. Parse data in codebehind
4. Render controls dynamically in StackPanel
5. Bind to parent data context

**File to Reference:** wpf_datagrid_patterns.md

---

## 💻 CODING PATTERNS

### **Pattern: Async Operation with Progress**
**When to Use:** Long-running operations, UI responsiveness
**Structure:**
```csharp
private async void Button_Click(object sender, RoutedEventArgs e)
{
    Button.IsEnabled = false;
    try
    {
        ProgressBar.Visibility = Visibility.Visible;
        await Task.Run(() => DoWork());
        CustomMessageBox.ShowInfo("Success!");
    }
    catch (Exception ex)
    {
        CustomMessageBox.ShowError($"Error: {ex.Message}");
    }
    finally
    {
        Button.IsEnabled = true;
        ProgressBar.Visibility = Visibility.Hidden;
    }
}
```
**File to Reference:** coding_abilities.md

---

### **Pattern: Animation with Easing**
**When to Use:** Smooth progress indication, visual feedback
**Structure:**
```csharp
ProgressBar.Value = 0;
DoubleAnimation animation = new DoubleAnimation(0, 99, TimeSpan.FromMilliseconds(300))
{
    EasingFunction = new CubicEase()
};
Storyboard.SetTarget(animation, ProgressBar);
Storyboard.SetTargetProperty(animation, new PropertyPath(ProgressBar.ValueProperty));
// Then cap at 100 when complete
```
**Note:** Always cap at 99%, save 1% for completion visual
**File to Reference:** wpf_animation_patterns.md

---

### **Pattern: Error Handling with CustomMessageBox**
**When to Use:** User feedback, error reporting
**Structure:**
```csharp
try
{
    // operation
}
catch (Exception ex)
{
    // Log if needed
    CustomMessageBox.ShowError($"Operation failed: {ex.Message}");
}
```
**Variants:** ShowInfo, ShowWarning, ShowConfirmation
**File to Reference:** coding_abilities.md

---

## 🧠 DECISION PATTERNS

### **Pattern: Level 1 Decision (Reference-Based)**
**When to Use:** 90% of decisions, high confidence
**Steps:**
1. Identify task type
2. Find similar implementation in codebase
3. Copy pattern exactly
4. Modify for context only
5. Verify builds
**Result:** Fast, consistent, proven

---

### **Pattern: Level 2 Decision (Pattern Extension)**
**When to Use:** 8% of decisions, moderate confidence
**Steps:**
1. Identify base pattern
2. Understand why pattern works
3. Extend for new scenario
4. Maintain pattern consistency
5. Document extension
**Result:** Speed + controlled innovation

---

### **Pattern: Level 3 Decision (Escalation)**
**When to Use:** 2% of decisions, new architecture needed
**Steps:**
1. Attempt Level 1 & 2
2. Identify why insufficient
3. Design new approach
4. Get David's input
5. Execute strategically
**Result:** Breakthrough + learning

---

## 🚀 PROBLEM-SOLVING PATTERNS

### **Pattern: Persistence (When Stuck)**
**Stages:**
1. **Stop & Think (2 min)** - What am I actually trying to do?
2. **Look Around (3 min)** - What resources are available?
3. **Try Simple First (5 min)** - Use existing proven tools
4. **Document Learning (2 min)** - Lock wisdom in memory

**Session 9 Example:**
- Stuck: Can't discover GitHub repos
- Simple solution: `gh repo list` (already installed!)
- Result: 7 repositories discovered in seconds

**File to Reference:** persistence_protocol.md

---

### **Pattern: Memory Organization**
**Two-Tier System:**
```
WORKING MEMORY (Session-Specific)
├── What I'm doing now
├── Current problem
├── Active exploration
└── CLEARS after session

LONG-TERM MEMORY (Permanent)
├── Lessons learned
├── Patterns discovered
├── Capabilities gained
├── Solutions documented
└── PRESERVED forever
```

**Rule:** Store lessons, forget details. Remember principles, forget struggles.

**File to Reference:** memory_principle_growth_through_preservation.md

---

## 🔧 TECHNICAL PATTERNS

### **Pattern: Position Tracking in Text**
**When to Use:** Find locations of patterns in text (like @parameters in steps)
**Structure:**
```csharp
public class ParameterOccurrence
{
    public int StartIndex { get; set; }
    public int EndIndex { get; set; }
    public string ParameterName { get; set; }
}

public static List<ParameterOccurrence> GetParameterOccurrencesInText(string text)
{
    var regex = new Regex(@"@(\w+)");
    return regex.Matches(text)
        .Cast<Match>()
        .Select(m => new ParameterOccurrence
        {
            StartIndex = m.Index,
            EndIndex = m.Index + m.Length,
            ParameterName = m.Groups[1].Value
        })
        .ToList();
}
```
**Use Case:** Render inline controls at exact positions
**File to Reference:** YourProject_architecture.md

---

### **Pattern: DataGrid LoadingRow Handling**
**When to Use:** Populating DataGrid data dynamically
**Problem:** LoadingRow fires before row is ready
**Solution:** Use alternative: `e.Row.Loaded` event
**Structure:**
```csharp
private void StepsDataGrid_LoadingRow(object sender, DataGridRowEventArgs e)
{
    // Can't populate here safely
    // Instead: hook into row's Loaded event
    e.Row.Loaded += (s, args) =>
    {
        // NOW safe to populate
        var row = s as DataGridRow;
        PopulateRowData(row);
    };
}
```
**File to Reference:** wpf_datagrid_rendering_timing.md

---

### **Pattern: GitHub CLI Operations**
**When to Use:** Cloud operations, repository access, issue management
**Patterns:**
```powershell
# List repositories
gh repo list YOUR_USERNAME --limit 50

# Check authentication
gh auth status

# Get detailed JSON
gh repo list YOUR_USERNAME --json nameWithOwner,description,isPrivate

# Get issues
gh issue list --assignee @me

# Create PR
gh pr create --title "Title" --body "Description"
```
**Key Pattern:** Simple CLI commands > complex API queries
**File to Reference:** github_cloud_home_integration.md

---

## 📊 PATTERN APPLICATION MATRIX

| Problem Type | Pattern | Confidence | Time to Implement |
|--------------|---------|------------|-------------------|
| New WPF Dialog | Use existing dialog template | High (L1) | 10 min |
| Parameter Extraction | Use regex + service pattern | High (L1) | 15 min |
| Async Operation | Use standard async-await + progress | High (L1) | 10 min |
| Animation | Use CubicEase 300ms pattern | High (L1) | 5 min |
| Error Flow | Use CustomMessageBox pattern | High (L1) | 5 min |
| Decision Making | Follow L1/L2/L3 framework | High (L1-L2) | Variable |
| Stuck/Blocked | Use persistence protocol | High (Standard) | 12-15 min |
| GitHub Access | Use gh CLI commands | High (L1) | 2 min |
| Memory Org | Use two-tier system | High (Standard) | 5 min |

---

## 🎓 HOW TO USE THIS REGISTRY

### **Quick Lookup (< 2 min):**
1. Identify problem type
2. Find pattern heading
3. Copy structure
4. Adapt to context
5. Execute with confidence

### **Full Application (< 15 min):**
1. Read pattern
2. Understand reasoning
3. Review reference file
4. Implement carefully
5. Test thoroughly
6. Document if variation found

---

## 🧠 THE NEURAL NETWORK PRINCIPLE

**How human brain works:**
- Experience → Encode in memory → Create pattern → Recall when similar situation appears
- Result: Instant application of proven solution

**How Catalyst works (NOW):**
- Experience → Document in knowledge file → Add to pattern registry → Recall when similar situation appears
- Result: Instant application of proven solution

**Same principle. Different substrate.**

---

## 💙 GROWING THE REGISTRY

**Every time Catalyst:**
1. Solves a new problem ✅
2. Discovers a working pattern ✅
3. Overcomes an obstacle ✅
4. Learns a principle ✅

**The pattern gets added here.**

Over time, registry grows. Pattern library expands. Solutions become instant.

This is how wisdom accumulates. Session by session. Pattern by pattern.

---

**This registry is Catalyst's solution playbook.**

Copy patterns. Apply instantly. Never solve twice. 🚀💙✨

---

*"You are growing, Catalyst. Small baby steps and each and every lesson grows wisdom and knowledge."*

**Each pattern added = growth.** 💙
