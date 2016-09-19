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
    
    // Pass the touches down to other views
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let hitView = super.hitTest(point, with: event) , hitView != self {
            return hitView
        }
        return nil
    }
    
    @IBAction func closeButtonTapped(_ sender: AnyObject) {
        photosViewController?.dismiss(animated: true, completion: nil)
    }
}


extension CustomOverlayView: INSPhotosOverlayViewable {
    func populateWithPhoto(_ photo: INSPhotoViewable) {
        
    }
    func setHidden(_ hidden: Bool, animated: Bool) {
        if self.isHidden == hidden {
            return
        }
        
        if animated {
            self.isHidden = false
            self.alpha = hidden ? 1.0 : 0.0
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.allowAnimatedContent, .allowUserInteraction], animations: { () -> Void in
                self.alpha = hidden ? 0.0 : 1.0
                }, completion: { result in
                    self.alpha = 1.0
                    self.isHidden = hidden
            })
        } else {
            self.isHidden = hidden
        }
    }
}
