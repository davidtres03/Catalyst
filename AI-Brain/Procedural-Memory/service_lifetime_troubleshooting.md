# Service Lifetime Troubleshooting

**Category:** Debugging / Architecture
**Difficulty:** Advanced
**Last Updated:** November 17, 2025
**Source:** YourProject v1.1.0.0 AI Integration

---

## Overview

Step-by-step procedure for diagnosing and fixing ASP.NET Core service lifetime issues, particularly "ObjectDisposedException: Cannot access a disposed object" errors related to DbContext.

---

## Symptoms

### Primary Symptom: ObjectDisposedException

**Error Message:**
```
System.ObjectDisposedException: Cannot access a disposed object. A common cause of this error is disposing a context that was resolved from dependency injection and then later trying to use the same context instance elsewhere in your application.
Object name: 'ApplicationDbContext'.
```

**When It Appears:**
- Second request to endpoint (first request works fine)
- Background services
- Singleton services accessing database
- Caching scenarios with database lookups

**Root Cause:**
- Singleton service holding reference to Scoped service
- DbContext disposed after first request
- Subsequent requests try to use disposed DbContext

---

## Diagnostic Procedure

### Step 1: Identify Service Lifetimes

**Command:**
```bash
# Search for service registrations
grep -rn "Add\(Singleton\|Scoped\|Transient\)" --include="*.cs" Program.cs Startup.cs
```

**Look for:**
```csharp
builder.Services.AddSingleton<IAIService, AIService>();        // Singleton
builder.Services.AddScoped<ApplicationDbContext>();             // Scoped
builder.Services.AddScoped<OllamaService>();                   // Scoped
```

**Key Questions:**
1. Is the service Singleton?
2. Does it depend on Scoped services?
3. Does it access DbContext directly or indirectly?

---

### Step 2: Trace Constructor Dependencies

**File:** Service implementation (e.g., `AIService.cs`)

**Check Constructor:**
```csharp
public class AIService : IAIService
{
    public AIService(ApplicationDbContext context) // ❌ PROBLEM!
    {
        _context = context; // Scoped service injected into Singleton
    }
}
```

**Red Flags:**
- ❌ `ApplicationDbContext` parameter in Singleton constructor
- ❌ Any Scoped service in Singleton constructor
- ❌ Storing Scoped service in Singleton field

**Correct Pattern:**
```csharp
public class AIService : IAIService
{
    public AIService(IServiceScopeFactory scopeFactory) // ✅ CORRECT
    {
        _scopeFactory = scopeFactory;
    }
}
```

---

### Step 3: Analyze Service Usage

**Search for DbContext Usage:**
```bash
# Find all DbContext usages in service
grep -n "ApplicationDbContext\|_context" Services/AIService.cs
```

**Check for:**
1. Direct DbContext field storage
2. DbContext used in methods without scope creation
3. DbContext passed to other services

**Example Problem:**
```csharp
public class AIService
{
    private readonly ApplicationDbContext _context; // ❌ Stored as field
    
    public async Task<Data> GetDataAsync()
    {
        return await _context.Data.ToListAsync(); // ❌ Uses stored field
    }
}
```

---

### Step 4: Verify Error Timing

**Test:**
```bash
# First request
curl http://localhost:5000/api/ai/process

# Second request (should fail if lifetime issue)
curl http://localhost:5000/api/ai/process
```

**If:**
- ✅ First request succeeds
- ❌ Second request fails with ObjectDisposedException
- **Diagnosis:** Captive dependency issue (Singleton holding Scoped service)

**If:**
- ❌ First request fails
- **Diagnosis:** Different issue (not lifetime-related)

---

### Step 5: Check Service Scope Creation

**Search for Scope Creation:**
```bash
grep -n "CreateScope\|IServiceScopeFactory\|IServiceProvider" Services/AIService.cs
```

**Correct Pattern:**
```csharp
using var scope = _scopeFactory.CreateScope();
var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
```

