//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Олег Кор on 25.08.2024.
//

import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize" // ссылка для авторизации на сайте
}

final class WebViewViewController: UIViewController {
    @IBOutlet private var webView: WKWebView! // Аутлет веб-формы
    @IBOutlet weak var progressView: UIProgressView! // Аутлет прогресс-бара
    
    weak var delegate: WebViewViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self // делегирование проверки авторизации (разобраться)
        loadAuthView() // Загрузка авторизации из сервиса Unsplash
        updateProgress()
    }
    
    // Кнопка возврата из окна авторизации сделаная аутлетом
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil)
        updateProgress()
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    
}

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




