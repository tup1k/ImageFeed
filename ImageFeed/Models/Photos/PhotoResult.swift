//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Олег Кор on 03.10.2024.
//

import Foundation

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let width: Int?
    let height: Int?
    let description: String?
    let isLiked: Bool?
    let urls: UrlsResult
    
    private enum CodingKeys : String, CodingKey {
        case id = "id"
        case createdAt = "created_at"
        case width = "width"
        case height = "height"
        case description = "description"
        case isLiked = "liked_by_user"
        case urls = "urls"
    }
}

struct UrlsResult: Decodable {
    let full: String?
    let thumb: String?
    
    private enum CodingKeys : String, CodingKey {
        case full = "full"
        case thumb = "thumb"
    }
}
