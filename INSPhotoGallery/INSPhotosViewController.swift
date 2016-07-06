//
//  INSPhotosViewController.swift
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

public typealias INSPhotosViewControllerReferenceViewHandler = (photo: INSPhotoViewable) -> (UIView?)
public typealias INSPhotosViewControllerNavigateToPhotoHandler = (photo: INSPhotoViewable) -> ()
public typealias INSPhotosViewControllerDismissHandler = (viewController: INSPhotosViewController) -> ()
public typealias INSPhotosViewControllerLongPressHandler = (photo: INSPhotoViewable, gestureRecognizer: UILongPressGestureRecognizer) -> (Bool)


public class INSPhotosViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIViewControllerTransitioningDelegate {
    
    /* 
     * Returns the view from which to animate for object conforming to INSPhotoViewable 
     */
    public var referenceViewForPhotoWhenDismissingHandler: INSPhotosViewControllerReferenceViewHandler?
    
    /*
     * Called when a new photo is displayed through a swipe gesture.
     */
    public var navigateToPhotoHandler: INSPhotosViewControllerNavigateToPhotoHandler?
    
    /*
     * Called before INSPhotosViewController will start a user-initiated dismissal.
     */
    public var willDismissHandler: INSPhotosViewControllerDismissHandler?
    
    /*
     * Called after the INSPhotosViewController has been dismissed by the user.
     */
    public var didDismissHandler: INSPhotosViewControllerDismissHandler?
    
    /*
     * Called when a photo is long pressed.
     */
    public var longPressGestureHandler: INSPhotosViewControllerLongPressHandler?
    
    /*
     * The overlay view displayed over photos, can be changed but must implement INSPhotosOverlayViewable
     */
    public var overlayView: INSPhotosOverlayViewable = INSPhotosOverlayView(frame: CGRect.zero) {
        willSet {
            overlayView.view().removeFromSuperview()
        }
        didSet {
            overlayView.photosViewController = self
            overlayView.view().autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            overlayView.view().frame = view.bounds
            view.addSubview(overlayView.view())
        }
    }

    /*
     * INSPhotoViewController is currently displayed by page view controller
     */
    public var currentPhotoViewController: INSPhotoViewController? {
        return pageViewController.viewControllers?.first as? INSPhotoViewController
    }
    
    /*
     * Photo object that is currently displayed by INSPhotoViewController
     */
    public var currentPhoto: INSPhotoViewable? {
        return currentPhotoViewController?.photo
    }
    
    public var currentDataSource: INSPhotosDataSource {
        return dataSource
    }
    
    // MARK: - Private
    private(set) var pageViewController: UIPageViewController!
    private(set) var dataSource: INSPhotosDataSource
    
    let interactiveAnimator: INSPhotosInteractionAnimator = INSPhotosInteractionAnimator()
    let transitionAnimator: INSPhotosTransitionAnimator = INSPhotosTransitionAnimator()
    
