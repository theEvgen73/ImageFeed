//import UIKit
////import Kingfisher
//
//final class ProfileViewController: UIViewController {
//
//    // MARK: - UI Elements
//    private let avatarImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.image = UIImage(named: "placeholder_avatar") // плейсхолдер из ассетов
//        imageView.layer.cornerRadius = 35
//        imageView.clipsToBounds = true
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
//
//    private let nameLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = .white
//        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    private let loginNameLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = UIColor(red: 0.68, green: 0.69, blue: 0.71, alpha: 1.0)
//        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    private let descriptionLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = .white
//        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
//        label.numberOfLines = 0
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    private let logoutButton: UIButton = {
//        let button = UIButton.systemButton(
//            with: UIImage(systemName: "ipad.and.arrow.forward")!,
//            target: nil,
//            action: nil
//        )
//        button.tintColor = UIColor(red: 0.96, green: 0.42, blue: 0.42, alpha: 1.0)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//
//    // MARK: - Properties
//    private var profileImageServiceObserver: NSObjectProtocol?
//
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = UIColor(red: 0.10, green: 0.11, blue: 0.13, alpha: 1.0)
//        setupViews()
//        setupConstraints()
//        setupLogoutButton()
//        updateProfileDetails()
//        observeProfileImage()
//    }
//
//    // MARK: - Setup
//    private func setupViews() {
//        [avatarImageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton].forEach {
//            view.addSubview($0)
//        }
//    }
//
//    private func setupConstraints() {
//        NSLayoutConstraint.activate([
//            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
//            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
//            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
//            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//
//            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
//            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
//            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//
//            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
//            loginNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
//            loginNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//
//            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
//            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
//            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//
//            logoutButton.widthAnchor.constraint(equalToConstant: 44),
//            logoutButton.heightAnchor.constraint(equalToConstant: 44),
//            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
//            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
//        ])
//    }
//
//    // MARK: - Profile Data
//    private func updateProfileDetails() {
//        guard let profile = ProfileService.shared.profile else { return }
//        nameLabel.text = profile.name
//        loginNameLabel.text = profile.loginName
//        descriptionLabel.text = profile.bio
//    }
//
//    private func observeProfileImage() {
//        profileImageServiceObserver = NotificationCenter.default.addObserver(
//            forName: ProfileImageService.didChangeNotification,
//            object: nil,
//            queue: .main
//        ) { [weak self] _ in
//            self?.updateAvatar()
//        }
//    }
//
//    private func updateAvatar() {
//        guard
//            let profileImageURL = ProfileImageService.shared.avatarURL,
//            let url = URL(string: profileImageURL)
//        else { return }
//        
//        avatarImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder_avatar"))
//    }
//
//    // MARK: - Logout
//    private func setupLogoutButton() {
//        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
//    }
//
//    @objc private func didTapLogoutButton() {
//        let alert = UIAlertController(
//            title: "Пока, пока!",
//            message: "Уверены, что хотите выйти?",
//            preferredStyle: .alert
//        )
//        
//        let yesAction = UIAlertAction(title: "Да", style: .default) { _ in
//            self.logout()
//        }
//        let noAction = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
//        
//        alert.addAction(yesAction)
//        alert.addAction(noAction)
//        present(alert, animated: true)
//    }
//
//    private func logout() {
//        // 1. Чистим токен
//        OAuth2TokenStorage().token = nil
//        
//        // 2. Переключаем корневой контроллер на экран авторизации
//        guard let window = UIApplication.shared.windows.first else { return }
//        window.rootViewController = SplashViewController()
//        window.makeKeyAndVisible()
//    }
//}
