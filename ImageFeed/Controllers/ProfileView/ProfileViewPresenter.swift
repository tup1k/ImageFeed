//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Олег Кор on 19.10.2024.
//

import Foundation
import UIKit

protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func profileExitTransit()
}

final class ProfileViewPresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private let profileLogOut = ProfileLogoutService.shared
    private let profileInfoPVC = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        view?.createSubview()
        view?.nameLabelFunc() // Вызов функции параметров отображения ФИО пользователя
        view?.accountNameFunc() // Вызов функции параметров отображения имени @пользователя
        view?.accountDescriptionFunc() // Вызов функции параметров отображения статуса аккаунта
        view?.logOutButtonFunc() // Вызов функции параметров отображения кнопки выхода из аккаунта
        profileImageServiceObserverFunc() // Метод слежение и обновления картинки аватара в профиле
        view?.updateAvatar()
        view?.updateProfileDetails(profile: profileInfoPVC.profile) // Загрузка данных профиля из инета
    }
    
    func profileImageServiceObserverFunc() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            view?.updateAvatar()
        }
    }
    
    func profileExitTransit() {
        profileLogOut.logout()
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
