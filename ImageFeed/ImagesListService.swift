//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Олег Кор on 27.09.2024.
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
}

final class ImagesListService {
    private (set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    
    // ...
    
    func fetchPhotosNextPage() {
        // ...
    }
}
