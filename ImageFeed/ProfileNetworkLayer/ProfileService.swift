//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Олег Кор on 14.09.2024.
//

import UIKit
import Foundation

enum ProfileServiceError: Error {
    case invalidRequest
}

// Структура данных пользователя, запрашиваемых в профиль из JSON
struct ProfileResult: Decodable {
    let userName: String // имя пользователя в системе
    let firstName: String // Настоящее имя пользователя
    let lastName: String? // Настоящая фамилия пользователя
    let bio: String?  // Информация о пользователе
    
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
    let loginName: String? // @userName
    let bio: String? // Информация о пользователе
}

final class ProfileService {
    private let urlSession = URLSession.shared // Вводим замену для метода URLSession
    private var task: URLSessionTask? // Название созданного запроса JSON в fetchProfile
    private var lastToken: String? // Последнее значение token которое было направлено в запросе
    private(set) var profile: Profile? // Хранит данные профиля из api
    
    // Синглтон ProfileService
    static let shared = ProfileService()
    private init () {}
    
    // Метод загрузки данных профиля из JSON
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        
        assert(Thread.isMainThread) // Проверяем что мы в главном потоке
        // Упрощенная версия кода для отслеживания повторного появления запроса с token
        guard lastToken != token else {
            completion(.failure(ProfileServiceError.invalidRequest))
            print("[fetchProfile]: [Состояние гонки] - Повторный вызов метода загрузки данных профиля.")
            return
        }
        task?.cancel()
        lastToken = token
        
        guard let newRequest = makeProfileRequest(token: token) else {
            completion(.failure(ProfileServiceError.invalidRequest))
            print("[fetchProfile]: [makeProfileRequest] - Не удалось сделать сетевой запрос")
            return
        }
        
        let task = urlSession.objectTask(for: newRequest) {[weak self] (result: Result<ProfileResult, Error>)  in
            guard let self = self else {return}
            
            switch result {
            case .success(let response):
                let profile = Profile(userName: "\(response.userName)",
                                      name: "\(response.firstName) " + "\(response.lastName ?? " ")",
                                      loginName: "@\(response.userName)",
                                      bio: "\(response.bio ?? " ")")
                self.profile = profile
                completion(.success(profile))
                self.task = nil
            case .failure(let error):
                completion(.failure(error))
                print("[fetchProfile]: [objectTask] - Ошибка загрузки JSON: \(error)")
                self.lastToken = nil
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    // Метод сборки ссылки для запроса JSON токена авторизации
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url  = URL(string: "https://api.unsplash.com/me/") else {
            print("[makeProfileRequest]: [URL] Не работает ссылка на профиль")
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url) // Создаем запрос собранной ссылки для получения json с даным
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}


