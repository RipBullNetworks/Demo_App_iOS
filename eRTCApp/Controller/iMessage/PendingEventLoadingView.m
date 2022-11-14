//
//  PendingEventLoadingView.m
//  eRTCApp
//
//  Created by rakesh  palotra on 17/11/20.
//  Copyright © 2018 Ripbull Network. All rights reserved.
//

#import "PendingEventLoadingView.h"

@implementation PendingEventLoadingView

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"initWithFrame");
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    NSLog(@"initWithCoder");
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [[NSBundle mainBundle] loadNibNamed:@"PendingEventLoadingView" owner:self options:nil];
    [self addSubview:self.view];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Our PendingEventLoadingView is a UIView that contains a UIView, we need to establish
    //  the relation with autolayout. We'll want the self.view to be 200x100 pixels
    //  and we'll have the superview (PendingEventLoadingView) stick to the edges (i.e. same size).
    
    // width and edges   H:|[self.view(200)]|
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_view(140)]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_view, self)]];
    
    // height and edges   V:|[self.view(100)]|
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_view(50)]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_view, self)]];
}


@end
