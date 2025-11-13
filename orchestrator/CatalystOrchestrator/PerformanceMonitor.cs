using System;
using System.Diagnostics;

namespace CatalystOrchestrator;

/// <summary>
/// ? Performance monitoring for Catalyst responses
/// </summary>
public class PerformanceMonitor
{
    private readonly Stopwatch _stopwatch = new Stopwatch();

    public void Start()
    {
        _stopwatch.Restart();
    }

    public void Stop()
    {
        _stopwatch.Stop();
    }

    public void PrintStats(string label)
    {
        var elapsed = _stopwatch.Elapsed;
        var color = elapsed.TotalSeconds < 2 ? ConsoleColor.Green :
                    elapsed.TotalSeconds < 5 ? ConsoleColor.Yellow :
                    ConsoleColor.Red;

        Console.ForegroundColor = color;
        Console.WriteLine($"? {label}: {elapsed.TotalSeconds:F2}s");
        Console.ResetColor();
    }

    public TimeSpan Elapsed => _stopwatch.Elapsed;
}
