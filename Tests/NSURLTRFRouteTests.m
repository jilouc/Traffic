//
//  NSURLTRFRouteTests.m
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
#import "NSURL+TRFRoute.h"
#import <Foundation/Foundation.h>
#import <Expecta/Expecta.h>

@interface NSURLTRFRouteTests : XCTestCase

@end

@implementation NSURLTRFRouteTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testEmptyQueryString
{
    NSURL *URL = [NSURL URLWithString:@"traffic://"];
    expect(URL.trf_queryParameters).notTo.beNil;
    expect(URL.trf_queryParameters).to.haveCountOf(0);
}

- (void)testBasicQueryString
{
    NSURL *URL = [NSURL URLWithString:@"traffic://test/?param1=value1&param2=value2"];
    expect(URL.trf_queryParameters).to.haveCountOf(2);
    expect(URL.trf_queryParameters[@"param1"]).to.equal(@"value1");
    expect(URL.trf_queryParameters[@"param2"]).to.equal(@"value2");
}

- (void)testQueryStringWithPercentEncodedValues
{
    NSURL *URL = [NSURL URLWithString:@"traffic://test/?param1=value%20with%2Fescaped%2Bcharacters&param2=value2"];
    expect(URL.trf_queryParameters).to.haveCountOf(2);
    expect(URL.trf_queryParameters[@"param1"]).to.equal(@"value with/escaped+characters");
    expect(URL.trf_queryParameters[@"param2"]).to.equal(@"value2");
}

- (void)testQueryStringWithArrayValue
{
    NSURL *URL = [NSURL URLWithString:@"traffic://test/?param=value1&param=value2&param=value3"];
    expect(URL.trf_queryParameters).to.haveCountOf(1);
    expect(URL.trf_queryParameters[@"param"]).to.equal(@[@"value1", @"value2", @"value3"]);
}

- (void)testQueryStringWithEmptyNameOrValues
{
    NSURL *URL = [NSURL URLWithString:@"traffic://test/?param1=&param2&=value3&"];
    expect(URL.trf_queryParameters).to.haveCountOf(2);
    expect(URL.trf_queryParameters[@"param1"]).to.equal(@"");
    expect(URL.trf_queryParameters[@"param2"]).to.beNil;
    expect(URL.trf_queryParameters[@""]).to.equal(@"value3");
}

- (void)testFirstParameterWithName
{
    NSURL *URL = [NSURL URLWithString:@"traffic://test/?param1=value11&param1=value12&param2=value2"];
    expect(URL.trf_queryParameters).to.haveCountOf(2);
    expect([URL trf_firstQueryParameterWithName:@"param1"]).to.equal(@"value11");
    expect([URL trf_firstQueryParameterWithName:@"param2"]).to.equal(@"value2");
    expect([URL trf_firstQueryParameterWithName:@"param3"]).to.beNil;
}

@end
