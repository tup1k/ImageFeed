//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Олег Кор on 12.08.2024.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    var largeImageURL: URL?
    
    @IBOutlet private var shareButton: UIButton! // Аутлет кнопки шеринга
    @IBOutlet private var imageView: UIImageView! // Аутлет картинки
    @IBOutlet private var scrollView: UIScrollView! // Аутлет скролла
    @IBOutlet private var SingleImageBackButton: UIButton! // Аутлет кнопки возврата из окна просмотра картинки
   
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Параметры масштабирования при просмотре картинки
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        loadLargeImageFromAPI(imageURL: largeImageURL)
    }
    
    // Экшн кнопки выхода из просмотра картинки
    @IBAction func didTapSingleImageBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // Экшн кнопки шеринга картинки
    @IBAction func tapShareButton(_ sender: Any) {
        guard let fullImage = imageView.image else { return }
        didTapShareButton(image: fullImage)
    }
    
    //  Функция расшаривания картинок
    private func didTapShareButton(image: UIImage) {
        let shareImage = [image]
        let toShare = UIActivityViewController(activityItems: shareImage, applicationActivities: nil)
        present(toShare, animated: true, completion: nil)
    }
    
    // Функция подгона картинки под экран телефона (надо не забыть повторить теорию)
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func loadLargeImageFromAPI(imageURL: URL?) {
        guard let imageURL else { return }
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: imageURL) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                self.imageView.image = imageResult.image
                self.imageView.frame.size = imageResult.image.size
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                self.showErrorAlert()
            }
        }
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Не удалось загрузить фото.", message: "Попробовать еще раз?", preferredStyle: .alert)
        let noButtonAction = UIAlertAction(title: "Нет", style: .cancel)
        let yesButtonAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.loadLargeImageFromAPI(imageURL: largeImageURL)
        }
        alert.addAction(noButtonAction)
        alert.addAction(yesButtonAction)
        self.present(alert, animated: true)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
