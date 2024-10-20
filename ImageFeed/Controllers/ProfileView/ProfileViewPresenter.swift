//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Олег Кор on 19.10.2024.
//

import Foundation
import UIKit

public protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func profileExitTransit()
}

final class ProfileViewPresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private let profileLogOut = ProfileLogoutService.shared
    
    
    func profileExitTransit() {
        profileLogOut.logout()
        guard let window = UIApplication.shared.windows.first else { return }
        let finalVC = SplashViewController()
        window.rootViewController = finalVC
        window.makeKeyAndVisible()
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
    
}
