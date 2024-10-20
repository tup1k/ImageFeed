//
//  ImageListPresenter.swift
//  ImageFeed
//
//  Created by Олег Кор on 20.10.2024.
//

import Foundation

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    var photoList: [Photo] {get}
    func viewDidLoad()
    func updateTableViewAnimated()
    func tapLike(indexPath: IndexPath)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    private (set) var photoList: [Photo] = []
    var imagesListServiceObserver: NSObjectProtocol?
    private let imageListService = ImagesListService.shared
    
    /// Метод загружает данные
    func viewDidLoad() {
        UIBlockingProgressHUD.show()
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil, queue: .main) {[weak self] _ in
                guard let self = self else { return }
                self.updateTableViewAnimated()
                UIBlockingProgressHUD.dismiss()
            }
        imageListService.fetchPhotosNextPage()
    }
    
    /// Метод отвечает за анимированное обновление таблицы
    func updateTableViewAnimated() {
        DispatchQueue.main.async {[weak self] in
            guard let self = self else { return }
            let oldCount = photoList.count
            let newCount = imageListService.photos.count
            photoList = imageListService.photos
            if oldCount != newCount {
                view?.importImagesToTable(oldCount: oldCount, newCount: newCount)
            }
        }
    }
    
    /// Метод отвечает за простановку like
    func tapLike(indexPath: IndexPath) {
        let photo = photoList[indexPath.row]
        UIBlockingProgressHUD.show()
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) {[weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.view?.tapedLike(indexPath: indexPath)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                self.view?.showLikeAlert()
            }
        }
    }
}
