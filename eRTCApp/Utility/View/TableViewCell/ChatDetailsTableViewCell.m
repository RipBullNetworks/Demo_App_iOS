//
//  ChatDetailsTableViewCell.m
//  eRTCApp
//
//  Created by apple on 02/08/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "ChatDetailsTableViewCell.h"

@implementation ChatDetailsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.height/2;
    self.imgProfile.clipsToBounds = true;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
