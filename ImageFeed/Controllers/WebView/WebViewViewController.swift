//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Олег Кор on 25.08.2024.
//

import UIKit
import WebKit

public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set}
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

// Протокол определяющий методы делегирования между окном авторизации и окном веб-контента
protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController & WebViewViewControllerProtocol {
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    var presenter: WebViewPresenterProtocol?
    weak var delegate: WebViewViewControllerDelegate? // Создаем делегата для контроллера (разобраться)
    
    @IBOutlet private var webView: WKWebView! // Аутлет веб-формы
    @IBOutlet weak var progressView: UIProgressView! // Аутлет прогресс-бара
    
    // поток загрузки контроллера
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self // навигационный делегат между webview и webviewviewcontroller (разобраться)
        webView.accessibilityIdentifier = "UnsplashWebView"
        presenter?.viewDidload()
//        updateProgress() // Обозреватель за изменением статуса загрузки через прогресс-бар
        
//        estimatedProgressObservation = webView.observe(
//            \.estimatedProgress,
//             options: [],
//             changeHandler: { [weak self] _, _ in
//                 guard let self = self else { return }
//                 self.updateProgress()
//             })
    }
    
    // поток появления контроллера
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    // поток исчезновения контроллера
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
    }
    
    // Кнопка возврата из окна авторизации сделаная аутлетом и делегирующая ответственность
    @IBAction private func didTapBackButton(_ sender: Any) {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            presenter?.didUpdateProgressValue(webView.estimatedProgress)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    func load(request: URLRequest) {
        webView.load(request)
    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
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
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        } else {
            return nil
        }
    }
}
