//
//  TRFSampleTabBarRouteHandler.m
//  TrafficExample
//
//  Created by Jean-Luc Dagon on 03/08/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

#import "TRFSampleTabBarRouteHandler.h"
#import "TRFSampleTabBarViewController.h"
#import "TRFSampleTabBarRouteContext.h"

@implementation TRFSampleTabBarRouteHandler

- (TRFSampleTabBarViewController *)targetViewControllerForURL:(NSURL *)URL context:(id)context
{
    return [TRFSampleTabBarViewController new];
}

- (id)contextForURL:(NSURL *)URL context:(id)context
{
    TRFSampleTabBarRouteContext *c = [TRFSampleTabBarRouteContext new];
    c.baseContext = context;
    c.tabBarController = (TRFSampleTabBarViewController *)[self targetViewControllerForURL:URL context:context];
    return c;
}

@end
