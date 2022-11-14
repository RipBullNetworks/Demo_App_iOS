//
//  RecentChatTableViewCell.h
//  eRTCApp
//
//  Created by rakesh  palotra on 26/12/18.
//  Copyright © 2018 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecentChatTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lblName;
@property (nonatomic, weak) IBOutlet UILabel *lblMessage;
@property (nonatomic, weak) IBOutlet UILabel *lblTime;
@property (nonatomic, weak) IBOutlet UILabel *lblAvailabilityStatus;
@property (nonatomic, weak) IBOutlet UIImageView *muteIMG;
@property (weak, nonatomic) IBOutlet UIImageView *imgBlock;
@property (weak, nonatomic) IBOutlet UIImageView *imgRightArrow;
@property (weak, nonatomic) IBOutlet UIImageView *imgPrivateChannel;

@property (nonatomic, weak) IBOutlet UIImageView *profileImageView;
@property (nonatomic, weak) IBOutlet UILabel *unReadMessage;

@end

NS_ASSUME_NONNULL_END
