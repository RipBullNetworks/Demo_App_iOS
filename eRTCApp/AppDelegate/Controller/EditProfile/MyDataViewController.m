//
//  MyDataViewController.m
//  eRTCApp
//
//  Created by apple on 14/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "MyDataViewController.h"
#import "manageNotificationCell.h"

@interface MyDataViewController ()<UITableViewDelegate, UITableViewDataSource> {
    UIBarButtonItem *ApplyBarButtonItem;
    NSInteger                                       _isIndexPath;
    NSInteger                                       _isSection;
}

@end

@implementation MyDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ApplyBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(applybtnAction:)];
    self.navigationItem.rightBarButtonItem=ApplyBarButtonItem;
    self.navigationItem.title = @"My Data";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"";
}

#pragma mark Table Delegate and DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}



-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 35;
    }else if (section == 1) {
        return 35;
    }
    return 0;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 3;
    }else if (section == 1) {
        return 3;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        if (indexPath.section == 0) {
    manageNotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"manageNotificationCell"];
            if (indexPath.row == 0) {
                cell.lblTitle.text = @"Messages";
            }else if (indexPath.row == 1) {
                cell.lblTitle.text = @"Images";
            }else if (indexPath.row == 2) {
                cell.lblTitle.text = @"Images";
            }
            
            if (_isIndexPath == indexPath.row) {
                [cell.imgCircle setImage:[UIImage imageNamed:@"radiocheck"]];
            }else{
                [cell.imgCircle setImage:[UIImage imageNamed:@"radioUncheck"]];
            }
            
        return  cell;
        }else if (indexPath.section == 1) {//
    manageNotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"manageNotificationCell"];
            if (indexPath.row == 0) {
                cell.lblTitle.text = @"1 Month";
            }else if (indexPath.row == 1) {
                cell.lblTitle.text = @"3 Month";
            }else if (indexPath.row == 2) {
                cell.lblTitle.text = @"6 Month";
            }
        return  cell;
        }
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _isIndexPath = indexPath.row;
    _isSection = indexPath.section;
    [self.tblMydata reloadData];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tblMydata.bounds.size.width, 40)];
  UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 7, _tblMydata.bounds.size.width-32, 20)];
  [headerView setBackgroundColor:[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0]];
  [headerTitle setTextColor:[UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0]];
  [headerTitle setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:14.0]];
    if (section == 0) {//What data you want to extract
        [headerTitle setText:@"What data you want to extract"];
    }else{//Extract data every
        [headerTitle setText:@"Extract data every"];
    }
     [headerView addSubview:headerTitle];
  return headerView;
}

-(IBAction)applybtnAction:(id)sender{
    
}




@end
