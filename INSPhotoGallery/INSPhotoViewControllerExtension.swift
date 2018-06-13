//
//  INSPhotoViewControllerExtension.swift
//  INSPhotoGalleryFramework
//
//  Created by akai on 2018/06/13.
//  Copyright © 2018年 Inspace Labs Sp z o. o. Spółka Komandytowa. All rights reserved.
//

import Foundation

public extension INSPhotoViewController {
    public func imageView() -> UIImageView {
        return self.scalingImageView.imageView
    }
}
