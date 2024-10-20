//
//  ProfileTest.swift
//  ProfileTest
//
//  Created by Олег Кор on 20.10.2024.
//
@testable import ImageFeed
import XCTest

final class ProfileTest: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
//        // given
//        let viewController = ProfileViewController()
//        let presenter = ProfileViewPresenterSpy()
//        viewController.presenter = presenter
//        presenter.view = viewController
//        
//        //when
//        presenter.
//        
//        //then
//        XCTAssertTrue(presenter.viewDidLoadCalled) // проверка запуска
    }

    func testViewControllerCallslogOut() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.profileExitTransit()
        
        //then
        XCTAssertTrue(presenter.profileLogOut) // проверка запуска
    }
    

}
