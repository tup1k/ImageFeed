//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Олег Кор on 30.09.2024.
//

@testable import ImageFeed
import XCTest

final class ImagesListServiceTests: XCTestCase {
    private let tokenStoragePVC = OAuth2TokenStorage()
    
    func testFetchPhotos() {
        let service = ImagesListService.shared
        
        let expectation = self.expectation(description: "Wait for Notification")
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { _ in
                expectation.fulfill()
            }
        
        service.fetchPhotosNextPage()
        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(service.photos.count, 10)
        
        service.fetchPhotosNextPage()
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(service.photos.count, 20)
        print(service.photos.count)
           
        }
    }
