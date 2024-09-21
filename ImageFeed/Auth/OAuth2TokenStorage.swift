//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Олег Кор on 02.09.2024.
//

import Foundation
import SwiftKeychainWrapper

// Класс записывает даные токена в память устройства в UserDefaults
final class OAuth2TokenStorage {
    //private let userData: UserDefaults = .standard // Вводим замену для упрощения
    
    // Параметр - токен
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: "myAuthToken")
            //userData.string(forKey: "token")
        }
        
        set {
            guard let token = newValue else {
                KeychainWrapper.standard.removeObject(forKey: "myAuthToken")
                return
            }
            
            let isSuccess = KeychainWrapper.standard.set(token, forKey: "myAuthToken")
            guard isSuccess else {
                print("Токен не сохранен в keychain")
                return
            }
            //userData.set(newValue, forKey: "token")
        }
    }
}
