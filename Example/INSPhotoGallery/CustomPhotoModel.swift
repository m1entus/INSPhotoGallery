//
//  CustomPhotoModel.swift
//  INSPhotoGallery
//
//  Created by Michal Zaborowski on 04.04.2016.
//  Copyright © 2016 Inspace Labs Sp z o. o. Spółka Komandytowa. All rights reserved.
//

import UIKit
import Kingfisher
import INSPhotoGalleryFramework

class CustomPhotoModel: NSObject, INSPhotoViewable {
    var image: UIImage?
    var thumbnailImage: UIImage?
    
    var imageURL: URL?
    var thumbnailImageURL: URL?
    
    var attributedTitle: NSAttributedString? {
        return NSAttributedString(string: "Example caption text", attributes: [NSForegroundColorAttributeName: UIColor.white])
    }
    
    init(image: UIImage?, thumbnailImage: UIImage?) {
        self.image = image
        self.thumbnailImage = thumbnailImage
    }
    
    init(imageURL: URL?, thumbnailImageURL: URL?) {
        self.imageURL = imageURL
        self.thumbnailImageURL = thumbnailImageURL
    }
    
    init (imageURL: URL?, thumbnailImage: UIImage) {
        self.imageURL = imageURL
        self.thumbnailImage = thumbnailImage
    }
    
    func loadImageWithCompletionHandler(_ completion: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        if let url = imageURL {
            
            KingfisherManager.shared.retrieveImage(with: ImageResource(downloadURL: url), options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                completion(image, error)
            })
        } else {
            completion(nil, NSError(domain: "PhotoDomain", code: -1, userInfo: [ NSLocalizedDescriptionKey: "Couldn't load image"]))
        }
    }
    func loadThumbnailImageWithCompletionHandler(_ completion: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        if let thumbnailImage = thumbnailImage {
            completion(thumbnailImage, nil)
            return
        }
        if let url = thumbnailImageURL {
            KingfisherManager.shared.retrieveImage(with: ImageResource(downloadURL: url), options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                completion(image, error)
            })
        } else {
            completion(nil, NSError(domain: "PhotoDomain", code: -1, userInfo: [ NSLocalizedDescriptionKey: "Couldn't load image"]))
        }
    }
}
