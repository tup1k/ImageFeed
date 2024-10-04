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
    
    private let photosName: [String] = Array(0..<20).map{"\($0)"} //Формируем текстовой массив из преобразованных чисел
    
    private let photosImportService = ImagesListService.shared
    private let tokenStorageILC = OAuth2TokenStorage()
    
    // Вводим переменную форматирующую дату создания фото
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        //formatter.locale = Locale(identifier: "ru") // Русскоязычная дата
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let token = tokenStorageILC.token else { return }
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
//        let photos = photosImportService.photos
        photosImportService.fetchPhotosNextPage(token) { result in
            switch result {
            case .success(let photos):
                self.tableView.reloadData()
                for item in photos {
                    print(item.height)
                }
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
        cell.dateLabel.text = dateFormatter.string(from: Date()) // Присваиваем дату в нужном формате аутлету даты
        
        // Присваиваем кнопке картинку нажатого/ненажатого лайк из условия четности фото
        let oddImage = indexPath.row % 2 == 0
//        let likeImage = oddImage ? UIImage.likeImageNonactive : UIImage.likeImageActive
        let likeImage = newImage.isLiked ? UIImage.likeImageNonactive : UIImage.likeImageActive
        cell.likeButton.setImage(likeImage, for: .normal)
        
        // Скругление фото и области градиента
        cell.setupCellImage()
        cell.setupGradientLayer() // вызываем инкапсулированную функцию свойств градиента
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            let viewController = segue.destination as? SingleImageViewController
            let indexPath = sender as! IndexPath
            let newImage = photosImportService.photos[indexPath.row]
            
//            let image = UIImage(named: photosName[indexPath.row])
            //viewController.image.kf.setImage(with: URL(string: newImage.largeImageURL))
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // Метод загрузки фото в ячейки
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath
    ) {
        let photos = photosImportService.photos
        guard indexPath.row + 1 == photos.count else {return}
        
        photosImportService.fetchPhotosNextPage(tokenStorageILC.token!) { result in
            switch result {
            case .success(let photos):
                self.tableView.reloadData()
                print(photos.count)
            case .failure(let error):
                print("[fetchProfileSVC]: [fetchProfile] - Ошибка загрузки данных в SVC: \(error)")
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
        //let indexPath = sender as! IndexPath
        let newImage = photosImportService.photos[indexPath.row]
        //guard let newImage = UIImage(named: photosName[indexPath.row]) else { return 0} // Проверяем наличие фото
        let imageDynamicWidth = tableView.bounds.width - 16 - 16
        let scale = imageDynamicWidth/newImage.size.width
        let imageDinamicHeight = CGFloat(((newImage.height ?? 3000)/10))
        return imageDinamicHeight
//        return 300
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
        
        return imagesListCell
    }
}

