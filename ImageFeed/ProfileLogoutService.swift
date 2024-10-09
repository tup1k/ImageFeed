//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Олег Кор on 06.10.2024.
//

import Foundation
import WebKit
import UIKit
import Kingfisher

final class ProfileLogoutService {
    private let myToken = OAuth2TokenStorage()
    
    static let shared = ProfileLogoutService()
    private init() { }
    
    func logout() {
        cleanCookies()
        myToken.toCleanToken()
        cleanImageCell()
    }
    
    private func cleanCookies() {
        // Очищаем все куки из хранилища
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // Запрашиваем все данные из локального хранилища
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            // Массив полученных записей удаляем из хранилища
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func cleanImageCell() {
        let cache = ImageCache.default
                cache.clearMemoryCache()
                cache.clearDiskCache()
                cache.cleanExpiredMemoryCache()
                cache.clearCache()
    }
    
    
}
