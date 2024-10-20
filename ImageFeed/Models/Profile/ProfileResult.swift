//
//  ProfileResult.swift
//  ImageFeed
//
//  Created by Олег Кор on 20.10.2024.
//

import Foundation

// Структура данных пользователя, запрашиваемых в профиль из JSON
struct ProfileResult: Decodable {
    let userName: String // имя пользователя в системе
    let firstName: String // Настоящее имя пользователя
    let lastName: String? // Настоящая фамилия пользователя
    let bio: String?  // Информация о пользователе
    
    private enum CodingKeys : String, CodingKey {
        case userName = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio = "bio"
    }
}
