//
//  TRFRoute.m
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

#import "TRFRoute.h"
#import "NSURL+TRFRoute.h"
#import "NSURL+TRFRoutePrivate.h"

//////////////////////////////////////////////////////////////////////

@interface TRFRouteParameter : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *pattern;
@property (nonatomic) NSInteger groupNumber;

@end

//////////////////////////////////////////////////////////////////////

@implementation TRFRouteParameter

@end

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

const struct {
    __unsafe_unretained NSString *String;
    __unsafe_unretained NSString *Int;
    __unsafe_unretained NSString *Regex;
} TRFRouteParameterType = {
    .String = @"str",
    .Int = @"int",
    .Regex = @"re",
};

NSString *const TRFRouteParameterValueStringPattern = @"[-!$&'()*+,.:=@_~0-9A-Za-z]+";
NSString *const TRFRouteParameterValueIntPattern    = @"[0-9]+";

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

@interface TRFRoute ()

@property (nonatomic, readwrite, copy) NSString *scheme;
@property (nonatomic, copy) NSArray<NSString *> *patterns;
@property (nonatomic) TRFRouteHandler *handler;

@property (nonatomic, readwrite, copy) NSArray<TRFRoute *> *childRoutes;

@property (nonatomic, copy) NSDictionary<NSString *, NSRegularExpression *> *routeRegularExpressions;
@property (nonatomic, copy) NSDictionary<NSString *, NSDictionary<NSString *, TRFRouteParameter *> *> *internalRouteParameters;

@end

//////////////////////////////////////////////////////////////////////

@implementation TRFRoute

+ (NSRegularExpression *)namedParametersRegex
{
    static NSRegularExpression *namedParametersRegex = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // See https://regex101.com/r/qL1jM6/1 for details about this regular expression
        // This is inspired by the way bottle.py is handling routes https://github.com/bottlepy/bottle/blob/master/bottle.py
        namedParametersRegex = [NSRegularExpression regularExpressionWithPattern:@"<([a-zA-Z0-9_]+)(?::(int|str|re))?(?::(.*?))?>"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:NULL];
    });
    return namedParametersRegex;
}

+ (instancetype)routeWithScheme:(NSString *)scheme
                        pattern:(NSString *)pattern
                        handler:(TRFRouteHandler *)routeHandler
{
    return [self routeWithScheme:scheme
                        patterns:pattern ? @[pattern] : nil
                         handler:routeHandler];
}

+ (instancetype)routeWithScheme:(NSString *)scheme
                       patterns:(NSArray<NSString *> *)patterns
                        handler:(TRFRouteHandler *)routeHandler
{
    return [[self alloc] initWithScheme:scheme 
                               patterns:patterns
                                handler:routeHandler];
}

- (instancetype)initWithScheme:(NSString *)scheme
                      patterns:(NSArray<NSString *> *)patterns
                       handler:(TRFRouteHandler *)routeHandler
{
    self = [super init];
    if (self) {
        self.scheme = scheme;
        self.patterns = patterns;
        self.handler = routeHandler;
        [self compileRoute];
    }
    return self;
}

