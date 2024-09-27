//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Олег Кор on 12.08.2024.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    @IBOutlet private var shareButton: UIButton! // Аутлет кнопки шеринга
    @IBOutlet private var imageView: UIImageView! // Аутлет картинки
    @IBOutlet private var scrollView: UIScrollView! // Аутлет скролла
    @IBOutlet private var SingleImageBackButton: UIButton! // Аутлет кнопки возврата из окна просмотра картинки
   
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Параметры масштабирования при просмотре картинки
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        guard let image else { return }
        imageView.image = image
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    // Экшн кнопки выхода из просмотра картинки
    @IBAction func didTapSingleImageBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // Экшн кнопки шеринга картинки
    @IBAction func tapShareButton(_ sender: Any) {
        guard let image else { return }
        didTapShareButton(image: image)
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
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
