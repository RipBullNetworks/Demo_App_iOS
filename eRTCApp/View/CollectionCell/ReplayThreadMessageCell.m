//
//  ReplayThreadMessageCell.m
//  eRTCApp
//
//  Created by Apple on 17/01/22.
//  Copyright © 2022 Ripbull Network. All rights reserved.
//

#import "ReplayThreadMessageCell.h"

@implementation ReplayThreadMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (IBAction)btnMore:(UIButton *)sender {
    [self.delegate selectedThreadMoreIndex:self];
}

@end
