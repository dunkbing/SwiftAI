# SwiftAI SDK

[![Swift Version](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2015+%20%7C%20macOS%2012+%20%7C-blue.svg)](https://developer.apple.com/)

A simple Swift library for interacting with multiple Large Language Models (LLMs) through a unified interface, inspired by Vercel's AI SDK.

## Features

*   **Unified API:** Use `generateText` and `streamText` with type-safe model selection.
*   **Multiple Providers:** Easily switch between supported AI models.
*   **Streaming Support:** Handle responses chunk by chunk using `AsyncThrowingStream`.
*   **Type Safe:** Built with Swift for robust applications.

## Supported Providers

*   OpenAI (and compatible APIs like DeepSeek)
*   DeepSeek (via OpenAI-compatible endpoint)
*   _(More planned)_

## Installation

Add SwiftAI as a dependency to your `Package.swift` file:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    dependencies: [
        .package(url: "https://github.com/dunkbing/SwiftAI.git", branch: "main")
    ],
    targets: [
        .target(
            name: "YourAppTarget",
            dependencies: [
                .product(name: "SwiftAI", package: "SwiftAI")
            ]),
    ]
)
```

## Basic Usage

### 1. Configuration

Configure the client with your API keys. Never hardcode API keys in production! Use environment variables or secure storage.

```swift
import SwiftAI

// Get keys securely (e.g., from environment variables)
let openAIKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
let deepSeekKey = ProcessInfo.processInfo.environment["DEEPSEEK_API_KEY"] ?? ""

let config = AIConfiguration(
    apiKeys: [
        .openAI: openAIKey,
        .deepSeek: deepSeekKey
    ],
    defaultOptions: RequestOptions(temperature: 0.7) // Optional default parameters
)

let aiClient = AIClient(configuration: config)
```

### 2. Generate Full Text

Get the complete response as a single string.

```swift
Task {
    let messages = [ChatMessage(role: .user, content: "Tell me a short joke.")]
    do {
        // Using predefined model constants
        let response = try await aiClient.generateText(
            model: .gpt4oMini,
            messages: messages
        )
        print("AI Response: \(response)")

        // Or specify the model directly
        let customResponse = try await aiClient.generateText(
            model: .openAI("gpt-4-turbo"),
            messages: messages
        )
    } catch {
        print("Error generating text: \(error)")
    }
}
```

### 3. Stream Text

Receive the response in chunks as they become available.

```swift
Task {
    let messages = [ChatMessage(role: .user, content: "Explain quantum physics simply.")]
    do {
        // Using a predefined model constant
        let stream = try await aiClient.streamText(
            model: .deepSeekChat,
            messages: messages
        )
        print("Streaming AI Response:")
        for try await chunk in stream {
            print(chunk.textDelta, terminator: "") // Print each piece
        }
        print("\n--- Stream Complete ---")
    } catch {
        print("Error streaming text: \(error)")
    }
}
```

## Available Models

SwiftAI includes predefined constants for common models:

```swift
// OpenAI Models
.gpt4o             // .openAI("gpt-4o")
.gpt4oMini         // .openAI("gpt-4o-mini")

// DeepSeek Models
.deepSeekChat      // .deepSeek("deepseek-chat")
.deepSeekCoder     // .deepSeek("deepseek-coder")

// Or use your own models
.openAI("gpt-4-vision-preview")
.deepSeek("deepseek-llm-7b-chat")
```

## Contributing

Contributions are welcome! Please feel free to open an issue or submit a pull request.
