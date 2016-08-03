//
//  TRFSampleTab1ViewController.m
//  TrafficExample
//
//  Created by Jean-Luc Dagon on 02/08/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

#import "TRFSampleTab1ViewController.h"

@implementation TRFSampleTab1ViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.navigationItem.titleView = [[UISegmentedControl alloc] initWithItems:@[@"Tab 1", @"Tab 2", @"Tab 3"]];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
}

@end
