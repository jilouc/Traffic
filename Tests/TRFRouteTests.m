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
- (NSUInteger)groupNumber;
@end

@interface TRFRoute ()

@property (nonatomic, copy) NSDictionary<NSString *, NSRegularExpression *> *routeRegularExpressions;
@property (nonatomic, copy) NSArray<NSString *> *patterns;
@property (nonatomic) TRFRouteHandler *handler;
@property (nonatomic, copy) NSDictionary<NSString *, NSDictionary<NSString *, TRFRouteParameter *> *> *internalRouteParameters;

@end

@interface TRFRouteTests : XCTestCase

@end

@implementation TRFRouteTests

- (void)testRouteCompilingBasics
{
    NSString *pattern = @"/routes";
    TRFRoute *route1 = [TRFRoute routeWithId:nil scheme:@"traffic" pattern:pattern handler:nil];
    expect(route1.scheme).to.equal(@"traffic");
    TRFRoute *route2 = [TRFRoute routeWithId:nil scheme:nil pattern:@"/routes" handler:nil];
    expect(route2.routeRegularExpressions[pattern].pattern).to.equal(@"^(?:[^:]+)://routes\\/?$");
    TRFRoute *route3 = [TRFRoute routeWithId:nil scheme:nil pattern:@"" handler:nil];
    expect(route3.routeRegularExpressions.allValues.firstObject).to.beNil;
}

- (void)testRouteParameterWithoutType
{
    NSString *pattern = @"/routes/<route_id>/no-type";
    TRFRoute *route = [TRFRoute routeWithId:nil scheme:nil pattern:pattern handler:nil];
    expect(route.internalRouteParameters[pattern]).to.haveCountOf(1);
    expect(route.internalRouteParameters[pattern][@"route_id"]).notTo.beNil;
    expect(route.internalRouteParameters[pattern][@"route_id"].pattern).to.equal(TRFRouteParameterValueStringPattern);
    expect(route.internalRouteParameters[pattern][@"route_id"].groupNumber).to.equal(1);
}

- (void)testRouteParameterTypeInt
{
    NSString *pattern = @"/route/<route_id:int>";
    TRFRoute *route = [TRFRoute routeWithId:nil scheme:nil pattern:pattern handler:nil];
    expect(route.internalRouteParameters).to.haveCountOf(1);
    expect(route.internalRouteParameters[pattern][@"route_id"]).notTo.beNil;
    expect(route.internalRouteParameters[pattern][@"route_id"].pattern).to.equal(TRFRouteParameterValueIntPattern);
    expect(route.internalRouteParameters[pattern][@"route_id"].groupNumber).to.equal(1);
    expect(route.routeRegularExpressions[pattern].pattern).to.contain(TRFRouteParameterValueIntPattern);
}

- (void)testRouteParameterTypeStr
{
    NSString *pattern = @"/route/<route_id:str>";
    TRFRoute *route = [TRFRoute routeWithId:nil scheme:nil pattern:pattern handler:nil];
    expect(route.internalRouteParameters[pattern]).to.haveCountOf(1);
    expect(route.internalRouteParameters[pattern][@"route_id"]).notTo.beNil;
    expect(route.internalRouteParameters[pattern][@"route_id"].pattern).to.equal(TRFRouteParameterValueStringPattern);
    expect(route.internalRouteParameters[pattern][@"route_id"].groupNumber).to.equal(1);
    expect(route.routeRegularExpressions[pattern].pattern).to.contain(TRFRouteParameterValueStringPattern);
}

- (void)testRouteParameterTypeStrWithRegex
{
    NSString *pattern = @"/route/<route_id:re:[a-f0-9]+>";
    TRFRoute *route = [TRFRoute routeWithId:nil scheme:nil pattern:pattern handler:nil];
    expect(route.internalRouteParameters[pattern]).to.haveCountOf(1);
    expect(route.internalRouteParameters[pattern][@"route_id"]).notTo.beNil;
    expect(route.internalRouteParameters[pattern][@"route_id"].pattern).to.equal(@"[a-f0-9]+");
    expect(route.routeRegularExpressions[pattern].pattern).to.contain(@"[a-f0-9]+");
}

