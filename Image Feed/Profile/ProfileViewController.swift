import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {

    // MARK: - UI Elements
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        // Плейсхолдер по умолчанию (серый силуэт), пока не загрузится настоящая аватарка
        imageView.image = UIImage(systemName: "person.crop.circle.fill")
        imageView.tintColor = .gray
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let loginNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 0.68, green: 0.69, blue: 0.71, alpha: 1.0)
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        if let image = UIImage(systemName: "ipad.and.arrow.forward") {
            button.setImage(image, for: .normal)
        }
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Properties
    private var profileImageServiceObserver: NSObjectProtocol?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.10, green: 0.11, blue: 0.13, alpha: 1.0)
        
        setupViews()
        setupConstraints()
        setupActions()
        
        // 1. Обновляем текстовые данные (имя, логин, био)
        if let profile = ProfileService.shared.profile {
            updateProfileDetails(profile: profile)
        }
        
        // 2. Подписываемся на уведомление об обновлении аватарки
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
            
        // 3. Пытаемся загрузить аватарку сразу (если она уже была получена на Splash-экране)
        updateAvatar()
    }

    // MARK: - Setup
    private func setupViews() {
        [avatarImageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton].forEach {
            view.addSubview($0)
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Avatar
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),

            // Name
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            // Login
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            // Description
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            // Logout Button
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }

    private func setupActions() {
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
    }

    // MARK: - Data Updates
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        // Плейсхолдер для аватарки на время загрузки
        let placeholder = UIImage(systemName: "person.crop.circle.fill")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        
        // 3. Используем Kingfisher для загрузки
        avatarImageView.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [
                .transition(.fade(0.3)), // Плавное появление
                .cacheOriginalImage      // Кеширование картинки
            ]
        )
    }
    // MARK: - Actions
    @objc
    private func didTapLogoutButton() {
        print("Logout tapped")
        // TODO [Sprint 11] Реализовать логику выхода
    }
}
