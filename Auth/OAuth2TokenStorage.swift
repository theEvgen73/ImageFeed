import Foundation

final class OAuth2TokenStorage {

    // MARK: - Singleton
    static let shared = OAuth2TokenStorage()
    private init() {}

    // MARK: - Keys
    private let tokenKey = "BearerToken"

    // MARK: - Token
    var token: String? {
        get {
            UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
}
