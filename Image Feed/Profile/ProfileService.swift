import Foundation

struct ProfileResult: Codable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

@MainActor
final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    private(set) var profile: Profile?
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            print("[ProfileService]: makeProfileRequest - Ошибка: Не удалось создать URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard lastToken != token else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastToken = token
        
        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            defer {
                self?.task = nil
                self?.lastToken = nil
            }
            
            switch result {
            case .success(let profileResult):
                var fullName = profileResult.firstName ?? ""
                if let lastName = profileResult.lastName {
                    fullName += " \(lastName)"
                }
                if fullName.trimmingCharacters(in: .whitespaces).isEmpty {
                    fullName = profileResult.username
                }
                
                let profile = Profile(
                    username: profileResult.username,
                    name: fullName,
                    loginName: "@\(profileResult.username)",
                    bio: profileResult.bio
                )
                
                self?.profile = profile
                completion(.success(profile))
            case .failure(let error):
                print("[ProfileService]: fetchProfile - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        self.task = task
        task.resume()
    }
}
