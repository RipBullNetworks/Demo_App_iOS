//
//  ReplyThreadFooterCell.m
//  eRTCApp
//
//  Created by Apple on 17/01/22.
//  Copyright © 2022 Ripbull Network. All rights reserved.
//

#import "ReplyThreadFooterCell.h"

@implementation ReplyThreadFooterCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _btnReply.layer.borderWidth = 1;
    _btnReply.layer.borderColor = [UIColor colorWithRed:0.86 green:0.91 blue:0.91 alpha:1.0].CGColor;
}

- (IBAction)btnReplyThread:(UIButton *)sender {
    [self.delegate selectedReplyThreadIndex:self];
}




@end
