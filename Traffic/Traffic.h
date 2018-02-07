#import <Foundation/Foundation.h>
#import <Availability.h>
#import <TargetConditionals.h>

#ifndef _TRAFFIC_
#define _TRAFFIC_

#import "TRFIntent.h"
#import "NSURL+TRFRoute.h"
#import "TRFRouteHandler.h"
#import "TRFRoute.h"
#import "TRFUIRouter.h"
#import "TRFExternalLaunchInfo.h"

#if !TARGET_OS_WATCH
#import "TRFIntent+PresentingWindow.h"
#import "TRFRoute+TRFViewControllerRoute.h"
#import "TRFRouteTargetViewController.h"
#import "TRFUIRouter+TRFViewControllerRoute.h"
#import "TRFViewControllerIntent.h"
#import "TRFViewControllerRouteHandler.h"
#endif


#endif /* _TRAFFIC_ */
