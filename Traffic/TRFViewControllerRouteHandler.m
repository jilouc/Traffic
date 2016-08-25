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

@property (nonatomic, copy) UIViewController *(^creationBlock)(NSURL *, __kindof TRFViewControllerIntent *);
@property (nonatomic, copy) void (^presentationBlock)(__kindof UIViewController *, UIViewController *, NSURL *, __kindof TRFViewControllerIntent *);

@end

//////////////////////////////////////////////////////////////////////

@implementation TRFViewControllerRouteHandler

- (UIViewController *)targetViewControllerForURL:(NSURL *)URL intent:(TRFViewControllerIntent *)intent
{
    NSAssert(intent == nil || [intent isKindOfClass:[TRFViewControllerIntent class]], @"intent must be kind of TRFViewControllerIntent");
    if (self.creationBlock) {
        return self.creationBlock(URL, intent);
    }
    return nil;
}

- (TRFViewControllerContext *)viewControllerConfigurationContextForURL:(NSURL *)URL intent:(TRFViewControllerIntent *)intent
{
    NSAssert(intent == nil || [intent isKindOfClass:[TRFViewControllerIntent class]], @"intent must be kind of TRFViewControllerIntent");
    return nil;
}

- (void)presentTargetViewController:(UIViewController *)targetViewController
           presentingViewController:(UIViewController *)proposedPresentingViewController
                            withURL:(NSURL *)URL
                             intent:(TRFViewControllerIntent *)intent
{
    NSAssert(intent == nil || [intent isKindOfClass:[TRFViewControllerIntent class]], @"intent must be kind of TRFViewControllerIntent");
    if (self.presentationBlock) {
        self.presentationBlock(targetViewController, proposedPresentingViewController, URL, intent);
    } else {
        
        TRFViewControllerPreferredTransition preferredTransition = TRFViewControllerPreferredTransitionAuto;
        if (intent) {
            preferredTransition = intent.preferredTransition;
        }
        
        if (preferredTransition == TRFViewControllerPreferredTransitionPush || ![self shouldPresentModallyInViewController:proposedPresentingViewController]) {
            UINavigationController *navigationController = nil;
            if ([proposedPresentingViewController isKindOfClass:[UINavigationController class]]) {
                navigationController = (UINavigationController *)proposedPresentingViewController;
            } else if (proposedPresentingViewController.navigationController) {
                navigationController = navigationController;
            }
            if (navigationController) {
                [navigationController pushViewController:targetViewController animated:YES];
                return;
            }
        }
        
        UIViewController *presentedViewController = targetViewController;
        if ([self shouldWrapInNavigationControllerWhenPresentingInViewController:proposedPresentingViewController]) {
            Class navigationControllerClass = [self wrappingNavigationControllerClass];
            NSAssert([navigationControllerClass isSubclassOfClass:[UINavigationController class]], @"-wrappingNavigationControllerClass must return a UINavigationController subclass");
            presentedViewController = [[navigationControllerClass alloc] initWithRootViewController:targetViewController];
        }
        
        [self willPresentViewController:presentedViewController targetViewController:targetViewController];
        [proposedPresentingViewController presentViewController:presentedViewController animated:YES completion:^{
            [self didPresentViewController:presentedViewController targetViewController:targetViewController];
        }];
    }
}

+ (instancetype)routeHandlerWithCreationBlock:(UIViewController *(^)(NSURL *, __kindof TRFViewControllerIntent *))creationBlock
                            presentationBlock:(void (^)(__kindof UIViewController *, UIViewController *, NSURL *, __kindof TRFViewControllerIntent *))presentationBlock
{
    return [[self alloc] initWithCreationBlock:creationBlock
                             presentationBlock:presentationBlock];
}

- (instancetype)initWithCreationBlock:(UIViewController *(^)(NSURL *, __kindof TRFViewControllerIntent *))creationBlock
                    presentationBlock:(void(^)(__kindof UIViewController *, UIViewController *, NSURL *, __kindof TRFViewControllerIntent *))presentationBlock
{
    self = [self init];
    if (self) {
        self.creationBlock = creationBlock;
        self.presentationBlock = presentationBlock;
    }
    return self;
}

- (BOOL)handleURL:(NSURL *)URL intent:(TRFViewControllerIntent *)intent
{
    UIViewController *targetVC = [self targetViewControllerForURL:URL intent:intent];
    if (!targetVC) {
        return NO;
    }
    
    UIViewController *presentingVC = [[UIApplication sharedApplication].keyWindow trf_currentViewControllerForRoutePresenting];
    
    if ([targetVC conformsToProtocol:@protocol(TRFRouteTargetViewController)]) {
        id<TRFRouteTargetViewController> routeTargetVC = (id<TRFRouteTargetViewController>)targetVC;
        TRFViewControllerContext *configurationContext = [self viewControllerConfigurationContextForURL:URL intent:intent];
        [routeTargetVC configureWithTrafficContext:configurationContext];
    }
    
    [self presentTargetViewController:targetVC
             presentingViewController:presentingVC
                              withURL:URL
                              intent:intent];
    
    return YES;
}

- (BOOL)shouldPresentModallyInViewController:(UIViewController *)proposedPresentingViewController
{
    return YES;
}

- (BOOL)shouldWrapInNavigationControllerWhenPresentingInViewController:(UIViewController *)proposedPresentingViewController
{
    return NO;
}

- (Class)wrappingNavigationControllerClass
{
    return [UINavigationController class];
}

- (void)willPresentViewController:(UIViewController *)viewController targetViewController:(UIViewController *)targetViewController
{
    
}

- (void)didPresentViewController:(UIViewController *)viewController targetViewController:(UIViewController *)targetViewController
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
