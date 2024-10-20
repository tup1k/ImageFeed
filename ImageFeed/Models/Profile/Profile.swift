//
//  Profile.swift
//  ImageFeed
//
//  Created by Олег Кор on 20.10.2024.
//

import Foundation

// Структура данных для загрузки на страницу профиля
struct Profile {
    let userName: String // имя пользователя в системе
    let name: String // Имя и фамилия пользователя
    let loginName: String? // @userName
    let bio: String? // Информация о пользователе
}
