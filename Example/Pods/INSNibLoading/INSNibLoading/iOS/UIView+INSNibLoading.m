//
//  NSView+INSNibLoading.m
//  NSView+INSNibLoading
//
//  Copyright © 2013 Nicolas Bouilleaud
//  UIView+NibLoading.h
//
//  Copyright © 2015 Inspace Labs Sp z o. o. Spółka Komandytowa. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "UIView+INSNibLoading.h"
#import <objc/runtime.h>

static char INSNibLoadingAssociatedNibsKey;
static char INSNibLoadingOutletsKey;

@implementation UIView (INSNibLoading)

+ (UINib *)ins_nibLoadingAssociatedNibWithName:(NSString *)nibName bundle:(NSBundle *)bundle {
    
    NSDictionary *associatedNibs = objc_getAssociatedObject(self, &INSNibLoadingAssociatedNibsKey);
    UINib *nib = associatedNibs[nibName];
    if (!nib) {
        nib = [UINib nibWithNibName:nibName bundle:bundle];
        if (nib) {
            NSMutableDictionary *newNibs = [NSMutableDictionary dictionaryWithDictionary:associatedNibs];
            newNibs[nibName] = nib;
            objc_setAssociatedObject(self, &INSNibLoadingAssociatedNibsKey, [NSDictionary dictionaryWithDictionary:newNibs], OBJC_ASSOCIATION_RETAIN);
        }
    }

    return nib;
}

- (UIView *)ins_contentViewForNib {
    return self;
}

- (void)ins_loadContentsFromNibNamed:(NSString *)nibName bundle:(NSBundle *)bundle {
    // Load the nib file, setting self as the owner.
    // The root view is only a container and is discarded after loading.
    UINib *nib = [[self class] ins_nibLoadingAssociatedNibWithName:nibName bundle:bundle];
    NSAssert(nib != nil, @"NSView+INSNibLoading : Can't load nib named %@.", nibName);

    // Instantiate (and keep a list of the outlets set through KVC.)
    NSMutableDictionary *outlets = [NSMutableDictionary new];
    objc_setAssociatedObject(self, &INSNibLoadingOutletsKey, outlets, OBJC_ASSOCIATION_RETAIN);
    
    NSArray *views = [nib instantiateWithOwner:self options:nil];
    NSAssert(views != nil, @"NSView+INSNibLoading : Can't instantiate nib named %@.", nibName);
    
    objc_setAssociatedObject(self, &INSNibLoadingOutletsKey, nil, OBJC_ASSOCIATION_RETAIN);

    // Search for the first encountered UIView base object
    UIView *containerView = nil;
    for (id v in views) {
        if ([v isKindOfClass:[UIView class]]) {
            containerView = v;
            break;
        }
    }
    NSAssert(containerView != nil, @"NSView+INSNibLoading : There is no container UIView found at the root of nib %@.", nibName);

    [containerView setTranslatesAutoresizingMaskIntoConstraints:NO];

    if (CGRectEqualToRect(self.bounds, CGRectZero)) {
        // `self` has no size : use the containerView's size, from the nib file
        self.bounds = containerView.bounds;
    } else {
        // `self` has a specific size : resize the containerView to this size, so that the subviews are autoresized.
        containerView.bounds = self.bounds;
    }

    // Save constraints for later
    NSArray *constraints = containerView.constraints;

    // reparent the subviews from the nib file
    for (UIView *view in containerView.subviews) {
        if (view.superview) {
            [view removeFromSuperview];
        }
        [[self ins_contentViewForNib] addSubview:view];
    }
    
    // Recreate constraints, replace containerView with self
    for (NSLayoutConstraint *oldConstraint in constraints) {
        id firstItem = oldConstraint.firstItem;
        id secondItem = oldConstraint.secondItem;
        if (firstItem == containerView) {
            firstItem = [self ins_contentViewForNib];
        }
        if (secondItem == containerView) {
            secondItem = [self ins_contentViewForNib];
        }

        NSLayoutConstraint *newConstraint = [NSLayoutConstraint constraintWithItem:firstItem
                                                                         attribute:oldConstraint.firstAttribute
                                                                         relatedBy:oldConstraint.relation
                                                                            toItem:secondItem
                                                                         attribute:oldConstraint.secondAttribute
                                                                        multiplier:oldConstraint.multiplier
                                                                          constant:oldConstraint.constant];
        [self addConstraint:newConstraint];

        // If there was outlet(s) to the old constraint, replace it with the new constraint.
        for (NSString *key in outlets) {
            if (outlets[key] == oldConstraint) {
                NSAssert([self valueForKey:key] == oldConstraint, @"NSView+INSNibLoading : Unexpected value for outlet %@ of view %@. Expected %@, found %@.", key, self, oldConstraint, [self valueForKey:key]);
                [self setValue:newConstraint forKey:key];
            }
        }
    }
}

- (void)setValue:(id)value forKey:(NSString *)key {
    // Keep a list of the outlets set during nib loading.
    // (See above: This associated object only exists during nib-loading)
    NSMutableDictionary *outlets = objc_getAssociatedObject(self, &INSNibLoadingOutletsKey);
    outlets[key] = value;
    [super setValue:value forKey:key];
}

- (void)ins_loadContentsFromNibNamed:(NSString *)nibName {
    [self ins_loadContentsFromNibNamed:nibName bundle:[NSBundle bundleForClass:[self class]]];
}

- (void)ins_loadContentsFromNib {
    NSString *className = NSStringFromClass([self class]);
    
    // A Swift class name will be in the format of ModuleName.ClassName
    // We want to remove the module name so the Nib can have exactly the same file name as the class
    NSRange range = [className rangeOfString:@"."];
    if (range.location != NSNotFound) {
        className = [className substringFromIndex:range.location + range.length];
    }
    [self ins_loadContentsFromNibNamed:className];
}

@end

#pragma mark - INSNibLoadedView

@implementation INSNibLoadedView : UIView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self ins_loadContentsFromNib];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self ins_loadContentsFromNib];
        [self awakeFromNib];
    }
    
    return self;
}

@end
