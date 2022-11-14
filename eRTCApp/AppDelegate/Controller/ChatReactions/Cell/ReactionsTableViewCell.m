//
//  ReactionsTableViewCell.m
//  eRTCApp
//
//  Created by rakesh  palotra on 21/06/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import "ReactionsTableViewCell.h"

@implementation ReactionsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateRecentEmojis {
    if ((self.emojiCategories != nil) || (self.emojiCategories != [NSNull null]) || [self.emojiCategories count] > 0) {
        
        [self.btnLike setImage:nil forState:UIControlStateNormal];
        [self.btnLike setTitle:[NSString stringWithFormat:@"%@", [self.emojiCategories objectAtIndex:0]] forState:UIControlStateNormal];
        
        if ([self.emojiCategories count] > 1) {
            [self.btnDisLike setImage:nil forState:UIControlStateNormal];
            [self.btnDisLike setTitle:[NSString stringWithFormat:@"%@", [self.emojiCategories objectAtIndex:1]] forState:UIControlStateNormal];
        }
        
        if ([self.emojiCategories count] > 2) {
            [self.btnLaughLike setImage:nil forState:UIControlStateNormal];
            [self.btnLaughLike setTitle:[NSString stringWithFormat:@"%@", [self.emojiCategories objectAtIndex:2]] forState:UIControlStateNormal];
        }
        
        if ([self.emojiCategories count] > 3) {
            [self.btnRofl setImage:nil forState:UIControlStateNormal];
            [self.btnRofl setTitle:[NSString stringWithFormat:@"%@", [self.emojiCategories objectAtIndex:3]] forState:UIControlStateNormal];
        }
        
        if ([self.emojiCategories count] > 4) {
            [self.btnHeart setImage:nil forState:UIControlStateNormal];
            [self.btnHeart setTitle:[NSString stringWithFormat:@"%@", [self.emojiCategories objectAtIndex:4]] forState:UIControlStateNormal];
        }
    }
}

@end