- (void)compileRoute
{
    if (self.patterns.count == 0) {
        return;
    }
    
    NSMutableDictionary *internalRouteParameters = [NSMutableDictionary dictionary];
    NSMutableDictionary *routeRegularExpressions = [NSMutableDictionary dictionary];
    
    NSRegularExpression *namedParameterRegex = [self.class namedParametersRegex];
    
    [self.patterns enumerateObjectsUsingBlock:^(NSString *pattern, NSUInteger patternIndex, BOOL *patternStop) {
    
        if (pattern.length == 0) {
            return;
        }
        
        NSMutableDictionary *routeParameters = [NSMutableDictionary dictionary];
        NSMutableString *compiledPatternBuffer = [pattern mutableCopy];
        __block NSInteger replacementOffset = 0;
        __block NSInteger parameterIndex = 1;
        
        [namedParameterRegex
         enumerateMatchesInString:pattern
         options:0
         range:NSMakeRange(0, pattern.length)
         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
             
             NSString *parameterName = [pattern substringWithRange:[result rangeAtIndex:1]];
             NSString *parameterType = TRFRouteParameterType.String;
             NSString *parameterValuePattern = TRFRouteParameterValueStringPattern;
             NSRange typeRange = [result rangeAtIndex:2];
             if (typeRange.location != NSNotFound) {
                 parameterType = [pattern substringWithRange:typeRange];
                 if ([parameterType isEqualToString:TRFRouteParameterType.Regex]) {
                     NSRange patternRange = [result rangeAtIndex:3];
                     if (patternRange.location != NSNotFound && patternRange.length != 0) {
                         parameterValuePattern = [pattern substringWithRange:patternRange];
                     } else {
                         NSLog(@"missing pattern for parameter %@ of type 'regular expression' in route %@", parameterName, pattern);
                     }
                 } else if ([parameterType isEqualToString:TRFRouteParameterType.Int]) {
                     parameterValuePattern = TRFRouteParameterValueIntPattern;
                 }
             }
             
             NSRange resultRange = [result range];
             
             NSString *replacementPattern = [[[NSString stringWithFormat:@"(%@)", parameterValuePattern]
                                              stringByReplacingOccurrencesOfString:@"*" withString:@"¤"]
                                             stringByReplacingOccurrencesOfString:@"." withString:@"§§"];
             [compiledPatternBuffer replaceCharactersInRange:NSMakeRange(resultRange.location + replacementOffset, resultRange.length)
                                                  withString:replacementPattern];
             
             replacementOffset += (replacementPattern.length - resultRange.length);
             
             TRFRouteParameter *routeParameter = [TRFRouteParameter new];
             routeParameter.name = parameterName;
             routeParameter.pattern = parameterValuePattern;
             routeParameter.groupNumber = parameterIndex;
             routeParameters[parameterName] = routeParameter;
             
             parameterIndex += 1;
         }];
        
        internalRouteParameters[pattern] = [routeParameters copy];
        
        // Any remaining dot should now be escaped
        [compiledPatternBuffer replaceOccurrencesOfString:@"." withString:@"\\." options:0 range:NSMakeRange(0, compiledPatternBuffer.length)];
        // Convert back the escaped regular expression dots to "."
        [compiledPatternBuffer replaceOccurrencesOfString:@"§§" withString:@"." options:0 range:NSMakeRange(0, compiledPatternBuffer.length)];
        // Handle wildcard in path, escape the *
        [compiledPatternBuffer replaceOccurrencesOfString:@"*" withString:@"#*#" options:0 range:NSMakeRange(0, compiledPatternBuffer.length)];
        // Convert global wildcards (initially **)
        [compiledPatternBuffer replaceOccurrencesOfString:@"#*##*#" withString:@"(?:.*?)" options:0 range:NSMakeRange(0, compiledPatternBuffer.length)];
        // Then convert the remaining simple wildcards (initially *)
        [compiledPatternBuffer replaceOccurrencesOfString:@"#*#" withString:@"(?:[^/]+?)" options:0 range:NSMakeRange(0, compiledPatternBuffer.length)];
        // Convert back the escaped regular expression *
        [compiledPatternBuffer replaceOccurrencesOfString:@"¤" withString:@"*" options:0 range:NSMakeRange(0, compiledPatternBuffer.length)];
        
        // Normalization - trim leading and trailing whitespaces, new lines and slashes
        NSString *compiledPattern = [[compiledPatternBuffer
                                      stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                                     stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
        
        // Support the same route with or without trailing slash
        compiledPattern = [compiledPattern stringByAppendingString:@"\\/?"];
        
        NSError *error = nil;
        BOOL assertsPositionAtStartOfRange = YES;
        BOOL assertsPositionAtEndOfRange = YES;
        
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:[NSString stringWithFormat:@"%@%@%@",
                                                                    assertsPositionAtStartOfRange ? @"^" : @"",
                                                                    compiledPattern,
                                                                    assertsPositionAtEndOfRange ? @"$" : @""]
                                      options:NSRegularExpressionCaseInsensitive
                                      error:&error];
        if (regex) {
            routeRegularExpressions[pattern] = regex;
        }
        if (error) {
            [[NSException exceptionWithName:NSInvalidArgumentException
                                     reason:[NSString stringWithFormat:@"Error while compiling pattern for route %@ (trying to compile regex with <<%@>>)", pattern, compiledPattern]
                                   userInfo:@{NSLocalizedFailureReasonErrorKey: error.localizedFailureReason}]
             raise];
        }
    }];
    
    self.routeRegularExpressions = routeRegularExpressions;
    self.internalRouteParameters = internalRouteParameters;
}

