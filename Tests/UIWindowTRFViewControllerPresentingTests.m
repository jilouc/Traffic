//
//  UIWindowTRFViewControllerPresentingTests.m
//  Traffic
//
//  Created by Jean-Luc Dagon on 04/06/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
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
