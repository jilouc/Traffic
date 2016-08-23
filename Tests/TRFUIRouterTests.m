//
//  TRFUIRouterTests.m
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
#import <XCTest/XCTest.h>
#import "TRFUIRouter.h"
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>
#import "NSURL+TRFRoutePrivate.h"

@interface TRFUIRouter (Private)
@property (nonatomic) NSArray<TRFRoute *> *routes;
@end

@interface TRFUIRouterTests : XCTestCase

@end

@implementation TRFUIRouterTests

- (void)testDefaultRouter
{
    expect([TRFUIRouter defaultRouter]).to.equal(nil);
    
    TRFUIRouter *router = [TRFUIRouter new];
    [TRFUIRouter setDefaultRouter:router];
    expect([TRFUIRouter defaultRouter]).to.equal(router);
}

- (void)testEmptyRoutesAreNotRegistered
{
    TRFUIRouter *router = [TRFUIRouter new];
    [router registerRoute:nil];
    expect(router.routes).to.beNil;
    [router registerRoutes:nil];
    expect(router.routes).to.beNil;
    [router registerRoutes:@[]];
    expect(router.routes).to.beNil;
}

- (void)testRouteIsRegistered
{
    TRFUIRouter *router = [TRFUIRouter new];
    TRFRoute *route = [TRFRoute routeWithScheme:nil pattern:nil handler:nil];
    [router registerRoute:route];
    expect(router.routes).to.haveCountOf(1);
    expect([router.routes firstObject]).to.equal(route);
}

- (void)testMultiplesRoutesAreRegistered
{
    TRFUIRouter *router = [TRFUIRouter new];
    TRFRoute *route1 = [TRFRoute routeWithScheme:nil pattern:@"route1" handler:nil];
    TRFRoute *route2 = [TRFRoute routeWithScheme:nil pattern:@"route2" handler:nil];
    [router registerRoutes:@[route1, route2]];
    expect(router.routes).to.equal(@[route1, route2]);
}

- (void)testRouteMatchesFirstRegisteredWhenMoreSpecific
{
    TRFUIRouter *router = [TRFUIRouter new];
    TRFRoute *specificRoute = [TRFRoute routeWithScheme:nil pattern:@"route/first" handler:nil];
    TRFRoute *genericRoute = [TRFRoute routeWithScheme:nil pattern:@"route/<param>" handler:nil];
    [router registerRoute:specificRoute];
    [router registerRoute:genericRoute];
    expect([router routeMatchingURL:[NSURL URLWithString:@"traffic://route/first"]]).to.equal(specificRoute);
}

- (void)testRouteMatchesFirstRegisteredWhenMoreGeneric
{
    TRFUIRouter *router = [TRFUIRouter new];
    TRFRoute *genericRoute = [TRFRoute routeWithScheme:nil pattern:@"route/<param>" handler:nil];
    TRFRoute *specificRoute = [TRFRoute routeWithScheme:nil pattern:@"route/first" handler:nil];
    [router registerRoute:genericRoute];
    [router registerRoute:specificRoute];
    expect([router routeMatchingURL:[NSURL URLWithString:@"traffic://route/first"]]).to.equal(genericRoute);
}

- (void)testRouterWhenNoRouteMatches
{
    TRFUIRouter *router = [TRFUIRouter new];
    expect([router routeMatchingURL:[NSURL URLWithString:@"traffic://no/route/match"]]).to.beFalsy;
}

- (void)testRouterCallsRouteHandler
{
    NSURL *URL = [NSURL URLWithString:@"traffic://routes"];
    id context = [NSObject new];
 
    TRFUIRouter *router = [TRFUIRouter new];
    id routeMock = [OCMockObject niceMockForClass:[TRFRoute class]];
    [[[routeMock stub] andReturnValue:@YES] matchWithURL:URL];
    [URL trf_setRoute:routeMock];
    
    [router routeURL:URL context:context];
    OCMVerify([routeMock handleURL:URL context:context]);
}

@end
