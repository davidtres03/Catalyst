# ASP.NET Core Service Lifetime Patterns

**Category:** Architecture / Dependency Injection
**Difficulty:** Advanced
**Date Created:** November 17, 2025
**Discovered In:** YourProject v1.1.0.0 AI Integration

---

## Overview

ASP.NET Core provides three service lifetimes: Singleton, Scoped, and Transient. Understanding when to use each is critical for building reliable applications.

---

## Service Lifetimes Explained

### Singleton
**Created:** Once per application lifetime
**Shared:** Across all requests and users
**Thread-Safety:** Must be thread-safe
**Use When:** Service maintains application-wide state

```csharp
services.AddSingleton<IAIService, AIService>();
```

**Example:** Cache service, configuration manager, state that persists across requests

### Scoped
**Created:** Once per HTTP request
**Shared:** Within single request only
**Thread-Safety:** Not required (single-threaded per request)
**Use When:** Service tied to request lifetime

```csharp
services.AddScoped<ApplicationDbContext>();
```

**Example:** DbContext, request-specific services, user context

### Transient
**Created:** Every time it's requested
**Shared:** Never
**Thread-Safety:** Not required
**Use When:** Stateless, lightweight operations

```csharp
services.AddTransient<IEmailService, EmailService>();
```

**Example:** Helpers, utilities, stateless operations

---

## The Captive Dependency Problem

**Problem:** Singleton service depends on Scoped service

```csharp
// ❌ WRONG - Causes disposed DbContext errors
public class AIService : IAIService
{
    private readonly ApplicationDbContext _context;
    
    public AIService(ApplicationDbContext context) // Scoped injected into Singleton
    {
        _context = context; // This DbContext will be disposed after first request!
    }
}
```

**Why It Fails:**
1. AIService created once (Singleton)
2. DbContext created once (should be per-request)
3. First request ends → DbContext disposed
4. Second request → AIService tries to use disposed DbContext
5. **ObjectDisposedException thrown**

---

## Solution 1: IServiceScopeFactory Pattern

**Best for:** Singleton services that need occasional Scoped service access

```csharp
public class AIService : IAIService
{
    private readonly IServiceScopeFactory _scopeFactory;
    
    public AIService(IServiceScopeFactory scopeFactory)
    {
        _scopeFactory = scopeFactory;
    }
    
    public async Task<AIResponse> ProcessRequestAsync(AIRequest request)
    {
        using var scope = _scopeFactory.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        
        // Use context safely - it will be disposed when scope is disposed
        var data = await context.Data.ToListAsync();
        return new AIResponse { Data = data };
    }
}
```

**Why It Works:**
- Singleton doesn't hold reference to Scoped service
- Creates new scope on-demand
- Each scope gets fresh DbContext
- Scope disposed automatically (using statement)
- Thread-safe (each request gets its own scope)

**Registration:**
```csharp
builder.Services.AddSingleton<IAIService, AIService>();
builder.Services.AddScoped<ApplicationDbContext>();
```

---

## Solution 2: IServiceProvider Pattern

**Best for:** Complex scenarios with multiple Scoped dependencies

```csharp
public class AIService : IAIService
{
    private readonly IServiceProvider _serviceProvider;
    
    public AIService(IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
    }
    
    public async Task<AIResponse> ProcessRequestAsync(AIRequest request)
    {
        using var scope = _serviceProvider.CreateScope();
        var router = scope.ServiceProvider.GetRequiredService<IRequestRouter>();
        var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        
        // Use both services safely
        return await router.RouteAsync(request, context);
    }
}
```

**When to Use:**
- Need multiple Scoped services
- Services have complex dependencies
- Want explicit control over scope

---

## Real-World Example: YourProject AI Integration

**Requirement:**
- AIService must be Singleton (preserve backend registrations)
- Backends need DbContext (Scoped)
- Configuration must reload from database

**Architecture:**

```
AIService (Singleton)
├── IServiceScopeFactory (injected)
├── _backends Dictionary (persists across requests)
│   ├── OllamaService (Scoped, uses IServiceScopeFactory)
│   └── ClaudeAIService (Scoped, uses IServiceScopeFactory)
└── ProcessRequestAsync (creates scope per request)
```

**Implementation:**

