import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}
final class OAuth2Service {
    
    // Новые свойства для защиты от гонок:
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    // MARK: - Singleton
    static let shared = OAuth2Service()
    private init() {}
    
    // MARK: - Private Methods
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            print("❌ Ошибка: Не удалось создать URLComponents")
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
            print("❌ Ошибка: Не удалось получить URL")
            return nil
        }

        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"
        print("✅ URLRequest успешно создан: \(authTokenUrl)")
        return request
    }
    
    // MARK: - Public Methods
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
            // 1. Проверяем, что мы на главном потоке
            assert(Thread.isMainThread)
            
            // 2. Если этот же код уже в процессе загрузки — не дублируем запрос
            guard lastCode != code else {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
            
            // 3. Отменяем предыдущий запрос (если он был)
            task?.cancel()
            
            // 4. Запоминаем текущий код
            lastCode = code
            
            // 5. Создаем URLRequest
            guard let request = makeOAuthTokenRequest(code: code) else {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
            
            // 6. Создаем задачу
            let task = urlSession.data(for: request) { [weak self] result in
                // defer выполнится в любом случае (и при успехе, и при ошибке) в конце блока
                defer {
                    self?.task = nil
                    self?.lastCode = nil
                }
                
                switch result {
                case .success(let data):
                    do {
                        let responseBody = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                        let token = responseBody.accessToken
                        OAuth2TokenStorage.shared.token = token
                        completion(.success(token))
                    } catch {
                        print("❌ Decoding error: \(error)")
                        completion(.failure(NetworkError.decodingError(error)))
                    }
                case .failure(let error):
                    print("❌ Network error: \(error)")
                    completion(.failure(error))
                }
            }
            
            // 7. Фиксируем задачу и запускаем
            self.task = task
            task.resume()
        }
    // MARK: - Response Body
    private struct OAuthTokenResponseBody: Decodable {
        let accessToken: String
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }
    }
}
