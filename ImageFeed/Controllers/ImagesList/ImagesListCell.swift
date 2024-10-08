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
    private let gradientLayer = CAGradientLayer() // Создаем слой градиента
    
    @IBOutlet weak var cellImage: UIImageView! // Аутлет фото в ячейке
    @IBOutlet weak var likeButton: UIButton! // Аутлет кнопки like
    @IBOutlet weak var gradientView: UIImageView! // Аутлет градиента
    @IBOutlet weak var dateLabel: UILabel! //Аутлет даты создания фото
    
    func setupCellImage() {
        cellImage.layer.cornerRadius = 16 // Сделали скругление всех углов фотки (дублирование сториборда на всякий случай)
        cellImage.layer.masksToBounds = true // Сделали обрезание всех подслоев фотки под радиус (дублирование сториборда на всякий случай)
    }
    
    // Настройка слоя градинта (инкапсулированная)
    func setupGradientLayer() {
        // Создание градиента внизу каждого фото
        gradientLayer.frame = gradientView.bounds
        gradientLayer.colors = [UIColor.gradientColor1.cgColor, UIColor.gradientColor2.cgColor] // делаем переход цветов
        gradientView.layer.addSublayer(gradientLayer)
        gradientView.layer.cornerRadius = 16 // Делаем скругление радиусов поля градиента (обязательно дополнение про нижние углы)
        gradientView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] // Тут мы определяем что скругление только по нижним углам
        
    }
    
}
