//
//  NotificationService.m
//  NotificationServiceExtension
//
//  Created by rakesh  palotra on 21/02/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import "NotificationService.h"
#import <eRTC/eRTC.h>
#import "NSString+HTML.h"
#import "GTMNSString+HTML.h"
#import "Helper.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService


- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    
   self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    NSLog(@"notification>>>>>> extension--%@",request.content);
    [eRTCSDK didReceiveRemoteNotification:request.content.userInfo withBundleID:@"com.ripbull.eRTC"];
    NSString * jsonString = [request.content.userInfo valueForKey:@"message"];
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary  *jsonnew = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSLog(@" jsonnew -->>>>>>>>>>>>>>>>>%@",jsonnew);
    NSDictionary *details = [eRTCSDK decryptMessage:jsonnew];
    NSLog(@" details -->>>>>>>>>>>>>>>>>%@",details);
    if ([jsonnew[@"msgType"] isEqualToString:@"text"]){
        NSString *message = details[@"message"];
        NSString *strDecode = [NSString stringWithFormat:@"%@", message];
        NSString *strNew = [strDecode stringByDecodingHTMLEntities];
        NSString *mentionString = [strNew stringByReplacingOccurrencesOfString:@"<" withString:@" "];
        NSString *strMention = [mentionString stringByReplacingOccurrencesOfString:@">" withString:@" "];
        NSLog(@"strNew extension-->>>>>>>>>>>>>>>>>%@",strMention);
        self.bestAttemptContent.title = [NSString stringWithFormat:@"%@", self.bestAttemptContent.title];
        self.bestAttemptContent.body = [NSString stringWithFormat:@"%@", strMention];
    }else if ([jsonnew[@"msgType"] isEqualToString:@"location"]) {
        NSLog(@"strNew-->>>>>>jsonnew[@]>>location>>>>>>>>>");
        self.bestAttemptContent.title = [NSString stringWithFormat:@"%@", self.bestAttemptContent.title];
        NSString *strDecode = [NSString stringWithFormat:@"%@", self.bestAttemptContent.body];
        NSString *strNew = [strDecode stringByDecodingHTMLEntities];
        self.bestAttemptContent.body = [NSString stringWithFormat:@"%@", strNew];
    }else{
        self.bestAttemptContent.title = [NSString stringWithFormat:@"%@", self.bestAttemptContent.title];
        NSString *strDecode = [NSString stringWithFormat:@"%@", self.bestAttemptContent.body];
        NSString *strNew = [strDecode stringByDecodingHTMLEntities];
        self.bestAttemptContent.body = [NSString stringWithFormat:@"%@", strNew];
    }
    self.contentHandler(self.bestAttemptContent);
}


- (void)serviceExtensionTimeWillExpire {
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
    NSLog(@"notification extension-->>>>>>>>>>%@",self.bestAttemptContent);
}

@end
