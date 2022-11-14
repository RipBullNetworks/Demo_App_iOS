//
//  ReplyThreadFooterCell.h
//  eRTCApp
//
//  Created by Apple on 17/01/22.
//  Copyright © 2022 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ReplyThreadFooterCell;
@protocol footerReplyDelegate <NSObject>
@required
- (void)selectedReplyThreadIndex:(ReplyThreadFooterCell *)cell;
@end

@interface ReplyThreadFooterCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *btnReply;
@property (nonatomic, weak) id<footerReplyDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
