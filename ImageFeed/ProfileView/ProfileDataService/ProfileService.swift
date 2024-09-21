//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Олег Кор on 14.09.2024.
//

import UIKit
import Foundation

// Структура данных пользователя, запрашиваемых в профиль из JSON
struct ProfileResult: Codable {
    let userName: String // имя пользователя в системе
    let firstName: String // Настоящее имя пользователя
    let lastName: String // Настоящая фамилия пользователя
    let bio: String // Информация о пользователе
    
    private enum CodingKeys : String, CodingKey {
        case userName = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio = "bio"
    }
}

// Структура данных для загрузки на страницу профиля
struct Profile {
    let userName: String // имя пользователя в системе
    let name: String // Имя и фамилия пользователя
    let loginName: String // @userName
    let bio: String // Информация о пользователе
}

final class ProfileService {
    private let urlSession = URLSession.shared // Вводим замену для метода URLSession
    private var task: URLSessionTask? // Название созданного запроса JSON в fetchProfile
    private var lastToken: String? // Последнее значение token которое было направлено в запросе
    private(set) var profile: Profile?
    
    static let shared = ProfileService()
    private init () {}
    
    // Метод загрузки данных профиля из JSON
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        
        assert(Thread.isMainThread) // Проверяем что мы в главном потоке
        // Упрощенная версия кода для отслеживания повторного появления запроса с token
        guard lastToken != token else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastToken = token
        
        guard let newRequest = makeProfileRequest(token: token) else {
            completion(.failure(AuthServiceError.invalidRequest))
            print("Не удалось сделать сетевой запрос")
            return
        }
        
        let task = urlSession.data(for: newRequest) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(ProfileResult.self, from: data)
                    // TODO - проверка если каких-то данных нет
                    DispatchQueue.main.async {
                        let profile = Profile(userName: "\(response.userName)", name: "\(response.firstName) \(response.lastName)", loginName: "@\(response.userName)", bio: "\(response.bio)")
                        self.profile = profile
                        completion(.success(profile))
                        self.task = nil
                        self.lastToken = nil
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                        print("Ошибка декодирования JSON: \(error)")
                        self.task = nil
                        self.lastToken = nil
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                    print("Ошибка загрузки JSON: \(error)")
                    self.task = nil
                    self.lastToken = nil
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    // Метод сборки ссылки для запроса JSON токена авторизации
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url  = URL(string: "https://api.unsplash.com/me/") else {
            print("Не работает ссылка на профиль")
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url) // Создаем запрос собранной ссылки для получения json с даным
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}


