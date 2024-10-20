//
//  ProfileViewPresenterSpy.swift
//  ProfileTest
//
//  Created by Олег Кор on 20.10.2024.
//

@testable import ImageFeed
import Foundation

final class ProfileViewPresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var profileLogOut: Bool = false
    
    func profileExitTransit() {
        profileLogOut = true
    }
    
    
}
