//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Олег Кор on 29.08.2024.
//

import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

// Класс получения токена авторизации
final class OAuth2Service {
    private let urlSession = URLSession.shared // Вводим замену для метода URLSession
    
    private var task: URLSessionTask? // Название созданного запроса JSON в fetchOAuthToken
    private var lastCode: String? // Последнее значение code которое было направлено в запросе
    
    // Синглтон OAuth2Service
    static let shared = OAuth2Service()
    private init () {}
    
    // Метод считывания JSON через расширение URLSession и парсинг по структуре responsebody
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread) // Проверяем что мы в главном потоке
        // Упрощенная версия кода для отслеживания повторного появления code
        // Если новое значени code совпадает со старым то нет смысла запускать новый запрос
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel() // Выходим из предыдущей задачи
        lastCode = code // Обновили значение lastCode
        
        guard let newRequest = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            print("Не удалось сделать сетевой запрос")
            return
        }
        
        let task = urlSession.objectTask(for: newRequest) {[weak self] (result: Result<OAuthTokenResponseBody, Error>)  in
            guard let self = self else {return}
            
            switch result {
            case .success(let response):
                let myToken = response.accessToken
                        completion(.success(myToken))
                self.task = nil
                self.lastCode = nil
            case .failure(let error):
                    completion(.failure(error))
                    print("Ошибка загрузки JSON: \(error)")
                self.task = nil
                self.lastCode = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    // Метод сборки ссылки для запроса JSON токена авторизации
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var baseURL = URLComponents(string: "https://unsplash.com/oauth/token") else {
            print("Не подгрузилась ссылка на сервис авторизации Unsplash.")
            fatalError()
        }
        
        // Собираем авторизационный код
        baseURL.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        // создаем ссылку со всеми параметрами API
        guard let url = baseURL.url else {
            print("Не собралась общая ссылка авторизации с ключами")
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url) // Создаем запрос собранной ссылки для авторизации в мое приложение
        request.httpMethod = "POST"
        return request
    }
}

