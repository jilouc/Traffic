//
//  TRFIntent+PresentingWindow.m
//  Traffic
//
//  Created by Jean-Luc Dagon on 06/02/2018.
//  Copyright © 2018 Cocoapps. All rights reserved.
//

#import "TRFIntent+PresentingWindow.h"
#import <objc/runtime.h>

#if TARGET_OS_IOS

static const void *_TRFIntentPresentingWindowKey;

@implementation TRFIntent (PresentingWindow)

- (void)setPresentingWindow:(UIWindow *)presentingWindow
{
    objc_setAssociatedObject(self, &_TRFIntentPresentingWindowKey, presentingWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIWindow *)presentingWindow
{
    UIWindow *window = objc_getAssociatedObject(self, &_TRFIntentPresentingWindowKey);
    if (window) {
        return window;
    }
    return [[UIApplication sharedApplication] keyWindow];
}

@end

#endif
