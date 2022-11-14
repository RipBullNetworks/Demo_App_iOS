//
//  ImageVideoCell.m
//  eRTCApp
//
//  Created by apple on 15/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "ImageVideoCell.h"

@implementation ImageVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imgUser.layer.cornerRadius = 8;
    self.imgUser.clipsToBounds = true;
   
}

@end
