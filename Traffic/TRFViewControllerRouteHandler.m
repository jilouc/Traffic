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

@property (nonatomic, copy) UIViewController *(^creationBlock)(NSURL *, id);
@property (nonatomic, copy) void (^presentationBlock)(__kindof UIViewController *, UIViewController *, NSURL *, id);

@end

//////////////////////////////////////////////////////////////////////

@implementation TRFViewControllerRouteHandler

- (UIViewController *)targetViewControllerForURL:(NSURL *)URL context:(id)context
{
    if (self.creationBlock) {
        return self.creationBlock(URL, context);
    }
    return nil;
}

- (TRFViewControllerContext *)viewControllerConfigurationContextForURL:(NSURL *)URL context:(id)context
{
    return nil;
}

- (void)presentTargetViewController:(UIViewController *)targetViewController
           presentingViewController:(UIViewController *)proposedPresentingViewController
                            withURL:(NSURL *)URL
                            context:(id)context
{
    if (self.presentationBlock) {
        self.presentationBlock(targetViewController, proposedPresentingViewController, URL, context);
    } else {
        [proposedPresentingViewController presentViewController:targetViewController animated:YES completion:nil];
    }
}

+ (instancetype)routeHandlerWithCreationBlock:(UIViewController *(^)(NSURL *, id))creationBlock
                            presentationBlock:(void (^)(__kindof UIViewController *, UIViewController *, NSURL *, id))presentationBlock
{
    return [[self alloc] initWithCreationBlock:creationBlock
                             presentationBlock:presentationBlock];
}

- (instancetype)initWithCreationBlock:(UIViewController *(^)(NSURL *, id))creationBlock
                    presentationBlock:(void(^)(__kindof UIViewController *, UIViewController *, NSURL *, id))presentationBlock
{
    self = [self init];
    if (self) {
        self.creationBlock = creationBlock;
        self.presentationBlock = presentationBlock;
    }
    return self;
}

- (BOOL)handleURL:(NSURL *)URL context:(id)context
{
    UIViewController *targetVC = [self targetViewControllerForURL:URL context:context];
    if (!targetVC) {
        return NO;
    }
    UIViewController *presentingVC = [[UIApplication sharedApplication].keyWindow trf_currentViewControllerForRoutePresenting];
    
    if ([targetVC conformsToProtocol:@protocol(TRFRouteTargetViewController)]) {
        id<TRFRouteTargetViewController> routeTargetVC = (id<TRFRouteTargetViewController>)targetVC;
        TRFViewControllerContext *configurationContext = [self viewControllerConfigurationContextForURL:URL context:context];
        [routeTargetVC configureWithTrafficContext:configurationContext];
    }
    
    [self presentTargetViewController:targetVC
             presentingViewController:presentingVC
                              withURL:URL
                              context:context];
    
    return YES;
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
