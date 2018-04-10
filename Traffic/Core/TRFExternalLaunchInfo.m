//
//  TRFExternalLaunchInfo.m
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

#import "TRFExternalLaunchInfo.h"

@interface TRFExternalLaunchInfo ()

- (instancetype)initWithOptions:(NSDictionary *)options;

@end

@implementation TRFExternalLaunchInfo

+ (instancetype)launchInfoWithOptions:(NSDictionary *)options
{
    return [(TRFExternalLaunchInfo *)[self alloc] initWithOptions:options];
}

- (instancetype)initWithOptions:(NSDictionary *)options
{
    self = [super init];
    if (self) {
        self.options = options;
    }
    return self;
}

#pragma mark - Deprecated

+ (instancetype)launchInfoWithSourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[self alloc] initWithSourceApplication:sourceApplication annotation:annotation];
}

- (instancetype)initWithSourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    self = [super init];
    if (self) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
        self.sourceApplication = sourceApplication;
        self.annotation = annotation;
#pragma clang diagnostic pop
    }
    return self;
}

@end
