//
//  INSPhotosTransitionAnimator.swift
//  INSPhotoViewer
//
//  Created by Michal Zaborowski on 28.02.2016.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

import UIKit

class INSPhotosTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var dismissing: Bool = false
    
    var startingView: UIView?
    var endingView: UIView?
    
    var startingViewForAnimation: UIView?
    var endingViewForAnimation: UIView?
    
    var animationDurationWithZooming = 0.5
    var animationDurationWithoutZooming = 0.3
    var animationDurationFadeRatio = 4.0 / 9.0 {
        didSet(value) {
            animationDurationFadeRatio = min(value, 1.0)
        }
    }
    var animationDurationEndingViewFadeInRatio = 0.1 {
        didSet(value) {
            animationDurationEndingViewFadeInRatio = min(value, 1.0)
        }
    }
    var animationDurationStartingViewFadeOutRatio = 0.05 {
        didSet(value) {
            animationDurationStartingViewFadeOutRatio = min(value, 1.0)
        }
    }
    var zoomingAnimationSpringDamping = 0.9
    
    var shouldPerformZoomingAnimation: Bool {
        get {
            return self.startingView != nil && self.endingView != nil
        }
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        if shouldPerformZoomingAnimation {
            return animationDurationWithZooming
        }
        return animationDurationWithoutZooming
    }
    
    func fadeDurationForTransitionContext(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        if shouldPerformZoomingAnimation {
            return transitionDuration(transitionContext) * animationDurationFadeRatio
        }
        return transitionDuration(transitionContext)
    }
    
    // MARK:- UIViewControllerAnimatedTransitioning
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        setupTransitionContainerHierarchyWithTransitionContext(transitionContext)
        
        // There is issue with startingView frame when performFadeAnimation
        // is called and prefersStatusBarHidden == true originY is moved 20px up,
        // so order of this two methods is important! zooming need to be first than fading
        if shouldPerformZoomingAnimation {
            performZoomingAnimationWithTransitionContext(transitionContext)
        }
        performFadeAnimationWithTransitionContext(transitionContext)
    }
    
    func setupTransitionContainerHierarchyWithTransitionContext(transitionContext: UIViewControllerContextTransitioning) {
        
        if let toView = transitionContext.viewForKey(UITransitionContextToViewKey),
           let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) {
            toView.frame = transitionContext.finalFrameForViewController(toViewController)
            if let containerView = transitionContext.containerView() where !toView.isDescendantOfView(containerView) {
                containerView.addSubview(toView)
            }
        }
        
        if dismissing {
            if let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey) {
                transitionContext.containerView()?.bringSubviewToFront(fromView)
            }
        }
    }
    
    func performFadeAnimationWithTransitionContext(transitionContext: UIViewControllerContextTransitioning) {
        let fadeView = dismissing ? transitionContext.viewForKey(UITransitionContextFromViewKey) : transitionContext.viewForKey(UITransitionContextToViewKey)
        let beginningAlpha: CGFloat = dismissing ? 1.0 : 0.0
        let endingAlpha: CGFloat = dismissing ? 0.0 : 1.0
        
        fadeView?.alpha = beginningAlpha

        UIView.animateWithDuration(fadeDurationForTransitionContext(transitionContext), animations: { () -> Void in
            fadeView?.alpha = endingAlpha
        }) { finished in
            if !self.shouldPerformZoomingAnimation {
                self.completeTransitionWithTransitionContext(transitionContext)
            }
        }
    }
    
    func performZoomingAnimationWithTransitionContext(transitionContext: UIViewControllerContextTransitioning) {
        
        guard let containerView = transitionContext.containerView() else {
            return
        }
        guard let startingView = startingView, let endingView = endingView else {
            return
        }
        guard let startingViewForAnimation = self.startingViewForAnimation ?? self.startingView?.ins_snapshotView(),
            let endingViewForAnimation = self.endingViewForAnimation ?? self.endingView?.ins_snapshotView() else {
                return
        }
        
        let finalEndingViewTransform = endingView.transform
        let endingViewInitialTransform = startingViewForAnimation.frame.height / endingViewForAnimation.frame.height
        let translatedStartingViewCenter = startingView.ins_translatedCenterPointToContainerView(containerView)
        
        startingViewForAnimation.center = translatedStartingViewCenter
        
        endingViewForAnimation.transform = CGAffineTransformScale(endingViewForAnimation.transform, endingViewInitialTransform, endingViewInitialTransform)
        endingViewForAnimation.center = translatedStartingViewCenter
        endingViewForAnimation.alpha = 0.0
        
        containerView.addSubview(startingViewForAnimation)
        containerView.addSubview(endingViewForAnimation)
        
        // Hide the original ending view and starting view until the completion of the animation.
        endingView.alpha = 0.0
        startingView.alpha = 0.0
        
        let fadeInDuration = transitionDuration(transitionContext) * animationDurationEndingViewFadeInRatio
        let fadeOutDuration = transitionDuration(transitionContext) * animationDurationStartingViewFadeOutRatio
        
        // Ending view / starting view replacement animation
        UIView.animateWithDuration(fadeInDuration, delay: 0.0, options: [.AllowAnimatedContent,.BeginFromCurrentState], animations: { () -> Void in
            endingViewForAnimation.alpha = 1.0
        }) { result in
            UIView.animateWithDuration(fadeOutDuration, delay: 0.0, options: [.AllowAnimatedContent,.BeginFromCurrentState], animations: { () -> Void in
                startingViewForAnimation.alpha = 0.0
            }, completion: { result in
                startingViewForAnimation.removeFromSuperview()
            })
        }
        
        let startingViewFinalTransform = 1.0 / endingViewInitialTransform
        let translatedEndingViewFinalCenter = endingView.ins_translatedCenterPointToContainerView(containerView)
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0.0, usingSpringWithDamping:CGFloat(zoomingAnimationSpringDamping), initialSpringVelocity:0, options: [.AllowAnimatedContent,.BeginFromCurrentState], animations: { () -> Void in
            endingViewForAnimation.transform = finalEndingViewTransform
            endingViewForAnimation.center = translatedEndingViewFinalCenter
            startingViewForAnimation.transform = CGAffineTransformScale(startingViewForAnimation.transform, startingViewFinalTransform, startingViewFinalTransform)
            startingViewForAnimation.center = translatedEndingViewFinalCenter
            
        }) { result in
            endingViewForAnimation.removeFromSuperview()
            endingView.alpha = 1.0
            startingView.alpha = 1.0
            self.completeTransitionWithTransitionContext(transitionContext)
        }
    }
    
    func completeTransitionWithTransitionContext(transitionContext: UIViewControllerContextTransitioning) {
        if transitionContext.isInteractive() {
            if transitionContext.transitionWasCancelled() {
                transitionContext.cancelInteractiveTransition()
            } else {
                transitionContext.finishInteractiveTransition()
            }
        }
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
    }
}