//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Олег Кор on 25.08.2024.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    private let webViewIdentificator = "ShowWebView" // Идентификатор сигвэя между стартовым окном и окном авторизации
    
    weak var authDelegate: AuthViewControllerDelegate?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == webViewIdentificator {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else { fatalError("Invalid segue destination") }
            
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            webViewViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        authDelegate?.authViewController(self, didAuthenticateWithCode: code)
    }
    
    // Метод закрытия webView - делегирован для разделения ответственности
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true) // Закрыли WebView по нажатию кнопки
    }
}