**Missing Patterns:**
- ❌ No `CreateScope()` calls
- ❌ No `IServiceScopeFactory` injection
- ❌ No `using` statement (scope not disposed)

---

## Fixing Procedures

### Fix 1: Use IServiceScopeFactory Pattern

**Before (WRONG):**
```csharp
public class AIService : IAIService
{
    private readonly ApplicationDbContext _context;
    
    public AIService(ApplicationDbContext context)
    {
        _context = context;
    }
    
    public async Task<Data> GetDataAsync()
    {
        return await _context.Data.ToListAsync();
    }
}
```

**After (CORRECT):**
```csharp
public class AIService : IAIService
{
    private readonly IServiceScopeFactory _scopeFactory;
    
    public AIService(IServiceScopeFactory scopeFactory)
    {
        _scopeFactory = scopeFactory;
    }
    
    public async Task<Data> GetDataAsync()
    {
        using var scope = _scopeFactory.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        return await context.Data.ToListAsync();
    }
}
```

**Steps:**
1. Replace `ApplicationDbContext` constructor parameter with `IServiceScopeFactory`
2. Store `IServiceScopeFactory` in field
3. Create scope in each method that needs DbContext
4. Get DbContext from scope
5. Use `using` statement to dispose scope

---

### Fix 2: Change Service Lifetime to Scoped

**Before:**
```csharp
builder.Services.AddSingleton<IAIService, AIService>();
```

**After:**
```csharp
builder.Services.AddScoped<IAIService, AIService>();
```

**When to Use:**
- Service doesn't need to preserve state across requests
- Service only accessed within request context
- Simpler than IServiceScopeFactory pattern

**When NOT to Use:**
- Service must preserve state (e.g., registered backends)
- Service accessed outside request context (background services)
- Performance-critical (Scoped creates new instance per request)

---

### Fix 3: Use IServiceProvider for Complex Scenarios

**Before:**
```csharp
public class AIService
{
    private readonly ApplicationDbContext _context;
    private readonly IRequestRouter _router;
    
    public AIService(ApplicationDbContext context, IRequestRouter router)
    {
        _context = context;
        _router = router;
    }
}
```

**After:**
```csharp
public class AIService
{
    private readonly IServiceProvider _serviceProvider;
    
    public AIService(IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
    }
    
    public async Task ProcessAsync()
    {
        using var scope = _serviceProvider.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var router = scope.ServiceProvider.GetRequiredService<IRequestRouter>();
        
        await router.RouteAsync(context);
    }
}
```

**Steps:**
1. Replace all Scoped constructor parameters with `IServiceProvider`
2. Create scope in methods
3. Get all services from scope
4. Dispose scope after use

---

## Testing Procedure

### Test 1: Multiple Requests

**Endpoint:**
```csharp
[HttpGet("test")]
public async Task<IActionResult> Test()
{
    var data = await _aiService.GetDataAsync();
    return Ok(data);
}
```

**Test Script:**
```bash
# Send 10 requests rapidly
for i in {1..10}; do
    curl -s http://localhost:5000/api/ai/test
    echo "Request $i: $?"
done
```

**Expected:**
- ✅ All requests return 200 OK
- ✅ No ObjectDisposedException
- ✅ Data returned correctly

**If Fails:**
- ❌ Some requests fail
- ❌ ObjectDisposedException in logs
- **Action:** Review scope creation, ensure `using` statements present

---

### Test 2: Concurrent Requests

**Test Script:**
```bash
# Send 5 concurrent requests
for i in {1..5}; do
    curl http://localhost:5000/api/ai/test &
done
wait
```

**Expected:**
- ✅ All requests complete successfully
- ✅ No thread-safety issues
- ✅ Each request gets its own DbContext

**If Fails:**
- ❌ "A second operation started on this context"
- **Action:** Ensure each scope gets its own DbContext (Scoped lifetime)