- (void)testRouteParameterTypeStrWithRegexEmpty
{
    NSString *pattern1 = @"/route/<route_id:re>";
    TRFRoute *route1 = [TRFRoute routeWithId:nil scheme:nil pattern:pattern1 handler:nil];
    expect(route1.routeRegularExpressions[pattern1].pattern).to.contain(TRFRouteParameterValueStringPattern);
    
    NSString *pattern2 = @"/route/<route_id:re:>";
    TRFRoute *route2 = [TRFRoute routeWithId:nil scheme:nil pattern:pattern2 handler:nil];
    expect(route2.routeRegularExpressions[pattern2].pattern).to.contain(TRFRouteParameterValueStringPattern);
}

- (void)testRouteWithMultipleParameters
{
    NSString *pattern = @"/routes/<route_id>/parameter/<parameter_id>";
    TRFRoute *route = [TRFRoute routeWithId:nil scheme:nil pattern:pattern handler:nil];
    expect(route.internalRouteParameters[pattern]).to.haveCountOf(2);
    expect(route.internalRouteParameters[pattern][@"route_id"]).notTo.beNil;
    expect(route.internalRouteParameters[pattern][@"parameter_id"]).notTo.beNil;
}

- (void)testRouteCompilationWildcards
{
    NSString *patternWithSimpleWildcard = @"/route/with/*/simple/wildcard";
    TRFRoute *routeWithSimpleWildcard = [TRFRoute routeWithId:nil scheme:nil pattern:patternWithSimpleWildcard handler:nil];
    expect(routeWithSimpleWildcard.routeRegularExpressions[patternWithSimpleWildcard].pattern).to.equal(@"^(?:[^:]+)://route/with/(?:[^/]+?)/simple/wildcard\\/?$");
    NSString *patternWithUnboundedWildcard = @"/route/with/**/wildcard";
    TRFRoute *routeWithUnboundedWildcard = [TRFRoute routeWithId:nil scheme:nil pattern:patternWithUnboundedWildcard handler:nil];
    expect(routeWithUnboundedWildcard.routeRegularExpressions[patternWithUnboundedWildcard].pattern).to.equal(@"^(?:[^:]+)://route/with/(?:.*?)/wildcard\\/?$");
    
    NSString *patternWithBothWildcards = @"/route/with/simple/*/and/**/unbounded/wildcards";
    TRFRoute *routeWithBothWildcards = [TRFRoute routeWithId:nil scheme:nil pattern:patternWithBothWildcards handler:nil];
    expect(routeWithBothWildcards.routeRegularExpressions[patternWithBothWildcards].pattern).to.equal(@"^(?:[^:]+)://route/with/simple/(?:[^/]+?)/and/(?:.*?)/unbounded/wildcards\\/?$");
}

- (void)testRouteWithWildcardAndParameters
{
    NSString *pattern1 = @"/routes/<route_id>/*/<parameter_id:re:[a-f]+[0-9]*>";
    TRFRoute *routeWithSimpleWildcard = [TRFRoute routeWithId:nil scheme:nil pattern:pattern1 handler:nil];
    expect(routeWithSimpleWildcard.routeRegularExpressions[pattern1].pattern).to.equal([NSString stringWithFormat:@"^(?:[^:]+)://routes/(%@)/(?:[^/]+?)/([a-f]+[0-9]*)\\/?$",
                                                                             TRFRouteParameterValueStringPattern]);
    
    NSString *pattern2 = @"/routes/<route_id>/**/wildcard";
    TRFRoute *routeWithWildcard = [TRFRoute routeWithId:nil scheme:nil pattern:pattern2 handler:nil];
    expect(routeWithWildcard.routeRegularExpressions[pattern2].pattern).to.equal([NSString stringWithFormat:@"^(?:[^:]+)://routes/(%@)/(?:.*?)/wildcard\\/?$",
                                                                       TRFRouteParameterValueStringPattern]);
}

- (void)testRouteMatchingWithScheme
{
    TRFRoute *routeWithScheme = [TRFRoute routeWithId:nil scheme:@"traffic" pattern:@"/routes" handler:nil];
    expect([routeWithScheme matchWithURL:[NSURL URLWithString:@"traffic://routes"]]).to.equal(YES);
    expect([routeWithScheme matchWithURL:[NSURL URLWithString:@"control://routes"]]).to.equal(NO);
}

- (void)testRouteMatchingWithoutScheme
{
    TRFRoute *routeWithoutScheme = [TRFRoute routeWithId:nil scheme:nil pattern:@"/routes" handler:nil];
    expect([routeWithoutScheme matchWithURL:[NSURL URLWithString:@"traffic://routes"]]).to.equal(YES);
    expect([routeWithoutScheme matchWithURL:[NSURL URLWithString:@"control://routes"]]).to.equal(YES);
}

