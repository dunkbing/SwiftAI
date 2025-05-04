import Foundation

// Protocol defining the contract for any AI provider implementation
public protocol AIProvider {
    var providerType: ProviderType { get }

    // Initialize with necessary credentials (could be API key, token, etc.)
    init(apiKey: String) throws // Or a more generic credential type

    /// Generates a complete text response from the model.
    /// - Parameters:
    ///   - model: The specific model identifier (e.g., "gpt-4o", "gemini-1.5-pro").
    ///   - messages: An array of ChatMessage representing the conversation history.
    ///   - options: Optional request parameters (temperature, maxTokens, etc.).
    /// - Returns: The generated text content as a String.
    /// - Throws: An `AIError` if generation fails.
    func generateText(
        model: String,
        messages: [ChatMessage],
        options: RequestOptions?
    ) async throws -> String

    /// Generates a text response streamed chunk by chunk.
    /// - Parameters:
    ///   - model: The specific model identifier.
    ///   - messages: An array of ChatMessage representing the conversation history.
    ///   - options: Optional request parameters.
    /// - Returns: An `AsyncThrowingStream<AIStreamChunk, Error>` emitting text chunks.
    /// - Throws: An `AIError` if starting the stream fails. Errors during streaming are emitted via the stream.
    func streamText(
        model: String,
        messages: [ChatMessage],
        options: RequestOptions?
    ) async throws -> AsyncThrowingStream<AIStreamChunk, Error>
}
