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

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
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

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
    
    init(photoResult: PhotoResult) {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        
        self.id = photoResult.id
        self.size = CGSize(width: photoResult.width, height: photoResult.height)
        self.createdAt = formatter.date(from: photoResult.createdAt ?? "nil")
        self.welcomeDescription = photoResult.description
        self.thumbImageURL = photoResult.urls.thumb ?? "nil"
        self.largeImageURL = photoResult.urls.full ?? "nil"
        self.isLiked = photoResult.isLiked ?? false
    }
}

final class ImagesListService {
    private let urlSession = URLSession.shared // Вводим замену для метода URLSession
    private var task: URLSessionTask? // Название созданного запроса JSON в fetchProfile
    private var lastToken: String? // Последнее значение token которое было направлено в запросе
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int? // номер последней скачаной страницы
    
    private var myOwnToken = OAuth2TokenStorage()
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // Синглтон ImageListService
    static let shared = ImagesListService()
    private init () {}
    
    
    func fetchPhotosNextPage(_ token: String, completion: @escaping (Result<[Photo], Error>) -> Void) {
        let token = myOwnToken.token
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        print(nextPage)
        
        assert(Thread.isMainThread) // Проверяем что мы в главном потоке
        // Упрощенная версия кода для отслеживания повторного появления запроса с token
        guard lastToken != token else {
            completion(.failure(ImageServiceError.invalidRequest))
            print("[fetchPhotosNextPage]: [Состояние гонки] - Повторный вызов метода загрузки данных профиля.")
            return
        }
        task?.cancel()
        lastToken = token
        
        guard let newRequest = makeImageRequest(token: token!, page: nextPage) else {
            completion(.failure(ImageServiceError.invalidRequest))
            print("[fetchPhotosNextPage]: [makeImageRequest] - Не удалось сделать сетевой запрос")
            return
        }
        
        let task = urlSession.objectTask(for: newRequest) {[weak self] (result: Result<[PhotoResult], Error>)  in
            guard let self = self else {return}
            
            switch result {
            case .success(let response):
                let photosPage = response.map{ Photo(photoResult: $0) }
                photos.append(contentsOf: photosPage)
                self.photos = photos
                completion(.success(photos))
                self.task = nil
            case .failure(let error):
                completion(.failure(error))
                print("[fetchPhotosNextPage]: [objectTask] - Ошибка загрузки JSON: \(error)")
                self.lastToken = nil
                self.task = nil
            }
        }
       self.task = task
        task.resume()
        //lastLoadedPage += 1
    }
    
    // Метод сборки ссылки для запроса JSON токена авторизации
    private func makeImageRequest(token: String, page: Int) -> URLRequest? {
        guard let url  = URL(string: "https://api.unsplash.com/photos?page=\(page)&&per_page=10") else {
            print("[makeImageRequest]: [URL] Не работает ссылка на профиль")
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url) // Создаем запрос собранной ссылки для получения json с даным
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
