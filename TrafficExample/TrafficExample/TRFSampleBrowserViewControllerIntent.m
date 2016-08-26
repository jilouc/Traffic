//
//  TRFSampleBrowserViewControllerIntent.m
//  
//
//  Created by Jean-Luc Dagon on 26/08/2016.
//
//

#import "TRFSampleBrowserViewControllerIntent.h"

@implementation TRFSampleBrowserViewControllerIntent

- (void)buildFromURL:(NSURL *)URL
{
    NSURLComponents *urlComponents = nil;
    if ([URL.scheme hasPrefix:@"http"]) {
        urlComponents = [[NSURLComponents alloc] initWithURL:URL resolvingAgainstBaseURL:nil];
    } else {
        NSString *webURLStr = URL.trf_queryParameters[@"url"];
        if (webURLStr.length) {
            urlComponents = [[NSURLComponents alloc] initWithURL:[NSURL URLWithString:webURLStr] resolvingAgainstBaseURL:nil];
        }
    }
    NSMutableArray *queryItems = [NSMutableArray arrayWithArray:urlComponents.queryItems];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"xtref"
                                                      value:@"traffic.github.io"]];
    urlComponents.queryItems = queryItems;
    
    self.webURL = [urlComponents URL];
}


@end
