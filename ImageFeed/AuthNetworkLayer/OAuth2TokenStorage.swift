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
    
    // Операции с сохранением/выгрузкой токена из кейчейна
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: "myAuthToken")
        }
        
        set {
            guard let token = newValue else {
                KeychainWrapper.standard.removeObject(forKey: "myAuthToken")
                return
            }
            
            let saveKeychain = KeychainWrapper.standard.set(token, forKey: "myAuthToken")
            guard saveKeychain else {
                print("[OAuth2TokenStorage]:[KeychainWrapper] - Не удалось сохранить токен в keychain")
                return
            }
        }
    }
    
    // Метод очистки токена
    func toCleanToken() {
        KeychainWrapper.standard.removeObject(forKey: "myAuthToken")
    }
}
