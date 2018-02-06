//
//  TRFIntent+PresentingWindow.h
//  Traffic
//
//  Created by Jean-Luc Dagon on 06/02/2018.
//  Copyright © 2018 Cocoapps. All rights reserved.
//

#import "TRFIntent.h"

#import <TargetConditionals.h>

#if TARGET_OS_IOS

#import <UIKit/UIKit.h>

@interface TRFIntent (PresentingWindow)

- (UIWindow *)presentingWindow NS_EXTENSION_UNAVAILABLE("Not supported in extensions");
- (void)setPresentingWindow:(UIWindow *)presentingWindow NS_EXTENSION_UNAVAILABLE("Not supported in extensions");

@end

#endif
