//
//  TRFIntent.h
//  Traffic
//
//  Created by Jean-Luc Dagon on 25/08/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSURL+TRFRoute.h"

@interface TRFIntent : NSObject

+ (instancetype)intentWithURL:(NSURL *)URL;

- (void)buildFromURL:(NSURL *)URL;

@property (nonatomic, copy) NSURL *URL;

@end
