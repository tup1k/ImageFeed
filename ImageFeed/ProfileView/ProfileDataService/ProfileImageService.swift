//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Олег Кор on 14.09.2024.
//

import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImageStruct // имя пользователя в системе
    
    private enum CodingKeys : String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImageStruct: Codable {
    let smallProfImage: String
    
    private enum CodingKeys : String, CodingKey {
        case smallProfImage = "small"
    }
}

final class ProfileImageService {
    private let urlSession = URLSession.shared // Вводим замену для метода URLSession
    private var task: URLSessionTask? // Название созданного запроса JSON в fetchProfile
    private var lastUsername: String? // Последнее значение token которое было направлено в запросе
    private(set) var avatarURL: String?
    private var profileInfo = ProfileService.shared
    private let tokenStoragePVC = OAuth2TokenStorage()
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
  
    static let shared = ProfileImageService()
    private init () {}
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
      
        assert(Thread.isMainThread) // Проверяем что мы в главном потоке
        // Упрощенная версия кода для отслеживания повторного появления запроса с username
        guard lastUsername != username else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastUsername = username
        
        guard let newRequest = makeProfileImageRequest(token: tokenStoragePVC.token!, username: profileInfo.profile!.userName) else {
            completion(.failure(AuthServiceError.invalidRequest))
            print("Не удалось сделать сетевой запрос для URL")
            return
        }
        let task = urlSession.data(for: newRequest) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(UserResult.self, from: data)
                    // TODO - проверка если каких-то данных нет
                    DispatchQueue.main.async {
                        let smallImage = response.profileImage.smallProfImage
                        self.avatarURL = smallImage
                        completion(.success(self.avatarURL!))
//                        self.task = nil
//                        self.lastUsername = nil
                        
                        NotificationCenter.default
                            .post(
                                name: ProfileImageService.didChangeNotification,
                                object: self,
                                userInfo: ["URL": self.avatarURL as Any])
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                        print("Ошибка декодирования JSON для URL: \(error)")
//                        self.task = nil
//                        self.lastUsername = nil
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                    print("Ошибка загрузки JSON для URL: \(error)")
//                    self.task = nil
//                    self.lastUsername = nil
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    // Метод сборки ссылки для запроса JSON токена авторизации
    private func makeProfileImageRequest(token: String, username: String) -> URLRequest? {
        
        guard let url  = URL(string: "https://api.unsplash.com/users/\(username)") else {
            print("Не работает ссылка на профиль для URL")
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url) // Создаем запрос собранной ссылки для авторизации в мое приложение
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    }

