//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Олег Кор on 06.10.2024.
//

import Foundation
import WebKit
import UIKit
import SwiftKeychainWrapper

final class ProfileLogoutService {
    private let tokenStoragePLS = OAuth2TokenStorage()
    
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    func logout() {
        cleanCookies()
        tokenStoragePLS.toCleanToken()
        switchToSplashScreen()
    }
    
    func switchToSplashScreen() {
//        let window = UIWindow(frame: UIScreen.main.bounds)
//        var navVC = UINavigationController()
//        var yourVC = SplashViewController()
//        navVC.viewControllers = [yourVC]
//       window.rootViewController = navVC
//        window.makeKeyAndVisible()
        
//        // Получаем текущее окно приложения
//               guard let window = UIApplication.shared.windows.first else {
//                   print("Не удалось получить главное окно.")
//                   return
//               }
//               
//               // Создаем экземпляр SplashViewController программно
//               let splashViewController = SplashViewController()
//               
//               // Устанавливаем его как rootViewController с анимацией
//               window.rootViewController = splashViewController
//               UIView.transition(with: window,
//                                 duration: 0.3,
//                                 options: .transitionCrossDissolve,
//                                 animations: nil,
//                                 completion: nil)
    }
    
    private func cleanCookies() {
        // Очищаем все куки из хранилища
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // Запрашиваем все данные из локального хранилища
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            // Массив полученных записей удаляем из хранилища
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    
}
