//
//  NSURL+TRFRoute.m
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

#import "NSURL+TRFRoute.h"
#import <objc/runtime.h>

const void *NSURLTRFRouteParametersKey;
const void *NSURLTRFQueryParametersKey;
const void *NSURLTRFFragmentParametersKey;
const void *NSURLTRFRouteKey;

@implementation NSURL (TRFRoute)

- (void)trf_setRoute:(TRFRoute *)route
{
    objc_setAssociatedObject(self, &NSURLTRFRouteKey, route, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TRFRoute *)trf_route
{
    return objc_getAssociatedObject(self, &NSURLTRFRouteKey);
}

- (void)trf_setRouteParameters:(NSDictionary *)routeParameters
{
    objc_setAssociatedObject(self, &NSURLTRFRouteParametersKey, routeParameters, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSDictionary *)trf_routeParameters
{
    return objc_getAssociatedObject(self, &NSURLTRFRouteParametersKey);
}

- (NSString *)trf_routeParameterWithName:(NSString *)parameterName
{
    return self.trf_routeParameters[parameterName];
}

- (NSDictionary *)trf_queryParameters
{
    NSDictionary *queryParameters = objc_getAssociatedObject(self, &NSURLTRFQueryParametersKey);
    if (!queryParameters) {
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
        NSMutableDictionary *queryParametersBuffer = [NSMutableDictionary dictionary];
        [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem *queryItem, NSUInteger idx, BOOL *stop) {
            if (!queryItem.value) {
                return;
            }
            id existingValue = queryParametersBuffer[queryItem.name];
            if (existingValue) {
                NSMutableArray<NSString *> *valueList = nil;
                if ([existingValue isKindOfClass:[NSArray class]]) {
                    valueList = [NSMutableArray arrayWithArray:existingValue];
                } else if ([existingValue isKindOfClass:[NSString class]]) {
                    valueList = [NSMutableArray arrayWithObject:existingValue];
                }
                if (queryItem.value) {
                    [valueList addObject:(NSString * _Nonnull)queryItem.value];
                }
                queryParametersBuffer[queryItem.name] = [valueList copy];
            } else {
                queryParametersBuffer[queryItem.name] = queryItem.value;
            }
        }];
        queryParameters = [queryParametersBuffer copy];
        objc_setAssociatedObject(self, &NSURLTRFQueryParametersKey, queryParameters, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return queryParameters;
}

- (id)trf_queryParameterWithName:(NSString *)parameterName
{
    return self.trf_queryParameters[parameterName];
}

- (NSString *)trf_firstQueryParameterWithName:(NSString *)parameterName
{
    id value = [self trf_queryParameterWithName:parameterName];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    } else if ([value isKindOfClass:[NSArray class]]) {
        return [value firstObject];
    }
    return nil;
}

- (NSDictionary *)trf_fragmentParameters
{
    NSDictionary *fragmentParameters = objc_getAssociatedObject(self, &NSURLTRFFragmentParametersKey);
    if (!fragmentParameters) {
        NSURLComponents *urlComponents = [NSURLComponents new];
        urlComponents.query = self.fragment;
        fragmentParameters = [urlComponents.URL trf_queryParameters];
        
        objc_setAssociatedObject(self, &NSURLTRFFragmentParametersKey, fragmentParameters, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return fragmentParameters;
}

- (id)trf_fragmentParameterWithName:(NSString *)parameterName
{
    return self.trf_fragmentParameters[parameterName];
}

- (NSString *)trf_firstFragmentParameterWithName:(NSString *)parameterName
{
    id value = [self trf_fragmentParameterWithName:parameterName];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    } else if ([value isKindOfClass:[NSArray class]]) {
        return [value firstObject];
    }
    return nil;
}

@end
