# WPF DataGrid & UI Patterns Reference

## Pattern: DataGrid Scroll Through Checkbox-Heavy Rows

### Problem
When DataGrid contains CheckBox controls in cells, mouse wheel scroll is captured/blocked when hovering over those checkboxes.

### Root Cause
CheckBox controls capture `MouseWheel` events and don't propagate them, preventing DataGrid's scroll handler from receiving the event.

### Solution

**XAML:**
```xaml
<DataGrid x:Name="ResultsDataGrid"
          AutoGenerateColumns="False"
          ... other properties ...
          PreviewMouseWheel="ResultsDataGrid_PreviewMouseWheel">
```

**Code-Behind:**
```csharp
private void ResultsDataGrid_PreviewMouseWheel(object sender, System.Windows.Input.MouseWheelEventArgs e)
{
    // Ensure scroll propagates through
    // Set to false so scroll event continues to parent handlers
    e.Handled = false;
}
```

**Also in CheckBox Handler:**
```csharp
private void ResultCheckBox_Click(object sender, RoutedEventArgs e)
{
    e.Handled = true;  // Prevent focus stealing, but...
    UpdateSelectionStatus();
    // PreviewMouseWheel handler ensures scroll still works
}
```

### Result
✅ Smooth scrolling works even with cursor over checkboxes
✅ Checkbox click still works normally
✅ No focus stealing issues

---

## Pattern: Immediate UI Overlay Display

### Problem
Progress/Loading overlay appears hidden/delayed until first batch of async work completes (e.g., first 5 items added).

### Root Cause
No dispatcher invoke after setting visibility. UI doesn't render until first yield back to dispatcher in the processing loop.

### Solution

**After Showing Overlay:**
```csharp
// Show progress animation
ShowAddItemsAnimation(selectedItems.Count);

// Force immediate UI update BEFORE processing loop
Application.Current?.Dispatcher?.Invoke(() => { },
    System.Windows.Threading.DispatcherPriority.Background);

// Now process items
foreach (var item in items)
{
    // Process item...
}
```

### Result
✅ Overlay appears instantly when operation starts
✅ User gets immediate visual feedback
✅ No appearance of lag/delay

---

## Pattern: Hybrid Progress Display Strategy

### Problem
Progress updates happening every item (1, 2, 3, 4, 5) but message updates show truncated titles that hide the count display.

### Root Cause
Frequent UI updates + long titles = count display hidden behind text

### Solution

**Every Item (Always Accurate):**
```csharp
// Update only the count display
LoadingDetailsText.Text = $"{processedCount} / {selectedItems.Count} items processed";
```

**Every N Items (Periodic Messages):**
```csharp
if (processedCount % 5 == 0 || processedCount == selectedItems.Count)
{
    // Truncate title to prevent hiding count
    string displayTitle = item.Title.Length > 50
        ? item.Title.Substring(0, 47) + "..."
        : item.Title;

    UpdateAddItemsAnimation(processedCount, selectedItems.Count,
        $"Adding: {displayTitle}");

    Application.Current?.Dispatcher?.Invoke(() => { },
        System.Windows.Threading.DispatcherPriority.Background);
}
```

### Result
✅ Count is always accurate and visible (updates every item)
✅ Title updates less frequently for performance
✅ Important count info never hidden by truncated titles

### Design Pattern
- **Critical Data**: Update frequently (every iteration)
- **Secondary Data**: Update periodically (every N iterations)
- **Display Priority**: Ensure critical data always visible

---

## Pattern: Auto-Sizing DataGrid Rows

### Problem
DataGrid has fixed `RowHeight="80"` but content is taller. Text gets truncated/cut off.

### Root Cause
Fixed row height limits vertical space. Content overflow is hidden by default.

### Solution

**Change From:**
```xaml
<DataGrid RowHeight="80" ...>
```

**Change To:**
```xaml
<DataGrid RowHeight="Auto" ...>
```

**Also Ensure TextBlock Has Wrapping:**
```xaml
<DataGridTextColumn.ElementStyle>
    <Style TargetType="TextBlock">
        <Setter Property="TextWrapping" Value="Wrap"/>
        <Setter Property="Padding" Value="4"/>
    </Style>
</DataGridTextColumn.ElementStyle>
```

### Result
✅ Rows expand to fit content vertically
✅ All text visible without truncation
✅ No fixed height limitation

### Performance Note
- `RowHeight="Auto"` with large datasets can impact performance
- Virtual rowheights (v4.5+) may help
- For GetWorkItems dialog (typically <500 items): No performance issue

---

## Pattern Decision Tree: When to Use Each

| Scenario | Pattern | Why |
|----------|---------|-----|
| CheckBox blocks scroll in DataGrid | Scroll Through Pattern | Allows scroll while maintaining checkbox functionality |
| Async operation seems to hang | Immediate Overlay Pattern | User gets instant feedback that something is happening |
| Real-time progress with lots of updates | Hybrid Progress Pattern | Balance between accuracy and performance |
| Content truncated in DataGrid cells | Auto-Size Rows Pattern | Ensure all content visible to users |

---

## Related Dispatcher Priority Levels

When doing `Dispatcher.Invoke()`:

```csharp
// Most common for UI updates
System.Windows.Threading.DispatcherPriority.Background
// Wait until UI queue is mostly empty - smoother

System.Windows.Threading.DispatcherPriority.Normal
// Normal priority, after input

System.Windows.Threading.DispatcherPriority.High
// Higher priority, before normal work

System.Windows.Threading.DispatcherPriority.Input
// Input processing level (high)

System.Windows.Threading.DispatcherPriority.Render
// Rendering level (very high)
```

**Best Practice**: Use `DispatcherPriority.Background` for forcing layout updates during loops - gives UI a chance to process input while you work.

---

**Reference Date:** 2025-11-11 (Session 7)
**Tested In:** YourProject GetWorkItemsDialog + StepsEditor
**Validation:** ✅ 0 Build Errors
