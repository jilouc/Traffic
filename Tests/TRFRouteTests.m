//
//  TRFRouteTests.m
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
#import <Expecta/Expecta.h>
#import "TRFRoute.h"
#import "NSURL+TRFRoute.h"
#import <OCMock/OCMock.h>

extern NSString *const TRFRouteParameterValueStringPattern;
extern NSString *const TRFRouteParameterValueIntPattern;

@interface TRFRouteParameter : NSObject
- (NSString *)pattern;
- (NSInteger)groupNumber;
@end

@interface TRFRoute ()

@property (nonatomic) NSRegularExpression *routeRegularExpression;
@property (nonatomic, copy) NSString *pattern;
@property (nonatomic) TRFRouteHandler *handler;
@property (nonatomic) NSDictionary<NSString *, TRFRouteParameter *> *internalRouteParameters;

@end

@interface TRFRouteTests : XCTestCase

@end

@implementation TRFRouteTests

- (void)testRouteCompilingBasics
{
    TRFRoute *route1 = [TRFRoute routeWithScheme:@"traffic" pattern:@"/routes" handler:nil];
    expect(route1.scheme).to.equal(@"traffic");
    TRFRoute *route2 = [TRFRoute routeWithScheme:nil pattern:@"/routes" handler:nil];
    expect(route2.routeRegularExpression.pattern).to.equal(@"^routes\\/?$");
    TRFRoute *route3 = [TRFRoute routeWithScheme:nil pattern:@"" handler:nil];
    expect(route3.routeRegularExpression).to.beNil;
}

- (void)testRouteParameterWithoutType
{
    TRFRoute *route = [TRFRoute routeWithScheme:nil pattern:@"/routes/<route_id>/no-type" handler:nil];
    expect(route.internalRouteParameters).to.haveCountOf(1);
    expect(route.internalRouteParameters[@"route_id"]).notTo.beNil;
    expect(route.internalRouteParameters[@"route_id"].pattern).to.equal(TRFRouteParameterValueStringPattern);
    expect(route.internalRouteParameters[@"route_id"].groupNumber).to.equal(1);
}

- (void)testRouteParameterTypeInt
{
    TRFRoute *route = [TRFRoute routeWithScheme:nil pattern:@"/route/<route_id:int>" handler:nil];
    expect(route.internalRouteParameters).to.haveCountOf(1);
    expect(route.internalRouteParameters[@"route_id"]).notTo.beNil;
    expect(route.internalRouteParameters[@"route_id"].pattern).to.equal(TRFRouteParameterValueIntPattern);
    expect(route.internalRouteParameters[@"route_id"].groupNumber).to.equal(1);
    expect(route.routeRegularExpression.pattern).to.contain(TRFRouteParameterValueIntPattern);
}

- (void)testRouteParameterTypeStr
{
    TRFRoute *route = [TRFRoute routeWithScheme:nil pattern:@"/route/<route_id:str>" handler:nil];
    expect(route.internalRouteParameters).to.haveCountOf(1);
    expect(route.internalRouteParameters[@"route_id"]).notTo.beNil;
    expect(route.internalRouteParameters[@"route_id"].pattern).to.equal(TRFRouteParameterValueStringPattern);
    expect(route.internalRouteParameters[@"route_id"].groupNumber).to.equal(1);
    expect(route.routeRegularExpression.pattern).to.contain(TRFRouteParameterValueStringPattern);
}

- (void)testRouteParameterTypeStrWithRegex
{
    TRFRoute *route = [TRFRoute routeWithScheme:nil pattern:@"/route/<route_id:re:[a-f0-9]+>" handler:nil];
    expect(route.internalRouteParameters).to.haveCountOf(1);
    expect(route.internalRouteParameters[@"route_id"]).notTo.beNil;
    expect(route.internalRouteParameters[@"route_id"].pattern).to.equal(@"[a-f0-9]+");
    expect(route.routeRegularExpression.pattern).to.contain(@"[a-f0-9]+");
}

- (void)testRouteParameterTypeStrWithRegexEmpty
{
    TRFRoute *route1 = [TRFRoute routeWithScheme:nil pattern:@"/route/<route_id:re>" handler:nil];
    expect(route1.routeRegularExpression.pattern).to.contain(TRFRouteParameterValueStringPattern);
    TRFRoute *route2 = [TRFRoute routeWithScheme:nil pattern:@"/route/<route_id:re:>" handler:nil];
    expect(route2.routeRegularExpression.pattern).to.contain(TRFRouteParameterValueStringPattern);
}

- (void)testRouteWithMultipleParameters
{
    TRFRoute *route = [TRFRoute routeWithScheme:nil pattern:@"/routes/<route_id>/parameter/<parameter_id>" handler:nil];
    expect(route.internalRouteParameters).to.haveCountOf(2);
    expect(route.internalRouteParameters[@"route_id"]).notTo.beNil;
    expect(route.internalRouteParameters[@"parameter_id"]).notTo.beNil;
}

