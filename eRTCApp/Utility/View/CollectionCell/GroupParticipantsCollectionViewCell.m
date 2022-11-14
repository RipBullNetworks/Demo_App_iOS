//
//  GroupParticipantsCollectionViewCell.m
//  eRTCApp
//
//  Created by Ashish Vani on 27/06/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import "GroupParticipantsCollectionViewCell.h"

@implementation GroupParticipantsCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.imgProfile.layer.cornerRadius = self.imgProfile.bounds.size.height/2;
    self.btnCross.layer.cornerRadius = self.btnCross.bounds.size.height/2;
    self.lblName.textColor = [UIColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.0];
    self.lblName.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:14];
    
    // Initialization code
}

@end
