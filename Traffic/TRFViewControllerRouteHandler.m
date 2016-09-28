//
//  TRFViewControllerRouteHandler.m
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

#import "TRFViewControllerRouteHandler.h"
#import "TRFRouteTargetViewController.h"

//////////////////////////////////////////////////////////////////////

@interface TRFViewControllerRouteHandler ()

@property (nonatomic, copy) UIViewController *(^creationBlock)(__kindof TRFViewControllerIntent *);
@property (nonatomic, copy) void (^presentationBlock)(__kindof UIViewController *, UIViewController *, __kindof TRFViewControllerIntent *);

@end

//////////////////////////////////////////////////////////////////////

@implementation TRFViewControllerRouteHandler

- (TRFViewControllerIntent *)intentForIntent:(TRFIntent *)intent
{
    NSCParameterAssert(intent != nil);
    TRFViewControllerIntent *handlerIntent = [TRFViewControllerIntent new];
    return handlerIntent;
}

- (Class)targetViewControllerClassForIntent:(TRFViewControllerIntent *)intent
{
    return [[self targetViewControllerForIntent:intent] class];
}

- (UIViewController *)targetViewControllerForIntent:(TRFViewControllerIntent *)intent
{
    NSCParameterAssert([intent isKindOfClass:[TRFViewControllerIntent class]]);
    if (self.creationBlock) {
        return self.creationBlock(intent);
    }
    return nil;
}

- (UIViewController *)prepareTargetViewController:(UIViewController *)targetViewController
                  forPresentationInViewController:(UIViewController *)presentingViewController
                                           intent:(TRFViewControllerIntent *)intent
{
    UIViewController *presentedViewController = targetViewController;
    if ([self shouldWrapInNavigationControllerWhenPresentingInViewController:presentingViewController intent:intent]) {
        Class navigationControllerClass = [self wrappingNavigationControllerClass];
        NSAssert([navigationControllerClass isSubclassOfClass:[UINavigationController class]], @"-wrappingNavigationControllerClass must return a UINavigationController subclass, but got %@", NSStringFromClass(navigationControllerClass));
        presentedViewController = [[navigationControllerClass alloc] initWithRootViewController:targetViewController];
    }
    
    if (intent.wrapInPopover) {
        targetViewController.preferredContentSize = intent.popoverPreferredContentSize;
        presentedViewController.modalPresentationStyle = UIModalPresentationPopover;
        
        UIPopoverPresentationController *presentationController = presentedViewController.popoverPresentationController;
        presentationController.sourceView = intent.popoverSourceView;
        presentationController.sourceRect = intent.popoverSourceRect;
        presentationController.delegate = intent.popoverPresentationDelegate;
    }
    
    presentedViewController.modalPresentationStyle = [self modalPresentationStyleWhenPresentingInViewController:presentingViewController intent:intent];
    
    presentedViewController.modalTransitionStyle = [self modalTransitionStyleWhenPresentingInViewController:presentingViewController intent:intent];
    
    return presentedViewController;
}

- (void)presentTargetViewController:(UIViewController *)targetViewController
           presentingViewController:(UIViewController *)proposedPresentingViewController
                             intent:(TRFViewControllerIntent *)intent
{
    
    NSCParameterAssert([intent isKindOfClass:[TRFViewControllerIntent class]]);
    if (self.presentationBlock) {
        self.presentationBlock(targetViewController, proposedPresentingViewController, intent);
    } else {
        
        TRFViewControllerPreferredTransition preferredTransition = TRFViewControllerPreferredTransitionAuto;
        if (intent) {
            preferredTransition = intent.preferredTransition;
        }
        
        BOOL transitionPush = (preferredTransition == TRFViewControllerPreferredTransitionPush &&
                               ![self shouldPresentModallyInViewController:proposedPresentingViewController intent:intent]);
        if (transitionPush) {
            UINavigationController *navigationController = nil;
            if ([proposedPresentingViewController isKindOfClass:[UINavigationController class]]) {
                navigationController = (UINavigationController *)proposedPresentingViewController;
            } else if (proposedPresentingViewController.navigationController) {
                navigationController = proposedPresentingViewController.navigationController;
            }
            if (navigationController) {
                [navigationController pushViewController:targetViewController animated:YES];
                return;
            }
        }
        
        UIViewController *presentedViewController = [self prepareTargetViewController:targetViewController
                                                      forPresentationInViewController:proposedPresentingViewController
                                                                               intent:intent];
        
        if (intent.deferredPresentation) {
            intent.targetViewController = targetViewController;
            intent.presentedViewController = presentedViewController;
            return;
        }
        
        [self presentTargetViewController:targetViewController
                  presentedViewController:presentedViewController
                 presentingViewController:proposedPresentingViewController
                                   intent:intent];
        
    }
}

