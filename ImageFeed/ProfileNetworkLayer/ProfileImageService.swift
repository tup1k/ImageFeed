//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Олег Кор on 14.09.2024.
//

import Foundation

enum ProfileImageServiceError: Error {
    case invalidRequest
}

struct UserResult: Decodable {
    let profileImage: ProfileImageStruct // имя пользователя в системе
    
    private enum CodingKeys : String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImageStruct: Decodable {
    let smallProfImage: String
    
    private enum CodingKeys : String, CodingKey {
        case smallProfImage = "small"
    }
}

final class ProfileImageService {
    private let urlSession = URLSession.shared // Вводим замену для метода URLSession
    private var task: URLSessionTask? // Название созданного запроса JSON в fetchProfile
    private var lastUsername: String? // Последнее значение username которое было направлено в запросе
    private(set) var avatarURL: String?
    private var profileInfo = ProfileService.shared
    private let tokenStoragePVC = OAuth2TokenStorage()
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
  
    // Синглтон ProfileImageService
    static let shared = ProfileImageService()
    private init () {}
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        
        assert(Thread.isMainThread) // Проверяем что мы в главном потоке
        if lastUsername == username { 
            completion(.failure(ProfileImageServiceError.invalidRequest))
            print("[fetchProfileImageURL]: [Состояние гонки] - Повторный вызов метода загрузки аватара профиля.")
            return}
        
        task?.cancel()
        lastUsername = username
        
        guard let token = tokenStoragePVC.token,
              let username = profileInfo.profile?.userName else { return }
        
        guard let newRequest = makeProfileImageRequest(token: token, username: username) else {
            completion(.failure(ProfileImageServiceError.invalidRequest))
            print("[fetchProfileImageURL]: [makeProfileImageRequest] - Не удалось сделать сетевой запрос")
            return
        }
        
        let task = urlSession.objectTask(for: newRequest) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else {return}
            switch result {
            case .success(let response):
                avatarURL = response.profileImage.smallProfImage
                guard let avatarURL = avatarURL else {return}
                completion(.success(avatarURL))
                // Создаем обозреватель за загрузкой аватара из сети
                NotificationCenter.default.post(name: ProfileImageService.didChangeNotification,
                                                object: self,
                                                userInfo: ["URL": self.avatarURL as Any])
                self.lastUsername = nil
            case .failure(let error):
                    completion(.failure(error))
                    print("[fetchProfileImageURL]: [objectTask] - Ошибка загрузки JSON для URL: \(error)")
                self.lastUsername = nil
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    // Метод сборки ссылки для запроса JSON токена авторизации
    private func makeProfileImageRequest(token: String, username: String) -> URLRequest? {
        
        guard let url  = URL(string: "https://api.unsplash.com/users/\(username)") else {
            print("[makeProfileImageRequest]: [URL] Не работает ссылка на профиль для URL")
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url) // Создаем запрос собранной ссылки для авторизации в мое приложение
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    }
