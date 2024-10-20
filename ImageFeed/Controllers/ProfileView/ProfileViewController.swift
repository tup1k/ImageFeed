//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Олег Кор on 07.08.2024.
//

import UIKit
import Kingfisher
import SwiftKeychainWrapper

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set}
    func createSubview()
    func nameLabelFunc() // Вызов функции параметров отображения ФИО пользователя
    func accountNameFunc() // Вызов функции параметров отображения имени @пользователя
    func accountDescriptionFunc() // Вызов функции параметров отображения статуса аккаунта
    func logOutButtonFunc() // Вызов функции параметров отображения кнопки выхода из аккаунта
    func updateAvatar()
    func updateProfileDetails(profile: Profile?)
    func logOutProfile()
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
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
    
    var presenter: ProfilePresenterProtocol?
    var profilePresenter = ProfileViewPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePresenter.view = self
        profilePresenter.viewDidLoad()
    }
    
    /// Метод создание сабвью для всех элементов контроллера профиля
    func createSubview() {
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
    func updateProfileDetails(profile: Profile?) {
        guard let profile = profileInfoPVC.profile else { return }
        nameLabel.text = profile.name
        accountName.text = profile.loginName
        accountDescription.text = profile.bio
    }
    
    /// Метод загрузки аватара из api unsplash
    func updateAvatar() {
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
    func nameLabelFunc() {
        nameLabel.textColor = .ypWhiteIOS
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        
        NSLayoutConstraint.activate([
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
        ])
    }
    
    /// Метод настройки отображения названия @пользователя
    func accountNameFunc() {
        accountName.textColor = .ypGrayIOS
        accountName.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        NSLayoutConstraint.activate([
            accountName.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            accountName.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            accountName.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
        ])
    }
    
    /// Метод настройки отображения статуса пользователя
    func accountDescriptionFunc() {
        accountDescription.textColor = .ypWhiteIOS
        accountDescription.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        NSLayoutConstraint.activate([
            accountDescription.trailingAnchor.constraint(equalTo: accountName.trailingAnchor),
            accountDescription.leadingAnchor.constraint(equalTo: accountName.leadingAnchor),
            accountDescription.topAnchor.constraint(equalTo: accountName.bottomAnchor, constant: 8)
        ])
    }
    
    /// Метод настройки кнопки выхода
    func logOutButtonFunc() {
        let logoutButtonImage = UIImage(named: "LogOutImage")
        logoutButton.accessibilityIdentifier = "LogOut"
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
            logOutProfile()
            print("ВЫ ВЫШЛИ ИЗ ПРОФИЛЯ. ТОКЕН - \(myToken.token ?? "НЕ ИДЕНТИФИЦИИРУЕТСЯ")")
        })
        let noButtonAction = UIAlertAction(title: "Нет", style: .default)
        
        alert.addAction(yesButtonAction)
        alert.addAction(noButtonAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func logOutProfile() {
        profilePresenter.profileExitTransit()
    }
}

