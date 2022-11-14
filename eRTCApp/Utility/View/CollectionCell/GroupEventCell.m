//
//  GroupEventCell.m
//  eRTCApp
//
//  Created by apple on 14/08/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "GroupEventCell.h"

@implementation GroupEventCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.lblTitle.layer.cornerRadius = self.lblTitle.frame.size.height/2;
}

@end