- (void)presentTargetViewController:(UIViewController *)targetViewController
            presentedViewController:(UIViewController *)presentedViewController
           presentingViewController:(UIViewController *)presentingViewController
                             intent:(TRFViewControllerIntent *)intent
{
    [self willPresentViewController:presentedViewController targetViewController:targetViewController intent:intent];
    [presentingViewController presentViewController:presentedViewController animated:YES completion:^{
        [self didPresentViewController:presentedViewController targetViewController:targetViewController intent:intent];
    }];
}


+ (instancetype)routeHandlerWithCreationBlock:(UIViewController *(^)(__kindof TRFViewControllerIntent *))creationBlock
                            presentationBlock:(void (^)(__kindof UIViewController *, UIViewController *, __kindof TRFViewControllerIntent *))presentationBlock
{
    return [[self alloc] initWithCreationBlock:creationBlock
                             presentationBlock:presentationBlock];
}

- (instancetype)initWithCreationBlock:(UIViewController *(^)(__kindof TRFViewControllerIntent *))creationBlock
                    presentationBlock:(void(^)(__kindof UIViewController *, UIViewController *, __kindof TRFViewControllerIntent *))presentationBlock
{
    self = [self init];
    if (self) {
        self.creationBlock = creationBlock;
        self.presentationBlock = presentationBlock;
    }
    return self;
}

- (BOOL)handleIntent:(TRFViewControllerIntent *)intent
{
    UIViewController *targetVC = [self targetViewControllerForIntent:intent];
    if (!targetVC) {
        return NO;
    }
    
    UIViewController *presentingVC = [[UIApplication sharedApplication].keyWindow trf_currentViewControllerForRoutePresenting];
    
    if ([targetVC conformsToProtocol:@protocol(TRFRouteTargetViewController)]) {
        id<TRFRouteTargetViewController> routeTargetVC = (id<TRFRouteTargetViewController>)targetVC;
        [routeTargetVC configureWithTrafficIntent:intent];
    }
    
    [self presentTargetViewController:targetVC
             presentingViewController:presentingVC
                               intent:intent];
    
    return YES;
}

- (BOOL)shouldPresentModallyInViewController:(UIViewController *)proposedPresentingViewController intent:(TRFViewControllerIntent *)intent
{
    return YES;
}

- (BOOL)shouldWrapInNavigationControllerWhenPresentingInViewController:(UIViewController *)proposedPresentingViewController intent:(TRFViewControllerIntent *)intent
{
    return NO;
}

- (Class)wrappingNavigationControllerClass
{
    return [UINavigationController class];
}

- (UIModalPresentationStyle)modalPresentationStyleWhenPresentingInViewController:(UIViewController *)proposedPresentingViewController intent:(TRFViewControllerIntent *)intent
{
    return UIModalPresentationFullScreen;
}

- (UIModalTransitionStyle)modalTransitionStyleWhenPresentingInViewController:(UIViewController *)proposedPresentingViewController intent:(TRFViewControllerIntent *)intent
{
    return UIModalTransitionStyleCoverVertical;
}

- (void)willPresentViewController:(UIViewController *)viewController targetViewController:(UIViewController *)targetViewController intent:(TRFViewControllerIntent *)intent
{
    
}

- (void)didPresentViewController:(UIViewController *)viewController targetViewController:(UIViewController *)targetViewController intent:(TRFViewControllerIntent *)intent
{
    
}

@end

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

@implementation UIWindow (TRFViewControllerRoutePresenting)

- (UIViewController *)trf_currentViewControllerForRoutePresentingInViewController:(UIViewController *)viewController
{
    UIViewController *vc = viewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarVC = (UITabBarController *)vc;
        vc = tabBarVC.selectedViewController;
        return [self trf_currentViewControllerForRoutePresentingInViewController:vc];
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)vc;
        UIViewController *topVC = navController.topViewController;
        if (!topVC) {
            return navController;
        }
        return [self trf_currentViewControllerForRoutePresentingInViewController:topVC];
    }
    return vc;
}

- (UIViewController *)trf_currentViewControllerForRoutePresenting
{
    return [self trf_currentViewControllerForRoutePresentingInViewController:self.rootViewController];
}

@end
