//
//  URLSession+data_.swift
//  ImageFeed
//
//  Created by Олег Кор on 03.09.2024.
//

import Foundation

enum NetworkError: Error {  // 1
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

// Добавляем для класса URLSession метод считывания ответа сервера
extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        
        let fulfillCompletionOnTheMainThread: (Result<T, Error>) -> Void = { result in  // 2
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let urlSession = URLSession.shared
        
        let task = urlSession.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    do {
                        let decoder = JSONDecoder()
                        let response = try decoder.decode(T.self, from: data)
                        
                        fulfillCompletionOnTheMainThread(.success(response)) // 3
                    } catch {
                        fulfillCompletionOnTheMainThread(.failure(error))
                        print("Ошибка декодирования: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                    }
                } else {
                    print("Некорректный статус-код ответа сервера: \(NetworkError.httpStatusCode(statusCode))")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                print("Ошибка запроса: \(NetworkError.urlRequestError(error))")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error))) // 5
            } else {
                print("Ошибка сессии: \(NetworkError.urlSessionError)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError)) // 6
            }
        })
        return task
    }
}
