//
//  ViewController.swift
//  ImageFeed
//
//  Created by Олег Кор on 01.08.2024.
//
// Все комментарии пишутся в первую очередь для запоминания последовательности формирования приложения

import UIKit

final class ImagesListViewController: UIViewController {

    @IBOutlet private var tableView: UITableView! // Создаем аутлет таблицы
    
    private let photosName: [String] = Array(0..<20).map{"\($0)"} //Формируем текстовой массив из преобразованных чисел
    
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

        tableView.rowHeight = 200 // Высота ячейка равна 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    // Метод конфигурации внутренностей ячейки - картинки, кнопки, текст
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        
        guard let newImage = UIImage(named: photosName[indexPath.row]) else { return } // Проверяем наличие передаваемого фото в массиве
        cell.cellImage.image = newImage // Присваиваем его аутлету фотографий
        
        cell.dateLabel.text = dateFormatter.string(from: Date()) // Присваиваем дату в нужном формате аутлету даты
        
        // Присваиваем кнопке картинку нажатого/ненажатого лайк из условия четности фото
        let oddImage = indexPath.row % 2 == 0
        let likeImage = oddImage ? UIImage.likeImageNonactive : UIImage.likeImageActive
        cell.likeButton.setImage(likeImage, for: .normal)
       
        // Скругление фото и области градиента
        cell.cellImage.layer.cornerRadius = 16 // Сделали скругление всех углов фотки (дублирование сториборда на всякий случай)
        cell.cellImage.layer.masksToBounds = true // Сделали обрезание всех подслоев фотки под радиус (дублирование сториборда на всякий случай)
        cell.gradientView.layer.cornerRadius = 16 // Делаем скругление радиусов поля градиента (обязательно дополнение про нижние углы)
        cell.gradientView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] // Тут мы определяем что скругление только по нижним углам
        
        // Создание градиента внизу каждого фото
        cell.gradientLayer.frame = cell.gradientView.bounds
        cell.gradientLayer.colors = [UIColor.gradientColor1.cgColor, UIColor.gradientColor2.cgColor] // наверное правильнее делать через alpha
        cell.gradientView.layer.addSublayer(cell.gradientLayer)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    // Метод, отвечающий за действия при нажатии на фото
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // To do
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
    
    // Метод определяет количество ячеек в секции таблицы - пока равно числу мок-овских фоток
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
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

