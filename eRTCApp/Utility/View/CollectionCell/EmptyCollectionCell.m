//
//  EmptyCollectionCell.m
//  eRTCApp
//
//  Created by apple on 03/08/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "EmptyCollectionCell.h"

@implementation EmptyCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _containerView.layer.borderWidth = 1;
    _containerView.layer.borderColor = [UIColor colorWithRed:0.86 green:0.91 blue:0.91 alpha:1.0].CGColor;
}

@end
