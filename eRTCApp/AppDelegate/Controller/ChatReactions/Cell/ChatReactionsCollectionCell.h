//
//  ChatReactionsCollectionCell.h
//  eRTCApp
//
//  Created by rakesh  palotra on 30/06/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ChatReactionsCollectionCellDelegate <NSObject>
- (void)showUserWhoReacted:(NSString *_Nullable)emojiString selectedIndexPath:(NSIndexPath *_Nullable)indexPath;
@end //end protocol

@interface ChatReactionsCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelEmoji;
@property (weak, nonatomic) IBOutlet UIButton *btnEmoji;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (nonatomic, weak) id <ChatReactionsCollectionCellDelegate> delegate; //define MyClassDelegate as delegate

@end

NS_ASSUME_NONNULL_END
