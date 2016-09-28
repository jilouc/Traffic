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
#import "TRFViewControllerRouteHandler.h"

//////////////////////////////////////////////////////////////////////

@interface TRFRouteParameter : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *pattern;
@property (nonatomic) NSUInteger groupNumber;

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

NSString *const TRFRouteParameterPatternWithSchemePattern = @"^(.*?)://(.*?)$";
NSString *const TRFRouteParameterValueStringPattern       = @"[-!$&'()*+,.:=@_~0-9A-Za-z]+";
NSString *const TRFRouteParameterValueIntPattern          = @"[0-9]+";

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

@interface TRFRoute ()

@property (nonatomic, readwrite, copy) NSString *identifier;
@property (nonatomic, readwrite, copy) NSString *scheme;
@property (nonatomic, copy) NSArray<NSString *> *patterns;
@property (nonatomic) TRFRouteHandler *handler;

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

+ (instancetype)routeWithId:(NSString *)identifier
                    handler:(TRFRouteHandler *)routeHandler
{
    return [self routeWithId:identifier
                      scheme:nil
                    patterns:nil
                     handler:routeHandler];
}

+ (instancetype)routeWithId:(NSString *)identifier
                     scheme:(NSString *)scheme
                    pattern:(NSString *)pattern
                    handler:(TRFRouteHandler *)routeHandler
{
    return [self routeWithId:identifier
                      scheme:scheme
                    patterns:pattern ? @[pattern] : nil
                     handler:routeHandler];
}

+ (instancetype)routeWithId:(NSString *)identifier
                     scheme:(NSString *)scheme
                   patterns:(NSArray<NSString *> *)patterns
                    handler:(TRFRouteHandler *)routeHandler
{
    return [[self alloc] initWithId:identifier
                             scheme:scheme
                           patterns:patterns
                            handler:routeHandler];
}

