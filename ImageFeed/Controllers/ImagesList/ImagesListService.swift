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

private var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    //formatter.locale = Locale(identifier: "ru") // Русскоязычная дата
    return formatter
}()

final class ImagesListService {
    private let urlSession = URLSession.shared // Вводим замену для метода URLSession
    private var task: URLSessionTask? // Название созданного запроса JSON в fetchProfile
    private var lastToken: String? // Последнее значение token которое было направлено в запросе
    private var lastPage: Int? // Последнее значение token которое было направлено в запросе
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int? // номер последней скачаной страницы
    private var isLiked: Bool = false // Параметр определяющий наличие лайка у фото
    private let formatter = ISO8601DateFormatter()
    
    private var myOwnToken = OAuth2TokenStorage()
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // Синглтон ImageListService
    static let shared = ImagesListService()
    private init () {}
    
    // Конвертер структур
    func convertPhotoStruct(photoResult: [PhotoResult]) {
        let newPhotoArray = photoResult.map { photo in
            return Photo(id: photo.id,
                         size: CGSize(width: photo.width ?? 300, height: photo.height ?? 300),
                         createdAt: formatter.date(from: photo.createdAt ?? " ") ?? Date(),
                         welcomeDescription: photo.description,
                         thumbImageURL: photo.urls.thumb ?? "nil",
                         largeImageURL: photo.urls.full ?? "nil",
                         isLiked: photo.isLiked ?? false)
        }
        self.photos.append(contentsOf: newPhotoArray)
    }
    
    // Метод загрузки фото по API
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        assert(Thread.isMainThread) // Проверяем что мы в главном потоке
        //guard let lastPage != nextPage else {return}
        // Упрощенная версия кода для отслеживания повторного появления запроса с token
        //        guard /*lastToken != token &*/ lastPage != nextPage else {
        //            completion(.failure(ImageServiceError.invalidRequest))
        //            print("[fetchPhotosNextPage]: [Состояние гонки] - Повторный вызов метода загрузки данных профиля.")
        //            return
        //        }
        //        task?.cancel()
        //        lastPage = nextPage
        
        
        guard let newRequest = makeImageRequest(page: nextPage) else {
            print("[fetchPhotosNextPage]: [makeImageRequest] - Не удалось сделать сетевой запрос")
            return
        }
        
        let task = urlSession.objectTask(for: newRequest) {[weak self] (result: Result<[PhotoResult], Error>)  in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                
                self.lastLoadedPage = nextPage
                self.convertPhotoStruct(photoResult: response)
                print(nextPage)
                NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                completion(.success(photos))
            case .failure(let error):
                completion(.failure(error))
                print("[fetchPhotosNextPage]: [objectTask] - Ошибка загрузки JSON: \(error)")
            }
            self.task = nil
        }
        self.task = task
        task.resume()
        
    }
    
    // Метод сборки ссылки для запроса JSON токена авторизации
    private func makeImageRequest(page: Int) -> URLRequest? {
        guard let url  = URL(string: "https://api.unsplash.com/photos?page=\(page)") else {
            print("[makeImageRequest]: [URL] Не работает ссылка на профиль")
            assertionFailure("Failed to create URL")
            return nil
        }
        
        guard let token = myOwnToken.token else { return nil}
        
        var request = URLRequest(url: url) // Создаем запрос собранной ссылки для получения json с даным
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        
        assert(Thread.isMainThread) // Проверяем что мы в главном потоке
        
        guard let newRequest = makeLikePhotosRequest(photoID: photoId, isLiked: isLike) else {
            print("[fetchPhotosNextPage]: [makeImageRequest] - Не удалось сделать сетевой запрос")
            return
        }
        
        let task = urlSession.objectTask(for: newRequest) {[weak self] (result: Result<[PhotoResult], Error>)  in
            guard let self = self else {return}
            
            switch result {
            case .success(let response):
                if let index = self.photos.firstIndex(where: { $0.id == photoId}) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(id: photo.id,
                                         size: photo.size,
                                         createdAt: photo.createdAt,
                                         welcomeDescription: photo.welcomeDescription,
                                         thumbImageURL: photo.thumbImageURL,
                                         largeImageURL: photo.largeImageURL,
                                         isLiked: !photo.isLiked)
                    self.photos[index] = newPhoto
                    completion(.success(()))
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                    
                    self.task = nil
                }
            case .failure(let error):
                completion(.failure(error))
                print("[fetchPhotosNextPage]: [objectTask] - Ошибка загрузки JSON: \(error)")
            }
        }
        self.task = task
        task.resume()
    }
    
    // Метод сборки ссылки для запроса JSON токена авторизации
    private func makeLikePhotosRequest(photoID: String, isLiked: Bool ) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoID)/like") else {
            print("[makeLikePhotosRequest]: [URL] Не работает ссылка на простановку/удаление like")
            assertionFailure("Failed to create URL")
            return nil }
        
        guard let token = myOwnToken.token else { return nil}
        
        var request = URLRequest(url: url) // Создаем запрос собранной ссылки для получения json с даным
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let likeRequest = isLiked ? "POST" : "DELETE"
        request.httpMethod = likeRequest
        return request
    }
}
