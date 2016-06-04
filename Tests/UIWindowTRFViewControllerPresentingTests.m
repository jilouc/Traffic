//
//  UIWindowTRFViewControllerPresentingTests.m
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
#import <OCMock/OCMock.h>
#import <Expecta/Expecta.h>
#import "TRFViewControllerRouteHandler.h"

@interface UIWindowTRFViewControllerPresentingTests : XCTestCase

@property (nonatomic) id mockApplication;

@end

@implementation UIWindowTRFViewControllerPresentingTests

- (void)setUp
{
    [super setUp];
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    
    id mockApplication = [OCMockObject niceMockForClass:[UIApplication class]];
    [[[mockApplication stub] andReturn:mockApplication] sharedApplication];
    [[[mockApplication stub] andReturn:window] keyWindow];
    self.mockApplication = mockApplication;
}

- (void)tearDown
{
    [super tearDown];
    self.mockApplication = nil;
}

- (void)testSimpleRootViewController
{
    UIViewController *rootVC = [UIViewController new];
    UIWindow *window = [self.mockApplication keyWindow];
    [window setRootViewController:rootVC];
    expect([window trf_currentViewControllerForRoutePresenting]).to.equal(rootVC);
}

- (void)testWithPresentedViewControllers
{
    id mockRootVC = OCMPartialMock([UIViewController new]);
    UIWindow *window = [self.mockApplication keyWindow];
    [window setRootViewController:mockRootVC];
    
    id mockPresentedVC = OCMPartialMock([UIViewController new]);
    [[[mockRootVC stub] andReturn:mockPresentedVC] presentedViewController];
    UIViewController *finalPresentedVC = [UIViewController new];
    [[[mockPresentedVC stub] andReturn:finalPresentedVC] presentedViewController];
    expect([window trf_currentViewControllerForRoutePresenting]).to.equal(finalPresentedVC);
}

- (void)testWithTabBarViewController
{
    id mockRootVC = OCMPartialMock([UITabBarController new]);
    UIWindow *window = [self.mockApplication keyWindow];
    [window setRootViewController:mockRootVC];
    
    UIViewController *selectedViewController = [UIViewController new];
    [[[mockRootVC stub] andReturn:selectedViewController] selectedViewController];
    expect([window trf_currentViewControllerForRoutePresenting]).to.equal(selectedViewController);
}

- (void)testWithNavigationController
{
    UIViewController *topViewController = [UIViewController new];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[UIViewController new]];
    [navController pushViewController:topViewController animated:NO];
    UIWindow *window = [self.mockApplication keyWindow];
    [window setRootViewController:navController];
    expect([window trf_currentViewControllerForRoutePresenting]).to.equal(topViewController);
}

- (void)testWithEmptyNavigationController
{
    UINavigationController *navController = [[UINavigationController alloc] init];
    UIWindow *window = [self.mockApplication keyWindow];
    [window setRootViewController:navController];
    expect([window trf_currentViewControllerForRoutePresenting]).to.equal(navController);
}


@end
