//
//  TRFUIRouter.h
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

#import <Foundation/Foundation.h>
#import "TRFRoute.h"
#import "TRFIntent.h"

@class TRFUIRouter;

@protocol TRFUIRouterDelegate <NSObject>

@optional
- (NSURL *)trafficRouter:(TRFUIRouter *)router willRouteURL:(NSURL *)URL;

@end

//////////////////////////////////////////////////////////////////////

@interface TRFUIRouter : NSObject

+ (instancetype)defaultRouter;
+ (void)setDefaultRouter:(TRFUIRouter *)uiRouter;

@property (nonatomic, weak) id<TRFUIRouterDelegate> delegate;

- (void)registerRoute:(TRFRoute *)route;
- (void)registerRoutes:(NSArray<TRFRoute *> *)routes;

- (BOOL)routeIntent:(TRFIntent *)intent;
- (BOOL)routeURL:(NSURL *)URL intent:(TRFIntent *)intent;

- (TRFRoute *)routeMatchingURL:(NSURL *)URL;
- (TRFRoute *)routeWithId:(NSString *)routeId;

- (BOOL)URL:(NSURL *)URL isMatchingRoute:(TRFRoute *)route;
- (BOOL)URL:(NSURL *)URL isMatchingRoutes:(NSArray<NSString *> *)routeIds;

- (TRFIntent *)intentForURL:(NSURL *)URL;

@end

