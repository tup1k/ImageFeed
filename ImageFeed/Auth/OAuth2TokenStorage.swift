//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Олег Кор on 02.09.2024.
//

import Foundation

// Класс записывает даные токена в память устройства в UserDefaults
final class OAuth2TokenStorage {
    private let userData: UserDefaults = .standard // Вводим замену для упрощения
    
    // Параметр - токен
    var token: String? {
        get {
            userData.string(forKey: "token")
        }
        
        set {
            userData.set(newValue, forKey: "token")
        }
    }
}
