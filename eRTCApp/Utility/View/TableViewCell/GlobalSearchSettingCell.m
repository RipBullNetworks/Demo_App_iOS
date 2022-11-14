//
//  GlobalSearchSettingCell.m
//  eRTCApp
//
//  Created by Apple on 21/12/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "GlobalSearchSettingCell.h"

@implementation GlobalSearchSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)btnSwitch:(id)sender {
    if (_btnSwitch.on) {
        [self.delegate globalSearchSwitch:true];
    }else{
        [self.delegate globalSearchSwitch:false];
    }
    
}




@end
