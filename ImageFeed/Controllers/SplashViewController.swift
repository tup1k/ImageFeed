//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Олег Кор on 03.09.2024.
//

import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    private let splashLogo = UIImageView() //Создаем вью картинки SplashViewController
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthScreen" // Идентификатор сигвэя между стартовым окном и окном авторизации
    private let service = OAuth2Service.shared // Вызов синглтона авторизации
    private let profileInfoSVC = ProfileService.shared // Вызов синглтона загрузки данных профиля
    private let profileImageSVC = ProfileImageService.shared // Вызов синглтона загрузки аватарки
    private let tokenStorageSVC = OAuth2TokenStorage() // Создаем экземпляр хранилища токена
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSplashLogo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // !!!!! Ключевое место авторизации - если есть токен сразу переходим к считыванию данных API
        if let token = tokenStorageSVC.token {
            self.fetchProfileSVC(token)
        } else {
            switchToAuthViewController()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    // Метод перехода в окно авторизации вместо сигвея
    private func switchToAuthViewController() {
        guard let authViewController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(identifier: "AuthViewController") as? AuthViewController else {return}
        authViewController.authDelegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    // Метод переключения в экран с тап-баром
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            print("[switchToTabBarController]: Некорректная конфигурация окна")
            assertionFailure("Invalid window configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    // Метод добавления логотипа кодом
    private func addSplashLogo() {
        splashLogo.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(splashLogo)
        
        let splashLogoImage = UIImage(named: "launchImage")
        splashLogo.image = splashLogoImage
        
        view.backgroundColor = .ypBlackIOS
        
        NSLayoutConstraint.activate([
            splashLogo.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            splashLogo.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        //vc.dismiss(animated: true) // Закрыли WebView
        vc.presentingViewController?.dismiss(animated: true)
        UIBlockingProgressHUD.show() // Заблокировали кнопки показом анимации
        
        service.fetchOAuthToken(code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else {return}
            switch result {
            case .success(let token):
                tokenStorageSVC.token = token // Записали полученный токен в хранилище
                fetchProfileSVC(token) // загрузили данные профиля через api
            case .failure(let error):
                print("[authViewController]: [fetchOAuthToken] - Ошибка считывания токена: \(error)")
                showAlert()
            }
        }
    }
    
    private func fetchProfileSVC(_ token: String) {
        UIBlockingProgressHUD.show()
        profileInfoSVC.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else {return}
            switch result {
            case .success:
                guard let userName = profileInfoSVC.profile?.userName else {return}
                profileImageSVC.fetchProfileImageURL(username: userName) {_ in}
                switchToTabBarController()
            case .failure(let error):
                print("[fetchProfileSVC]: [fetchProfile] - Ошибка загрузки данных в SVC: \(error)")
                break
            }
        }
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: "Что-то пошло не так(", // заголовок всплывающего окна
                                      message: "Не удалось войти в систему", // текст во всплывающем окне
                                      preferredStyle: .alert) // preferredStyle может быть .alert или .actionSheet

        let action = UIAlertAction(title: "OK", style: .default) { _ in
          print("OK button is clicked!")
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
}
