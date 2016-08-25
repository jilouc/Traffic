//
//  TRFViewControllerIntent.m
//  Traffic
//
//  Created by Jean-Luc Dagon on 25/08/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

#import "TRFViewControllerIntent.h"

@implementation TRFViewControllerIntent

+ (instancetype)intentWithIntent:(TRFIntent *)intent
{
    TRFViewControllerIntent *newIntent = [self intentWithURL:intent.URL];
    if ([intent isKindOfClass:[TRFViewControllerIntent class]]) {
        TRFViewControllerIntent *vcIntent = (TRFViewControllerIntent *)intent;
        newIntent.preferredTransition = vcIntent.preferredTransition;
    }
    return newIntent;
}

@end
