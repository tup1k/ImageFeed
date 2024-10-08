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
    private var imagesListServiceObserver: NSObjectProtocol?
    
    @IBOutlet private var tableView: UITableView! // Создаем аутлет таблицы
    
    private var photos: [Photo] = []
    private let imageListService = ImagesListService.shared
    private let tokenStorage = OAuth2TokenStorage()
    
    // MARK: Форматирование даты по параметры ленты
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
        
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil, queue: .main) {[weak self] _ in
                guard let self = self else { return }
                self.updateTableViewAnimated()
            }
        
        imageListService.fetchPhotosNextPage() { result in
            switch result {
            case .success(let photos):
                self.tableView.reloadData()
            case .failure(let error):
                print("[ImagesListViewController]: [fetchPhotosNextPage] - Ошибка загрузки данных в SVC: \(error)")
                break
            }
        }
    }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imageListService.photos.count
        photos = imageListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    
    // Метод конфигурации внутренностей ячейки - картинки, кнопки, текст
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let newImage = imageListService.photos[indexPath.row]
        let newImageURL = newImage.largeImageURL
        let newImagePlaceholder = UIImage(named: "stab")
        
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(with: URL(string: newImageURL),placeholder: newImagePlaceholder) // Присваиваем его аутлету фотографий
        cell.dateLabel.text = dateFormatter.string(from: newImage.createdAt ?? Date()) // Присваиваем дату в нужном формате аутлету даты
        cell.pictureIsLiked(isLiked: newImage.isLiked)
        
        cell.delegate = self
        
        
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
            let largeImageURL = URL(string: imageListService.photos[indexPath.row].largeImageURL)
            viewController.largeImageURL = largeImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Метод загружающий фото в ячейку
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        let photos = imageListService.photos
        guard indexPath.row + 1 == photos.count else {return}
        imageListService.fetchPhotosNextPage() { result in
            switch result {
            case .success:
                self.tableView.reloadData()
            case .failure(let error):
                print("[tableView]: [fetchPhotosNextPage] - Ошибка загрузки данных в ячейку: \(error)")
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
        let newImage = imageListService.photos[indexPath.row]
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
        return imageListService.photos.count
    }
    
    // Метод возвращает данные ячейкм
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) // Определяем номер переиспользуемой ячейки
        
        // Проверяем принадлежит ли полученная ячейка cell к классу  ImagesListCell
        guard let imagesListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imagesListCell.delegate = self
        configCell(for: imagesListCell, with: indexPath) // Выполняет обработку методом configCell для каждой ячейки
        return imagesListCell
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = imageListService.photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) {[weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.photos = self.imageListService.photos
                cell.pictureIsLiked(isLiked: !photo.isLiked)
            case .failure(let error):
                print("error")
            }
            UIBlockingProgressHUD.dismiss()
        }
    
        
        
    }
}

