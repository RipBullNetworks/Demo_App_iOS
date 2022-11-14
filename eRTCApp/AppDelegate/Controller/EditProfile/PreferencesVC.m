//
//  PreferencesVC.m
//  eRTCApp
//
//  Created by apple on 13/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "PreferencesVC.h"
#import "EditTblCell.h"
#import "CannedResponsesVC.h"
#import "MyDataViewController.h"
#import "DisappearingMessagesVC.h"


@interface PreferencesVC ()<UITableViewDelegate,UITableViewDataSource> {
    
}

@end

@implementation PreferencesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"Preferences";
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
        
    } else {
        // Fallback on earlier versions
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Preferences";
    self.navigationController.navigationBar.topItem.title = @"";
}

#pragma mark - UITableView Delegates and DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EditTblCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditTblCell" forIndexPath:indexPath];
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self pushToCannedVC];
    }else{
        [self pushToMyDataVC];
    }
}

- (void)pushToCannedVC {
    DisappearingMessagesVC *_vcDisappering = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"DisappearingMessagesVC"];
    [_vcDisappering setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:_vcDisappering animated:false completion:nil];
   // [self.navigationController pushViewController:_vcChangePwd animated:YES];
}

- (void)pushToMyDataVC {
    MyDataViewController *_vcChangePwd = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"MyDataViewController"];
    [self.navigationController pushViewController:_vcChangePwd animated:YES];
}



@end
