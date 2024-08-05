//
//  ViewController.swift
//  ImageFeed
//
//  Created by Олег Кор on 01.08.2024.
//

import UIKit

class ImagesListViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{"\($0)"}
    
    // Формат даты
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //tableView.rowHeight = 200 // Высота ячейка равна 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        
        guard let newImage = UIImage(named: photosName[indexPath.row]) else { return } // Проверяем наличие фото
        
        cell.cellImage.image = newImage // Присваиваем фото по номерам из массива
        
        cell.dateLabel.text = dateFormatter.string(from: Date()) // Присваиваем дату в нужном формате
        
        if indexPath.row % 2 == 0 {
            cell.likeButton.setImage(UIImage(named: "LikeImageNonactive") , for: .normal)
        } else {
            cell.likeButton.setImage(UIImage(named: "LikeImageActive"), for: .normal)
        }
       
        
        // Создание градиента внизу каждого фото
        cell.gradientLayer.frame = cell.gradientView.bounds
       // cell.gradientLayer.colors = [UIColor.red.cgColor, UIColor.blue.cgColor]
        cell.gradientLayer.colors = [UIColor(named: "GradientColor_1")?.cgColor ?? UIColor.white.cgColor, UIColor(named: "YP Red (iOS)")?.cgColor ?? UIColor.black.cgColor]
        cell.gradientView.layer.addSublayer(cell.gradientLayer)
       
        //cell.gradientView.layer.cornerRadius = 16
        //cell.gradientView.layer.clipsToBounds = true
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let newImage = UIImage(named: photosName[indexPath.row]) else { return 0} // Проверяем наличие фото
        let imageDynamicWidth = tableView.bounds.width - 16 - 16
        let scale = imageDynamicWidth/newImage.size.width
        let imageDinamicHeight = newImage.size.height * scale + 4 + 4
        return imageDinamicHeight
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imagesListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imagesListCell, with: indexPath)
        
        return imagesListCell
    }
}

