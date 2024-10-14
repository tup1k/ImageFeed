//
//  DateFormater.swift
//  ImageFeed
//
//  Created by Олег Кор on 30.09.2024.
//

import Foundation


class customDateFormat: DateFormatter {
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        //formatter.locale = Locale(identifier: "ru") // Русскоязычная дата
        return formatter
    }()
}

