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
import AVFoundation

class CTGalleryOverlayView: INSNibLoadedView {
    weak var photosViewController: INSPhotosViewController?
    
    @IBOutlet weak var leftArrow: UIButton!
    @IBOutlet weak var rightArrow: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var videoPlayBtn: UIButton!
    @IBOutlet weak var videofullBtn: UIButton!
    @IBOutlet weak var lblVideoTime: UILabel!
    @IBOutlet weak var videoProgress: UIProgressView!
    @IBOutlet weak var videoControl: UIView!
    

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
    @IBAction func videoPlayBtnClick(sender: AnyObject){
        if let _ = photosViewController!.currentPhoto?.videoURL{
            if let player = photosViewController!.currentPhotoViewController?.videoPlayer{
                if (player.rate != 0 && player.error == nil) {
                    player.pause()
                    videoPlayBtn.setImage(UIImage(named: "btnVideoPlay"), forState: .Normal)
                }
                else{
                    player.play()
                    videoPlayBtn.setImage(UIImage(named: "btnVideoPause"), forState: .Normal)
                }
            }
        }
    }
    @IBAction func videoFullBtnClick(sender: AnyObject){
        if let playerLayer = photosViewController!.currentPhotoViewController?.videoPlayerLayer{
            if playerLayer.videoGravity == AVLayerVideoGravityResizeAspect{
                playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                videofullBtn.setImage(UIImage(named: "btnVideoExit"), forState: .Normal)
            }
            else{
                playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
                videofullBtn.setImage(UIImage(named: "btnVideoFullscreen"), forState: .Normal)
            }
        }
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
            if let _ = photosViewController.currentPhoto?.videoURL{
                if let player = photosViewController.currentPhotoViewController?.videoPlayer{
                    if (player.rate != 0 && player.error == nil) {
                        videoPlayBtn.setImage(UIImage(named: "btnVideoPause"), forState: .Normal)
                    }
                    else{
                        videoPlayBtn.setImage(UIImage(named: "btnVideoPlay"), forState: .Normal)
                    }
                    
                    if let playerLayer = photosViewController.currentPhotoViewController?.videoPlayerLayer{
                        if playerLayer.videoGravity == AVLayerVideoGravityResizeAspect{
                            videofullBtn.setImage(UIImage(named: "btnVideoFullscreen"), forState: .Normal)
                        }
                        else{
                            videofullBtn.setImage(UIImage(named: "btnVideoExit"), forState: .Normal)
                        }
                    }
                    if let observer = photosViewController.currentPhotoViewController?.videoPlayerObserver{
                        player.removeTimeObserver(observer)
                    }
                    photosViewController.currentPhotoViewController?.videoPlayerObserver = player.addPeriodicTimeObserverForInterval(CMTimeMake(1, 1), queue: dispatch_get_main_queue(), usingBlock: {_ in
                        self.updateTimeFrame(player)
                    })
                    self.updateTimeFrame(player)
                    videoControl.hidden = false
                }
            }
            else{
                videoControl.hidden = true
            }
        }
    }
    func updateTimeFrame(player:AVPlayer) {
        let currentSeconds = CMTimeGetSeconds(player.currentTime())
        
        let hours:Int = Int(currentSeconds / 3600)
        let minutes:Int = Int(currentSeconds % 3600 / 60)
        let seconds:Int = Int(currentSeconds % 60)
        
        if hours > 0 {
            self.lblVideoTime.text = String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            self.lblVideoTime.text = String(format: "%02i:%02i", minutes, seconds)
        }
        let totalSeconds = CMTimeGetSeconds((player.currentItem?.duration)!)
        self.videoProgress.progress = Float(currentSeconds / totalSeconds)
        
        print("Updated Frame")
    }
}
