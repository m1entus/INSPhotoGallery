//
//  INSPhotosOverlayView.swift
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

import UIKit

public protocol INSPhotosOverlayViewable:class {
    weak var photosViewController: INSPhotosViewController? { get set }
    
    func populateWithPhoto(photo: INSPhotoViewable)
    func setHidden(hidden: Bool, animated: Bool)
    func view() -> UIView
}

extension INSPhotosOverlayViewable where Self: UIView {
    public func view() -> UIView {
        return self
    }
}

public class INSPhotosOverlayView: UIView , INSPhotosOverlayViewable {
    public private(set) var navigationBar: UINavigationBar!
    public private(set) var captionLabel: UILabel!
    
    public private(set) var navigationItem: UINavigationItem!
    public weak var photosViewController: INSPhotosViewController?
    private var currentPhoto: INSPhotoViewable?
    
    var leftBarButtonItem: UIBarButtonItem? {
        didSet {
            navigationItem.leftBarButtonItem = leftBarButtonItem
        }
    }
    var rightBarButtonItem: UIBarButtonItem? {
        didSet {
            navigationItem.rightBarButtonItem = rightBarButtonItem
        }
    }
    var titleTextAttributes: [String : AnyObject] = [:] {
        didSet {
            navigationBar.titleTextAttributes = titleTextAttributes
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupNavigationBar()
        setupCaptionLabel()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Pass the touches down to other views
    public override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if let hitView = super.hitTest(point, withEvent: event) where hitView != self {
            return hitView
        }
        return nil
    }
    
    public override func layoutSubviews() {
        // The navigation bar has a different intrinsic content size upon rotation, so we must update to that new size.
        // Do it without animation to more closely match the behavior in `UINavigationController`
        UIView.performWithoutAnimation { () -> Void in
            self.navigationBar.invalidateIntrinsicContentSize()
            self.navigationBar.layoutIfNeeded()
        }
        super.layoutSubviews()
    }
    
    public func setHidden(hidden: Bool, animated: Bool) {
        if self.hidden == hidden {
            return
        }
        
        if animated {
            self.hidden = false
            self.alpha = hidden ? 1.0 : 0.0
            
            UIView.animateWithDuration(0.2, delay: 0.0, options: [.CurveEaseInOut, .AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                self.alpha = hidden ? 0.0 : 1.0
                }, completion: { result in
                    self.alpha = 1.0
                    self.hidden = hidden
            })
        } else {
            self.hidden = hidden
        }
    }
    
    public func populateWithPhoto(photo: INSPhotoViewable) {
        self.currentPhoto = photo

        if let photosViewController = photosViewController {
            if let index = photosViewController.dataSource.indexOfPhoto(photo) {
                navigationItem.title = "\(index+1) of \(photosViewController.dataSource.numberOfPhotos)"
            }
            captionLabel.attributedText = photo.attributedTitle
        }
    }
    
    @objc private func closeButtonTapped(sender: UIBarButtonItem) {
        photosViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @objc private func actionButtonTapped(sender: UIBarButtonItem) {
        if let currentPhoto = currentPhoto {
            currentPhoto.loadImageWithCompletionHandler({ [weak self] (image, error) -> () in
                if let image = (image ?? currentPhoto.thumbnailImage) {
                    let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                    self?.photosViewController?.presentViewController(activityController, animated: true, completion: nil)
                }
            });
        }
    }
    
    private func setupNavigationBar() {
        navigationBar = UINavigationBar()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.backgroundColor = UIColor.clearColor()
        navigationBar.barTintColor = nil
        navigationBar.translucent = true
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        
        navigationItem = UINavigationItem(title: "")
        navigationBar.items = [navigationItem]
        addSubview(navigationBar)
        
        let topConstraint = NSLayoutConstraint(item: navigationBar, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let widthConstraint = NSLayoutConstraint(item: navigationBar, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 0.0)
        let horizontalPositionConstraint = NSLayoutConstraint(item: navigationBar, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        self.addConstraints([topConstraint,widthConstraint,horizontalPositionConstraint])
        
        if let bundlePath = NSBundle(forClass: self.dynamicType).pathForResource("INSPhotoGallery", ofType: "bundle") {
            let bundle = NSBundle(path: bundlePath)
            leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "INSPhotoGalleryClose", inBundle: bundle, compatibleWithTraitCollection: nil), landscapeImagePhone: UIImage(named: "INSPhotoGalleryCloseLandscape", inBundle: bundle, compatibleWithTraitCollection: nil), style: .Plain, target: self, action: #selector(INSPhotosOverlayView.closeButtonTapped(_:)))
        } else {
            leftBarButtonItem = UIBarButtonItem(title: "CLOSE".uppercaseString, style: .Plain, target: self, action: #selector(INSPhotosOverlayView.closeButtonTapped(_:)))
        }
        
        rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(INSPhotosOverlayView.actionButtonTapped(_:)))
    }
    
    private func setupCaptionLabel() {
        captionLabel = UILabel()
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.backgroundColor = UIColor.clearColor()
        captionLabel.numberOfLines = 0
        addSubview(captionLabel)
        
        let bottomConstraint = NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: captionLabel, attribute: .Bottom, multiplier: 1.0, constant: 8.0)
        let leadingConstraint = NSLayoutConstraint(item: captionLabel, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 8.0)
        let trailingConstraint = NSLayoutConstraint(item: captionLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 8.0)
        self.addConstraints([bottomConstraint,leadingConstraint,trailingConstraint])
    }
}