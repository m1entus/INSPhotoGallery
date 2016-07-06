//
//  INSPhotoViewController.swift
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
import AVFoundation

public class INSPhotoViewController: UIViewController, UIScrollViewDelegate {
    var photo: INSPhotoViewable
    public var videoPlayer: AVPlayer?
    public var videoPlayerLayer: AVPlayerLayer?
    public var videoPlayerObserver: AnyObject?
    
    var longPressGestureHandler: ((UILongPressGestureRecognizer) -> ())?
    
    lazy private(set) var scalingImageView: INSScalingImageView = {
        return INSScalingImageView()
    }()
    
    lazy private(set) var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(INSPhotoViewController.handleDoubleTapWithGestureRecognizer(_:)))
        gesture.numberOfTapsRequired = 2
        return gesture
    }()
    
    lazy private(set) var longPressGestureRecognizer: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(INSPhotoViewController.handleLongPressWithGestureRecognizer(_:)))
        return gesture
    }()
    
    lazy private(set) var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    public init(photo: INSPhotoViewable) {
        self.photo = photo
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        scalingImageView.delegate = nil
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        scalingImageView.delegate = self
        scalingImageView.frame = view.bounds
        scalingImageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.addSubview(scalingImageView)
        
        view.addSubview(activityIndicator)
        activityIndicator.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        activityIndicator.autoresizingMask = [.FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleBottomMargin]
        activityIndicator.sizeToFit()
        
        view.addGestureRecognizer(doubleTapGestureRecognizer)
        view.addGestureRecognizer(longPressGestureRecognizer)
        
        if let image = photo.image {
            self.scalingImageView.image = image
            self.activityIndicator.stopAnimating()
        } else if let thumbnailImage = photo.thumbnailImage {
            self.scalingImageView.image = thumbnailImage
            self.activityIndicator.stopAnimating()
            loadFullSizeImage()
        } else {
            loadThumbnailImage()
        }
        if let videoURL = photo.videoURL{
            self.initVideo(videoURL)
        }
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopVideo()
        if let player = videoPlayer{
            if let observer = videoPlayerObserver{
                player.removeTimeObserver(observer)
                videoPlayerObserver = nil
            }
        }
    }
    
    public func initVideo(videoURL: NSURL){
        let playerItem = AVPlayerItem(URL: videoURL)
        videoPlayer = AVPlayer(playerItem: playerItem)
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
        videoPlayerLayer!.frame = scalingImageView.bounds
        scalingImageView.layer.addSublayer(videoPlayerLayer!)
        videoPlayerLayer!.videoGravity = AVLayerVideoGravityResizeAspect
        videoPlayer!.muted = false
    }
    
    public func stopVideo(){
        if let player = videoPlayer{
            player.pause()
        }
    }
    
    public func playVideo(){
        if let player = videoPlayer{
            player.play()
        }
    }
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scalingImageView.frame = view.bounds
        if let playerLayer = videoPlayerLayer{
            playerLayer.frame = scalingImageView.bounds
        }
    }
    
    private func loadThumbnailImage() {
        view.bringSubviewToFront(activityIndicator)
        photo.loadThumbnailImageWithCompletionHandler { [weak self] (image, error) -> () in
            
            let completeLoading = {
                self?.scalingImageView.image = image
                if image != nil {
                    self?.activityIndicator.stopAnimating()
                }
                self?.loadFullSizeImage()
            }
            
            if NSThread.isMainThread() {
                completeLoading()
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completeLoading()
                })
            }
        }
    }
    
    private func loadFullSizeImage() {
        view.bringSubviewToFront(activityIndicator)
        self.photo.loadImageWithCompletionHandler({ [weak self] (image, error) -> () in
            let completeLoading = {
                self?.activityIndicator.stopAnimating()
                self?.scalingImageView.image = image    
            }
            
            if NSThread.isMainThread() {
                completeLoading()
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completeLoading()
                })
            }
        })
    }
    
    @objc private func handleLongPressWithGestureRecognizer(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Began {
            longPressGestureHandler?(recognizer)
        }
    }
    
    @objc private func handleDoubleTapWithGestureRecognizer(recognizer: UITapGestureRecognizer) {
        let pointInView = recognizer.locationInView(scalingImageView.imageView)
        var newZoomScale = scalingImageView.maximumZoomScale
        
        if scalingImageView.zoomScale >= scalingImageView.maximumZoomScale || abs(scalingImageView.zoomScale - scalingImageView.maximumZoomScale) <= 0.01 {
            newZoomScale = scalingImageView.minimumZoomScale
        }
        
        let scrollViewSize = scalingImageView.bounds.size
        let width = scrollViewSize.width / newZoomScale
        let height = scrollViewSize.height / newZoomScale
        let originX = pointInView.x - (width / 2.0)
        let originY = pointInView.y - (height / 2.0)
        
        let rectToZoom = CGRect(x: originX, y: originY, width: width, height: height)
        scalingImageView.zoomToRect(rectToZoom, animated: true)
    }
    
    // MARK:- UIScrollViewDelegate
    
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return scalingImageView.imageView
    }
    
    public func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView?) {
        scrollView.panGestureRecognizer.enabled = true
    }
    
    public func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        // There is a bug, especially prevalent on iPhone 6 Plus, that causes zooming to render all other gesture recognizers ineffective.
        // This bug is fixed by disabling the pan gesture recognizer of the scroll view when it is not needed.
        if (scrollView.zoomScale == scrollView.minimumZoomScale) {
            scrollView.panGestureRecognizer.enabled = false;
        }
    }
}