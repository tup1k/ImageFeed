//
//  ImagesListPresenterSpy.swift
//  ImageFeed
//
//  Created by Олег Кор on 21.10.2024.
//

@testable import ImageFeed
import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var photoList: [Photo] = []
    var viewDidLoadCalled: Bool = false
    var tapedLikeButton: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func updateTableViewAnimated() {
        
    }
    
    func tapLike(indexPath: IndexPath) {
       tapedLikeButton = true
    }
    
    
}