- (void)testRouteCompilationWildcards
{
    TRFRoute *routeWithSimpleWildcard = [TRFRoute routeWithScheme:nil pattern:@"/route/with/*/simple/wildcard" handler:nil];
    expect(routeWithSimpleWildcard.routeRegularExpression.pattern).to.equal(@"^route/with/(?:[^/]+?)/simple/wildcard\\/?$");
    TRFRoute *routeWithUnbouundedWildcard = [TRFRoute routeWithScheme:nil pattern:@"/route/with/**/wildcard" handler:nil];
    expect(routeWithUnbouundedWildcard.routeRegularExpression.pattern).to.equal(@"^route/with/(?:.*?)/wildcard\\/?$");
    TRFRoute *routeWithBothWildcards = [TRFRoute routeWithScheme:nil pattern:@"/route/with/simple/*/and/**/unbounded/wildcards" handler:nil];
    expect(routeWithBothWildcards.routeRegularExpression.pattern).to.equal(@"^route/with/simple/(?:[^/]+?)/and/(?:.*?)/unbounded/wildcards\\/?$");
}

- (void)testRouteWithWildcardAndParameters
{
    TRFRoute *routeWithSimpleWildcard = [TRFRoute routeWithScheme:nil pattern:@"/routes/<route_id>/*/<parameter_id:re:[a-f]+[0-9]*>" handler:nil];
    expect(routeWithSimpleWildcard.routeRegularExpression.pattern).to.equal([NSString stringWithFormat:@"^routes/(%@)/(?:[^/]+?)/([a-f]+[0-9]*)\\/?$",
                                                                             TRFRouteParameterValueStringPattern]);
    TRFRoute *routeWithWildcard = [TRFRoute routeWithScheme:nil pattern:@"/routes/<route_id>/**/wildcard" handler:nil];
    expect(routeWithWildcard.routeRegularExpression.pattern).to.equal([NSString stringWithFormat:@"^routes/(%@)/(?:.*?)/wildcard\\/?$",
                                                                       TRFRouteParameterValueStringPattern]);
}

- (void)testRouteMatchingWithScheme
{
    TRFRoute *routeWithScheme = [TRFRoute routeWithScheme:@"traffic" pattern:@"/routes" handler:nil];
    expect([routeWithScheme matchWithURL:[NSURL URLWithString:@"traffic://routes"]]).to.equal(YES);
    expect([routeWithScheme matchWithURL:[NSURL URLWithString:@"control://routes"]]).to.equal(NO);
}

- (void)testRouteMatchingWithoutScheme
{
    TRFRoute *routeWithoutScheme = [TRFRoute routeWithScheme:nil pattern:@"/routes" handler:nil];
    expect([routeWithoutScheme matchWithURL:[NSURL URLWithString:@"traffic://routes"]]).to.equal(YES);
    expect([routeWithoutScheme matchWithURL:[NSURL URLWithString:@"control://routes"]]).to.equal(YES);
}

- (void)testRouteMatchingWithTrailingSlash
{
    TRFRoute *route = [TRFRoute routeWithScheme:nil pattern:@"/routes" handler:nil];
    expect([route matchWithURL:[NSURL URLWithString:@"traffic://routes/"]]).to.equal(YES);
}

- (void)testRouteMatchingWithParameter
{
    TRFRoute *route = [TRFRoute routeWithScheme:nil pattern:@"/routes/<id_route>" handler:nil];
    NSURL *URL = [NSURL URLWithString:@"traffic://routes/123abc"];
    BOOL res = [route matchWithURL:URL];
    expect(res).to.equal(YES);
    expect(URL.trf_route).to.equal(route);
}

- (void)testRouteMatchingWithParameterTypeInt
{
    TRFRoute *route = [TRFRoute routeWithScheme:nil pattern:@"/routes/<id_route:int>" handler:nil];
    expect([route matchWithURL:[NSURL URLWithString:@"traffic://routes/123abc"]]).to.equal(NO);
    NSURL *URL = [NSURL URLWithString:@"traffic://routes/456"];
    BOOL res = [route matchWithURL:URL];
    expect(res).to.equal(YES);
    expect([URL trf_routeParameterWithName:@"id_route"]).to.equal(@"456");
}

- (void)testRouteMatchingWithParameterTypeStr
{
    TRFRoute *route = [TRFRoute routeWithScheme:nil pattern:@"/routes/<route_name:str>" handler:nil];
    NSURL *URL = [NSURL URLWithString:@"traffic://routes/abcdef"];
    BOOL res = [route matchWithURL:URL];
    expect(res).to.equal(YES);
    expect([URL trf_routeParameterWithName:@"route_name"]).to.equal(@"abcdef");
    // test that we don't consider the / as part of the parameter
    expect([route matchWithURL:[NSURL URLWithString:@"traffic://routes/abcdef/1234"]]);
}