---

### Test 3: Background Service

**Service:**
```csharp
public class BackgroundWorker : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            
            await ProcessItemsAsync(context);
            await Task.Delay(TimeSpan.FromMinutes(1), stoppingToken);
        }
    }
}
```

**Test:**
```bash
# Start application
dotnet run

# Wait 5 minutes
# Check logs for errors
```

**Expected:**
- ✅ Background service runs continuously
- ✅ No ObjectDisposedException
- ✅ Data processed every minute

---

## Verification Checklist

**After Applying Fix:**

- [ ] Constructor dependencies reviewed
- [ ] IServiceScopeFactory injected (if Singleton needs Scoped services)
- [ ] Scope created in each method that needs DbContext
- [ ] `using` statement wraps scope creation
- [ ] DbContext obtained from scope, not stored in field
- [ ] Multiple requests test passes
- [ ] Concurrent requests test passes
- [ ] No ObjectDisposedException in logs
- [ ] Application logs show successful operations

---

## Common Mistakes

### Mistake 1: Forgetting `using` Statement

**Wrong:**
```csharp
var scope = _scopeFactory.CreateScope();
var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
// Scope never disposed! Memory leak!
```

**Correct:**
```csharp
using var scope = _scopeFactory.CreateScope();
var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
// Scope disposed automatically
```

### Mistake 2: Storing DbContext from Scope

**Wrong:**
```csharp
private ApplicationDbContext _cachedContext;

public async Task InitAsync()
{
    using var scope = _scopeFactory.CreateScope();
    _cachedContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    // DbContext disposed when scope ends, but stored in field!
}
```

**Correct:**
```csharp
public async Task InitAsync()
{
    using var scope = _scopeFactory.CreateScope();
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    // Use context here, don't store
}
```

### Mistake 3: Creating Scope Outside Method

**Wrong:**
```csharp
private readonly IServiceScope _scope;

public AIService(IServiceScopeFactory scopeFactory)
{
    _scope = scopeFactory.CreateScope(); // Created once, never disposed!
}
```

**Correct:**
```csharp
private readonly IServiceScopeFactory _scopeFactory;

public async Task ProcessAsync()
{
    using var scope = _scopeFactory.CreateScope(); // Created per method call
}
```

---

## Diagnostic Tools

### Tool 1: Enable Detailed Logging

**appsettings.Development.json:**
```json
{
  "Logging": {
    "LogLevel": {
      "Microsoft.EntityFrameworkCore": "Information",
      "Microsoft.Extensions.DependencyInjection": "Debug"
    }
  }
}
```

**Logs Show:**
- DbContext creation/disposal
- Service lifetime violations
- Scope creation/disposal

### Tool 2: Service Lifetime Validation

**Program.cs:**
```csharp
builder.Host.UseDefaultServiceProvider(options =>
{
    options.ValidateScopes = true; // Throws exception if lifetime issue detected
    options.ValidateOnBuild = true; // Validate at startup
});
```

**Benefits:**
- Detects captive dependencies at startup
- Throws clear exception message
- Prevents runtime issues

### Tool 3: Custom Diagnostic Middleware

**Middleware:**
```csharp
public class ServiceLifetimeDiagnosticMiddleware
{
    private readonly RequestDelegate _next;
    
    public async Task InvokeAsync(HttpContext context)
    {
        var scopeFactory = context.RequestServices.GetService<IServiceScopeFactory>();
        if (scopeFactory == null)
        {
            throw new InvalidOperationException("IServiceScopeFactory not available");
        }
        
        await _next(context);
    }
}
```

---

## References

- YourProject v1.1.0.0 AI Integration
- Session 22: Service Lifetime Debugging
- `aspnet_service_lifetime_patterns.md` (Long-Term Knowledge)

**Related Procedures:**
- AI Backend Configuration
- GitHub Release Procedure
- Build Process
