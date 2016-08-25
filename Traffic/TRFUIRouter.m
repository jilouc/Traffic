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

- (BOOL)routeURL:(NSURL *)URL intent:(TRFIntent *)intent
{
    TRFRoute *route = [self routeMatchingURL:URL];
    if (route == nil) {
        return NO;
    }
    NSLog(@"URL %@ matches route: %@", URL.absoluteString, route);
    return [route handleURL:URL intent:intent];
}

@end
