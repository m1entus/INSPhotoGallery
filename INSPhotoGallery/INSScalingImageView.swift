//
//  INSScalingImageView.swift
//  INSPhotoViewer
//
//  Created by Michal Zaborowski on 28.02.2016.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

import UIKit

class INSScalingImageView: UIScrollView {
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)
        return imageView
    }()
    
    var image: UIImage? {
        didSet {
            updateImage(image)
        }
    }
    
    override var frame: CGRect {
        didSet {
            updateZoomScale()
            centerScrollViewContents()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageScrollView()
        updateZoomScale()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupImageScrollView()
        updateZoomScale()
    }
    
    override func didAddSubview(subview: UIView) {
        super.didAddSubview(subview)
        centerScrollViewContents()
    }
    
    private func setupImageScrollView() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false;
        bouncesZoom = true;
        decelerationRate = UIScrollViewDecelerationRateFast;
    }
    
    func centerScrollViewContents() {
        var horizontalInset: CGFloat = 0;
        var verticalInset: CGFloat = 0;
        
        if (contentSize.width < bounds.width) {
            horizontalInset = (bounds.width - contentSize.width) * 0.5;
        }
        
        if (self.contentSize.height < CGRectGetHeight(bounds)) {
            verticalInset = (CGRectGetHeight(bounds) - contentSize.height) * 0.5;
        }
        
        if (window?.screen.scale < 2.0) {
            horizontalInset = floor(horizontalInset);
            verticalInset = floor(verticalInset);
        }
        
        // Use `contentInset` to center the contents in the scroll view. Reasoning explained here: http://petersteinberger.com/blog/2013/how-to-center-uiscrollview/
        self.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
    }
    
    private func updateImage(image: UIImage?) {
        let size = image?.size ?? CGSize.zero
        
        imageView.transform = CGAffineTransformIdentity
        imageView.image = image
        imageView.frame = CGRect(origin: CGPoint.zero, size: size)
        self.contentSize = size
        
        updateZoomScale()
        centerScrollViewContents()
    }
    
    private func updateZoomScale() {
        if let image = imageView.image {
            let scrollViewFrame = self.bounds
            let scaleWidth = scrollViewFrame.size.width / image.size.width
            let scaleHeight = scrollViewFrame.size.height / image.size.height
            let minimumScale = min(scaleWidth, scaleHeight)
            
            self.minimumZoomScale = minimumScale
            self.maximumZoomScale = max(minimumScale, scaleHeight)
            
            self.zoomScale = minimumZoomScale

            // scrollView.panGestureRecognizer.enabled is on by default and enabled by
            // viewWillLayoutSubviews in the container controller so disable it here
            // to prevent an interference with the container controller's pan gesture.
            //
            // This is enabled in scrollViewWillBeginZooming so panning while zoomed-in
            // is unaffected.
            self.panGestureRecognizer.enabled = false
        }
    }
}