//
//  TRFRoute+Internal.h
//  Traffic
//
//  Created by Jean-Luc Dagon on 07/03/2017.
//  Copyright © 2017 Cocoapps. All rights reserved.
//

#import "TRFRoute.h"

@class TRFRouteHandler;
@class TRFIntent;

@interface TRFRoute (Internal)

- (TRFRouteHandler *)handler;
- (TRFIntent *)intentForURL:(NSURL *)URL intent:(TRFIntent *)intent;

@end
