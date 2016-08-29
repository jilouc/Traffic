//
//  TRFSampleBrowserRouteHandler.m
//  TrafficExample
//
//  Created by Jean-Luc Dagon on 26/08/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

#import "TRFSampleBrowserRouteHandler.h"
#import <SafariServices/SafariServices.h>
#import "TRFSampleBrowserViewControllerIntent.h"

@implementation TRFSampleBrowserRouteHandler

- (TRFViewControllerIntent *)intentForIntent:(TRFIntent *)intent
{
    return [TRFSampleBrowserViewControllerIntent new];
}

- (UIViewController *)targetViewControllerForIntent:(TRFSampleBrowserViewControllerIntent *)intent
{
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:intent.webURL];
    return safariVC;
}

@end
