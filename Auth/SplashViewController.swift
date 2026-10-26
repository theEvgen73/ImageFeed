import UIKit

final class SplashViewController: UIViewController {

    // MARK: - UI Elements
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "splash_screen_logo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: - Properties
    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private var didStartInitialCheck = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.10, green: 0.11, blue: 0.13, alpha: 1.0)
        setupViews()
        setupConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !didStartInitialCheck else { return }
        didStartInitialCheck = true

        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            showAuthScreen()
        }
    }

    // MARK: - Setup
    private func setupViews() {
        view.addSubview(logoImageView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 75),
            logoImageView.heightAnchor.constraint(equalToConstant: 77)
        ])
    }

    // MARK: - Navigation
    private func showAuthScreen() {
        // 1. Создаем AuthViewController из Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(
            withIdentifier: "AuthViewController"
        ) as? AuthViewController else { return }
        
        // 2. Устанавливаем делегата
        authViewController.delegate = self
        
        // 3. Устанавливаем стиль презентации
        authViewController.modalPresentationStyle = .fullScreen
        
        // 4. Презентуем
        present(authViewController, animated: true)
    }

    private func switchToTabBarController() {
        guard let window = view.window else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
           
        window.rootViewController = tabBarController
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                self.switchToTabBarController()
            case .failure(let error):
                print("[SplashViewController]: fetchProfile - \(error.localizedDescription)")
                self.didStartInitialCheck = false
            }
        }
    }
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = storage.token else { return }
        fetchProfile(token: token)
    }
}
