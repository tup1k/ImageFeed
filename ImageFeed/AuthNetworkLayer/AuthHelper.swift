//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Олег Кор on 14.10.2024.
//

import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

final class AuthHelper: AuthHelperProtocol {
    let configuration: AuthConfiguration
    
    init(configuration: AuthConfiguration = .standart) {
        self.configuration = configuration
    }
    
    func authRequest() -> URLRequest? {
        guard let url = authURL() else { return nil}
        
        return URLRequest(url: url)
    }
    
    func authURL() -> URL? {
        // создаем базовую ссылку страницы авторизации
        guard var urlComponents = URLComponents(string: configuration.authURLString) else {
            print("Не подгрузилась ссылка на сервис авторизации Unsplash")
            return nil
        }
        
        // Прописываем в URLQueryItems параметры API необходимые для авторизации в мое приложение
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope)
        ]
        
        return urlComponents.url
    }
    
    func code(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code"})
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
