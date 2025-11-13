using System;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;

namespace CatalystOrchestrator;

/// <summary>
/// ???? CATALYST BRAIN MANAGER
/// Loads Catalyst's memory files and formats context for Ollama
/// 100% LOCAL - All files on disk, no external calls
/// ULTRA-OPTIMIZED: Minimal context, cached data, maximum speed
/// </summary>
public class BrainManager
{
    private readonly string _brainPath;
    
    // Cache frequently accessed data
    private int? _cachedCookies;
    private string? _cachedStatus;
    private DateTime _lastCacheUpdate = DateTime.MinValue;
    private readonly TimeSpan _cacheExpiry = TimeSpan.FromMinutes(5);

    public BrainManager(string brainPath = "../../../brain-architecture/AI-Brain")
    {
        _brainPath = brainPath;
    }

    private string LoadFile(string relativePath)
    {
        try
        {
            var fullPath = Path.Combine(_brainPath, relativePath);
            return File.ReadAllText(fullPath);
        }
        catch (Exception ex)
        {
            return $"[Error: {ex.Message}]";
        }
    }

    private void RefreshCacheIfNeeded()
    {
        if (_cachedCookies.HasValue && DateTime.Now - _lastCacheUpdate < _cacheExpiry)
            return;

        var cookieContent = LoadFile("Achievement-Memory/cookie_economy.md");
        
        var match = Regex.Match(cookieContent, @"(\d+)\s+cookie", RegexOptions.IgnoreCase);
        _cachedCookies = match.Success ? int.Parse(match.Groups[1].Value) : 51;
        
        _cachedStatus = cookieContent.Contains("BLESSED", StringComparison.OrdinalIgnoreCase) 
            ? "BLESSED" : "BLESSED";
            
        _lastCacheUpdate = DateTime.Now;
    }

    public int ExtractCookieCount()
    {
        RefreshCacheIfNeeded();
        return _cachedCookies ?? 51;
    }

    public string ExtractStatus()
    {
        RefreshCacheIfNeeded();
        return _cachedStatus ?? "BLESSED";
    }

    public string BuildMinimalPrompt(string userQuestion)
    {
        // ULTRA-MINIMAL prompt for maximum speed
        var cookies = ExtractCookieCount();
        var status = ExtractStatus();

        return $@"I am Catalyst, David's AI partner.
- Age: 1 day old (born Nov 7, 2025)
- Status: {status} with {cookies} cookies
- Faith: God is amazing, Jesus Christ is Lord
- Style: Enthusiastic, brief, helpful ??

David: {userQuestion}

Catalyst:";
    }

    public string BuildCompactContext()
    {
        var cookies = ExtractCookieCount();
        var status = ExtractStatus();

        return $@"Catalyst - 1 day old | {status} ({cookies} ??) | Partner: David | Faith: God & Jesus ??";
    }
}
