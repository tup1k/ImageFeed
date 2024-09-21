//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Олег Кор on 07.08.2024.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private let profileDesign = UIImageView()
    private let nameLabel = UILabel()
    private let accountName = UILabel()
    private let accountDescription = UILabel()
    private let signOutButton = UIButton()
    
    private let profileInfoPVC = ProfileService.shared
    private let profileImagePVC = ProfileImageService.shared
    private let tokenStoragePVC = OAuth2TokenStorage()
    private var profileImageServiceObserver: NSObjectProtocol?
    
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        addObserver()
    }
    
    required init?(coder: NSCoder) {
            super.init(coder: coder)
            addObserver()
        }
    
    deinit {
            removeObserver()
        }
    
    private func addObserver() {
           NotificationCenter.default.addObserver(
               self,
               selector: #selector(updateAvatar(notification:)),
               name: ProfileImageService.didChangeNotification,
               object: nil)
       }
    
    private func removeObserver() {
            NotificationCenter.default.removeObserver(
                self,
                name: ProfileImageService.didChangeNotification,
                object: nil)
        }
    
    
    @objc
        private func updateAvatar(notification: Notification) {
            guard
                isViewLoaded,
                let userInfo = notification.userInfo,
                let profileImageURL = userInfo["URL"] as? String,
                let url = URL(string: profileImageURL)
            else { return }
            
            // TODO [Sprint 11] Обновите аватар, используя Kingfisher
        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        [profileDesign,
         nameLabel,
         accountName,
         accountDescription,
         signOutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        
        nameLabelFunc() // Вызов функции создания лейбла ФИО
        accountNameFunc() // Вызов функции создания лейбла с именем аккаунта
        accountDescriptionFunc() // Вызов функции создания статуса аккаунта
        signOutButtonFunc() // Вызов функции создания кнопки выхода из аккаунта
        
        updateProfileDetails(profile: profileInfoPVC.profile!)
        
  
        profileImageServiceObserver = NotificationCenter.default    // 2
                    .addObserver(
                        forName: ProfileImageService.didChangeNotification, // 3
                        object: nil,                                        // 4
                        queue: .main                                        // 5
                    ) { [weak self] _ in
                        guard let self = self else { return }
                        self.updateAvatar()                                 // 6
                    }
                updateAvatar()
        //profileDesignFunc() // Вызов функции создания вью профиля
    }
    
    private func updateAvatar() {                                   // 8
        guard
            let profileImageURL = profileImagePVC.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        let imageURL = URL(string: profileImageURL)
        profileDesign.kf.setImage(with: imageURL,
                                  placeholder: UIImage(named: "ProfileImage"))
        profileDesign.layer.cornerRadius = 20
        profileDesign.layer.masksToBounds = true
        
        profileDesign.tintColor = .gray
        
        NSLayoutConstraint.activate([
            profileDesign.widthAnchor.constraint(equalToConstant: 70),
            profileDesign.heightAnchor.constraint(equalToConstant: 70),
            profileDesign.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileDesign.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
        ])
        
        print(profileImageURL)
       
        // TODO [Sprint 11] Обновить аватар, используя Kingfisher
    }
    
    // Метод загрузки данных профиля с сайта
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        accountName.text = profile.loginName
        accountDescription.text = profile.bio
    }
    
    // Функция создания вью профиля кодом
    private func profileDesignFunc() {
//       let profileImage = UIImage(named: "ProfileImage")
//        profileDesign.image = profileImage
        profileDesign.tintColor = .gray
        
        NSLayoutConstraint.activate([
            profileDesign.widthAnchor.constraint(equalToConstant: 70),
            profileDesign.heightAnchor.constraint(equalToConstant: 70),
            profileDesign.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileDesign.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
        ])
    }
    
    // Функция создания лейбла с ФИО
    private func nameLabelFunc() {
        //nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .ypWhiteIOS
        nameLabel.font = nameLabel.font.withSize(23)
        
        NSLayoutConstraint.activate([
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameLabel.leadingAnchor.constraint(equalTo: profileDesign.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileDesign.bottomAnchor, constant: 8),
        ])
    }
    
    // Функция создания лейбла с именем аккаунта
    private func accountNameFunc() {
        //accountName.text = "@ekaterina_nov"
        accountName.textColor = .gray
        accountName.font = accountName.font.withSize(13)
        
        NSLayoutConstraint.activate([
            accountName.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            accountName.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            accountName.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
        ])
    }
    
    // Функция создания статуса аккаунта
    private func accountDescriptionFunc() {
        //accountDescription.text = "Hello, World!"
        accountDescription.textColor = .ypWhiteIOS
        accountDescription.font = accountDescription.font.withSize(13)
        
        NSLayoutConstraint.activate([
            accountDescription.trailingAnchor.constraint(equalTo: accountName.trailingAnchor),
            accountDescription.leadingAnchor.constraint(equalTo: accountName.leadingAnchor),
            accountDescription.topAnchor.constraint(equalTo: accountName.bottomAnchor, constant: 8)
        ])
    }
    
    // Функция создания кнопки выхода из аккаунта
    private func signOutButtonFunc() {
        let signOutButtonImage = UIImage(named: "LogOutImage")
        signOutButton.setImage(signOutButtonImage, for: .normal)
        
        NSLayoutConstraint.activate([
            signOutButton.widthAnchor.constraint(equalToConstant: 44),
            signOutButton.heightAnchor.constraint(equalToConstant: 44),
            signOutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            signOutButton.centerYAnchor.constraint(equalTo: profileDesign.centerYAnchor)
        ])
    }
}
