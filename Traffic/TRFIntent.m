//
//  TRFIntent.m
//  Traffic
//
//  Created by Jean-Luc Dagon on 25/08/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

#import "TRFIntent.h"

@interface TRFIntent ()

@end

@implementation TRFIntent

+ (instancetype)intentWithURL:(NSURL *)URL
{
    TRFIntent *intent = [[self alloc] initWithURL:URL];
    return intent;
}

- (instancetype)initWithURL:(NSURL *)URL
{
    self = [super init];
    if (self) {
        self.URL = URL;
    }
    return self;
}

- (void)setURL:(NSURL *)URL
{
    _URL = URL;
    [self buildFromURL:URL];
}

- (void)buildFromURL:(NSURL *)URL
{
    
}

@end
