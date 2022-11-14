//
//  InfoTableViewCell.h
//  eRTCApp
//
//  Created by apple on 16/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface InfoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgUserProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblDateAndTime;

@end

NS_ASSUME_NONNULL_END
