//
//  TRFUIRouter.m
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

#import "TRFUIRouter.h"
#import "TRFRoute.h"
#import "NSURL+TRFRoute.h"
#import "TRFRoute+Internal.h"

//////////////////////////////////////////////////////////////////////

@interface TRFUIRouter ()

@property (nonatomic, copy) NSArray<TRFRoute *> *routes;

@end

static TRFUIRouter *_defaultRouter = nil;

//////////////////////////////////////////////////////////////////////

@implementation TRFUIRouter

+ (instancetype)defaultRouter
{
    return _defaultRouter;
}

+ (void)setDefaultRouter:(TRFUIRouter *)uiRouter
{
    _defaultRouter = uiRouter;
}

- (void)registerRoute:(TRFRoute *)route
{
    if (!route) {
        return;
    }
    [self registerRoutes:@[route]];
}

- (void)registerRoutes:(NSArray<TRFRoute *> *)routes
{
    if (routes.count == 0) {
        return;
    }
    NSMutableArray *registeredRoutes = [NSMutableArray arrayWithArray:self.routes];
    [registeredRoutes addObjectsFromArray:routes];
    self.routes = registeredRoutes;
}

- (TRFRoute *)routeMatchingURL:(NSURL *)URL
{
    [self.routes enumerateObjectsUsingBlock:^(TRFRoute *route, NSUInteger idx, BOOL *stop) {
        if (![route matchWithURL:URL]) {
            return;
        }
        *stop = YES;
    }];
    return URL.trf_route;
}

- (BOOL)routeIntent:(TRFIntent *)intent
{
    if (intent.routeId.length) {
        TRFRoute *route = [self routeWithId:intent.routeId];
        if (route) {
            [route handleIntent:intent];
            return YES;
        }
    }
    if (intent.URL) {
        return [self routeURL:intent.URL intent:intent];
    }
    return NO;
}

- (BOOL)routeURL:(NSURL *)URL intent:(TRFIntent *)intent
{
    id<TRFUIRouterDelegate> strongDelegate = self.delegate;
    // Give the delegate a chance to perform some changes on the URL on the fly
    if ([strongDelegate respondsToSelector:@selector(trafficRouter:willRouteURL:)]) {
        URL = [strongDelegate trafficRouter:self
                               willRouteURL:URL];
    }
    
    TRFRoute *route = [self routeMatchingURL:URL];
    if (route == nil) {
        return NO;
    }
    NSLog(@"URL %@ matches route: %@", URL.absoluteString, route.identifier);
    
    return [route handleURL:URL intent:intent] != nil;
}

- (TRFRoute *)routeWithId:(NSString *)routeId
{
    if (routeId.length == 0) {
        return nil;
    }
    
    __block TRFRoute *resultRoute = nil;
    [self.routes enumerateObjectsUsingBlock:^(TRFRoute *route, NSUInteger idx, BOOL *stop) {
        if ([route.identifier isEqualToString:routeId]) {
            resultRoute = route;
            *stop = YES;
        }
    }];
    return resultRoute;
}

- (BOOL)URL:(NSURL *)URL isMatchingRoute:(TRFRoute *)route
{
    return [route matchWithURL:URL];
}

- (BOOL)URL:(NSURL *)URL isMatchingRoutes:(NSArray<NSString *> *)routeIds
{
    __block BOOL matchFound = NO;
    [routeIds enumerateObjectsUsingBlock:^(NSString *routeId, NSUInteger idx, BOOL *stop) {
        TRFRoute *route = [self routeWithId:routeId];
        if ([route matchWithURL:URL]) {
            matchFound = YES;
            *stop = YES;
        }
    }];
    return matchFound;
}

- (TRFIntent *)intentForURL:(NSURL *)URL
{
    TRFRoute *route = [self routeMatchingURL:URL];
    TRFIntent *baseIntent = [route intentForURL:URL intent:nil];
    TRFIntent *routeIntent = [route.handler intentForIntent:baseIntent];
    [routeIntent applyIntent:baseIntent];
    return routeIntent;
}

@end
