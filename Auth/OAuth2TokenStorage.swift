import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    private let tokenKey = "BearerToken"
    
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let newValue = newValue {
                let isSuccess = KeychainWrapper.standard.set(newValue, forKey: tokenKey)
                if !isSuccess {
                    print("❌ [OAuth2TokenStorage]: Не удалось сохранить токен в Keychain")
                }
            } else {
                let isRemoved = KeychainWrapper.standard.removeObject(forKey: tokenKey)
                if !isRemoved {
                    print("❌ [OAuth2TokenStorage]: Не удалось удалить токен из Keychain")
                }
            }
        }
    }
}
