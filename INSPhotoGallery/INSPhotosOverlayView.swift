//
//  INSPhotosOverlayView.swift
//  INSPhotoViewer
//
//  Created by Michal Zaborowski on 28.02.2016.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

import UIKit

public protocol INSPhotosOverlayViewable: class {
    weak var photosViewController: UIViewController? { get set }
    
    func populateWithPhoto<T: INSPhotoViewable>(photo: T)
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
    public private(set) var navigationItem: UINavigationItem!
    public weak var photosViewController: UIViewController?
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
    
    public func populateWithPhoto<T: INSPhotoViewable>(photo: T) {
        self.currentPhoto = photo
        self.navigationItem.title = photo.attributedTitle?.string
    }
    
    @objc func closeButtonTapped(sender: UIBarButtonItem) {
        photosViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @objc func actionButtonTapped(sender: UIBarButtonItem) {
        if let currentPhoto = currentPhoto {
            currentPhoto.loadImageWithCompletionHandler({ [weak self] (image, error) -> () in
                if let image = (image ?? currentPhoto.thumbnailImage) {
                    let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                    self?.photosViewController?.presentViewController(activityController, animated: true, completion: nil)
                }
            });
        }
    }
    
    func setupNavigationBar() {
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
        
        leftBarButtonItem = UIBarButtonItem(title: "CLOSE".uppercaseString, style: .Plain, target: self, action: #selector(INSPhotosOverlayView.closeButtonTapped(_:)))
        rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(INSPhotosOverlayView.actionButtonTapped(_:)))
    }
}