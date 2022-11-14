//
//  ParticipantTableViewCell.m
//  eRTCApp
//
//  Created by Ashish Vani on 28/06/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import "ParticipantTableViewCell.h"

@implementation ParticipantTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupViewCellSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
#pragma mark SetupView

-(void) setupViewCellSubviews {
    self.imgProfile.layer.cornerRadius = self.imgProfile.bounds.size.height/2;
    self.lblName.textColor = [UIColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.0];
    self.lblName.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:14];
}
@end
