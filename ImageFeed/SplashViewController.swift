//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Олег Кор on 03.09.2024.
//

import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthScreen" // Идентификатор сигвэя между стартовым окном и окном авторизации
    private let service = OAuth2Service.shared // Вызов синглтона
    private let profileInfoSVC = ProfileService.shared // Ссылка на класс ProfileService
    private let profileImageSVC = ProfileImageService.shared // Ссылка на класс ProfileImageService

    private let tokenStorageSVC = OAuth2TokenStorage()
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = tokenStorageSVC.token {
            self.fetchProfile(token)
            self.switchToTabBarController()
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            viewController.authDelegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // Метод переключения в экран с тап-баром
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) // Закрыли WebView
//        guard let token = tokenStorageSVC.token else {
//            return
//        }
        
        // Мы проверям наличие токена в сохраненных данных
        UIBlockingProgressHUD.show()
        service.fetchOAuthToken(code) { result in
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let token):
                self.tokenStorageSVC.token = token
                self.switchToTabBarController()
                self.fetchProfile(token)
            case .failure(let error):
                print("Ошибка считывания токена: \(error)")
            }
        }
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileInfoSVC.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success:
                guard let userName = profileInfoSVC.profile?.userName else {return}
                self.profileImageSVC.fetchProfileImageURL(username: userName) {_ in}
                self.switchToTabBarController()
            case .failure(let error):
                print("Ошибка загрузки данных в SVC: \(error)")
                break
            }
        }
    }
}
