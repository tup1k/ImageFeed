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
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled) // проверка запуска
    }

    func testPresenterCallsLoadRequest() {
        // given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.viewDidload()
        
        //then
        XCTAssertTrue(viewController.loadRequestCalled) // проверка запуска
    }
    
    func testProgressVisibleWhenLessThenOne() {
        // given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //then
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        // given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        //given
        let configuration = AuthConfiguration.standart
        let authHelper = AuthHelper()
        
        //when
        let url = authHelper.authURL()
        
        guard let urlString = url?.absoluteString else {
            XCTFail("AuthURL is nil")
            return
        }
        
        //then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testCodeFromURL() {
        //given
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native") else {
            print("[testCodeFromURL] - Не подгрузилась базовая ссылка авторизации")
            return
        }
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        guard let url = urlComponents.url else {
            print("[testCodeFromURL] - Не собралась ссылка авторизации с параметром code")
            return
        }
        let authHelper = AuthHelper()
        
        //when
        let code = authHelper.code(from: url)
        
        //then
        XCTAssertEqual(code, "test code")
    }
    
}
