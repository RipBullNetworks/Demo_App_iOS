//
//  MediaModerationVc.m
//  eRTCApp
//
//  Created by apple on 14/05/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "MediaModerationVc.h"

@interface MediaModerationVc ()

@end

@implementation MediaModerationVc

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Media Moderation";
    NSDictionary *dictChat = _dictMedia[@"chat"];
    NSString *msgType = dictChat[MsgType];
    if ([msgType isEqualToString:GifyFileName]) {
        NSString *imageURL = [NSString stringWithFormat:@"%@",dictChat[GifyFileName]];
        [_imgProfile sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
    }else if ([msgType isEqualToString:Key_video]) {
        
    }else if ([msgType isEqualToString:Key_image]) {
        NSDictionary *dictmedia = dictChat[@"media"];
        NSDictionary *dictConfig = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
        NSString *imgBaseurl;
        if ([dictConfig isKindOfClass:[NSDictionary class]]){
            if  (![Helper stringIsNilOrEmpty:dictConfig[ChatServerBaseurl]]) {
                imgBaseurl = [dictConfig[ChatServerBaseurl] stringByAppendingString:BaseUrlVersion];
            }
        }
        NSString *imageURL = [NSString stringWithFormat:@"%@",dictmedia[@"path"]];
        NSString *strUrl = [imgBaseurl stringByAppendingString:imageURL];
        [_imgProfile sd_setImageWithURL:strUrl placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
    }else{
        [_imgProfile sd_setImageWithURL:[UIImage imageNamed:@"DefaultUserIcon"] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
    }
}



@end
