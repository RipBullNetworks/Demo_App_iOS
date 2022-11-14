//
//  DisappearingMessagesVC.h
//  eRTCApp
//
//  Created by apple on 04/06/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DisappearingMessagesVC : UIViewController
@property (weak, nonatomic) IBOutlet UISwitch *switchEnableMessage;
@property (weak, nonatomic) IBOutlet UISwitch *switchAllowMember;

@end

NS_ASSUME_NONNULL_END
