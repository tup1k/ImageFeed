//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Олег Кор on 02.09.2024.
//

import Foundation

// Структура данных получаемых при распарсивании JSON
struct OAuthTokenResponseBody: Decodable {
        let access_token: String // токен
}
