//
//  TRFRoute+TRFViewControllerRoute.m
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

#import "TRFRoute+TRFViewControllerRoute.h"
#import "TRFViewControllerRouteHandler.h"
#import "TRFRoute+Internal.h"

@implementation TRFRoute (TRFViewControllerRoute)

- (TRFViewControllerIntent *)targetIntentForURL:(NSURL *)URL intent:(TRFIntent *)intent
{
    TRFIntent *handlerIntent = [self.handler intentForIntent:intent];
    if (![self.handler isKindOfClass:[TRFViewControllerRouteHandler class]] ||
        ![handlerIntent isKindOfClass:[TRFViewControllerIntent class]]) {
        return nil;
    }
    return (TRFViewControllerIntent *)handlerIntent;
}

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
