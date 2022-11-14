//
//  chatReplyCount.h
//  eRTCApp
//
//  Created by rakesh  palotra on 02/05/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatReactionsCollectionCell.h"

@class chatReplyCount;
@protocol ChatReplyCountDelegate <NSObject>
- (void)sendEmoji:(NSString *_Nullable)string selectedIndexPath:(NSIndexPath *_Nullable)indexPath;
- (void)showUserWhoReacted:(NSString *_Nullable)emojiString selectedIndexPath:(NSIndexPath *_Nullable)indexPath;
- (void)btnUndoChatMessage:(NSIndexPath *_Nullable)indexPath;

@end //end protocol

NS_ASSUME_NONNULL_BEGIN

@interface chatReplyCount : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, ChatReactionsCollectionCellDelegate>

@property (nonatomic,retain)IBOutlet UILabel *lblCount;
@property (nonatomic,retain)IBOutlet UIButton *btnReplyThread;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reactionViewHeight;
@property (nonatomic, weak) id <ChatReplyCountDelegate> delegate; //define MyClassDelegate as delegate

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *arrEmojis;
@property (strong, nonatomic) NSMutableArray *arrUsers;
@property (strong, nonatomic) NSMutableArray *arrUnduMessage;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (weak , nonatomic) NSString *selectedUndoMessage;


- (void)messageSent:(BOOL)status;
- (void)convertDataToEmoji:(NSDate *)data;
 -(void)showUndoChatMessage: (NSArray *)ary;
- (void)showHideThreadReplyView:(BOOL)threadView;
- (void)showHideChatReactionViews:(BOOL)reactionView;
-(void)setPaddingForLastMessage;

@end

NS_ASSUME_NONNULL_END
