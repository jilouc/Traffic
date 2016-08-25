//
//  TRFViewControllerIntent.h
//  Traffic
//
//  Created by Jean-Luc Dagon on 25/08/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

#import "TRFIntent.h"

typedef NS_ENUM(NSInteger, TRFViewControllerPreferredTransition)
{
    TRFViewControllerPreferredTransitionAuto = 0,
    TRFViewControllerPreferredTransitionPush,
    TRFViewControllerPreferredTransitionModal,
};

@interface TRFViewControllerIntent : TRFIntent

@property (nonatomic) TRFViewControllerPreferredTransition preferredTransition;

+ (instancetype)intentWithIntent:(TRFIntent *)intent;

@end
