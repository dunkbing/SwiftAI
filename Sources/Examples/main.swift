import Foundation
import SwiftAI

print("🚀 Starting SwiftAI Example Runner...")

let deepSeekAPIKey = ProcessInfo.processInfo.environment["DEEPSEEK_API_KEY"]
let openAIAPIKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]

guard let validDeepSeekKey = deepSeekAPIKey, !validDeepSeekKey.isEmpty else {
    print("""
    Error: DEEPSEEK_API_KEY environment variable not set or is empty.
    Please set it before running the example:
    export DEEPSEEK_API_KEY="your_actual_deepseek_api_key"
    """)
    exit(1)
}

let config = AIConfiguration(
    apiKeys: [
        .deepSeek: validDeepSeekKey,
        // Uncomment if you have an OpenAI key
        // .openAI: openAIAPIKey ?? ""
    ],
    defaultOptions: RequestOptions(temperature: 0.7)
)

let aiClient = AIClient(configuration: config)

// conversation messages
let messages = [
    ChatMessage(role: .system, content: "You are a helpful and concise assistant."),
    ChatMessage(role: .user, content: "Explain the concept of asynchronous programming in Swift using an analogy.")
]

Task {
    print("\n-----------------------------------------")
    print("🧪 Testing DeepSeek Provider")
    print("-----------------------------------------")

    // --- Generate Text (DeepSeek) ---
    print("\n💬 Requesting Full Text Generation (DeepSeek)...")
    do {
        // Using the new AIModel enum
        let deepSeekResponse = try await aiClient.generateText(
            model: .deepSeek("deepseek-chat"),
            messages: messages
            // override options here:
            // options: RequestOptions(temperature: 0.5)
        )
        print("\n✅ DeepSeek Full Response:\n\(deepSeekResponse)")
    } catch {
        print("\n❌ Error generating text with DeepSeek:")
        if let aiError = error as? AIError {
            print("   Error Type: AIError")
            print("   Details: \(aiError.localizedDescription)")
        } else {
            print("   Error Type: \(type(of: error))")
            print("   Details: \(error.localizedDescription)")
        }
    }

    // --- Stream Text (DeepSeek) ---
    print("\n\n🌊 Requesting Text Streaming (DeepSeek)...")
    do {
        // Using the predefined constant from AIModel
        let deepSeekStream = try await aiClient.streamText(
            model: .deepSeekChat,
            messages: messages
        )
        print("\n✅ DeepSeek Streaming Response:")
        var accumulatedText = ""
        for try await chunk in deepSeekStream {
            print(chunk.textDelta, terminator: "") // Print chunk as it arrives
            accumulatedText += chunk.textDelta
            // You could check chunk.isFinal if needed
        }
        print("\n--- End of DeepSeek Stream ---")
        // Optional: Print the fully accumulated text if needed
        // print("\n   (Accumulated Streamed Text: \(accumulatedText))")

    } catch {
        print("\n❌ Error streaming text with DeepSeek:")
         if let aiError = error as? AIError {
            print("   Error Type: AIError")
            print("   Details: \(aiError.localizedDescription)")
        } else {
            print("   Error Type: \(type(of: error))")
            print("   Details: \(error.localizedDescription)")
        }
    }

    print("\n-----------------------------------------")
    print("🏁 Example Runner Finished")
    print("-----------------------------------------")
    exit(0) // Exit successfully
}

// Keep the program running until the Task completes.
// Necessary for command-line tools using top-level async/await.
dispatchMain()
