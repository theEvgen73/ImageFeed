import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

private struct OAuthTokenResponseBody: Decodable {
    let accessToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            print("[OAuth2Service]: makeOAuthTokenRequest - Ошибка: Не удалось создать URLComponents")
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]

        guard let authTokenUrl = urlComponents.url else {
            print("[OAuth2Service]: makeOAuthTokenRequest - Ошибка: Не удалось получить URL")
            return nil
        }

        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            defer {
                self?.task = nil
                self?.lastCode = nil
            }
            
            switch result {
            case .success(let responseBody):
                let token = responseBody.accessToken
                OAuth2TokenStorage.shared.token = token
                completion(.success(token))
            case .failure(let error):
                print("[OAuth2Service]: fetchOAuthToken - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        self.task = task
        task.resume()
    }
}
