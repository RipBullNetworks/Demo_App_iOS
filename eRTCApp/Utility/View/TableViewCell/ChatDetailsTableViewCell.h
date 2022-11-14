//
//  ChatDetailsTableViewCell.h
//  eRTCApp
//
//  Created by apple on 02/08/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatDetailsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblUserEmailId;
@property (weak, nonatomic) IBOutlet UIImageView *imgCurrentUser;
@property (weak, nonatomic) IBOutlet UIImageView *imgDot;

@end

NS_ASSUME_NONNULL_END