    private(set) lazy var singleTapGestureRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(INSPhotosViewController.handleSingleTapGestureRecognizer(_:)))
    }()
    private(set) lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(INSPhotosViewController.handlePanGestureRecognizer(_:)))
    }()
    
    private var interactiveDismissal: Bool = false
    private var statusBarHidden = false
    private var shouldHandleLongPressGesture = false
    
    // MARK: - Initialization
    
    deinit {
        pageViewController.delegate = nil
        pageViewController.dataSource = nil
    }
    
    required public init?(coder aDecoder: NSCoder) {
        dataSource = INSPhotosDataSource(photos: [])
        super.init(nibName: nil, bundle: nil)
        initialSetupWithInitialPhoto(nil)
    }
    
    public override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        dataSource = INSPhotosDataSource(photos: [])
        super.init(nibName: nil, bundle: nil)
        initialSetupWithInitialPhoto(nil)
    }
    
    /**
     The designated initializer that stores the array of objects implementing INSPhotoViewable
     
     - parameter photos:        An array of objects implementing INSPhotoViewable.
     - parameter initialPhoto:  The photo to display initially. Must be contained within the `photos` array.
     - parameter referenceView: The view from which to animate.
     
     - returns: A fully initialized object.
     */
    public init(photos: [INSPhotoViewable], initialPhoto: INSPhotoViewable? = nil, referenceView: UIView? = nil) {
        dataSource = INSPhotosDataSource(photos: photos)
        super.init(nibName: nil, bundle: nil)
        initialSetupWithInitialPhoto(initialPhoto)
        transitionAnimator.startingView = referenceView
        transitionAnimator.endingView = currentPhotoViewController?.scalingImageView.imageView
    }
    
    private func initialSetupWithInitialPhoto(initialPhoto: INSPhotoViewable? = nil) {
        overlayView.photosViewController = self
        setupPageViewControllerWithInitialPhoto(initialPhoto)

        modalPresentationStyle = .Custom
        transitioningDelegate = self
        modalPresentationCapturesStatusBarAppearance = true
        
        setupOverlayViewInitialItems()
    }
    
    private func setupOverlayViewInitialItems() {
        let textColor = view.tintColor ?? UIColor.whiteColor()
        if let overlayView = overlayView as? INSPhotosOverlayView {
            overlayView.photosViewController = self
            overlayView.titleTextAttributes = [NSForegroundColorAttributeName: textColor]
        }
    }
    
    // MARK: - View Life Cycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = UIColor.whiteColor()
        view.backgroundColor = UIColor.blackColor()
        pageViewController.view.backgroundColor = UIColor.clearColor()
        
        pageViewController.view.addGestureRecognizer(panGestureRecognizer)
        pageViewController.view.addGestureRecognizer(singleTapGestureRecognizer)
        
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        pageViewController.didMoveToParentViewController(self)
        
        setupOverlayView()
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // This fix issue that navigationBar animate to up
        // when presentingViewController is UINavigationViewController
        statusBarHidden = true
        UIView.animateWithDuration(0.25) { () -> Void in
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    private func setupOverlayView() {
        updateCurrentPhotosInformation()
        
        overlayView.view().autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        overlayView.view().frame = view.bounds
        view.addSubview(overlayView.view())
        overlayView.setHidden(true, animated: false)
    }
    
    private func setupPageViewControllerWithInitialPhoto(initialPhoto: INSPhotoViewable? = nil) {
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: 16.0])
        pageViewController.view.backgroundColor = UIColor.clearColor()
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        if let photo = initialPhoto where dataSource.containsPhoto(photo) {
            changeToPhoto(photo, animated: false)
        } else if let photo = dataSource.photos.first {
            changeToPhoto(photo, animated: false)
        }
    }
    
    private func updateCurrentPhotosInformation() {
        if let currentPhoto = currentPhoto {
            overlayView.populateWithPhoto(currentPhoto)
        }
    }
    
    // MARK: - Public
    
    /**
     Displays the specified photo. Can be called before the view controller is displayed. Calling with a photo not contained within the data source has no effect.
     
     - parameter photo:    The photo to make the currently displayed photo.
     - parameter animated: Whether to animate the transition to the new photo.
     */
    public func changeToPhoto(photo: INSPhotoViewable, animated: Bool) {
        if !dataSource.containsPhoto(photo) {
            return
        }
        let photoViewController = initializePhotoViewControllerForPhoto(photo)
        var direction = UIPageViewControllerNavigationDirection.Forward
            
        if let currentPhoto = currentPhoto {
            direction = self.dataSource.indexOfPhoto(currentPhoto) > self.dataSource.indexOfPhoto(photo) ? UIPageViewControllerNavigationDirection.Reverse : UIPageViewControllerNavigationDirection.Forward
        }
        pageViewController.setViewControllers([photoViewController], direction: direction, animated: animated, completion: nil)
        updateCurrentPhotosInformation()
    }
    
    // MARK: - Gesture Recognizers
    
    @objc private func handlePanGestureRecognizer(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .Began {
            interactiveDismissal = true
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            interactiveDismissal = false
            interactiveAnimator.handlePanWithPanGestureRecognizer(gestureRecognizer, viewToPan: pageViewController.view, anchorPoint: CGPoint(x: view.bounds.midX, y: view.bounds.midY))
        }
    }
    
    @objc private func handleSingleTapGestureRecognizer(gestureRecognizer: UITapGestureRecognizer) {
        overlayView.setHidden(!overlayView.view().hidden, animated: true)
    }
    
    // MARK: - View Controller Dismissal
    
    public override func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
        if presentedViewController != nil {
            super.dismissViewControllerAnimated(flag, completion: completion)
            return
        }
        var startingView: UIView?
        if currentPhotoViewController?.scalingImageView.imageView.image != nil {
            startingView = currentPhotoViewController?.scalingImageView.imageView
        }
        transitionAnimator.startingView = startingView
        
        if let currentPhoto = currentPhoto {
            transitionAnimator.endingView = referenceViewForPhotoWhenDismissingHandler?(photo: currentPhoto)
        } else {
            transitionAnimator.endingView = nil
        }
        let overlayWasHiddenBeforeTransition = overlayView.view().hidden
        overlayView.setHidden(true, animated: true)
        
        willDismissHandler?(viewController: self)
        
        super.dismissViewControllerAnimated(flag) { () -> Void in
            let isStillOnscreen = self.view.window != nil
            if isStillOnscreen && !overlayWasHiddenBeforeTransition {
                self.overlayView.setHidden(false, animated: true)
            }
            
            if !isStillOnscreen {
                self.didDismissHandler?(viewController: self)
            }
            completion?()
        }
    }
    
    // MARK: - UIPageViewControllerDataSource / UIPageViewControllerDelegate

    private func initializePhotoViewControllerForPhoto(photo: INSPhotoViewable) -> INSPhotoViewController {
        let photoViewController = INSPhotoViewController(photo: photo)
        singleTapGestureRecognizer.requireGestureRecognizerToFail(photoViewController.doubleTapGestureRecognizer)
        photoViewController.longPressGestureHandler = { [weak self] gesture in
            guard let weakSelf = self else {
                return
            }
            weakSelf.shouldHandleLongPressGesture = false
            
            if let gestureHandler = weakSelf.longPressGestureHandler {
                weakSelf.shouldHandleLongPressGesture = gestureHandler(photo: photo, gestureRecognizer: gesture)
            }
            weakSelf.shouldHandleLongPressGesture = !weakSelf.shouldHandleLongPressGesture
            
            if weakSelf.shouldHandleLongPressGesture {
                guard let view = gesture.view else {
                    return
                }
                let menuController = UIMenuController.sharedMenuController()
                var targetRect = CGRectZero
                targetRect.origin = gesture.locationInView(view)
                menuController.setTargetRect(targetRect, inView: view)
                menuController.setMenuVisible(true, animated: true)
            }
        }
        return photoViewController
    }
    
    @objc public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let photoViewController = viewController as? INSPhotoViewController,
           let photoIndex = dataSource.indexOfPhoto(photoViewController.photo),
           let newPhoto = dataSource[photoIndex-1] else {
            return nil
        }
        return initializePhotoViewControllerForPhoto(newPhoto)
    }
    
    @objc public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let photoViewController = viewController as? INSPhotoViewController,
            let photoIndex = dataSource.indexOfPhoto(photoViewController.photo),
            let newPhoto = dataSource[photoIndex+1] else {
                return nil
        }
        return initializePhotoViewControllerForPhoto(newPhoto)
    }
    
    @objc public func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            updateCurrentPhotosInformation()
            if let currentPhotoViewController = currentPhotoViewController {
                navigateToPhotoHandler?(photo: currentPhotoViewController.photo)
            }
        }
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionAnimator.dismissing = false
        return transitionAnimator
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionAnimator.dismissing = true
        return transitionAnimator
    }

    public func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if interactiveDismissal {
            transitionAnimator.endingViewForAnimation = transitionAnimator.endingView?.ins_snapshotView()
            interactiveAnimator.animator = transitionAnimator
            interactiveAnimator.shouldAnimateUsingAnimator = transitionAnimator.endingView != nil
            interactiveAnimator.viewToHideWhenBeginningTransition = transitionAnimator.startingView != nil ? transitionAnimator.endingView : nil
            
            return interactiveAnimator
        }
        return nil
    }
    
    // MARK: - UIResponder
    
    @objc public override func copy(sender: AnyObject?) {
        UIPasteboard.generalPasteboard().image = currentPhoto?.image ?? currentPhotoViewController?.scalingImageView.image
    }
    
    public override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    public override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if let _ = currentPhoto?.image ?? currentPhotoViewController?.scalingImageView.image where shouldHandleLongPressGesture && action == #selector(NSObject.copy(_:)) {
            return true
        }
        return false
    }
    
    // MARK: - Status Bar
    
    public override func prefersStatusBarHidden() -> Bool {
        if let parentStatusBarHidden = presentingViewController?.prefersStatusBarHidden() where parentStatusBarHidden == true {
            return parentStatusBarHidden
        }
        return statusBarHidden
    }
    
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    public override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Fade
    }
}

