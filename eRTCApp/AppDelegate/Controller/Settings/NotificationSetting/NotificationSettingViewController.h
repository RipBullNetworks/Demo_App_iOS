//
//  NotificationSettingViewController.h
//  eRTCApp
//
//  Created by rakesh  palotra on 12/05/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NotificationSettingViewController : UIViewController
@property (assign) BOOL isFromGroup;
@property (nonatomic, strong) NSString *strGroupThreadID;
@property (weak, nonatomic) IBOutlet UIImageView *imgNewMessage;

@property (weak, nonatomic) IBOutlet UIImageView *imgMention;
@property (weak, nonatomic) IBOutlet UIImageView *imgNothing;


@end

NS_ASSUME_NONNULL_END
