//
//  ParticipantInfoTableViewCell.m
//  eRTCApp
//
//  Created by Ashish Vani on 06/07/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import "ParticipantInfoTableViewCell.h"

@implementation ParticipantInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupViewCellSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void) setupViewCellSubviews {
    self.imgProfile.layer.cornerRadius = self.imgProfile.bounds.size.height/2;
    self.lblName.textColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    self.lblName.font = [UIFont fontWithName:@"SFProDisplay-Medium" size:14];
    self.lblEmail.textColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    self.lblEmail.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:12];
    [self.btnRole setTitleColor:[UIColor colorWithRed:0.0 green:0.48 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [self.btnRole.titleLabel setFont:[UIFont fontWithName:@"SFProDisplay-Medium" size:13]];
    [self.btnRole.titleLabel setTextAlignment:UIListContentTextAlignmentCenter];
}

@end
