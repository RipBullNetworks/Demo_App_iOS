//
//  ParticipantInfoTableViewCell.h
//  eRTCApp
//
//  Created by Ashish Vani on 06/07/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ParticipantInfoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *btnRole;
@property (weak, nonatomic) IBOutlet UILabel *lblSeprater;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;

@end

NS_ASSUME_NONNULL_END
