//
//  DisappearingMessagesVC.m
//  eRTCApp
//
//  Created by apple on 04/06/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "DisappearingMessagesVC.h"

@interface DisappearingMessagesVC () {
    UIBarButtonItem *ApplyBarButtonItem;
}

@end

@implementation DisappearingMessagesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    ApplyBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(applybtnAction:)];
    self.navigationItem.rightBarButtonItem=ApplyBarButtonItem;
    self.navigationItem.title = @"Disappearing Messages";
    
    [ApplyBarButtonItem setEnabled:false];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"";
}

- (IBAction)switchEnableMessage:(id)sender {
    if ([_switchEnableMessage isOn]) {
        [ApplyBarButtonItem setEnabled:true];
    }else{
        [ApplyBarButtonItem setEnabled:false];
    }
}

- (IBAction)switchAllowMember:(id)sender {
}

-(IBAction)applybtnAction:(id)sender{
    
}


@end
