import Foundation

public enum AIModel {
    case openAI(String)
    case deepSeek(String)
    case googleGemini(String)

    var providerType: ProviderType {
        switch self {
        case .openAI: return .openAI
        case .deepSeek: return .deepSeek
        case .googleGemini: return .googleGemini
        }
    }

    var modelString: String {
        switch self {
        case .openAI(let model): return model
        case .deepSeek(let model): return model
        case .googleGemini(let model): return model
        }
    }

    public static let gpt4o = AIModel.openAI("gpt-4o")
    public static let gpt4oMini = AIModel.openAI("gpt-4o-mini")
    public static let deepSeekChat = AIModel.deepSeek("deepseek-chat")
    public static let deepSeekCoder = AIModel.deepSeek("deepseek-coder")
}
