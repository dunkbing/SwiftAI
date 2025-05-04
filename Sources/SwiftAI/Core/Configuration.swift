import Foundation

public struct AIConfiguration {
    public var apiKeys: [ProviderType: String]
    public var defaultModel: [ProviderType: String]?
    public var defaultOptions: RequestOptions?

    public init(apiKeys: [ProviderType : String], defaultModel: [ProviderType : String]? = nil, defaultOptions: RequestOptions? = nil) {
        self.apiKeys = apiKeys
        self.defaultModel = defaultModel
        self.defaultOptions = defaultOptions
    }

    func getAPIKey(for provider: ProviderType) -> String? {
        return apiKeys[provider]
    }
}