- (void)testRouteMatchingWithTrailingSlash
{
    TRFRoute *route = [TRFRoute routeWithId:nil scheme:nil pattern:@"/routes" handler:nil];
    expect([route matchWithURL:[NSURL URLWithString:@"traffic://routes/"]]).to.equal(YES);
}

- (void)testPatternIncludingScheme
{
    TRFRoute *route = [TRFRoute routeWithId:nil
                                     scheme:nil
                                   patterns:@[
                                              @"traffic1://route-with-scheme",
                                              @"traffic2://route-with-scheme",
                                              ]
                                    handler:nil];
    expect([route matchWithURL:[NSURL URLWithString:@"traffic1://route-with-scheme"]]).to.equal(YES);
    expect([route matchWithURL:[NSURL URLWithString:@"traffic2://route-with-scheme"]]).to.equal(YES);
    expect([route matchWithURL:[NSURL URLWithString:@"foo://route-with-scheme"]]).to.equal(NO);
}

- (void)testRouteMatchingWithParameter
{
    TRFRoute *route = [TRFRoute routeWithId:nil scheme:nil pattern:@"/routes/<id_route>" handler:nil];
    NSURL *URL = [NSURL URLWithString:@"traffic://routes/123abc"];
    BOOL res = [route matchWithURL:URL];
    expect(res).to.equal(YES);
    expect(URL.trf_route).to.equal(route);
}

- (void)testRouteMatchingWithParameterTypeInt
{
    TRFRoute *route = [TRFRoute routeWithId:nil scheme:nil pattern:@"/routes/<id_route:int>" handler:nil];
    expect([route matchWithURL:[NSURL URLWithString:@"traffic://routes/123abc"]]).to.equal(NO);
    NSURL *URL = [NSURL URLWithString:@"traffic://routes/456"];
    BOOL res = [route matchWithURL:URL];
    expect(res).to.equal(YES);
    expect([URL trf_routeParameterWithName:@"id_route"]).to.equal(@"456");
}

- (void)testRouteMatchingWithParameterTypeStr
{
    TRFRoute *route = [TRFRoute routeWithId:nil scheme:nil pattern:@"/routes/<route_name:str>" handler:nil];
    NSURL *URL = [NSURL URLWithString:@"traffic://routes/abcdef"];
    BOOL res = [route matchWithURL:URL];
    expect(res).to.equal(YES);
    expect([URL trf_routeParameterWithName:@"route_name"]).to.equal(@"abcdef");
    // test that we don't consider the / as part of the parameter
    expect([route matchWithURL:[NSURL URLWithString:@"traffic://routes/abcdef/1234"]]);
}

- (void)testRouteMatchingWithParameterTypeRegex
{
    TRFRoute *route = [TRFRoute routeWithId:nil scheme:nil pattern:@"/routes/<id_route:re:[a-f0-9]+>" handler:nil];
    NSURL *URL = [NSURL URLWithString:@"traffic://routes/a12cd45ef"];
    BOOL res = [route matchWithURL:URL];
    expect(res).to.equal(YES);
    expect([URL trf_routeParameterWithName:@"id_route"]).to.equal(@"a12cd45ef");
    expect([route matchWithURL:[NSURL URLWithString:@"traffic/routes/abc_123"]]).to.equal(NO);
}

- (void)testRouteMatchingWithMultipleParameters
{
    TRFRoute *route = [TRFRoute routeWithId:nil scheme:nil pattern:@"/posts/<id_post>/comments/<id_comment>" handler:nil];
    NSURL *URL = [NSURL URLWithString:@"traffic://posts/1234/comments/5678"];
    BOOL res = [route matchWithURL:URL];
    expect(res).to.equal(YES);
    expect([URL trf_routeParameterWithName:@"id_post"]).to.equal(@"1234");
    expect([URL trf_routeParameterWithName:@"id_comment"]).to.equal(@"5678");
    expect([route matchWithURL:[NSURL URLWithString:@"traffic://posts/1234/comments"]]).to.equal(NO);
}

- (void)testMatchingWithSimpleWildcard
{
    TRFRoute *route = [TRFRoute routeWithId:nil scheme:nil pattern:@"*/route" handler:nil];
    expect([route matchWithURL:[NSURL URLWithString:@"traffic://wilcard_content/route"]]).to.equal(YES);
    expect([route matchWithURL:[NSURL URLWithString:@"traffic://wilcard_content/not_matching/route"]]).to.equal(NO);
}

