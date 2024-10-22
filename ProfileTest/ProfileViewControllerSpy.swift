//
//  ProfileViewControllerSpy.swift
//  ProfileTest
//
//  Created by Олег Кор on 20.10.2024.
//

@testable import ImageFeed
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    
    func createSubview() {
        
    }
    
    func nameLabelFunc() {
       
    }
    
    func accountNameFunc() {
        
    }
    
    func accountDescriptionFunc() {
        
    }
    
    func logOutButtonFunc() {
        
    }
    
    func updateAvatar() {
        
    }
    
    func updateProfileDetails(profile: Profile?) {
        
    }
    
    func logOutProfile() {
       
    }
}
