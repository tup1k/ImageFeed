//
//  ImagesListViewTest.swift
//  ImagesListViewTest
//
//  Created by Олег Кор on 20.10.2024.
//
@testable import ImageFeed
import XCTest

final class ImagesListViewTest: XCTestCase {

    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled) // проверка запуска
    }
    
    func testViewControllerTapedLikeButton() {
        // given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.tapLike(indexPath: IndexPath(row: 0, section: 0))
        
        //then
        XCTAssertTrue(presenter.tapedLikeButton) // проверка запуска
    }

}
