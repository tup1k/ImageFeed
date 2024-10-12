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
    
    // Параметры ячейки
    func setupCellImage() {
        cellImage.layer.cornerRadius = 16
        cellImage.layer.masksToBounds = true 
    }
    
    // Настройка градиента в нижней части ячейки
    func setupGradientLayer() {
        gradientLayer.frame = gradientView.bounds
        gradientLayer.colors = [UIColor.gradientColor1.cgColor, UIColor.gradientColor2.cgColor] // делаем переход цветов
        gradientView.layer.addSublayer(gradientLayer)
        gradientView.layer.cornerRadius = 16
        gradientView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] // Тут мы определяем что скругление только по нижним углам
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
    
    /// Метод нажатия на кнопку простановки like
    @IBAction private func likeButtonPushed(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    /// Метод простановки like
    func pictureIsLiked(isLiked: Bool) {
        let likeImage = isLiked ? UIImage.likeImageActive : UIImage.likeImageNonactive
        likeButton.setImage(likeImage, for: .normal)
        print("ПРОСТАНОВКА/СНЯТИЕ LIKE - СЕЙЧАС \(isLiked)")
    }
}

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
