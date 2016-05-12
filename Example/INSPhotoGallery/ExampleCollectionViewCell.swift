//
//  ExampleCollectionViewCell.swift
//  INSPhotoGallery
//
//  Created by Michal Zaborowski on 04.04.2016.
//  Copyright © 2016 Inspace Labs Sp z o. o. Spółka Komandytowa. All rights reserved.
//

import UIKit
import INSPhotoGalleryFramework

protocol SelectCollectionViewCellDataSource :NSObjectProtocol {
    func getSelectIndex() -> String
}

class ExampleCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectButton: UIButton!
    weak var dataSource: SelectCollectionViewCellDataSource?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectButton.layer.cornerRadius = 15
        selectButton.layer.masksToBounds = true
    }
    
    func populateWithPhoto(photo: INSPhotoViewable) {
        photo.loadThumbnailImageWithCompletionHandler { [weak photo] (image, error) in
            if let image = image {
                if let photo = photo as? INSPhoto {
                    photo.thumbnailImage = image
                }
                self.imageView.image = image
            }
        }
    }
    @IBAction func selectButtonEvent(button: UIButton) {
        button.selected = !button.selected
        if button.selected {
            button.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
            button.setTitle("", forState: UIControlState.Selected)
        }else{
            button.backgroundColor = UIColor.greenColor()
            button.setTitle(dataSource?.getSelectIndex(), forState: UIControlState.Normal)
        }
    }
}
