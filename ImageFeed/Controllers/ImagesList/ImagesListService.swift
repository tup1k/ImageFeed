//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Олег Кор on 27.09.2024.
//

import Foundation

enum ImageServiceError: Error {
    case invalidRequest
}

final class ImagesListService {
    private let urlSession = URLSession.shared // Вводим замену для метода URLSession
    private var task: URLSessionTask? // Название созданного запроса JSON в fetchProfile
    private (set) var photos: [Photo] = [] // Массив фото для передачи в ленту
    private var lastLoadedPage: Int? // номер последней скачаной страницы
    private var isLiked: Bool = false // Параметр определяющий наличие лайка у фото
    private let formatter = ISO8601DateFormatter()
    
    private var tokenStorage = OAuth2TokenStorage()
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // Синглтон ImageListService
    static let shared = ImagesListService()
    private init () {}
    
    /// Конвертер структур с обновлением массива
    /// - Параметры: Конвертирует из [PhotoResult] в [Photo]
    private func convertPhotoStruct(photoResult: [PhotoResult]) {
        let newPhotoArray = photoResult.map { photo in
            return Photo(id: photo.id,
                         size: CGSize(width: photo.width ?? 300, height: photo.height ?? 300),
                         createdAt: formatter.date(from: photo.createdAt ?? " "),
                         welcomeDescription: photo.description,
                         thumbImageURL: photo.urls.thumb ?? "nil",
                         largeImageURL: photo.urls.full ?? "nil",
                         isLiked: photo.isLiked ?? false)
        }
        self.photos.append(contentsOf: newPhotoArray)
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
    }
    
    // MARK: Сетевой слой загрузки фото по API
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread) // Проверяем что мы в главном потоке
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        print("ПРОВЕРКА ИЗМЕНЕНИЯ СТРАНИЦ - loaded page: \(nextPage)")
        
        if task != nil {
            print("[fetchPhotosNextPage] - ЗАГРУЗКА ФОТО УЖЕ ВЫПОЛНЯЕТСЯ")
            return
        }
        
        guard nextPage != lastLoadedPage else {
            print("[fetchPhotosNextPage] - ЭТА СТРАНИЦА УЖЕ ЗАГРУЖЕНА. СТРАНИЦА: \(nextPage)")
            return }
        
        guard let newRequest = makeImageDataRequest(page: nextPage) else {
            print("[fetchPhotosNextPage]: [makeImageRequest] - Не удалось сделать сетевой запрос для загрузки фото.")
            return
        }
        
        let task = urlSession.objectTask(for: newRequest) {[weak self] (result: Result<[PhotoResult], Error>)  in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.lastLoadedPage = nextPage
                self.convertPhotoStruct(photoResult: response)
                NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self, userInfo: ["photos": self.photos])
                print("ЗАГРУЗИЛИ ФОТО ДЛЯ СТРАНИЦЫ: \(lastLoadedPage ?? 0)")
            case .failure(let error):
                print("[fetchPhotosNextPage]: [objectTask] - Ошибка загрузки JSON: \(error)")
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    /// Метод сборки ссылки для запроса JSON токена авторизации
    /// - Параметры: page - номер загружаемой страницы с фото (из расчета 10 фото на странице)
    private func makeImageDataRequest(page: Int) -> URLRequest? {
        guard let url  = URL(string: "https://api.unsplash.com/photos?page=\(page)&per_page=10") else {
            print("[makeImageDataRequest]: [URL] Не работает ссылка на загрузку фото")
            assertionFailure("Failed to create URL")
            return nil
        }
        
        guard let token = tokenStorage.token else { 
            print("[makeImageDataRequest] - НЕ ЗАГРУЖЕН ТОКЕН ПОЛЬЗОВАТЕЛЯ")
            return nil}
        
        var request = URLRequest(url: url) // Создаем запрос собранной ссылки для получения json с даным
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    /// Метод сборки ссылки для установки/удаления like
    /// - Параметры: photoID - номер фото; isLiked - поставлен/снят like
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread) // Проверяем что мы в главном потоке
        
        guard let newRequest = makeLikePhotosRequest(photoID: photoId, isLiked: isLike) else {
            print("[changeLike]: [makeLikePhotosRequest] - Не удалось сделать сетевой запрос для установки like")
            return
        }
        
        let task = urlSession.objectTask(for: newRequest) {[weak self] (result: Result<LikeStruct, Error>)  in
            guard let self = self else {return}
            
            switch result {
            case .success:
                if let index = self.photos.firstIndex(where: { $0.id == photoId}) {
                    let photo = self.photos[index]
                    print(photo.id)
                    
                    let newPhoto = Photo(id: photo.id,
                                         size: photo.size,
                                         createdAt: photo.createdAt,
                                         welcomeDescription: photo.welcomeDescription,
                                         thumbImageURL: photo.thumbImageURL,
                                         largeImageURL: photo.largeImageURL,
                                         isLiked: !photo.isLiked)
                    self.photos[index] = newPhoto
                    
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                    print("[changeLike]: [objectTask] - ЗНАЧЕНИЕ LIKE БЫЛО ИЗМЕНЕНО")
                }
                completion(.success(()))
                
            case .failure(let error):
                completion(.failure(error))
                print("[changeLike]: [objectTask] - Ошибка загрузки JSON: \(error)")
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    // Метод сборки ссылки для запроса JSON токена авторизации
    private func makeLikePhotosRequest(photoID: String, isLiked: Bool ) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoID)/like") else {
            print("[makeLikePhotosRequest]: [URL] - Не работает ссылка на простановку/удаление like")
            assertionFailure("Failed to create URL")
            return nil }
        
        guard let token = tokenStorage.token else { 
            print("[makeLikePhotosRequest] - НЕ ЗАГРУЖЕН ТОКЕН ПОЛЬЗОВАТЕЛЯ")
            return nil}
        
        var request = URLRequest(url: url) // Создаем запрос собранной ссылки для получения json с даным
        let likeRequestMethod = isLiked ? "POST" : "DELETE"
        request.httpMethod = likeRequestMethod
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
