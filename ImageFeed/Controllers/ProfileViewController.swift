//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Олег Кор on 07.08.2024.
//

import UIKit
import Kingfisher
import SwiftKeychainWrapper

final class ProfileViewController: UIViewController {
    
    private let profileImage = UIImageView()
    private let nameLabel = UILabel()
    private let accountName = UILabel()
    private let accountDescription = UILabel()
    private let logoutButton = UIButton()
    
    private let profileInfoPVC = ProfileService.shared
    private let profileImagePVC = ProfileImageService.shared
    private let myToken = OAuth2TokenStorage()
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private let imageListStore = ImagesListService.shared
    private let profileLogOut = ProfileLogoutService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubview()
        nameLabelFunc() // Вызов функции параметров отображения ФИО пользователя
        accountNameFunc() // Вызов функции параметров отображения имени @пользователя
        accountDescriptionFunc() // Вызов функции параметров отображения статуса аккаунта
        logOutButtonFunc() // Вызов функции параметров отображения кнопки выхода из аккаунта
        
        // Метод слежение и обновления картинки аватара в профиле
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar()
        }
        updateAvatar()
        updateProfileDetails(profile: profileInfoPVC.profile) // Загрузка данных профиля из инета
        
        
    }
    
    /// Метод создание сабвью для всех элементов контроллера профиля
    private func createSubview() {
        [profileImage,
         nameLabel,
         accountName,
         accountDescription,
         logoutButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    /// Метод загрузки данных профиля с сайта
    private func updateProfileDetails(profile: Profile?) {
        guard let profile = profileInfoPVC.profile else { return }
        nameLabel.text = profile.name
        accountName.text = profile.loginName
        accountDescription.text = profile.bio
    }
    
    /// Метод загрузки аватара из api unsplash
    private func updateAvatar() {
        guard
            let profileImageURL = profileImagePVC.avatarURL,
            let imageURL = URL(string: profileImageURL)
        else {
            print("НЕ ПОДГРУЗИЛАСЬ ССЫЛКА НА АВАТАР")
            return }
        
        // Очистка кэша
        let cashe = ImageCache.default
        cashe.clearMemoryCache()
        cashe.clearDiskCache()
        
        // Задание радиуса через кингфишер
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        profileImage.kf.indicatorType = .activity
        profileImage.kf.setImage(with: imageURL, placeholder: UIImage(named: "launchImage"), options: [.processor(processor)])
        
        profileImage.tintColor = .gray
        
        // Задание констрейнтов кодом
        NSLayoutConstraint.activate([
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
        ])
    }
    
    /// Метод настройки отображения ФАМИЛИЯ ИМЯ пользователя
    private func nameLabelFunc() {
        nameLabel.textColor = .ypWhiteIOS
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        
        NSLayoutConstraint.activate([
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
        ])
    }
    
    /// Метод настройки отображения названия @пользователя
    private func accountNameFunc() {
        accountName.textColor = .ypGrayIOS
        accountName.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        NSLayoutConstraint.activate([
            accountName.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            accountName.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            accountName.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
        ])
    }
    
    /// Метод настройки отображения статуса пользователя
    private func accountDescriptionFunc() {
        accountDescription.textColor = .ypWhiteIOS
        accountDescription.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        NSLayoutConstraint.activate([
            accountDescription.trailingAnchor.constraint(equalTo: accountName.trailingAnchor),
            accountDescription.leadingAnchor.constraint(equalTo: accountName.leadingAnchor),
            accountDescription.topAnchor.constraint(equalTo: accountName.bottomAnchor, constant: 8)
        ])
    }
    
    /// Метод настройки кнопки выхода
    private func logOutButtonFunc() {
        let logoutButtonImage = UIImage(named: "LogOutImage")
        logoutButton.setImage(logoutButtonImage, for: .normal)
        logoutButton.addTarget(self, action: #selector(tapLogOutButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor)
        ])
    }
    
    
    ///  Функция, выполняемая при нажатии кнопки выхода
    @objc
    private func tapLogOutButton() {
        let alert = UIAlertController(title: "Пока, пока!", message: "Уверены что хотите выйти?", preferredStyle: .alert)
        
        let yesButtonAction = UIAlertAction(title: "Да", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            profileLogOut.logout()
            profileExitTransit()
            print("ВЫ ВЫШЛИ ИЗ ПРОФИЛЯ. ТОКЕН - \(myToken.token ?? "НЕ ИДЕНТИФИЦИИРУЕТСЯ")")
        })
        let noButtonAction = UIAlertAction(title: "Нет", style: .default)
        
        alert.addAction(yesButtonAction)
        alert.addAction(noButtonAction)
        self.present(alert, animated: true, completion: nil)
    }

    /// Функция перехода в экран авторизации при выходе из профиля
    private func profileExitTransit() {
        guard let window = UIApplication.shared.windows.first else { return }
        let finalVC = SplashViewController()
        window.rootViewController = finalVC
        window.makeKeyAndVisible()
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
}

