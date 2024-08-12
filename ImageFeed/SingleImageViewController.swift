//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Олег Кор on 12.08.2024.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage?
    
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
}
