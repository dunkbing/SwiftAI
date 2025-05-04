import Foundation

public enum ProviderType: String, CaseIterable, Codable, Hashable {
    case openAI
    case googleGemini
    case deepSeek
}
