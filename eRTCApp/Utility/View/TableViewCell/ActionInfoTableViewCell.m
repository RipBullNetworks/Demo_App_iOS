//
//  ActionInfoTableViewCell.m
//  eRTCApp
//
//  Created by Ashish Vani on 04/07/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import "ActionInfoTableViewCell.h"

@implementation ActionInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupViewCellSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark SetupView
-(void) setupViewCellSubviews {
    self.lblTitle.textColor =  [UIColor colorWithRed:.44 green:.53 blue:.61 alpha:1.0];
    self.lblTitle.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:15];
    self.lblSubTitle.textColor = [UIColor  colorWithRed:0.0 green:0.0 blue:0.0 alpha: 0.38];
    self.lblSubTitle.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:14];
}


- (IBAction)btnSwitchNotification:(UISwitch *)sender {
    if (sender.isOn) {
        
    }else{
        
    }
}

@end
