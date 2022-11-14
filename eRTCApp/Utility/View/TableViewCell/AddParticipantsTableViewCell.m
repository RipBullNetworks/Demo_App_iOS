//
//  AddParticipantsTableViewCell.m
//  eRTCApp
//
//  Created by Ashish Vani on 31/08/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import "AddParticipantsTableViewCell.h"

@implementation AddParticipantsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupViewCellSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void) setupViewCellSubviews {
    self.imgAdd.layer.cornerRadius = self.imgAdd.bounds.size.height/2;
    self.imgAdd.image = [UIImage imageNamed:@"DefaultGroupIcon"];
    self.lblTitle.textColor = [UIColor colorWithRed:0.0 green:0.48 blue:1.0 alpha:1.0];
    self.lblTitle.font = [UIFont fontWithName:@"SFProDisplay-Bold" size:14];
}
@end
