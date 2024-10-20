//
//  ViewController.swift
//  ImageFeed
//
//  Created by Олег Кор on 01.08.2024.
//
// Все комментарии пишутся в первую очередь для запоминания последовательности формирования приложения

import UIKit
import Kingfisher

protocol ImagesViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set}
    func importImagesToTable(oldCount: Int, newCount: Int)
//    func load(request: URLRequest)
//    func setProgressValue(_ newValue: Float)
//    func setProgressHidden(_ isHidden: Bool)
}


final class ImagesListViewController: UIViewController, ImagesViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var imagesListServiceObserver: NSObjectProtocol?
    
    @IBOutlet private var tableView: UITableView! // Создаем аутлет таблицы
    
    private var photoList: [Photo] = []
    private let imageListService = ImagesListService.shared
    private let myToken = OAuth2TokenStorage()
    var imagesListPresenter = ImagesListPresenter()
    
    /// Форматирование даты в ячейке
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        UIBlockingProgressHUD.show()
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil, queue: .main) {[weak self] _ in
                guard let self = self else { return }
                self.updateTableViewAnimated()
//                imagesListPresenter.updateTableViewAnimated()
                UIBlockingProgressHUD.dismiss()
            }
        imageListService.fetchPhotosNextPage()
        print("ТЕПЕРЬ ТВОЙ TOKEN РАВЕН - \(myToken.token ?? "НЕ ИДЕНТИФИЦИИРУЕТСЯ")")
    }
    
    /// Метод отвечает за анимированное обновление таблицы
    private func updateTableViewAnimated() {
        let oldCount = photoList.count
        let newCount = imageListService.photos.count
        photoList = imageListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                var indexPaths: [IndexPath] = []
                for i in oldCount..<newCount {
                    indexPaths.append(IndexPath(row: i, section: 0))
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    func importImagesToTable(oldCount: Int, newCount: Int) {
        tableView.performBatchUpdates {
            var indexPaths: [IndexPath] = []
            for i in oldCount..<newCount {
                indexPaths.append(IndexPath(row: i, section: 0))
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
    
    /// Метод настройки параметров ячейки
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let newImage = photoList[indexPath.row]
        let newImageURL = newImage.thumbImageURL
        guard let url = URL(string: newImageURL) else { return }
        let newImagePlaceholder = UIImage(named: "stab")
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(with: url,placeholder: newImagePlaceholder) { [weak self] _ in
            guard let self = self else {return}
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        if let newImageCreationDate = newImage.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: newImageCreationDate)
        } else {
            cell.dateLabel.text = ""
        }
        
        cell.pictureIsLiked(isLiked: newImage.isLiked)
        
        // Скругление фото и области градиента
        cell.setupCellImage()
        cell.setupGradientLayer() // вызываем инкапсулированную функцию свойств градиента
    }
    
    /// Метод отвечает за переход в окно просмотра полноразмерного фото
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
    
    /// Метод отвечает за отображения данных в ячейке
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        let photos = imageListService.photos
        guard indexPath.row + 1 == photos.count else {return}
        imageListService.fetchPhotosNextPage() 
    }
}

extension ImagesListViewController: UITableViewDelegate {
    /// Метод отвечает за действия при нажатии ячейки
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    /// Метод отвечает за размеры каждой ячейки в таблицн
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let newImage = imageListService.photos[indexPath.row]
        let imageDynamicWidth = tableView.bounds.width - 16 - 16
        let scale = imageDynamicWidth/newImage.size.width
        let imageDinamicHeight = newImage.size.height * scale + 4 + 4
        return imageDinamicHeight
    }
}

extension ImagesListViewController: UITableViewDataSource {
    
    /// Метод определяет количество ячеек в секции таблицы
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoList.count
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
    /// Метод установки like
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let photo = photoList[indexPath.row]
        UIBlockingProgressHUD.show()
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) {[weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.photoList = self.imageListService.photos
                cell.pictureIsLiked(isLiked: !photo.isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                likeAlert()
            }
        }
    }
    
    /// Метод вызова уведомления об ошибке установки like
    private func likeAlert() {
        let alert = UIAlertController(title: "Внимание!", message: "Функция недоступна, попробуйте позже", preferredStyle: .alert)
        let okButtonAction = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(okButtonAction)
        self.present(alert, animated: true)
    }
}

