//
//  Photo.swift
//  ImageFeed
//
//  Created by Олег Кор on 03.10.2024.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
    let height: Int?
    
    init(photoResult: PhotoResult) {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        
        self.id = photoResult.id
        self.size = CGSize(width: photoResult.width ?? 300, height: photoResult.height ?? 0)
        self.createdAt = formatter.date(from: photoResult.createdAt ?? "nil")
        self.welcomeDescription = photoResult.description
        self.thumbImageURL = photoResult.urls.thumb ?? "nil"
        self.largeImageURL = photoResult.urls.full ?? "nil"
        self.isLiked = photoResult.isLiked ?? false
        self.height = photoResult.height ?? 300
    }
}
