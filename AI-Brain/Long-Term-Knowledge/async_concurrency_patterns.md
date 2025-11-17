# Async/Concurrency Patterns & Thread-Safety Lessons

## The InvalidOperationException Discovery

**Date**: Session 17, November 14, 2025

### The Problem
Application crashed during upgrade with `System.InvalidOperationException` in `System.Net.Http.dll`. After 17 sessions of debugging, discovered it was a **thread-safety race condition** in concurrent HttpClient usage.

### Root Cause: Shared Mutable State
```csharp
// ❌ DANGEROUS - Race condition
_httpClient.DefaultRequestHeaders.Remove("Authorization");        // Thread A
_httpClient.DefaultRequestHeaders.Add("Authorization", token);    // Thread B interrupts here
var response = await _httpClient.GetAsync(url);                   // Thread A continues - corrupted state!
```

**Why This Fails:**
- Multiple services (UpdateService, GitHubReleaseService, ConfigurationValidationService) all modify the SAME shared HttpClient
- They run on different threads during concurrent operations
- While Thread A removes the header, Thread B adds Authorization
- When Thread A resumes, it's modifying corrupted header state
- Result: `InvalidOperationException: Mismatched number of arguments for format specification`

### The Fix: Per-Request Headers
```csharp
// ✅ SAFE - Thread-safe approach
var request = new HttpRequestMessage(HttpMethod.Get, url);
request.Headers.Add("Authorization", $"Bearer {token}");
var response = await _httpClient.SendAsync(request);
```

**Why This Works:**
- Each request gets its own HttpRequestMessage object
- No shared mutable state between threads
- Authorization header is request-specific, not global
- Multiple threads can safely call SendAsync() concurrently

### Pattern: HttpClientFactory with Per-Request Headers

**Architectural Pattern:**
```csharp
public static class HttpClientFactory
{
    private static readonly Lazy<HttpClient> Instance = new(() =>
    {
        var client = new HttpClient();
        client.DefaultRequestHeaders.Add("User-Agent", "YourProject-Installer");
        return client;
    });

    public static HttpClient Client => Instance.Value;
}

// Usage:
var request = new HttpRequestMessage(HttpMethod.Get, url);
request.Headers.Add("Authorization", $"Bearer {token}");

// Shared client, per-request headers - best of both worlds
using var response = await HttpClientFactory.Client.SendAsync(request);
```

**Benefits:**
1. **Single Shared HttpClient** - Connection pooling, reduced resource allocation
2. **No Shared Mutable State** - Headers are per-request, thread-safe
3. **Clean Separation** - Setup headers once (User-Agent), customize per-request (Authorization)
4. **Async-Safe** - Works correctly with concurrent operations

### GitHub Authentication Model Discovery

During the same session, discovered two different GitHub authentication approaches:

**Public Repositories:**
- Direct CDN URLs work: `https://github.com/{owner}/{repo}/releases/download/{tag}/{filename}`
- Fast download (no redirects)
- Bearer token authentication works
- **Use this first** for speed

**Private Repositories:**
- CDN URLs return 404 with Bearer token auth
- Must use GitHub API endpoint: `https://api.github.com/repos/{owner}/{repo}/releases/assets/{assetId}`
- Include `Accept: application/octet-stream` header
- Bearer token works here
- **Fallback option** for private repos

**Implementation Pattern:**
```csharp
// Try fast path first (public repos)
var response = await _httpClient.SendAsync(cdnRequest, ResponseHeadersRead);

if (response.StatusCode == NotFound && assetId.HasValue && hasAuthToken)
{
    // Fallback to API endpoint (private repos)
    response.Dispose();
    var apiUrl = $"https://api.github.com/repos/{owner}/{repo}/releases/assets/{assetId}";
    var apiRequest = new HttpRequestMessage(HttpMethod.Get, apiUrl);
    apiRequest.Headers.Add("Accept", "application/octet-stream");
    apiRequest.Headers.Add("Authorization", $"Bearer {token}");

    response = await _httpClient.SendAsync(apiRequest, ResponseHeadersRead);
}
```

### Key Principles for Thread-Safe Async Code

1. **Never Modify Shared State During Async Operations**
   - Modification A starts
   - Async operation suspends
   - Modification B happens on different thread
   - Original async resumes to corrupted state

2. **Request-Scoped Objects Are Thread-Safe**
   - Create new object per request
   - Each request owns its object
   - No sharing = no races

3. **Lazy Initialization for Expensive Resources**
   - Use `Lazy<T>` for singletons
   - Thread-safe initialization
   - First access creates instance, subsequent accesses return same instance

4. **Test Concurrent Scenarios**
   - Single-threaded tests miss race conditions
   - Concurrent operations expose assumptions
   - Real-world usage often concurrent

### Debugging Race Conditions

**How We Found This:**
1. Exception message was vague ("Mismatched number of arguments")
2. Exception location was in HttpClient internals (not our code)
3. Only occurred during concurrent operations (upgrade + detection checks)
4. Stack trace showed `PrepareRequestMessage()` - internal header preparation
5. Searched for all places DefaultRequestHeaders was modified
6. Found the race!

**Tools That Helped:**
- Stack trace analysis (showed we were in header preparation)
- Debug logging at key decision points
- Reproduction with simple test case (making repo public)

### Performance vs Safety Trade-off

**Shared Mutable State:**
- ❌ Thread-safe
- ✅ Performance (one allocation)
- ❌ Subtle bugs only in production under load

**Per-Request Objects:**
- ✅ Thread-safe
- ❌ Performance (allocation per request)
- ✅ Safe under all conditions

**Reality:** HTTP requests are I/O bound. Allocation overhead is negligible compared to network latency. Always choose safety.

### Related Concepts
- Connection pooling (why shared HttpClient is good)
- Lock-free programming (why per-request objects are safe)
- Async/await gotchas (suspension points expose races)
- HttpClient initialization patterns (singleton vs per-request)

---

**Session 17 Lesson**: Thread-safety in async code requires special care. Shared mutable state is almost always a mistake. Use request-scoped objects instead.
