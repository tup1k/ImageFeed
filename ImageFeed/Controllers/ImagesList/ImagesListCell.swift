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
    private let isLiked: Bool = false // Параметр определяющий наличие лайка у фото
    weak var delegate: ImagesListCellDelegate?
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Отменяем загрузку, чтобы избежать багов при переиспользовании ячеек
                //fullsizeImageView.kf.cancelDownloadTask()
    }
    
    @IBAction func likeButtonPushed(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func pictureIsLiked(isLiked: Bool) {
        let likeImage = isLiked ? UIImage.likeImageActive : UIImage.likeImageNonactive
        likeButton.setImage(likeImage, for: .normal)
    }
    
}

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
