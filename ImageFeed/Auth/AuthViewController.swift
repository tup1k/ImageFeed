//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Олег Кор on 25.08.2024.
//

import UIKit

final class AuthViewController: UIViewController {
    
    private let authService = OAuth2Service()
    
    private let webViewIdentificator = "ShowWebView" // Идентификатор сигвэя между стартовым окном и окном авторизации
    
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
        authService.fetchOAuthToken(code) { result in
            switch result {
            case .success(let token):
                OAuth2TokenStorage().token = token
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
    
    
}
