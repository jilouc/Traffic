//
//  TRFSampleTabBarViewController.m
//  TrafficExample
//
//  Created by Jean-Luc Dagon on 02/08/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

#import "TRFSampleTabBarViewController.h"
#import "TRFSampleTab1ViewController.h"
#import "TRFSampleTab2ViewController.h"

@implementation TRFSampleTabBarViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        TRFSampleTab1ViewController *tab1VC = [TRFSampleTab1ViewController new];
        TRFSampleTab2ViewController *tab2VC = [TRFSampleTab2ViewController new];
        
        UINavigationController *nav1VC = [[UINavigationController alloc] initWithRootViewController:tab1VC];
        nav1VC.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemRecents
                                                                       tag:0];
        UINavigationController *nav2VC = [[UINavigationController alloc] initWithRootViewController:tab2VC];
        nav2VC.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFeatured
                                                                       tag:0];
        
        self.viewControllers = @[
                                 nav1VC,
                                 nav2VC,
                                 ];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
}

@end
