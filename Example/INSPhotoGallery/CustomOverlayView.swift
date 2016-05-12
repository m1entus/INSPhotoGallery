//
//  CustomOverlayView.swift
//  INSPhotoGallery
//
//  Created by Michal Zaborowski on 04.04.2016.
//  Copyright © 2016 Inspace Labs Sp z o. o. Spółka Komandytowa. All rights reserved.
//

import UIKit
import INSNibLoading
import INSPhotoGalleryFramework

class CustomOverlayView: INSNibLoadedView {
    weak var photosViewController: INSPhotosViewController?
    
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var finishButton: UIButton!
    // Pass the touches down to other views
    
    override func awakeFromNib() {
        numLabel.layer.cornerRadius = 10
        numLabel.layer.masksToBounds = true
        
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if let hitView = super.hitTest(point, withEvent: event) where hitView != self {
            return hitView
        }
        return nil
    }
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        photosViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}


extension CustomOverlayView: INSPhotosOverlayViewable {
    func populateWithPhoto(photo: INSPhotoViewable) {
        
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
}
