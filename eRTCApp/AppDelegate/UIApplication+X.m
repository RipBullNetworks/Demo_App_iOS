//
//  UIApplication+X.m
//  eRTCApp
//
//  Created by rakesh  palotra on 15/03/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "UIApplication+X.h"

@implementation UIApplication (X)
+(void)openLinkInBrowser:(NSURL*)url{
    if (!url){return;}
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:NULL];
    }else{
        // Fallback on earlier versions
        [[UIApplication sharedApplication] openURL:url];
    }
}
@end
