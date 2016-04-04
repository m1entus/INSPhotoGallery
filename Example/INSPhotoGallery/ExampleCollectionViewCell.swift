//
//  ExampleCollectionViewCell.swift
//  INSPhotoGallery
//
//  Created by Michal Zaborowski on 04.04.2016.
//  Copyright © 2016 Inspace Labs Sp z o. o. Spółka Komandytowa. All rights reserved.
//

import UIKit

class ExampleCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    func populateWithPhoto(photo: INSPhotoViewable) {
        photo.loadThumbnailImageWithCompletionHandler { (image, error) in
            if let image = image {
                self.imageView.image = image
            }
        }
    }
}
