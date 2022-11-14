//
//  manageNotificationCell.h
//  eRTCApp
//
//  Created by apple on 14/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface manageNotificationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgCircle;
@property (weak, nonatomic) IBOutlet UILabel *lblSetCustomNotification;

@end

NS_ASSUME_NONNULL_END
