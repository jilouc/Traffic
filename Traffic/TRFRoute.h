//
//  TRFRoute.h
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

@import Foundation;
@import UIKit;

#import "TRFRouteHandler.h"
#import "TRFIntent.h"

//////////////////////////////////////////////////////////////////////

@interface TRFRoute : NSObject

+ (instancetype)routeWithId:(NSString *)identifier
                    handler:(TRFRouteHandler *)routeHandler;

+ (instancetype)routeWithId:(NSString* )identifier
                     scheme:(NSString *)scheme
                   patterns:(NSArray<NSString *> *)patterns
                    handler:(TRFRouteHandler *)routeHandler;

+ (instancetype)routeWithId:(NSString* )identifier
                     scheme:(NSString *)scheme
                    pattern:(NSString *)pattern
                    handler:(TRFRouteHandler *)routeHandler;

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) NSString *scheme;

- (BOOL)matchWithURL:(NSURL *)URL;
- (TRFIntent *)handleURL:(NSURL *)URL intent:(TRFIntent *)intent;
- (TRFIntent *)handleIntent:(TRFIntent *)intent;

@end

@interface TRFRoute (TRFViewControllerRoute)

- (UIViewController *)targetViewControllerForIntent:(TRFIntent *)intent;
- (UIViewController *)targetViewControllerForURL:(NSURL *)URL intent:(TRFIntent *)intent;

- (Class)targetViewControllerClassForIntent:(TRFIntent *)intent;
- (Class)targetViewControllerClassForURL:(NSURL *)URL intent:(TRFIntent *)intent;

@end
