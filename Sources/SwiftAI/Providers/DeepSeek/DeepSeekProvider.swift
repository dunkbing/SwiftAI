// Sources/SwiftAI/Providers/DeepSeek/DeepSeekProvider.swift
import Foundation

public final class DeepSeekProvider: AIProvider {
    public let providerType: ProviderType = .deepSeek

    // Use the shared internal client
    private let client: OpenAICompatibleClient

    // Protocol requirement initializer
    public convenience required init(apiKey: String) throws {
        // Use the standard DeepSeek base URL by default
        guard let defaultBaseURL = URL(string: "https://api.deepseek.com/v1") else {
            throw AIError.configurationError("Invalid default DeepSeek base URL.")
        }
        try self.init(apiKey: apiKey, apiBaseURL: defaultBaseURL, urlSession: .shared)
    }

    // Designated initializer (can be internal if only the convenience init is public)
    // Made public to allow custom URLSession/BaseURL if needed
    public init(apiKey: String, apiBaseURL: URL? = nil, urlSession: URLSession = .shared) throws {
        guard !apiKey.isEmpty else {
            throw AIError.configurationError("DeepSeek API Key is missing.")
        }
        // Determine the base URL
        let baseURL = apiBaseURL ?? URL(string: "https://api.deepseek.com/v1")! // Force unwrap okay if default is known good

        // Initialize the shared client
        self.client = OpenAICompatibleClient(apiKey: apiKey, baseURL: baseURL, urlSession: urlSession)
    }

    // MARK: - AIProvider Methods (Delegate to shared client)

    public func generateText(model: String, messages: [ChatMessage], options: RequestOptions?) async throws -> String {
        // Delegate the work to the internal client
        return try await client.generateTextInternal(model: model, messages: messages, options: options)
    }

    public func streamText(model: String, messages: [ChatMessage], options: RequestOptions?) async throws -> AsyncThrowingStream<AIStreamChunk, Error> {
        // Delegate the work to the internal client
        return try await client.streamTextInternal(model: model, messages: messages, options: options)
    }

    // No need for createURLRequest, JSON coders etc. here anymore
}