- (instancetype)initWithId:(NSString *)identifier
                    scheme:(NSString *)scheme
                  patterns:(NSArray<NSString *> *)patterns
                   handler:(TRFRouteHandler *)routeHandler
{
    self = [super init];
    if (self) {
        if (identifier.length != 0) {
            self.identifier = identifier;
        } else {
            self.identifier = [[NSUUID UUID] UUIDString];
        }
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
        __block NSUInteger replacementOffset = 0;
        __block NSUInteger parameterIndex = 1;
        
        [namedParameterRegex
         enumerateMatchesInString:pattern
         options:(NSMatchingOptions)0
         range:NSMakeRange(0, pattern.length)
         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
             
             NSString *parameterName = [pattern substringWithRange:[result rangeAtIndex:1]];
             NSString *parameterType;
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
        
        NSStringCompareOptions options = (NSStringCompareOptions)0;
        
        // Any remaining dot should now be escaped
        [compiledPatternBuffer replaceOccurrencesOfString:@"." withString:@"\\." options:options range:NSMakeRange(0, compiledPatternBuffer.length)];
        // Convert back the escaped regular expression dots to "."
        [compiledPatternBuffer replaceOccurrencesOfString:@"§§" withString:@"." options:options range:NSMakeRange(0, compiledPatternBuffer.length)];
        // Handle wildcard in path, escape the *
        [compiledPatternBuffer replaceOccurrencesOfString:@"*" withString:@"#*#" options:options range:NSMakeRange(0, compiledPatternBuffer.length)];
        // Convert global wildcards (initially **)
        [compiledPatternBuffer replaceOccurrencesOfString:@"#*##*#" withString:@"(?:.*?)" options:options range:NSMakeRange(0, compiledPatternBuffer.length)];
        // Then convert the remaining simple wildcards (initially *)
        [compiledPatternBuffer replaceOccurrencesOfString:@"#*#" withString:@"(?:[^/]+?)" options:options range:NSMakeRange(0, compiledPatternBuffer.length)];
        // Convert back the escaped regular expression *
        [compiledPatternBuffer replaceOccurrencesOfString:@"¤" withString:@"*" options:options range:NSMakeRange(0, compiledPatternBuffer.length)];
        
        // Normalization - trim leading and trailing whitespaces, new lines and slashes
        NSString *compiledPattern = [[compiledPatternBuffer
                                      stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                                     stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
        
        // Support the same route with or without trailing slash
        compiledPattern = [compiledPattern stringByAppendingString:@"\\/?"];
        
        NSError *error = nil;
        BOOL assertsPositionAtStartOfRange = YES;
        BOOL assertsPositionAtEndOfRange = YES;
        
        
        static NSRegularExpression *patternWithSchemeRegex = nil;
        if (!patternWithSchemeRegex) {
            patternWithSchemeRegex = [NSRegularExpression regularExpressionWithPattern:TRFRouteParameterPatternWithSchemePattern
                                                                               options:(NSRegularExpressionOptions)0
                                                                                 error:NULL];
        }
        
        BOOL patternIncludesScheme = NO;
        if (compiledPattern.length) {
            // The URL scheme may be included right in the pattern
            // so that a route can match multiple patterns with multiple schemes for instance
            // We need to check whether each pattern includes the URL scheme and match it
            // against the given URL scheme.
            NSTextCheckingResult *patternWithSchemeResult = [patternWithSchemeRegex firstMatchInString:compiledPattern
                                                                                               options:(NSMatchingOptions)0
                                                                                                 range:NSMakeRange(0, compiledPattern.length)];
            patternIncludesScheme = (patternWithSchemeResult != nil);
        }
        
        
        
        NSString *regexPattern = [NSString stringWithFormat:@"%@%@%@%@",
                                  assertsPositionAtStartOfRange ? @"^" : @"",
                                  patternIncludesScheme ? (self.scheme.length ? self.scheme : @"") : @"(?:[^:]+)://",
                                  compiledPattern,
                                  assertsPositionAtEndOfRange ? @"$" : @""];
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:regexPattern
                                      options:NSRegularExpressionCaseInsensitive
                                      error:&error];
        if (regex) {
            routeRegularExpressions[pattern] = regex;
        }
        if (error) {
            [[NSException exceptionWithName:NSInvalidArgumentException
                                     reason:[NSString stringWithFormat:@"Error while compiling pattern for route %@ (trying to compile regex with <<%@>>)", pattern, regexPattern]
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
    
    NSURLComponents *testedUrlComponents = [NSURLComponents new];
    testedUrlComponents.host = URL.host;
    testedUrlComponents.scheme = URL.scheme;
    testedUrlComponents.path = URL.path;
    
    if (!testedUrlComponents) {
        return NO;
    }
    
    __block NSTextCheckingResult *result = nil;
    __block NSDictionary *internalRouteParameters = nil;
    __block NSString *testedURLPart = nil;
    
    [self.patterns enumerateObjectsUsingBlock:^(NSString *pattern, NSUInteger patternIndex, BOOL *patternStop) {
        
        NSRegularExpression *regex = self.routeRegularExpressions[pattern];
        if (!regex) {
            return;
        }
        
        if ([pattern containsString:@"#"]) {
            testedUrlComponents.fragment = URL.fragment;
        } else {
            testedUrlComponents.fragment = nil;
        }
        NSString *testedURLPartForPattern = [testedUrlComponents string];
        
        result = [regex
                  firstMatchInString:testedURLPartForPattern
                  options:(NSMatchingOptions)0
                  range:NSMakeRange(0, testedURLPartForPattern.length)];
        if (result) {
            internalRouteParameters = self.internalRouteParameters[pattern];
            testedURLPart = testedURLPartForPattern;
            *patternStop = YES;
        }
    }];
    
    if (result == nil) {
        return NO;
    }
    
    [URL trf_setRoute:self];
    
    NSMutableDictionary *routeParameters = [NSMutableDictionary dictionary];
    [internalRouteParameters enumerateKeysAndObjectsUsingBlock:^(NSString *name, TRFRouteParameter *parameter, BOOL *stop) {
        NSRange resultRange = [result rangeAtIndex:parameter.groupNumber];
        if (resultRange.length == 0 || resultRange.location == NSNotFound) {
            return;
        }
        NSString *paramValue = [testedURLPart substringWithRange:resultRange];
        if (paramValue) {
            routeParameters[name] = paramValue;
        }
    }];
    
    [URL trf_setRouteParameters:routeParameters];
    return YES;
}

- (TRFIntent *)intentForURL:(NSURL *)URL intent:(TRFIntent *)intent
{
    TRFIntent *routeIntent = nil;
    if (!intent) {
        routeIntent = [TRFIntent intentWithURL:URL];
    } else {
        routeIntent = intent;
        routeIntent.URL = URL;
    }
    routeIntent.routeId = self.identifier;
    return routeIntent;
}

- (TRFIntent *)handleURL:(NSURL *)URL intent:(TRFIntent *)intent
{
    if (![self matchWithURL:URL]) {
        return nil;
    }
    
    TRFIntent *routeIntent = [self intentForURL:URL intent:intent];
    
    if (!self.handler) {
        return routeIntent;
    }
    
    TRFIntent *handlerIntent = [self.handler intentForIntent:routeIntent];
    [handlerIntent applyIntent:routeIntent];
    
    if ([self.handler handleIntent:handlerIntent]) {
        return handlerIntent;
    }
    return nil;
}

- (TRFIntent *)handleIntent:(TRFIntent *)intent
{
    if (!self.handler) {
        return intent;
    }
    
    TRFIntent *handlerIntent = [self.handler intentForIntent:intent];
    [handlerIntent applyIntent:intent];
    
    if ([self.handler handleIntent:handlerIntent]) {
        return handlerIntent;
    }
    return nil;
}

#pragma mark -

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"[%@] %@ - %@ - %@",
            self.identifier,
            self.scheme,
            self.patterns,
            [self.routeRegularExpressions valueForKey:@"pattern"]];
}

@end


@implementation TRFRoute (TRFViewControllerRoute)

- (UIViewController *)targetViewControllerForIntent:(TRFIntent *)intent
{
    TRFIntent *handlerIntent = [self.handler intentForIntent:intent];
    if (![self.handler isKindOfClass:[TRFViewControllerRouteHandler class]] ||
        ![handlerIntent isKindOfClass:[TRFViewControllerIntent class]]) {
        return nil;
    }
    TRFViewControllerRouteHandler *vcRouteHandler = (TRFViewControllerRouteHandler *)self.handler;
    TRFViewControllerIntent *vcIntent = (TRFViewControllerIntent *)handlerIntent;
    return [vcRouteHandler targetViewControllerForIntent:vcIntent];
}

- (UIViewController *)targetViewControllerForURL:(NSURL *)URL intent:(TRFIntent *)intent
{
    TRFIntent *routeIntent = [self intentForURL:URL intent:intent];
    return [self targetViewControllerForIntent:routeIntent];
}

- (Class)targetViewControllerClassForIntent:(TRFIntent *)intent
{
    TRFIntent *handlerIntent = [self.handler intentForIntent:intent];
    if (![self.handler isKindOfClass:[TRFViewControllerRouteHandler class]] ||
        ![handlerIntent isKindOfClass:[TRFViewControllerIntent class]]) {
        return Nil;
    }
    TRFViewControllerRouteHandler *vcRouteHandler = (TRFViewControllerRouteHandler *)self.handler;
    TRFViewControllerIntent *vcIntent = (TRFViewControllerIntent *)handlerIntent;
    return [vcRouteHandler targetViewControllerClassForIntent:vcIntent];
}


- (Class)targetViewControllerClassForURL:(NSURL *)URL intent:(TRFIntent *)intent
{
    TRFIntent *routeIntent = [self intentForURL:URL intent:intent];
    return [self targetViewControllerClassForIntent:routeIntent];
}

@end
