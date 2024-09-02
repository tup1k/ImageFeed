//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Олег Кор on 02.09.2024.
//

import Foundation

class OAuth2TokenStorage {
    private let userData: UserDefaults = .standard // Вводим замену для упрощения
    
    // Параметр - число сыгранных игр
        var token: String? {
            get {
                userData.string(forKey: "token")
            }
            
            set {
                userData.set(newValue, forKey: "token")
            }
        }
}
