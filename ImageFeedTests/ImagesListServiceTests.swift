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
        guard let token = tokenStoragePVC.token else { return }
        let service = ImagesListService.shared
        
        let expectation = self.expectation(description: "Wait for Notification")
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { _ in
                expectation.fulfill()
            }
        
        service.fetchPhotosNextPage(token) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let photos):
                for item in photos {
                    print(item.largeImageURL)
                }
                print(photos.first?.largeImageURL)
            case .failure(let error):
                print("[fetchProfileSVC]: [fetchProfile] - Ошибка загрузки данных в SVC: \(error)")
                break
            }
        }
        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(service.photos.count, 10)
        
        service.fetchPhotosNextPage(token) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let photos):
                for item in photos {
                    print(item.largeImageURL)
                }
                print(photos.first?.largeImageURL)
            case .failure(let error):
                print("[fetchProfileSVC]: [fetchProfile] - Ошибка загрузки данных в SVC: \(error)")
                break
            }
        }
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(service.photos.count, 20)
        print(service.photos.count)
           
        }
    }
