//
//  AppDelegate.m
//  TrafficExample
//
//  Created by Jean-Luc Dagon on 29/05/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

#import "AppDelegate.h"
#import "TRFUIRouter.h"
#import "TRFViewControllerRouteHandler.h"
#import "NSURL+TRFRoute.h"

#import "TRFSampleTabBarViewController.h"
#import "TRFSampleTabBarRouteHandler.h"

@interface AppDelegate ()

@property (nonatomic) TRFUIRouter *uiRouter;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self createRoutes];
    
    return YES;
}

- (void)createRoutes
{
    TRFUIRouter *uiRouter = [TRFUIRouter new];
    self.uiRouter = uiRouter;
    
    TRFRouteHandler *recentsTabHandler;
    recentsTabHandler = [TRFRouteHandler
                         routeHandlerWithBlock:^(NSURL *URL, id context, void (^completionBlock)(BOOL stop)) {
                             NSLog(@"handling %@", [URL.trf_route debugDescription]);
                             completionBlock(NO);
                         }];
    TRFRouteHandler *featuredTabHandler;
    featuredTabHandler = [TRFRouteHandler
                          routeHandlerWithBlock:^(NSURL *URL, id context, void (^completionBlock)(BOOL stop)) {
                              NSLog(@"handling %@", [URL.trf_route debugDescription]);
                              completionBlock(NO);
                          }];
    
    TRFRoute *tabBarRoute = [TRFRoute routeWithScheme:nil pattern:@"tabbar" handler:[TRFSampleTabBarRouteHandler new]];
    TRFRoute *recentsTabRoute = [TRFRoute routeWithScheme:nil pattern:@"recents" handler:recentsTabHandler];
    TRFRoute *featureTabRoute = [TRFRoute routeWithScheme:nil pattern:@"featured" handler:featuredTabHandler];
    [tabBarRoute addChildRoutes:@[recentsTabRoute, featureTabRoute]];
    
//    TRFRoute *tabBarRoute = [TRFRoute routeWithScheme:nil pattern:@"tabbar" handler:tabBarHandler];
    [uiRouter registerRoute:tabBarRoute];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    return [self.uiRouter routeURL:url context:options];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
