import Foundation

public struct AIConfiguration {
    public var apiKeys: [ProviderType: String]
    public var defaultOptions: RequestOptions?

    public init(apiKeys: [ProviderType : String], defaultOptions: RequestOptions? = nil) {
        self.apiKeys = apiKeys
        self.defaultOptions = defaultOptions
    }

    func getAPIKey(for provider: ProviderType) -> String? {
        return apiKeys[provider]
    }
}
