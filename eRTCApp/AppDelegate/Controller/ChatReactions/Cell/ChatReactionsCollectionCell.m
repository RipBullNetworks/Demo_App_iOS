//
//  ChatReactionsCollectionCell.m
//  eRTCApp
//
//  Created by rakesh  palotra on 30/06/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import "ChatReactionsCollectionCell.h"
@interface  ChatReactionsCollectionCell() <UIGestureRecognizerDelegate>
@end
@implementation ChatReactionsCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPresseAction:)];
    gestureRecognizer.minimumPressDuration = 0.5;
    gestureRecognizer.delaysTouchesBegan = YES;
    gestureRecognizer.delegate = self;
    [self addGestureRecognizer:gestureRecognizer];
}

- (void)longPresseAction:(UILongPressGestureRecognizer *)gestureRecogniser {
    if (gestureRecogniser.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Start State");
    } else if (gestureRecogniser.state == UIGestureRecognizerStateEnded) {
        NSLog(@"End State");
        if (self.delegate != nil) {
            [self.delegate showUserWhoReacted:self.labelEmoji.text selectedIndexPath:self.selectedIndexPath];
        }
    }
}

@end
