//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Олег Кор on 29.08.2024.
//

import Foundation

final class OAuth2Service {
    
    func makeOAuthTokenRequest(code: String) -> URLRequest {
        guard var baseURL = URLComponents(string: "https://unsplash.com/oauth/token") else {
            print("Не подгрузилась ссылка на сервис авторизации Unsplash")
            fatalError()
        }
        
        baseURL.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")]
        
        // создаем ссылку со всеми параметрами API
        guard let url = baseURL.url else {
            print("Не собралась общая ссылка авторизации с ключами")
            fatalError()
        }
        
        var request = URLRequest(url: url) // Создаем запрос собранной ссылки для авторизации в мое приложение
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let newRequest = makeOAuthTokenRequest(code: code)
        let codeData2 = URLSession.shared.data(for: newRequest) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(response.access_token)) // TODO [Sprint 10]
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

