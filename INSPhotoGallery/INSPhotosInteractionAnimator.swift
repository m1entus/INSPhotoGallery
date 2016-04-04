//
//  INSInteractionAnimator.swift
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

class INSPhotosInteractionAnimator: NSObject, UIViewControllerInteractiveTransitioning {
    var animator: UIViewControllerAnimatedTransitioning?
    var viewToHideWhenBeginningTransition: UIView?
    var shouldAnimateUsingAnimator: Bool = false
    
    private var transitionContext: UIViewControllerContextTransitioning?
    
    func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        viewToHideWhenBeginningTransition?.alpha = 0.0
        self.transitionContext = transitionContext
    }
    
    func handlePanWithPanGestureRecognizer(gestureRecognizer: UIPanGestureRecognizer, viewToPan: UIView, anchorPoint: CGPoint) {
        guard let fromView = transitionContext?.viewForKey(UITransitionContextFromViewKey) else {
            return
        }
        let translatedPanGesturePoint = gestureRecognizer.translationInView(fromView)
        let newCenterPoint = CGPoint(x: anchorPoint.x, y: anchorPoint.y + translatedPanGesturePoint.y)
        
        viewToPan.center = newCenterPoint
        
        let verticalDelta = newCenterPoint.y - anchorPoint.y
        let backgroundAlpha = backgroundAlphaForPanningWithVerticalDelta(verticalDelta)
        fromView.backgroundColor = fromView.backgroundColor?.colorWithAlphaComponent(backgroundAlpha)
        
        if gestureRecognizer.state == .Ended {
            finishPanWithPanGestureRecognizer(gestureRecognizer, verticalDelta: verticalDelta,viewToPan: viewToPan, anchorPoint: anchorPoint)
        }
    }
    
    func finishPanWithPanGestureRecognizer(gestureRecognizer: UIPanGestureRecognizer, verticalDelta: CGFloat, viewToPan: UIView, anchorPoint: CGPoint) {
        guard let fromView = transitionContext?.viewForKey(UITransitionContextFromViewKey) else {
            return
        }
        let returnToCenterVelocityAnimationRatio = 0.00007
        let panDismissDistanceRatio = 50.0 / 667.0 // distance over iPhone 6 height
        let panDismissMaximumDuration = 0.45
        
        let velocityY = gestureRecognizer.velocityInView(gestureRecognizer.view).y
        
        var animationDuration = (Double(abs(velocityY)) * returnToCenterVelocityAnimationRatio) + 0.2
        var animationCurve: UIViewAnimationOptions = .CurveEaseOut
        var finalPageViewCenterPoint = anchorPoint
        var finalBackgroundAlpha = 1.0
        
        let dismissDistance = panDismissDistanceRatio * Double(fromView.bounds.height)
        let isDismissing = Double(abs(verticalDelta)) > dismissDistance
        
        var didAnimateUsingAnimator = false
        
        if isDismissing {
            if let animator = self.animator, let transitionContext = transitionContext where shouldAnimateUsingAnimator {
                animator.animateTransition(transitionContext)
                didAnimateUsingAnimator = true
            } else {
                let isPositiveDelta = verticalDelta >= 0
                let modifier: CGFloat = isPositiveDelta ? 1 : -1
                let finalCenterY = fromView.bounds.midY + modifier * fromView.bounds.height
                finalPageViewCenterPoint = CGPoint(x: fromView.center.x, y: finalCenterY)
                
                animationDuration = Double(abs(finalPageViewCenterPoint.y - viewToPan.center.y) / abs(velocityY))
                animationDuration = min(animationDuration, panDismissMaximumDuration)
                animationCurve = .CurveEaseOut
                finalBackgroundAlpha = 0.0
            }
        }
        
        if didAnimateUsingAnimator {
            self.transitionContext = nil
        } else {
            UIView.animateWithDuration(animationDuration, delay: 0, options: animationCurve, animations: { () -> Void in
                viewToPan.center = finalPageViewCenterPoint
                fromView.backgroundColor = fromView.backgroundColor?.colorWithAlphaComponent(CGFloat(finalBackgroundAlpha))
                
            }, completion: { finished in
                if isDismissing {
                    self.transitionContext?.finishInteractiveTransition()
                } else {
                    self.transitionContext?.cancelInteractiveTransition()
                    if !self.isRadar20070670Fixed() {
                        self.fixCancellationStatusBarAppearanceBug()
                    }
                }
                
                self.viewToHideWhenBeginningTransition?.alpha = 1.0
                self.transitionContext?.completeTransition(isDismissing && !(self.transitionContext?.transitionWasCancelled() ?? false))
                self.transitionContext = nil
            })
        }
    }
    
    private func fixCancellationStatusBarAppearanceBug() {
        guard let toViewController = self.transitionContext?.viewControllerForKey(UITransitionContextToViewControllerKey),
            let fromViewController = self.transitionContext?.viewControllerForKey(UITransitionContextFromViewControllerKey) else {
                return
        }
        
        let statusBarViewControllerSelector = Selector("_setPresentedSta" + "tusBarViewController:")
        if toViewController.respondsToSelector(statusBarViewControllerSelector) && fromViewController.modalPresentationCapturesStatusBarAppearance {
            toViewController.performSelector(statusBarViewControllerSelector, withObject: fromViewController)
        }
    }
    
    private func isRadar20070670Fixed() -> Bool {
        return NSProcessInfo.processInfo().isOperatingSystemAtLeastVersion(NSOperatingSystemVersion.init(majorVersion: 8, minorVersion: 3, patchVersion: 0))
    }
    
    private func backgroundAlphaForPanningWithVerticalDelta(delta: CGFloat) -> CGFloat {
        guard let fromView = transitionContext?.viewForKey(UITransitionContextFromViewKey) else {
            return 0.0
        }
        
        let startingAlpha: CGFloat = 1.0
        let finalAlpha: CGFloat = 0.1
        let totalAvailableAlpha = startingAlpha - finalAlpha
        
        let maximumDelta = CGFloat(fromView.bounds.height / 2.0)
        let deltaAsPercentageOfMaximum = min(abs(delta) / maximumDelta, 1.0)
        return startingAlpha - (deltaAsPercentageOfMaximum * totalAvailableAlpha)
    }
}