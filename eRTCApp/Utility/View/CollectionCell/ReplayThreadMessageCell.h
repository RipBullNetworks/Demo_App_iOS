//
//  ReplayThreadMessageCell.h
//  eRTCApp
//
//  Created by Apple on 17/01/22.
//  Copyright © 2022 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ReplayThreadMessageCell;
@protocol replyThreadHeaderDelegate <NSObject>
@required
-(void)selectedThreadMoreIndex:(ReplayThreadMessageCell *)cell;
@end

//@property (nonatomic, weak) id<footerReplyDelegate> delegate;

@interface ReplayThreadMessageCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnReplies;
@property (weak, nonatomic) IBOutlet UIImageView *imgUserProfile;
@property (weak, nonatomic) IBOutlet UILabel *lbluserName;
@property (weak, nonatomic) IBOutlet UIButton *btnMore;
@property (weak, nonatomic) IBOutlet UILabel *lblUserType;
@property (nonatomic,weak) id<replyThreadHeaderDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
