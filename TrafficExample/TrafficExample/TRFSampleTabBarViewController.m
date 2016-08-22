//
//  TRFSampleTabBarViewController.m
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

#import "TRFSampleTabBarViewController.h"
#import "TRFSampleTabRecentsViewController.h"
#import "TRFSampleTabFeaturedViewController.h"
#import "TRFSampleTabBarViewControllerContext.h"

@implementation TRFSampleTabBarViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        TRFSampleTabRecentsViewController *tab1VC = [TRFSampleTabRecentsViewController new];
        TRFSampleTabFeaturedViewController *tab2VC = [TRFSampleTabFeaturedViewController new];
        
        UINavigationController *nav1VC = [[UINavigationController alloc] initWithRootViewController:tab1VC];
        nav1VC.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemRecents
                                                                       tag:0];
        tab1VC.title = @"Recents";
        
        UINavigationController *nav2VC = [[UINavigationController alloc] initWithRootViewController:tab2VC];
        nav2VC.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFeatured
                                                                       tag:0];
        tab2VC.title = @"Featured";
        
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

- (void)configureWithTrafficContext:(TRFSampleTabBarViewControllerContext *)configurationContext
                         completion:(void (^)(id, BOOL))completion
{
    switch (configurationContext.selectedTab) {
        case TRFSampleTabBarTabRecents:
            self.selectedIndex = 0;
            break;
        case TRFSampleTabBarTabFeatured:
            self.selectedIndex = 1;
            break;
        default:
            break;
    }
    
    completion(configurationContext.urlContext, NO);
}

@end