- (BOOL)matchWithURL:(NSURL *)URL
{
    if (URL.trf_route) {
        return URL.trf_route == self;
    }
    if (!URL) {
        return NO;
    }
    if (self.scheme && [URL.scheme compare:self.scheme options:NSCaseInsensitiveSearch] != NSOrderedSame) {
        return NO;
    }
    NSString *hostAndPath = [URL.host stringByAppendingString:URL.path];
    if (!hostAndPath) {
        return NO;
    }
    
    __block NSTextCheckingResult *result = nil;
    __block NSDictionary *internalRouteParameters = nil;
    
    [self.patterns enumerateObjectsUsingBlock:^(NSString *pattern, NSUInteger patternIndex, BOOL *patternStop) {
        NSRegularExpression *regex = self.routeRegularExpressions[pattern];
        if (!regex) {
            return;
        }
        result = [regex
                  firstMatchInString:hostAndPath
                  options:(NSMatchingOptions)0
                  range:NSMakeRange(0, hostAndPath.length)];
        if (result) {
            internalRouteParameters = self.internalRouteParameters[pattern];
            *patternStop = YES;
        }
    }];
    
    if (!result) {
        __block BOOL foundChildRouteMatch = NO;
        [self.childRoutes enumerateObjectsUsingBlock:^(TRFRoute *childRoute, NSUInteger idx, BOOL *childRouteStop) {
            foundChildRouteMatch = [childRoute matchWithURL:URL];
            if (foundChildRouteMatch) {
                *childRouteStop = YES;
            }
        }];
        return foundChildRouteMatch;
    }
    
    [URL trf_setRoute:self];
    
    NSMutableDictionary *routeParameters = [NSMutableDictionary dictionary];
    [internalRouteParameters enumerateKeysAndObjectsUsingBlock:^(NSString *name, TRFRouteParameter *parameter, BOOL *stop) {
        NSRange resultRange = [result rangeAtIndex:parameter.groupNumber];
        if (resultRange.length == 0 || resultRange.location == NSNotFound) {
            return;
        }
        NSString *paramValue = [hostAndPath substringWithRange:resultRange];
        if (paramValue) {
            routeParameters[name] = paramValue;
        }
    }];
    [URL trf_setRouteParameters:routeParameters];
    return YES;
}

- (BOOL)handleURL:(NSURL *)URL
{
    return [self handleURL:URL context:nil];
}

- (BOOL)handleURL:(NSURL *)URL context:(id)context
{
    if (![self matchWithURL:URL]) {
        return NO;
    }
    
    NSMutableArray<TRFRouteHandler *> *handlerChain = [NSMutableArray array];
    TRFRoute *route = self;
    while (route) {
        if (route.handler) {
            [handlerChain insertObject:route.handler atIndex:0];
        }
        route = route.parentRoute;
    }
    
    _recursiveHandlerChainCall(handlerChain, URL, context);
    
    return YES;
}

void _recursiveHandlerChainCall(NSMutableArray<TRFRouteHandler *> *handlerChain, NSURL *URL, id context)
{
    TRFRouteHandler *handler = [handlerChain firstObject];
    if (!handler) {
        return;
    }
    id newContext = [handler contextForURL:URL context:context];
    [handler handleURL:URL context:newContext];
    [handlerChain removeObjectAtIndex:0];
    _recursiveHandlerChainCall(handlerChain, URL, newContext);
}

#pragma mark - Child routes

- (void)addChildRoute:(TRFRoute *)childRoute
{
    if (!childRoute) {
        return;
    }
    [self addChildRoutes:@[childRoute]];
}

- (void)addChildRoutes:(NSArray<TRFRoute *> *)childRoutes
{
    if (childRoutes.count == 0) {
        return;
    }
    NSMutableArray *newChildRoutes = [NSMutableArray arrayWithArray:self.childRoutes];
    [newChildRoutes addObject:childRoutes];
    self.childRoutes = childRoutes;
    
    [childRoutes enumerateObjectsUsingBlock:^(TRFRoute *childRoute, NSUInteger idx, BOOL *stop) {
        if (childRoute.scheme.length == 0) {
            childRoute.scheme = self.scheme;
        }
        childRoute.parentRoute = self;
    }];
}

- (void)setParentRoute:(TRFRoute *)parentRoute
{
    _parentRoute = parentRoute;
    [self compileRoute];
}

#pragma mark -

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"%@ - %@ - %@",
            self.scheme,
            self.patterns,
            [self.routeRegularExpressions valueForKey:@"pattern"]];
}

@end
