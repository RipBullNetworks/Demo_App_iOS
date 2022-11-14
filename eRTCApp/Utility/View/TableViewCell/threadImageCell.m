//
//  threadImageCell.m
//  eRTCApp
//
//  Created by apple on 09/08/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "threadImageCell.h"

@implementation threadImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.imgProduct.layer.cornerRadius = 10;
    self.imgProduct.clipsToBounds = true;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
