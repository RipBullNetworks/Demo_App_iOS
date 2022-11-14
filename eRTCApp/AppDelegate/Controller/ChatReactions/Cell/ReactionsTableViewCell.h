//
//  ReactionsTableViewCell.h
//  eRTCApp
//
//  Created by rakesh  palotra on 21/06/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmojiHelper.h"
NS_ASSUME_NONNULL_BEGIN

@interface ReactionsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIButton *btnLike;
@property (weak, nonatomic) IBOutlet UIButton *btnDisLike;
@property (weak, nonatomic) IBOutlet UIButton *btnLaughLike;
@property (weak, nonatomic) IBOutlet UIButton *btnRofl;
@property (weak, nonatomic) IBOutlet UIButton *btnHeart;
@property (weak, nonatomic) IBOutlet UIButton *btnClap;
@property (strong, nonatomic) NSArray<MyEmojiCategory *> *emojiCategories;

- (void)updateRecentEmojis;
@end

NS_ASSUME_NONNULL_END
