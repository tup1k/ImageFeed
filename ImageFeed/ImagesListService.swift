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
    private var lastLoadedPage: Int? = 0// номер последней скачаной страницы
    
    private var myOwnToken = OAuth2TokenStorage()
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // Синглтон ImageListService
    static let shared = ImagesListService()
    private init () {}
    
    
    func fetchPhotosNextPage(_ token: String, completion: @escaping (Result<[Photo], Error>) -> Void) {
        guard let token = myOwnToken.token else { return }
        
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
        
        
        guard let newRequest = makeImageRequest(token: token, page: nextPage) else {
            completion(.failure(ImageServiceError.invalidRequest))
            print("[fetchPhotosNextPage]: [makeImageRequest] - Не удалось сделать сетевой запрос")
            return
        }
        
        let task = urlSession.objectTask(for: newRequest) {[weak self] (result: Result<[PhotoResult], Error>)  in
            
            switch result {
            case .success(let response):
                
                guard let self = self else {return}
                
                let photosPage = response.map{ Photo(photoResult: $0) }
                photos.append(contentsOf: photosPage)
                self.photos = photos
                completion(.success(photos))
                self.task = nil
                NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                self.lastLoadedPage = nextPage
                print(nextPage)
            case .failure(let error):
                completion(.failure(error))
                print("[fetchPhotosNextPage]: [objectTask] - Ошибка загрузки JSON: \(error)")
            }
        }
        self.task = task
        task.resume()
        
    }
    
    // Метод сборки ссылки для запроса JSON токена авторизации
    private func makeImageRequest(token: String, page: Int) -> URLRequest? {
        guard let url  = URL(string: "https://api.unsplash.com/photos?page=\(page)") else {
            print("[makeImageRequest]: [URL] Не работает ссылка на профиль")
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url) // Создаем запрос собранной ссылки для получения json с даным
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
