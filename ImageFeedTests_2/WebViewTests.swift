//
//  ImageFeedTests_2.swift
//  ImageFeedTests_2
//
//  Created by Олег Кор on 14.10.2024.
//

@testable import ImageFeed
import XCTest

final class ImageFeedTests_2: XCTestCase {

    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewControllerViewDidLoadTest = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        
        let presenterViewDidLoadTest = WebViewPresenterSpy()
        viewControllerViewDidLoadTest.presenter = presenterViewDidLoadTest
        presenterViewDidLoadTest.view = viewControllerViewDidLoadTest
        
        //when
        _ = viewControllerViewDidLoadTest.view
        
        //then
        XCTAssertTrue(presenterViewDidLoadTest.viewDidLoadCalled) // проверка запуска
    }

    func testPresenterCallsLoadRequest() {
        // given
        let presenterLoadRequestTest = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenterLoadRequestTest = WebViewPresenter(authHelper: authHelper)
        viewControllerWebVCTest.presenter = presenterLoadRequestTest
    }
    
}
