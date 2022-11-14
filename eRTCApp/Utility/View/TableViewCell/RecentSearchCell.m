//
//  RecentSearchCell.m
//  eRTCApp
//
//  Created by Apple on 25/12/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "RecentSearchCell.h"

@implementation RecentSearchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)btnRecentSearch:(UIButton *)sender {
    [self.delegate selectedIndex:self];
}

- (IBAction)btnSearchHistory:(id)sender {
    [self.delegate selectedClearRecentChat:self];
}

@end
