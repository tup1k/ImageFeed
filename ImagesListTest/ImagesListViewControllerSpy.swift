//
//  ImagesListViewControllerSpy.swift
//  ImageFeed
//
//  Created by Олег Кор on 21.10.2024.
//

@testable import ImageFeed
import Foundation

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    var photoList: [Photo] = []
    
    func importImagesToTable(oldCount: Int, newCount: Int) {
        
    }
    
    func tapedLike(indexPath: IndexPath) {
        
    }
    
    func showLikeAlert() {
        
    }
    
    
}
