//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Олег Кор on 25.08.2024.
//

import UIKit
import WebKit

// Протокол определяющий методы делегирования между окном авторизации и окном веб-контента
protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

// Ссылка для авторизации на сайте
enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

final class WebViewViewController: UIViewController {
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    weak var delegate: WebViewViewControllerDelegate? // Создаем делегата для контроллера (разобраться)
    
    @IBOutlet private var webView: WKWebView! // Аутлет веб-формы
    @IBOutlet weak var progressView: UIProgressView! // Аутлет прогресс-бара
    
    // поток загрузки контроллера
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self // навигационный делегат между webview и webviewviewcontroller (разобраться)
        loadAuthView() // Загрузка во webView экрана авторизации из сервиса Unsplash
        updateProgress() // Обозреватель за изменением статуса загрузки через прогресс-бар
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self = self else { return }
                 self.updateProgress()
             })
    }
    
    // поток появления контроллера
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // поток исчезновения контроллера
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // Кнопка возврата из окна авторизации сделаная аутлетом и делегирующая ответственность
    @IBAction func didTapBackButton(_ sender: Any) {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    // Метод сбора ссылки и загрузки окна авторизации
    private func loadAuthView() {
        // создаем базовую ссылку страницы авторизации
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            print("Не подгрузилась ссылка на сервис авторизации Unsplash")
            return
        }
        
        // Прописываем в URLQueryItems параметры API необходимые для авторизации в мое приложение
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        // создаем ссылку со всеми параметрами API
        guard let url = urlComponents.url else {
            print("Не собралась общая ссылка авторизации с ключами")
            return
        }
        
        let request = URLRequest(url: url) // Создаем запрос собранной ссылки для авторизации в мое приложение
        webView.load(request) // подгружаем во вебвью наш экран авторизации
    }
    
    // Метод вычисление процентов загрузки прогресс бара
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
}

// Расширение описывает один из методов навигационного делегата позволяющий совершать действия при совпадении параметра code
extension WebViewViewController: WKNavigationDelegate {
    
    // Метод определяющий действия при успешной авторизации
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    // Метод проверяющий успешная авторизация или нет
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
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
