//
//  CustomPhotoModel.swift
//  INSPhotoGallery
//
//  Created by Michal Zaborowski on 04.04.2016.
//  Copyright © 2016 Inspace Labs Sp z o. o. Spółka Komandytowa. All rights reserved.
//

import UIKit
import Haneke
import INSPhotoGallery

class CustomPhotoModel: NSObject, INSPhotoViewable {
    var image: UIImage?
    var thumbnailImage: UIImage?
    
    var imageURL: NSURL?
    var thumbnailImageURL: NSURL?
    
    var attributedTitle: NSAttributedString? {
        return NSAttributedString(string: "Example caption text", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
    }
    
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
            Shared.imageCache.fetch(URL: url).onSuccess({ image in
                completion(image: image, error: nil)
            }).onFailure({ error in
                completion(image: nil, error: error)
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
            Shared.imageCache.fetch(URL: url).onSuccess({ image in
                completion(image: image, error: nil)
            }).onFailure({ error in
                completion(image: nil, error: error)
            })
        } else {
            completion(image: nil, error: NSError(domain: "PhotoDomain", code: -1, userInfo: [ NSLocalizedDescriptionKey: "Couldn't load image"]))
        }
    }
}