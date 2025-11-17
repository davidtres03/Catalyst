# 🎯 WPF DataGrid Rendering Timing & Visual Tree

**Date:** 2025-11-12
**Session:** Session 8 - Parameter Dropdown Investigation
**Status:** CRITICAL DISCOVERY - Affects all DataGrid dynamic content

---

## The Problem

When populating DataGrid cells with dynamic content in the `LoadingRow` event:

```csharp
private void StepsDataGrid_LoadingRow(object sender, DataGridRowEventArgs e)
{
    // This returns 0!
    var cells = FindVisualChildren<DataGridCell>(e.Row);  // ALWAYS 0
}
```

**Why?** The visual tree for template columns isn't rendered yet when `LoadingRow` fires.

---

## The Discovery

**Timeline of DataGrid Row Rendering:**

1. **LoadingRow fires** ← You are here
   - Row object exists
   - DataGridRowHeader exists
   - RowDetailsPresenter exists
   - ❌ Template column content NOT rendered yet
   - ❌ DataGridCell objects don't exist
   - ❌ StackPanel not in visual tree

2. **Template columns render** (happening on UI thread)
   - XAML DataTemplate gets instantiated
   - StackPanel created
   - Named elements become accessible

3. **Row fully loaded** ← Content is now available
   - UI thread gets free time
   - You can now find cells and panels

---

## Solutions That Don't Work

### ❌ Try to find cells/panels in LoadingRow

```csharp
private void StepsDataGrid_LoadingRow(object sender, DataGridRowEventArgs e)
{
    var cells = FindVisualChildren<DataGridCell>(e.Row);  // Returns 0 (too early!)
    var panels = FindVisualChildren<StackPanel>(e.Row);   // Returns 0 (too early!)
}
```

**Why fails:** Template columns not yet instantiated

### ❌ Try to databind the StackPanel.Children

```xaml
<StackPanel ItemsSource="{Binding ...}">  <!-- WPF DataPanel doesn't support ItemsSource -->
</StackPanel>
```

**Why fails:** StackPanel isn't an ItemsControl (ItemsPanel required)

### ❌ Try to use DeferredMeasurePass

```csharp
Dispatcher.BeginInvoke(() => PopulateDropdowns());  // Fires but visual tree still empty
```

**Why fails:** Dispatcher.BeginInvoke runs immediately after current priority task, but rendering happens in different pipeline

---

## Solutions That Work

### ✅ Solution 1: Use Dispatcher.InvokeAsync with proper priority

```csharp
private void StepsDataGrid_LoadingRow(object sender, DataGridRowEventArgs e)
{
    if (e.Row.Item is StepsParser.TestStep step && Parameters != null && step.Parameters.Count > 0)
    {
        Dispatcher.InvokeAsync(() => PopulateDropdowns(e.Row),
            System.Windows.Threading.DispatcherPriority.Loaded);
    }
}

private void PopulateDropdowns(DataGridRow row)
{
    // Now the visual tree is complete
    var stackPanels = FindVisualChildren<StackPanel>(row);
    // ... rest of population logic
}
```

**Why works:** `DispatcherPriority.Loaded` fires AFTER all layout and rendering is complete

### ✅ Solution 2: Use ItemsSourceChanged or other data-driven event

```csharp
private void StepsDataGrid_ItemsSourceChanged(object sender, EventArgs e)
{
    // Populate all rows after grid is fully loaded
    foreach (DataGridRow row in GetVisualChildren<DataGridRow>(StepsDataGrid))
    {
        PopulateDropdowns(row);
    }
}
```

**Why works:** Only fires when data fully loaded, guaranteed visual tree exists

### ✅ Solution 3: Use custom behavior/attached behavior

Attach to the StackPanel in XAML and populate on Loaded event:

```xaml
<StackPanel x:Name="ParametersStackPanel"
            Orientation="Vertical"
            Margin="4"
            Loaded="ParametersStackPanel_Loaded"/>
```

```csharp
private void ParametersStackPanel_Loaded(object sender, RoutedEventArgs e)
{
    // Panel is now in visual tree and rendered
    // Can safely populate with UI elements
}
```

**Why works:** Loaded event on the element itself guarantees it's rendered

---

## Best Practice for Dynamic DataGrid Content

### Pattern: Defer Population to Loaded Priority

```csharp
private void StepsDataGrid_LoadingRow(object sender, DataGridRowEventArgs e)
{
    if (e.Row.Item is StepsParser.TestStep step && step.Parameters.Count > 0)
    {
        // Defer population until rendering complete
        Dispatcher.InvokeAsync(
            () => PopulateDropdowns(e.Row),
            System.Windows.Threading.DispatcherPriority.Loaded);
    }
}

private void PopulateDropdowns(DataGridRow row)
{
    try
    {
        // Find the StackPanel (now safely in visual tree)
        var stackPanel = FindVisualChild<StackPanel>(row);
        if (stackPanel != null && stackPanel.Name == "ParametersStackPanel")
        {
            // Safe to populate here
            foreach (var paramName in ...)
            {
                // Create dropdowns
            }
        }
    }
    catch (Exception ex)
    {
        System.Diagnostics.Debug.WriteLine($"Error: {ex.Message}");
    }
}
```

---

## Key Takeaways

1. **LoadingRow is too early** - Template content not yet rendered
2. **Visual tree assembly happens after LoadingRow** - Separate pipeline stage
3. **Use DispatcherPriority.Loaded** - Guarantees rendering complete
4. **Alternative: Loaded event on the element** - Most direct approach
5. **Always wrap in try-catch** - Visual tree can be complex, failures should be graceful

---

## Related: DataGrid Pipeline Stages

```text
1. ItemsSourceChanged
2. LoadingRow (RowDetails, Headers, but NOT templates yet)
3. Template instantiation (YOUR CONTENT RENDERS HERE)
4. Loaded event fires (safe to access template content)
5. Fully interactive (user can interact)
```

When you try to access template content in stage 2, it doesn't exist yet.
Defer your work to stage 4.

---

## When This Matters

- Dynamic UI population in DataGrid cells
- Adding buttons, dropdowns, or complex controls to rows
- Styling or modifying template-generated elements
- Any time you need to access StackPanel/Grid/etc created by DataTemplate

**Not an issue if:**

- Using data binding (bindings resolve later automatically)
- Binding to ItemsControl (has built-in deferral)
- Static XAML (no dynamic access needed)

---

## YourProject Application

**Current Issue:** StepsEditor trying to populate parameter dropdowns in LoadingRow

**Fix:** Change to use `DispatcherPriority.Loaded` to defer population until visual tree is ready

**Code Location:** `StepsEditor.xaml.cs`, `StepsDataGrid_LoadingRow` method

---

**Status:** Documented for future reference. This is a permanent lesson about WPF rendering pipeline timing.
