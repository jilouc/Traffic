//
//  TRFViewControllerRouteHandler.h
//  Copyright © 2016 Cocoapps. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "TRFRouteHandler.h"
#import "TRFViewControllerIntent.h"

@import UIKit;

//////////////////////////////////////////////////////////////////////

@interface TRFViewControllerRouteHandler : TRFRouteHandler

+ (instancetype)routeHandlerWithBlock:(void (^)(TRFViewControllerIntent *intent))block NS_UNAVAILABLE;

+ (instancetype)routeHandlerWithCreationBlock:(UIViewController *(^)(__kindof TRFViewControllerIntent *intent))creationBlock
                            presentationBlock:(void(^)(__kindof UIViewController *targetViewController, UIViewController *proposedPresentingViewController, __kindof TRFViewControllerIntent *intent))presentationBlock;

- (Class)targetViewControllerClassForIntent:(TRFViewControllerIntent *)intent;
- (UIViewController *)targetViewControllerForIntent:(TRFViewControllerIntent *)intent;
- (TRFViewControllerIntent *)intentForIntent:(TRFIntent *)intent;

- (void)presentTargetViewController:(UIViewController *)targetViewController
           presentingViewController:(UIViewController *)proposedPresentingViewController
                              intent:(TRFViewControllerIntent *)intent;

- (BOOL)shouldPresentModallyInViewController:(UIViewController *)proposedPresentingViewController intent:(TRFViewControllerIntent *)intent;

- (BOOL)shouldWrapInNavigationControllerWhenPresentingInViewController:(UIViewController *)proposedPresentingViewController intent:(TRFViewControllerIntent *)intent;
- (Class)wrappingNavigationControllerClass;

- (UIModalPresentationStyle)modalPresentationStyleWhenPresentingInViewController:(UIViewController *)proposedPresentingViewController intent:(TRFViewControllerIntent *)intent;

- (UIModalTransitionStyle)modalTransitionStyleWhenPresentingInViewController:(UIViewController *)proposedPresentingViewController intent:(TRFViewControllerIntent *)intent;

- (void)willPresentViewController:(UIViewController *)viewController targetViewController:(UIViewController *)targetViewController intent:(TRFViewControllerIntent *)intent;
- (void)didPresentViewController:(UIViewController *)viewController targetViewController:(UIViewController *)targetViewController intent:(TRFViewControllerIntent *)intent;



@end

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

@interface UIWindow (TRFViewControllerRoutePresenting)

- (UIViewController *)trf_currentViewControllerForRoutePresenting;

@end
