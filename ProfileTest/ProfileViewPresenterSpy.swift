//
//  ProfileViewPresenterSpy.swift
//  ProfileTest
//
//  Created by Олег Кор on 20.10.2024.
//

@testable import ImageFeed
import Foundation

final class ProfileViewPresenterSpy: ProfilePresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: ProfileViewControllerProtocol?
    var profileLogOut: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func profileExitTransit() {
        profileLogOut = true
    }
    
    
}
