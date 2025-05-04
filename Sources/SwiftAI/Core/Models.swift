import Foundation

public struct ChatMessage: Codable, Hashable, Identifiable {
    public let id: UUID
    public let role: ChatRole
    public let content: String

    public init(id: UUID = UUID(), role: ChatRole, content: String) {
        self.id = id
        self.role = role
        self.content = content
    }
}

public enum ChatRole: String, Codable, Hashable {
    case system
    case user
    case assistant
    // case tool
    // case function
}

public enum AIError: Error, LocalizedError {
    case configurationError(String)
    case networkError(Error)
    case apiError(statusCode: Int, message: String)
    case responseParsingError(Error)
    case streamingError(String)
    case providerNotConfigured(ProviderType)
    case unsupportedFunctionality(String)

    public var errorDescription: String? {
        switch self {
        case .configurationError(let msg): return "Configuration Error: \(msg)"
        case .networkError(let err): return "Network Error: \(err.localizedDescription)"
        case .apiError(let code, let msg): return "API Error (\(code)): \(msg)"
        case .responseParsingError(let err): return "Response Parsing Error: \(err.localizedDescription)"
        case .streamingError(let msg): return "Streaming Error: \(msg)"
        case .providerNotConfigured(let type): return "Provider \(type.rawValue) is not configured with necessary credentials."
        case .unsupportedFunctionality(let msg): return "Unsupported Functionality: \(msg)"
        }
    }
}

public struct RequestOptions: Codable {
    public var temperature: Double?
    public var maxTokens: Int?
    public var topP: Double?

    public init(temperature: Double? = nil, maxTokens: Int? = nil, topP: Double? = nil) {
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.topP = topP
    }
}

// Represents a chunk received during streaming
public struct AIStreamChunk: Equatable {
    public let id: String
    public let textDelta: String
    public let isFinal: Bool // check for last chunk
    public let usage: UsageStats?
    public let rawProviderResponse: Data?

    public init(textDelta: String, id: String = UUID().uuidString, isFinal: Bool = false, usage: UsageStats? = nil, rawProviderResponse: Data? = nil) {
        self.id = id
        self.textDelta = textDelta
        self.isFinal = isFinal
        self.usage = usage
        self.rawProviderResponse = rawProviderResponse
    }
}

public struct UsageStats: Codable, Equatable {
    public let promptTokens: Int?
    public let completionTokens: Int?
    public let totalTokens: Int?

    public init(promptTokens: Int? = nil, completionTokens: Int? = nil, totalTokens: Int? = nil) {
        self.promptTokens = promptTokens
        self.completionTokens = completionTokens
        self.totalTokens = totalTokens
    }
}
