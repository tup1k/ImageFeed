//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Олег Кор on 04.08.2024.
//

import UIKit

final class ImagesListCell: UITableViewCell {
   
    @IBOutlet weak var cellImage: UIImageView! // Аутлет фото
    @IBOutlet weak var likeButton: UIButton! // Аутлет кнопки like
    @IBOutlet weak var gradientView: UIImageView! // Аутлет градиента
    @IBOutlet weak var dateLabel: UILabel! //Аутлет даты создания фото

    static let reuseIdentifier = "ImagesListCell"
    
    let gradientLayer = CAGradientLayer()
    
    

}