- (void)testRouteMatchingWithParameterTypeRegex
{
    TRFRoute *route = [TRFRoute routeWithScheme:nil pattern:@"/routes/<id_route:re:[a-f0-9]+>" handler:nil];
    NSURL *URL = [NSURL URLWithString:@"traffic://routes/a12cd45ef"];
    BOOL res = [route matchWithURL:URL];
    expect(res).to.equal(YES);
    expect([URL trf_routeParameterWithName:@"id_route"]).to.equal(@"a12cd45ef");
    expect([route matchWithURL:[NSURL URLWithString:@"traffic/routes/abc_123"]]).to.equal(NO);
}

- (void)testRouteMatchingWithMultipleParameters
{
    TRFRoute *route = [TRFRoute routeWithScheme:nil pattern:@"/posts/<id_post>/comments/<id_comment>" handler:nil];
    NSURL *URL = [NSURL URLWithString:@"traffic://posts/1234/comments/5678"];
    BOOL res = [route matchWithURL:URL];
    expect(res).to.equal(YES);
    expect([URL trf_routeParameterWithName:@"id_post"]).to.equal(@"1234");
    expect([URL trf_routeParameterWithName:@"id_comment"]).to.equal(@"5678");
    expect([route matchWithURL:[NSURL URLWithString:@"traffic://posts/1234/comments"]]).to.equal(NO);
}

- (void)testMatchingWithSimpleWildcard
{
    TRFRoute *route = [TRFRoute routeWithScheme:nil pattern:@"*/route" handler:nil];
    expect([route matchWithURL:[NSURL URLWithString:@"traffic://wilcard_content/route"]]).to.equal(YES);
    expect([route matchWithURL:[NSURL URLWithString:@"traffic://wilcard_content/not_matching/route"]]).to.equal(NO);
}

- (void)testMatchingWithGlobalWildcard
{
    TRFRoute *route = [TRFRoute routeWithScheme:nil pattern:@"**/route" handler:nil];
    expect([route matchWithURL:[NSURL URLWithString:@"traffic://wilcard_content/route"]]).to.equal(YES);
    expect([route matchWithURL:[NSURL URLWithString:@"traffic://wilcard_content/also_matching/route"]]).to.equal(YES);
    expect([route matchWithURL:[NSURL URLWithString:@"traffic://wilcard_content/not_matching/route/extra"]]).to.equal(NO);
}

- (void)testMatchingRouteWithDot
{
    TRFRoute *route = [TRFRoute routeWithScheme:nil pattern:@"foo.bar" handler:nil];
    expect([route matchWithURL:[NSURL URLWithString:@"http://foo.bar"]]).to.equal(YES);
    expect([route matchWithURL:[NSURL URLWithString:@"http://foo+bar"]]).to.equal(NO);
}

- (void)testAlreadyMatchedURL
{
    TRFRoute *route1 = [TRFRoute routeWithScheme:nil pattern:@"route/<param1>" handler:nil];
    TRFRoute *route2 = [TRFRoute routeWithScheme:nil pattern:@"route/<param2>" handler:nil];
 
    NSURL *URL = [NSURL URLWithString:@"traffic://route/value1"];
    expect([route1 matchWithURL:URL]).to.equal(YES);
    expect(URL.trf_route).to.equal(route1);
    
    expect([route2 matchWithURL:[NSURL URLWithString:@"traffic://route/value1"]]).to.equal(YES);
    expect([route2 matchWithURL:URL]).to.equal(NO);
}

- (void)testNilURL
{
    TRFRoute *route1 = [TRFRoute routeWithScheme:nil pattern:@"route/<param1>" handler:nil];
    expect([route1 matchWithURL:nil]).to.equal(NO);
}

- (void)testInvalidRoutePattern
{
    expect(^{
        [TRFRoute routeWithScheme:nil pattern:@"route/<param:re:[>" handler:nil];
    }).to.raise(NSInvalidArgumentException);
}

- (void)testHandleURL
{
    TRFRoute *route1 = [TRFRoute routeWithScheme:nil pattern:@"route/<param1>" handler:nil];
    expect([route1 handleURL:[NSURL URLWithString:@"traffic://not/matching"]]).to.equal(NO);
    expect([route1 handleURL:[NSURL URLWithString:@"traffic://route/matching"]]).to.equal(YES);
}

- (void)testHandleURLWithHandler
{
    TRFRouteHandler *mockHandler = [OCMockObject niceMockForClass:[TRFRouteHandler class]];
    TRFRoute *route1 = [TRFRoute routeWithScheme:nil pattern:@"route/<param1>" handler:mockHandler];
    
    NSURL *URL = [NSURL URLWithString:@"traffic://route/value"];
    id context = [NSObject new];
    [route1 handleURL:URL context:context];
    [[(id)mockHandler verify] handleURL:URL context:context];
    
}

@end
