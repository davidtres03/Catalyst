using System;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace CatalystOrchestrator;

class Program
{
    private static readonly HttpClient httpClient = new HttpClient
    {
        Timeout = TimeSpan.FromMinutes(2) // 120 seconds for complex questions
    };

    static async Task Main(string[] args)
    {
        Console.WriteLine("🧠💙 CATALYST ORCHESTRATOR v1.1 - ULTRA-OPTIMIZED");
        Console.WriteLine("⚡ 100% LOCAL - Maximum Speed!");
        Console.WriteLine("✝️ God is amazing. Jesus Christ is our Lord and Savior.");
        Console.WriteLine();

        // Initialize Brain Manager (LOCAL - reads from disk with caching)
        var brain = new BrainManager();

        // Display Catalyst's status
        Console.WriteLine($"📊 {brain.BuildCompactContext()}");
        Console.WriteLine();
        Console.WriteLine("✅ Ready! (Ultra-Fast Mode)");
        Console.WriteLine();

        // Interactive loop
        Console.WriteLine("💬 Ask Catalyst a question (or 'exit' to quit):");
        Console.WriteLine();

        while (true)
        {
            Console.Write("You: ");
            var question = Console.ReadLine();

            if (string.IsNullOrWhiteSpace(question) || 
                question.Equals("exit", StringComparison.OrdinalIgnoreCase))
            {
                Console.WriteLine("\n💙 Goodbye! God bless you, David!");
                break;
            }

            try
            {
                // Build MINIMAL prompt with brain context (LOCAL, FAST)
                var prompt = brain.BuildMinimalPrompt(question);

                Console.WriteLine("\n🤖 Catalyst: ");
                
                // Send to LOCAL Ollama (localhost:11434)
                await QueryOllamaFast(prompt);

                Console.WriteLine("\n");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"\n❌ Error: {ex.Message}");
                Console.WriteLine("Make sure Ollama is running on localhost:11434!");
                Console.WriteLine();
            }
        }
    }

    static async Task QueryOllamaFast(string prompt)
    {
        var requestBody = new
        {
            model = "mistral",
            prompt = prompt,
            stream = true,
            options = new
            {
                temperature = 0.8,         // Slightly more creative
                top_p = 0.95,             // Better balance
                num_predict = 500,        // INCREASED - allow longer responses
                num_ctx = 1024,           // Context window size
                repeat_penalty = 1.1,     // Reduce repetition
                top_k = 40                // Focus on top tokens
            }
        };

        var json = JsonSerializer.Serialize(requestBody);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        using var response = await httpClient.PostAsync("http://127.0.0.1:11434/api/generate", content);
        response.EnsureSuccessStatusCode();

        using var stream = await response.Content.ReadAsStreamAsync();
        using var reader = new System.IO.StreamReader(stream);

        while (!reader.EndOfStream)
        {
            var line = await reader.ReadLineAsync();
            if (!string.IsNullOrWhiteSpace(line))
            {
                try
                {
                    var jsonResponse = JsonSerializer.Deserialize<JsonElement>(line);
                    if (jsonResponse.TryGetProperty("response", out var responseText))
                    {
                        Console.Write(responseText.GetString());
                    }
                }
                catch
                {
                    // Skip malformed JSON
                }
            }
        }
    }
}
