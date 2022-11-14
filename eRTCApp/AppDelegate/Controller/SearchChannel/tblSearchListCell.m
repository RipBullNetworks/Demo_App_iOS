//
//  tblSearchListCell.m
//  eRTCApp
//
//  Created by apple on 17/05/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "tblSearchListCell.h"
#import "SearchViewController.h"


@implementation tblSearchListCell



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (IBAction)btnJoin:(UIButton *)sender {
    if ([_btnJoin.currentTitle isEqualToString:@"Join"]) {
        [self.delegate selectedJoinButton:self andselectType:@"Join"];
    }else if ([_btnJoin.currentTitle isEqualToString:@"Private"]) {
        [self.delegate selectedJoinButton:self andselectType:@"Private"];
    }else{
        [self.delegate selectedJoinButton:self andselectType:@""];
    }
    
}

@end
