//
//  INSPhoto.swift
//  INSPhotoViewer
//
//  Created by Michal Zaborowski on 28.02.2016.
//  Copyright © 2016 Inspace Labs Sp z o. o. Spółka Komandytowa. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this library except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Foundation
import UIKit

public protocol INSPhotoViewable: NSObjectProtocol {
    var image: UIImage? { get }
    var thumbnailImage: UIImage? { get }
    
    func loadImageWithCompletionHandler(completion: (image: UIImage?, error: NSError?) -> ())
    func loadThumbnailImageWithCompletionHandler(completion: (image: UIImage?, error: NSError?) -> ())
    
    var attributedTitle: NSAttributedString? { get }
}

public class INSPhoto: NSObject, INSPhotoViewable {
    public var image: UIImage?
    public var thumbnailImage: UIImage?
    
    var imageURL: NSURL?
    var thumbnailImageURL: NSURL?
    
    public var attributedTitle: NSAttributedString?
    
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
    
    public func loadImageWithCompletionHandler(completion: (image: UIImage?, error: NSError?) -> ()) {
        if let image = image {
            completion(image: image, error: nil)
            return
        }
        loadImageWithURL(imageURL, completion: completion)
    }
    public func loadThumbnailImageWithCompletionHandler(completion: (image: UIImage?, error: NSError?) -> ()) {
        if let thumbnailImage = thumbnailImage {
            completion(image: thumbnailImage, error: nil)
            return
        }
        loadImageWithURL(thumbnailImageURL, completion: completion)
    }
    
    private func loadImageWithURL(url: NSURL?, completion: (image: UIImage?, error: NSError?) -> ()) {
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        if let imageURL = url {
            session.dataTaskWithURL(imageURL, completionHandler: { (response: NSData?, data: NSURLResponse?, error: NSError?) in
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if error != nil {
                        completion(image: nil, error: error)
                    } else if let response = response, let image = UIImage(data: response) {
                        completion(image: image, error: nil)
                    } else {
                        completion(image: nil, error: NSError(domain: "INSPhotoDomain", code: -1, userInfo: [ NSLocalizedDescriptionKey: "Couldn't load image"]))
                    }
                    session.finishTasksAndInvalidate()
                })
                
            }).resume()
        } else {
            completion(image: nil, error: NSError(domain: "INSPhotoDomain", code: -2, userInfo: [ NSLocalizedDescriptionKey: "Image URL not found."]))
        }
    }
}

public func ==<T: INSPhoto>(lhs: T, rhs: T) -> Bool {
    return lhs === rhs
}