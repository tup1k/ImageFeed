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
    
    private var photoList: [Photo] = []
    private let imageListService = ImagesListService.shared
    private let myToken = OAuth2TokenStorage()
    
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
        
        UIBlockingProgressHUD.show()
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil, queue: .main) {[weak self] _ in
                guard let self = self else { return }
                self.updateTableViewAnimated()
                UIBlockingProgressHUD.dismiss()
            }
        imageListService.fetchPhotosNextPage()
        print("ТЕПЕРЬ ТВОЙ TOKEN РАВЕН - \(myToken.token ?? "НЕ ИДЕНТИФИЦИИРУЕТСЯ")")
    }
    
    // MARK: Обновление таблицы
    func updateTableViewAnimated() {
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
    
    // Метод конфигурации внутренностей ячейки - картинки, кнопки, текст
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
            cell.dateLabel.text = dateFormatter.string(from: newImageCreationDate) // Присваиваем дату в нужном формате аутлету даты
        } else {
            cell.dateLabel.text = "" // Если даты нет ставим пустую строку
        }
        
        cell.pictureIsLiked(isLiked: newImage.isLiked)
        
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
        imageListService.fetchPhotosNextPage() 
    }
}

extension ImagesListViewController: UITableViewDelegate {
    // Метод, отвечающий за действия при нажатии на фото - выводит большое фото
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
    
    private func likeAlert() {
        let alert = UIAlertController(title: "Внимание!", message: "Функция недоступна, попробуйте позже", preferredStyle: .alert)
        let okButtonAction = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(okButtonAction)
        self.present(alert, animated: true)
    }
}

