//
//  NotificationPopUpViewController.m
//  eRTCApp
//
//  Created by Taresh Jain on 31/05/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import "NotificationPopUpViewController.h"

@interface NotificationPopUpViewController() {
    __weak IBOutlet UIView *viewInner;
    __weak IBOutlet UILabel *lblPopUpMsg;
}

@end

@implementation NotificationPopUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureViewPopup];
}

-(void)configureViewPopup{
    self->viewInner.backgroundColor = [UIColor whiteColor];
    self->viewInner.layer.borderColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0].CGColor;
    self->viewInner.layer.cornerRadius = 16;
    self->lblPopUpMsg.textColor = [UIColor colorWithRed:0.125 green:0.129 blue:0.123 alpha:1.0];
}

#pragma mark - Custom Action
- (IBAction)doTapOnBtnCancel:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)doTapOnBtnTurnOff:(id)sender {
    if ([self.delegate respondsToSelector:@selector(dismissPopUp)]){
        [self.delegate dismissPopUp];
    }
}

@end
