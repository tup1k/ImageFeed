//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Олег Кор on 17.10.2024.
//
@testable import ImageFeed
import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testAuth() throws {
        // Нажать кнопку авторизации
        app.buttons["Authenticate"].tap()
        let webView = app.webViews["UnsplashWebView"]
        
        // Подождать, пока экран авторизации открывается и загружается
        XCTAssertTrue(webView.waitForExistence(timeout: 7))
        
        // Ввести данные в форму
        // Вводим логин
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText("o.kozirev@gmail.com")
        XCUIApplication().toolbars.buttons["Done"].tap()
        webView.swipeUp()
        
        // Вводим пароль
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        passwordTextField.tap()
        passwordTextField.typeText("*********")
        XCUIApplication().toolbars.buttons["Done"].tap()
        webView.swipeUp()
        
        // Нажать кнопку логина
        app.buttons["Login"].tap()
        
        // Подождать, пока открывается экран ленты
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
    }
    
    func testFeed() throws {
        // Подождать, пока открывается и загружается экран ленты
        sleep(2)
        let tablesQuery = app.tables
        sleep(4)
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
      
        // Сделать жест «смахивания» вверх по экрану для его скролла
        cell.swipeUp()
        sleep(5)
        
        // Поставить лайк в ячейке верхней картинки
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        cellToLike.buttons["LikeButton"].tap()
        sleep(5)
        
        // Отменить лайк в ячейке верхней картинки
        cellToLike.buttons["LikeButton"].tap()
        sleep(5)
        
        // Нажать на верхнюю ячейку
       cellToLike.tap()
        sleep(5)
        
        // Подождать, пока картинка открывается на весь экран
        let image = app.scrollViews.images.element(boundBy: 0)
        
        // Увеличить картинку
        image.pinch(withScale: 3, velocity: 1)
        
        // Уменьшить картинку
        image.pinch(withScale: 0.5, velocity: -1)
        
        // Вернуться на экран ленты
        let navigationBackButton = app.buttons["navBackButton"]
        navigationBackButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts["Олег Козырев"].exists)
        XCTAssertTrue(app.staticTexts["@tup1k"].exists)
        
        app.buttons["LogOut"].tap()
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}

