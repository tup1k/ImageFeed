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
    //private let authService = OAuth2Service.shared
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == webViewIdentificator {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else { fatalError("Invalid segue destination") }
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
