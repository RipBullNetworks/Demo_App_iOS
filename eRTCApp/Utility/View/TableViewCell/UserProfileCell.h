//
//  UserProfileCell.h
//  eRTCApp
//
//  Created by Rakesh Palotra on 28/01/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserProfileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *img;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@property (weak, nonatomic) IBOutlet UILabel *lblPlaceholder;

@property (weak, nonatomic) IBOutlet UISwitch *switchNotifications;



@end

NS_ASSUME_NONNULL_END
