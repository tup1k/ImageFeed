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
    private let tokenStorage = OAuth2TokenStorage()
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = tokenStorage.token {
            switchToTabBarController()
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
        
        // Мы проверям наличие токена в сохраненных данных
        UIBlockingProgressHUD.show()
        service.fetchOAuthToken(code) { result in
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let token):
                self.tokenStorage.token = token
                self.switchToTabBarController()
            case .failure(let error):
                print("Ошибка считывания токена: \(error)")
            }
        }
    }
}
