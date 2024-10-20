//
//  ImageListPresenter.swift
//  ImageFeed
//
//  Created by Олег Кор on 20.10.2024.
//

import Foundation

protocol ImagesListPresenterProtocol {
    var view: ImagesViewControllerProtocol? { get set }
    var photoList: [Photo] {get}
    func updateTableViewAnimated()
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesViewControllerProtocol?
    private (set) var photoList: [Photo] = []
    private let imageListService = ImagesListService.shared
    
    
    /// Метод отвечает за анимированное обновление таблицы
    func updateTableViewAnimated() {
        DispatchQueue.main.async {[weak self] in
            guard let self = self else { return }
            let oldCount = photoList.count
            let newCount = imageListService.photos.count
            photoList = imageListService.photos
            if oldCount != newCount {
                view?.importImagesToTable(oldCount: oldCount, newCount: newCount)
                //view?.importImagesToTable(indexPath: indexPaths, updatedArray: self.photoList)
            }
        }
        }
}
