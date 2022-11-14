//
//  InvitationViewController.m
//  eRTCApp
//
//  Created by apple on 22/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "InvitationViewController.h"
#import "InvitationTblCellTableViewCell.h"
#import "ThreadViewController.h"

@interface InvitationViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation InvitationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Invitations";
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
    } else {
        // Fallback on earlier versions
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"";
    self.navigationItem.title = @"Invitations";
}


#pragma mark Table Delegate and DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    }else if (section == 1) {
        return 6;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        if (indexPath.section == 0) {
            InvitationTblCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InvitationTblCellTableViewCell"];
        return  cell;
       }else if (indexPath.section == 1) {
            InvitationTblCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InvitationTblCellTableViewCell"];
        return  cell;
        }
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ThreadViewController *_vcmanageNotification = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"ThreadViewController"];
    [self.navigationController pushViewController:_vcmanageNotification animated:YES];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tblList.bounds.size.width, 50)];
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 7, _tblList.bounds.size.width-32, 20)];
  //[headerView setBackgroundColor:[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0]];
  [headerTitle setTextColor:[UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0]];
  [headerTitle setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:16.0]];
    if (section == 0) {
        [headerTitle setText:@"Invitations"];
    }else{
        [headerTitle setText:@"Notifications"];
    }
     [headerView addSubview:headerTitle];
  return headerView;
}



@end
