//
//  CTGalleryOverlayView.swift
//  ComoTravel
//
//  Created by WOO Yu Kit on 5/7/2016.
//  Copyright © 2016 Como. All rights reserved.
//

import UIKit
import INSNibLoading
import INSPhotoGalleryFramework

class CTGalleryOverlayView: INSNibLoadedView {
    weak var photosViewController: INSPhotosViewController?
    
    @IBOutlet weak var leftArrow: UIButton!
    @IBOutlet weak var rightArrow: UIButton!
    @IBOutlet weak var lblTitle: UILabel!

    // Pass the touches down to other views
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if let hitView = super.hitTest(point, withEvent: event) where hitView != self {
            return hitView
        }
        return nil
    }
    @IBAction func nextBtnClick(sender: AnyObject) {
        if let photosViewController = self.photosViewController{
            let index = photosViewController.currentDataSource.indexOfPhoto(photosViewController.currentPhoto!)
            if index < photosViewController.currentDataSource.numberOfPhotos-1{
                photosViewController.changeToPhoto(photosViewController.currentDataSource.photoAtIndex(index!+1)!, animated: true)
            }
        }
    }
    @IBAction func prevBtnClick(sender: AnyObject) {
        if let photosViewController = self.photosViewController{
            let index = photosViewController.currentDataSource.indexOfPhoto(photosViewController.currentPhoto!)
            if index > 0{
                photosViewController.changeToPhoto(photosViewController.currentDataSource.photoAtIndex(index!-1)!, animated: true)
            }
        }
    }
    @IBAction func closeBtnClick(sender: AnyObject) {
        photosViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension CTGalleryOverlayView: INSPhotosOverlayViewable {
    func view() -> UIView {
        setupView()
        return self
    }
    func populateWithPhoto(photo: INSPhotoViewable) {
        setupView()
    }
    func setHidden(hidden: Bool, animated: Bool) {
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
    func setupView(){
        if let photosViewController = photosViewController {
            let index = photosViewController.currentDataSource.indexOfPhoto(photosViewController.currentPhoto!)!+1
            lblTitle.text = "\(index) / \(photosViewController.currentDataSource.numberOfPhotos)"
            leftArrow.hidden = false
            rightArrow.hidden = false
            if index == 1{
                leftArrow.hidden = true
            }
            else if index==photosViewController.currentDataSource.numberOfPhotos{
                rightArrow.hidden = true
            }
        }
    }
}
