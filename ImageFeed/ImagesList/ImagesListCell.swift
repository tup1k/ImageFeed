//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Олег Кор on 04.08.2024.
//

import UIKit

// Создаем класс кастомной ячейки куда будем закидывать все внутренние аутлеты и слои
final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell" // Создаем идентификатор ячейки
    let gradientLayer = CAGradientLayer() // Создаем слой градиента
    
    @IBOutlet weak var cellImage: UIImageView! // Аутлет фото в ячейке
    @IBOutlet weak var likeButton: UIButton! // Аутлет кнопки like
    @IBOutlet weak var gradientView: UIImageView! // Аутлет градиента
    @IBOutlet weak var dateLabel: UILabel! //Аутлет даты создания фото
}
