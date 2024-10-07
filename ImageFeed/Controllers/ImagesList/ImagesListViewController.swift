//
//  ViewController.swift
//  ImageFeed
//
//  Created by Олег Кор on 01.08.2024.
//
// Все комментарии пишутся в первую очередь для запоминания последовательности формирования приложения

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    @IBOutlet private var tableView: UITableView! // Создаем аутлет таблицы
    
//    private let photosName: [String] = Array(0..<20).map{"\($0)"} //Формируем текстовой массив из преобразованных чисел
    private var photosName: [Photo] = []
    private let photosImportService = ImagesListService.shared
    private let tokenStorageILC = OAuth2TokenStorage()
    private let imagesListService = ImagesListService.shared
    
    // Вводим переменную форматирующую дату создания фото
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru") // Русскоязычная дата
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        photosImportService.fetchPhotosNextPage() { result in
            switch result {
            case .success(let photos):
                self.tableView.reloadData()
                print(self.tokenStorageILC.token)
            case .failure(let error):
                print("[photosImportService]: [fetchPhotosNextPage] - Ошибка загрузки данных в SVC: \(error)")
                break
            }
        }
    }
    
    
    // Метод конфигурации внутренностей ячейки - картинки, кнопки, текст
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let newImage = photosImportService.photos[indexPath.row]
        
        cell.cellImage.kf.setImage(with: URL(string: newImage.largeImageURL)) // Присваиваем его аутлету фотографий
        cell.dateLabel.text = dateFormatter.string(from: newImage.createdAt ?? Date()) // Присваиваем дату в нужном формате аутлету даты
        print(newImage.createdAt)
        // Присваиваем кнопке картинку нажатого/ненажатого лайк из условия четности фото
        let oddImage = indexPath.row % 2 == 0
//        let likeImage = oddImage ? UIImage.likeImageNonactive : UIImage.likeImageActive
//        let likeImage = newImage.isLiked ? UIImage.likeImageActive : UIImage.likeImageNonactive
//        print(newImage.isLiked)
//        cell.likeButton.setImage(likeImage, for: .normal)
        cell.pictureIsLiked(isLiked: photosImportService.photos[indexPath.row].isLiked)
        
        // Скругление фото и области градиента
        cell.setupCellImage()
        cell.setupGradientLayer() // вызываем инкапсулированную функцию свойств градиента
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            let fullImageURL = URL(string: photosImportService.photos[indexPath.row].largeImageURL)
            viewController.fullImageURL = fullImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // Метод загрузки фото в ячейки
    func tableView(_ tableView: UITableView, 
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        let photos = photosImportService.photos
        guard indexPath.row + 1 == photos.count else {return}
        
        photosImportService.fetchPhotosNextPage() { result in
            switch result {
            case .success(let photos):
                self.tableView.reloadData()
            case .failure(let error):
                print("[photosImportService]: [fetchPhotosNextPage] - Ошибка загрузки данных в SVC: \(error)")
                break
            }
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    // Метод, отвечающий за действия при нажатии на фото
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    // Метод отвечающий за подгон размеров картинки в ячейке
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let newImage = photosImportService.photos[indexPath.row]
        let imageDynamicWidth = tableView.bounds.width - 16 - 16
        let scale = imageDynamicWidth/newImage.size.width
        let imageDinamicHeight = newImage.size.height * scale + 4 + 4
        return imageDinamicHeight
    }
}

extension ImagesListViewController: UITableViewDataSource {
    
    // Метод определяет количество ячеек в секции таблицы - пока равно числу мок-овских фоток
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return photosName.count
        return photosImportService.photos.count
    }
    
    // Метод возвращает данные ячейкм
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) // Определяем номер переиспользуемой ячейки
        
        // Проверяем принадлежит ли полученная ячейка cell к классу  ImagesListCell
        guard let imagesListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imagesListCell, with: indexPath) // Выполняет обработку методом configCell для каждой ячейки
        
        imagesListCell.delegate = self
        
        return imagesListCell
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photosName[indexPath.row]
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) {[weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.photosName = self.imagesListService.photos
                
            case .failure(let error):
                print("error")
            }
        }
    
        
        
    }
}

