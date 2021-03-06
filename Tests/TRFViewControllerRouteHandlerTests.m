//
//  TRFViewControllerRouteHandlerTests.m
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
#import "TRFViewControllerRouteHandler.h"
#import "TRFIntent+PresentingWindow.h"
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>

@interface TRFViewControllerRouteHandlerTests : XCTestCase

@end

@implementation TRFViewControllerRouteHandlerTests

#define IntentWithURL(_urlStr) [TRFViewControllerIntent intentWithURL:[NSURL URLWithString:_urlStr]]

- (void)testCreationBlockIsCalled
{
    TRFViewControllerRouteHandler *routeHandler;
    XCTestExpectation *creationExpectation = [self expectationWithDescription:@"route handler should call the creation block"];
    
    UIViewController *targetViewController = [UIViewController new];
    routeHandler = [TRFViewControllerRouteHandler
                    routeHandlerWithCreationBlock:^UIViewController *(TRFIntent *intent) {
                        [creationExpectation fulfill];
                        return targetViewController;
                    } presentationBlock:nil];
    
    TRFIntent *intent = IntentWithURL(@"traffic://routes");
    expect([routeHandler handleIntent:intent]).to.equal(YES);
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testTargetViewControllerIsCreated
{
    TRFViewControllerRouteHandler *routeHandler;
    UIViewController *targetViewController = [UIViewController new];
    routeHandler = [TRFViewControllerRouteHandler
                    routeHandlerWithCreationBlock:^UIViewController *(TRFIntent *intent) {
                        return targetViewController;
                    } presentationBlock:nil];
    expect([routeHandler targetViewControllerForIntent:IntentWithURL(@"traffic://routes")]).to.equal(targetViewController);
}

- (void)testEmptyCreationBlock
{
    TRFViewControllerRouteHandler *routeHandler;
    routeHandler = [TRFViewControllerRouteHandler
                    routeHandlerWithCreationBlock:nil
                    presentationBlock:nil];
    
    TRFIntent *intent = IntentWithURL(@"traffic://routes");
    expect([routeHandler handleIntent:intent]).to.equal(NO);
}

- (void)testPresentationBlock
{
    TRFViewControllerRouteHandler *routeHandler;
    XCTestExpectation *presentationExpectation = [self expectationWithDescription:@"route handler should call the presentation block"];
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    id mockApplication = [OCMockObject niceMockForClass:[UIApplication class]];
    [[[mockApplication stub] andReturn:mockApplication] sharedApplication];
    [[[mockApplication stub] andReturn:window] keyWindow];
    
    UIViewController *presentingViewController = [UIViewController new];
    window.rootViewController = presentingViewController;
    
    TRFIntent *routeIntent = IntentWithURL(@"traffic://routes");
    
    UIViewController *targetViewController = [UIViewController new];
    routeHandler = [TRFViewControllerRouteHandler
                    routeHandlerWithCreationBlock:^UIViewController *(TRFIntent *intent) {
                        return targetViewController;
                    } presentationBlock:^(__kindof UIViewController *targetViewController, UIViewController *proposedPresentingViewController, TRFIntent *intent) {
                        expect(proposedPresentingViewController).to.equal(presentingViewController);
                        expect(intent.URL).to.equal(routeIntent.URL);
                        expect(intent).to.equal(routeIntent);
                        [presentationExpectation fulfill];
                    }];
    [routeHandler handleIntent:routeIntent];
    [self waitForExpectationsWithTimeout:0. handler:nil];
}

- (void)testUserDefinedWindowIsUsedForPresenting
{
    UIWindow *customWindow = [UIWindow new];
    TRFViewControllerIntent *intent = [TRFViewControllerIntent intentWithRouteId:@"foo"];
    intent.presentingWindow = customWindow;
    
    TRFViewControllerRouteHandler *routeHandler;
    routeHandler = [TRFViewControllerRouteHandler
                    routeHandlerWithCreationBlock:^UIViewController *(__kindof TRFViewControllerIntent *intent) {
                        return [UIViewController new];
                    }
                    presentationBlock:nil];
    
    id customWindowMock = OCMPartialMock(customWindow);
    [[customWindowMock expect] trf_currentViewControllerForRoutePresenting];
    
    [routeHandler handleIntent:intent];
    
    OCMVerifyAll(customWindowMock);
}

@end
