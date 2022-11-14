//
//  InfoGruopTableViewCell.m
//  eRTCApp
//
//  Created by Ashish Vani on 04/07/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import "BasicInfoTableViewCell.h"

@implementation BasicInfoTableViewCell

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
    self.lblTitle.textColor = [UIColor colorWithRed:.44 green:.53 blue:.61 alpha:1.0];
    self.lblTitle.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:14];
    self.lblSubTitle.textColor = [UIColor  colorWithRed:0.13 green:0.13 blue:0.13 alpha: 1.0];
    self.lblSubTitle.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:16];
}
@end
