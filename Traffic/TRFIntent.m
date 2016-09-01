//
//  TRFIntent.m
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

#import "TRFIntent.h"
#import <objc/runtime.h>

@interface TRFIntent ()

@end

@implementation TRFIntent

+ (instancetype)intentWithURL:(NSURL *)URL
{
    return [[self alloc] initWithURL:URL];
}

+ (instancetype)intentWithRouteId:(NSString *)routeId
{
    return [[self alloc] initWithRouteId:routeId];
}

- (instancetype)initWithURL:(NSURL *)URL
{
    self = [super init];
    if (self) {
        self.URL = URL;
    }
    return self;
}

- (instancetype)initWithRouteId:(NSString *)routeId
{
    self = [super init];
    if (self) {
        self.routeId = routeId;
    }
    return self;
}

- (void)setURL:(NSURL *)URL
{
    _URL = URL;
    [self buildFromURL:URL];
}

- (void)buildFromURL:(NSURL *)URL
{
    
}

- (void)applyIntent:(TRFIntent *)intent
{
    unsigned int outCount;
    
    Class klass = [intent class];
    while (klass != [NSObject class]) {
        
        objc_property_t *properties = class_copyPropertyList(klass, &outCount);
        
        for (NSUInteger propertyIndex = 0; propertyIndex < outCount; propertyIndex++) {
            objc_property_t property = properties[propertyIndex];
            const char *propName = property_getName(property);
        
            if (propName != NULL) {
                NSString *propertyName = [NSString
                                          stringWithCString:propName
                                          encoding:[NSString defaultCStringEncoding]];
                
                id propValue = [intent valueForKey:propertyName];
                if (propValue) {
                    [self setValue:propValue forKey:propertyName];
                }
            }
        }
        klass = [klass superclass];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

@end