- (void)testMatchingWithGlobalWildcard
{
    TRFRoute *route = [TRFRoute routeWithId:nil scheme:nil pattern:@"**/route" handler:nil];
    expect([route matchWithURL:[NSURL URLWithString:@"traffic://wilcard_content/route"]]).to.equal(YES);
    expect([route matchWithURL:[NSURL URLWithString:@"traffic://wilcard_content/also_matching/route"]]).to.equal(YES);
    expect([route matchWithURL:[NSURL URLWithString:@"traffic://wilcard_content/not_matching/route/extra"]]).to.equal(NO);
}

- (void)testMatchingRouteWithDot
{
    TRFRoute *route = [TRFRoute routeWithId:nil scheme:nil pattern:@"foo.bar" handler:nil];
    expect([route matchWithURL:[NSURL URLWithString:@"http://foo.bar"]]).to.equal(YES);
    expect([route matchWithURL:[NSURL URLWithString:@"http://foo+bar"]]).to.equal(NO);
}

- (void)testAlreadyMatchedURL
{
    TRFRoute *route1 = [TRFRoute routeWithId:nil scheme:nil pattern:@"route/<param1>" handler:nil];
    TRFRoute *route2 = [TRFRoute routeWithId:nil scheme:nil pattern:@"route/<param2>" handler:nil];
 
    NSURL *URL = [NSURL URLWithString:@"traffic://route/value1"];
    expect([route1 matchWithURL:URL]).to.equal(YES);
    expect(URL.trf_route).to.equal(route1);
    
    expect([route2 matchWithURL:[NSURL URLWithString:@"traffic://route/value1"]]).to.equal(YES);
    expect([route2 matchWithURL:URL]).to.equal(NO);
}

- (void)testNilURL
{
    TRFRoute *route1 = [TRFRoute routeWithId:nil scheme:nil pattern:@"route/<param1>" handler:nil];
    expect([route1 matchWithURL:nil]).to.equal(NO);
}

- (void)testInvalidRoutePattern
{
    expect(^{
        [TRFRoute routeWithId:nil scheme:nil pattern:@"route/<param:re:[>" handler:nil];
    }).to.raise(NSInvalidArgumentException);
}

- (void)testHandleURL
{
    TRFRoute *route1 = [TRFRoute routeWithId:nil scheme:nil pattern:@"route/<param1>" handler:nil];
    expect([route1 handleURL:[NSURL URLWithString:@"traffic://not/matching"] intent:nil]).to.beNil;
    expect([route1 handleURL:[NSURL URLWithString:@"traffic://route/matching"] intent:nil]).to.beKindOf([TRFIntent class]);
}

- (void)testHandleURLWithHandler
{
    TRFRouteHandler *mockHandler = [OCMockObject niceMockForClass:[TRFRouteHandler class]];
    TRFRoute *route1 = [TRFRoute routeWithId:nil scheme:nil pattern:@"route/<param1>" handler:mockHandler];
    
    NSURL *URL = [NSURL URLWithString:@"traffic://route/value"];
    TRFIntent *intent = [TRFIntent new];
    [[[(id)mockHandler stub] andReturn:intent] intentForIntent:intent];
    
    [route1 handleURL:URL intent:intent];
    [(TRFRouteHandler *)[(id)mockHandler verify] handleIntent:intent];
}

- (void)testRouteWithQueryParameterMatching
{
    TRFRoute *route = [TRFRoute routeWithId:nil scheme:nil
                                   patterns:@[
                                              @"**\\?param=<param>",
                                              @"**;param=<param>",
                                              ] handler:nil];
    
    NSURL *URL1 = [NSURL URLWithString:@"traffic://route/?param=foo"];
    expect([route matchWithURL:URL1]).to.equal(YES);
    expect(URL1.trf_routeParameters[@"param"]).to.equal(@"foo");
    
    NSURL *URL2 = [NSURL URLWithString:@"traffic://route;param=foo"];
    expect([route matchWithURL:URL2]).to.equal(YES);
    expect(URL2.trf_routeParameters[@"param"]).to.equal(@"foo");
    
    expect([route matchWithURL:[NSURL URLWithString:@"traffic://route"]]).to.equal(NO);
    expect([route matchWithURL:[NSURL URLWithString:@"traffic://route/?otherparam=bar"]]).to.equal(NO);
    expect([route matchWithURL:[NSURL URLWithString:@"traffic://route;otherparam=bar"]]).to.equal(NO);
}

@end
