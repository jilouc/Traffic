//
//  TRFUIRouter+TRFViewControllerRoute.m
//  Traffic
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

#import "TRFUIRouter+TRFViewControllerRoute.h"
#import "TRFRoute+TRFViewControllerRoute.h"

@implementation TRFUIRouter (TRFViewControllerRoute)

- (TRFViewControllerIntent *)targetIntentForURL:(NSURL *)URL intent:(TRFIntent *)intent
{
    TRFRoute *route = [self routeMatchingURL:URL];
    if (route == nil) {
        return nil;
    }
    
    TRFViewControllerIntent *baseIntent = [TRFViewControllerIntent intentWithURL:URL];
    [baseIntent applyIntent:intent];
    
    TRFIntent *finalIntent = [route targetIntentForURL:URL intent:baseIntent];
    [finalIntent applyIntent:baseIntent];
    
    if ([finalIntent isKindOfClass:[TRFViewControllerIntent class]]) {
        return (TRFViewControllerIntent *)finalIntent;
    }
    return nil;
}

- (Class)targetViewControllerClassForIntent:(TRFIntent *)intent
{
    if (intent.routeId.length) {
        TRFRoute *route = [self routeWithId:intent.routeId];
        if (route) {
            return [route targetViewControllerClassForIntent:intent];
        }
    }
    if (intent.URL) {
        return [self targetViewControllerClassForURL:intent.URL intent:intent];
    }
    return Nil;
}

- (Class)targetViewControllerClassForURL:(NSURL *)URL intent:(TRFIntent *)intent
{
    TRFRoute *route = [self routeMatchingURL:URL];
    return [route targetViewControllerClassForURL:URL intent:intent];
}

- (UIViewController *)targetViewControllerForIntent:(TRFIntent *)intent
{
    if (intent.routeId.length) {
        TRFRoute *route = [self routeWithId:intent.routeId];
        if (route) {
            return [route targetViewControllerForIntent:intent];
        }
    }
    if (intent.URL) {
        return [self targetViewControllerForURL:intent.URL intent:intent];
    }
    return Nil;
}

- (UIViewController *)targetViewControllerForURL:(NSURL *)URL intent:(TRFIntent *)intent
{
    TRFRoute *route = [self routeMatchingURL:URL];
    return [route targetViewControllerForURL:URL intent:intent];
}

- (TRFViewControllerIntent *)deferredRouteURL:(NSURL *)URL intent:(TRFIntent *)intent
{
    TRFRoute *route = [self routeMatchingURL:URL];
    if (route == nil) {
        return nil;
    }
    
    TRFViewControllerIntent *baseIntent = [TRFViewControllerIntent intentWithURL:URL];
    [baseIntent applyIntent:intent];
    baseIntent.deferredPresentation = YES;
    
    TRFIntent *finalIntent = [route handleURL:URL intent:baseIntent];
    if ([finalIntent isKindOfClass:[TRFViewControllerIntent class]]) {
        return (TRFViewControllerIntent *)finalIntent;
    }
    return nil;
}

@end