```csharp
// Program.cs
builder.Services.AddSingleton<IAIService, AIService>();
builder.Services.AddScoped<OllamaService>();
builder.Services.AddScoped<ClaudeAIService>();
builder.Services.AddScoped<ApplicationDbContext>();

// AIService.cs
public class AIService : IAIService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly Dictionary<AIBackendType, IAIBackendService> _backends;
    
    public AIService(IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
        _backends = new Dictionary<AIBackendType, IAIBackendService>();
    }
    
    public void RegisterBackend(AIBackendType type, IAIBackendService backend)
    {
        _backends[type] = backend; // Persists across requests
    }
    
    public async Task<AIResponse> ProcessRequestAsync(AIRequest request)
    {
        using var scope = _serviceProvider.CreateScope();
        var router = scope.ServiceProvider.GetRequiredService<IRequestRouter>();
        
        // Router can safely use DbContext
        return await router.RouteAsync(request);
    }
}

// OllamaService.cs
public class OllamaService : IAIBackendService
{
    private readonly IServiceScopeFactory _scopeFactory;
    
    public OllamaService(IServiceScopeFactory scopeFactory)
    {
        _scopeFactory = scopeFactory;
    }
    
    private async Task EnsureConfigurationLoadedAsync()
    {
        using var scope = _scopeFactory.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        
        // Load configuration safely
        var config = await context.ApiConfigurations
            .FirstOrDefaultAsync(c => c.Service == "Ollama");
    }
}
```

**Why This Architecture:**
1. AIService Singleton → Backend registrations persist
2. IServiceProvider → Can create scopes for Scoped services
3. Backend services use IServiceScopeFactory → Can access DbContext safely
4. Each request gets fresh DbContext → No disposal issues
5. Thread-safe → Multiple requests don't interfere

---

## Common Patterns

### Pattern 1: Cache with Database Fallback
```csharp
public class CachedDataService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly IMemoryCache _cache;
    
    public CachedDataService(IServiceScopeFactory scopeFactory, IMemoryCache cache)
    {
        _scopeFactory = scopeFactory;
        _cache = cache;
    }
    
    public async Task<Data> GetDataAsync(int id)
    {
        return await _cache.GetOrCreateAsync($"data_{id}", async entry =>
        {
            entry.AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(5);
            
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            return await context.Data.FindAsync(id);
        });
    }
}
```

### Pattern 2: Background Service with Database Access
```csharp
public class BackgroundWorker : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    
    public BackgroundWorker(IServiceScopeFactory scopeFactory)
    {
        _scopeFactory = scopeFactory;
    }
    
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            
            // Do work with database
            await ProcessItemsAsync(context);
            await Task.Delay(TimeSpan.FromMinutes(5), stoppingToken);
        }
    }
}
```

### Pattern 3: Configuration Service with Periodic Reload
```csharp
public class ConfigurationService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private DateTime _lastLoad = DateTime.MinValue;
    private Dictionary<string, string> _config = new();
    
    public async Task<string> GetConfigAsync(string key)
    {
        if (DateTime.UtcNow - _lastLoad > TimeSpan.FromMinutes(5))
        {
            await ReloadConfigAsync();
        }
        
        return _config.GetValueOrDefault(key);
    }
    
    private async Task ReloadConfigAsync()
    {
        using var scope = _scopeFactory.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        
        _config = await context.Configurations
            .ToDictionaryAsync(c => c.Key, c => c.Value);
        
        _lastLoad = DateTime.UtcNow;
    }
}
```

---

## Troubleshooting

### Error: "Cannot access a disposed object"
**Cause:** Singleton holding reference to Scoped service
**Solution:** Use IServiceScopeFactory or IServiceProvider

### Error: "A second operation started on this context"
**Cause:** Multiple threads using same DbContext
**Solution:** Each scope should have its own DbContext (already automatic with Scoped)

### Error: "No service for type 'IServiceScopeFactory'"
**Cause:** IServiceScopeFactory not registered
**Solution:** Already registered by default in ASP.NET Core (built-in service)

---

## Best Practices

1. **Default to Scoped** for business logic services
2. **Use Singleton only when:** State must persist across requests
3. **Never inject Scoped into Singleton directly**
4. **Use IServiceScopeFactory** when Singleton needs occasional Scoped access
5. **Dispose scopes explicitly** with `using` statements
6. **Keep Singleton services thread-safe**
7. **Avoid storing Scoped services** in Singleton fields

---

## References

- YourProject v1.1.0.0 AI Integration
- Microsoft Docs: Dependency Injection in ASP.NET Core
- Session 22: AI Integration Victory

**Related Files:**
- `AIService.cs`
- `OllamaService.cs`
- `ClaudeAIService.cs`
- `Program.cs`
