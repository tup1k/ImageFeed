//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Олег Кор on 07.08.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    private let profileDesign = UIImageView()
    private let nameLabel = UILabel()
    private let accountName = UILabel()
    private let accountDescription = UILabel()
    private let signOutButton = UIButton()
    
    
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
        
        profileDesignFunc() // Вызов функции создания вью профиля
        nameLabelFunc() // Вызов функции создания лейбла ФИО
        accountNameFunc() // Вызов функции создания лейбла с именем аккаунта
        accountDescriptionFunc() // Вызов функции создания статуса аккаунта
        signOutButtonFunc() // Вызов функции создания кнопки выхода из аккаунта
        
    }
    
    // Функция создания вью профиля кодом
    private func profileDesignFunc() {
        let profileImage = UIImage(named: "ProfileImage")
        profileDesign.image = profileImage
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
        nameLabel.text = "Екатерина Новикова"
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
        accountName.text = "@ekaterina_nov"
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
        accountDescription.text = "Hello, World!"
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
