//
//  INSPhotosViewControllerDataSource.swift
//  INSPhotoViewer
//
//  Created by Michal Zaborowski on 28.02.2016.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

import Foundation

struct INSPhotosDataSource<T: INSPhotoViewable> {
    var photos: NSArray = []
    
    var numberOfPhotos: Int {
        return photos.count
    }
    
    func photoAtIndex(index: Int) -> T? {
        if (index < photos.count && index >= 0) {
            return photos[index] as? T;
        }
        return nil
    }
    
    func indexOfPhoto(photo: T) -> Int? {
        return photos.indexOfObject(photo)
    }

    func containsPhoto(photo: T) -> Bool {
        return indexOfPhoto(photo) != nil
    }
    
    subscript(index: Int) -> T? {
        get {
            return photoAtIndex(index)
        }
    }
}