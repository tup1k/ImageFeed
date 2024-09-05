//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Олег Кор on 29.08.2024.
//

import Foundation

// Класс получения токена авторизации
final class OAuth2Service {
    static let shared = OAuth2Service()
    private init () {}
    
    // Метод сборки ссылки для запроса JSON токена авторизации
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var baseURL = URLComponents(string: "https://unsplash.com/oauth/token") else {
            print("Не подгрузилась ссылка на сервис авторизации Unsplash.")
            fatalError()
        }
        
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
            return nil
        }
        
        var request = URLRequest(url: url) // Создаем запрос собранной ссылки для авторизации в мое приложение
        request.httpMethod = "POST"
        return request
    }
    
    // Метод считывания JSON через расширение URLSession и парсинг по структуре responsebody
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let newRequest = makeOAuthTokenRequest(code: code) else {
            print("Не удалось сделать сетевой запрос")
            return
        }
        
        let codeData2 = URLSession.shared.data(for: newRequest) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(response.access_token))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                        print("Ошибка декодирования JSON: \(error)")
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                    print("Ошибка загрузки JSON: \(error)")
                }
            }
        }
        codeData2.resume()
    }
}

