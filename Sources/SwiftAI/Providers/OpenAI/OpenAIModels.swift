import Foundation

struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIChatMessage]
    let stream: Bool
    let temperature: Double?
    let max_tokens: Int? // Note the snake_case for JSON compatibility
    let top_p: Double?

    // Map from our ChatMessage
    init(model: String, messages: [ChatMessage], stream: Bool, options: RequestOptions?) {
        self.model = model
        self.messages = messages.map { OpenAIChatMessage(role: $0.role.rawValue, content: $0.content) }
        self.stream = stream
        self.temperature = options?.temperature
        self.max_tokens = options?.maxTokens
        self.top_p = options?.topP
    }
}

struct OpenAIChatMessage: Codable {
    let role: String
    let content: String
}

struct OpenAIResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [OpenAIChoice]
    let usage: OpenAIUsage?
}

struct OpenAIChoice: Codable {
    let index: Int
    let message: OpenAIMessageContent
    let finish_reason: String?
}

struct OpenAIMessageContent: Codable {
    let role: String
    let content: String? // Content can be null sometimes (e.g., function calls)
}

struct OpenAIUsage: Codable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
}

struct OpenAIStreamChunk: Decodable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [OpenAIStreamChoice]
    // Usage might appear in the *last* chunk for some models, handle accordingly if needed
}

struct OpenAIStreamChoice: Decodable {
    let index: Int
    let delta: OpenAIStreamDelta
    let finish_reason: String? // Non-nil indicates the last chunk for this choice
}

struct OpenAIStreamDelta: Decodable {
    let role: String? // Present in the first delta chunk
    let content: String? // The actual text chunk
}
