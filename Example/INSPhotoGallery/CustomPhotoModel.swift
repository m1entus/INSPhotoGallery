//
//  CustomPhotoModel.swift
//  INSPhotoGallery
//
//  Created by Michal Zaborowski on 04.04.2016.
//  Copyright © 2016 Inspace Labs Sp z o. o. Spółka Komandytowa. All rights reserved.
//

import UIKit
import SDWebImage

class CustomPhotoModel: NSObject, INSPhotoViewable {
    var image: UIImage?
    var thumbnailImage: UIImage?
    
    var imageURL: NSURL?
    var thumbnailImageURL: NSURL?
    
    var attributedTitle: NSAttributedString?
    
    init(image: UIImage?, thumbnailImage: UIImage?) {
        self.image = image
        self.thumbnailImage = thumbnailImage
    }
    
    init(imageURL: NSURL?, thumbnailImageURL: NSURL?) {
        self.imageURL = imageURL
        self.thumbnailImageURL = thumbnailImageURL
    }
    
    init (imageURL: NSURL?, thumbnailImage: UIImage) {
        self.imageURL = imageURL
        self.thumbnailImage = thumbnailImage
    }
    
    func loadImageWithCompletionHandler(completion: (image: UIImage?, error: NSError?) -> ()) {
        if let url = imageURL {
            SDWebImageManager.sharedManager().downloadImageWithURL(url, options: [], progress: nil, completed: { image, error, cahcheType, finished, url in
                completion(image: image, error: error)
            })
        } else {
            completion(image: nil, error: NSError(domain: "PhotoDomain", code: -1, userInfo: [ NSLocalizedDescriptionKey: "Couldn't load image"]))
        }
    }
    func loadThumbnailImageWithCompletionHandler(completion: (image: UIImage?, error: NSError?) -> ()) {
        if let thumbnailImage = thumbnailImage {
            completion(image: thumbnailImage, error: nil)
            return
        }
        if let url = thumbnailImageURL {
            SDWebImageManager.sharedManager().downloadImageWithURL(url, options: [], progress: nil, completed: { image, error, cahcheType, finished, url in
                if let image = image {
                    self.thumbnailImage = image
                }
                completion(image: image, error: error)
            })
        } else {
            completion(image: nil, error: NSError(domain: "PhotoDomain", code: -1, userInfo: [ NSLocalizedDescriptionKey: "Couldn't load image"]))
        }
    }
}