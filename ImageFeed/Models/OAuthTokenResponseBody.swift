//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Олег Кор on 02.09.2024.
//

import Foundation

// Структура данных получаемых при распарсивании JSON
struct OAuthTokenResponseBody: Decodable {
    let accessToken: String // токен
    
    private enum CodingKeys : String, CodingKey {
        case accessToken = "access_token"
    }
    
}
