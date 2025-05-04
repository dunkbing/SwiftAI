import Foundation

public class AIClient {
    private let configuration: AIConfiguration
    private var initializedProviders: [ProviderType: AIProvider] = [:]
    private let urlSession: URLSession

    public init(configuration: AIConfiguration, urlSession: URLSession = .shared) {
        self.configuration = configuration
        self.urlSession = urlSession
    }

    // Lazily initializes and retrieves a provider instance
    private func getProvider(type: ProviderType) throws -> AIProvider {
        if let existingProvider = initializedProviders[type] {
            return existingProvider
        }

        guard let apiKey = configuration.getAPIKey(for: type) else {
            throw AIError.providerNotConfigured(type)
        }

        let newProvider: AIProvider
        switch type {
        case .openAI:
            newProvider = try OpenAIProvider(apiKey: apiKey, urlSession: urlSession)
        case .googleGemini:
             throw AIError.unsupportedFunctionality("Gemini provider not yet implemented.")
        case .deepSeek:
            newProvider = try DeepSeekProvider(apiKey: apiKey, urlSession: urlSession)
        }

        initializedProviders[type] = newProvider
        return newProvider
    }

    /// Generates a complete text response using the specified provider.
    public func generateText(
        provider type: ProviderType,
        model: String? = nil, // use default if nil
        messages: [ChatMessage],
        options: RequestOptions? = nil
    ) async throws -> String {
        let provider = try getProvider(type: type)
        let targetModel = model ?? configuration.defaultModel?[type] ?? ""
        if targetModel.isEmpty {
            throw AIError.configurationError("Model must be specified either in the call or in the configuration for \(type).")
        }
        let mergedOptions = mergeOptions(callOptions: options, configOptions: configuration.defaultOptions)

        return try await provider.generateText(model: targetModel, messages: messages, options: mergedOptions)
    }

    /// Generates a streamed text response using the specified provider.
    public func streamText(
        provider type: ProviderType,
        model: String? = nil,
        messages: [ChatMessage],
        options: RequestOptions? = nil
    ) async throws -> AsyncThrowingStream<AIStreamChunk, Error> {
        let provider = try getProvider(type: type)
        let targetModel = model ?? configuration.defaultModel?[type] ?? "" // Provider should handle empty model if it has a default
         if targetModel.isEmpty {
            throw AIError.configurationError("Model must be specified either in the call or in the configuration for \(type).")
        }
       let mergedOptions = mergeOptions(callOptions: options, configOptions: configuration.defaultOptions)

        return try await provider.streamText(model: targetModel, messages: messages, options: mergedOptions)
    }

    // Helper to merge request options
    private func mergeOptions(callOptions: RequestOptions?, configOptions: RequestOptions?) -> RequestOptions? {
        guard callOptions != nil || configOptions != nil else { return nil }

        var merged = configOptions ?? RequestOptions()

        if let call = callOptions { // Override with call-specific options
            merged.temperature = call.temperature ?? merged.temperature
            merged.maxTokens = call.maxTokens ?? merged.maxTokens
            merged.topP = call.topP ?? merged.topP
            // Merge other options
        }
        return merged
    }
}
