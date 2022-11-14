//
//  GroupSearchViewController.m
//  eRTCApp
//
//  Created by Ashish Vani on 28/06/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import "GroupSearchViewController.h"
#import "ParticipantTableViewCell.h"
#import "tblSearchListCell.h"

@interface GroupSearchViewController ()

@end

@implementation GroupSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
}


#pragma mark setupView
-(void) setupTableView {
    [self.tableView setEstimatedRowHeight:56];
    [self.tableView setRowHeight:UITableViewAutomaticDimension];
    [self.tableView registerNib:[UINib nibWithNibName:@"ParticipantTableViewCell" bundle:nil] forCellReuseIdentifier:@"ParticipantTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"tblSearchListCell" bundle:nil] forCellReuseIdentifier:@"tblSearchListCell"];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
    noDataLabel.textColor        = [UIColor blueColor];
    noDataLabel.textAlignment    = NSTextAlignmentCenter;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (self.arySearchResults.count > 0) {
        noDataLabel.text             = @"";
        self.tableView.backgroundView = noDataLabel;
        return self.arySearchResults.count;
    }else{
        noDataLabel.text             = @"No User Found";
        self.tableView.backgroundView = noDataLabel;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ParticipantTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ParticipantTableViewCell"];
    //tblSearchListCell *cell = [tableView dequeueReusableCellWithIdentifier:TblSearchListCell];
    
    [cell.btnSelected setHidden:YES];
    if (self.arySearchResults.count>indexPath.row) {
        NSDictionary * dict = [self.arySearchResults objectAtIndex:indexPath.row];
        if (dict[User_Name] != nil && dict[Key_Name] != [NSNull null]) {
            cell.lblName.text = dict[Key_Name];
        }
        if (dict[User_ProfilePic_Thumb] != nil && dict[User_ProfilePic_Thumb] != [NSNull null]) {
            NSString *imageURL = [NSString stringWithFormat:@"%@",dict[User_ProfilePic_Thumb]];
            [cell.imgProfile sd_setImageWithURL:[NSURL URLWithString:imageURL]
            placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
                cell.imgProfile.layer.cornerRadius= cell.imgProfile.frame.size.height/2;
                cell.imgProfile.layer.masksToBounds = YES;
        } else{
            cell.imgProfile.image =  [UIImage imageNamed:@"DefaultUserIcon"];
        }
        
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.gsDelegate respondsToSelector:@selector(didSelectedItem:)]) {
        if (self.arySearchResults.count > indexPath.row) {
            NSDictionary *item = [self.arySearchResults objectAtIndex:indexPath.row];
            [self.gsDelegate didSelectedItem:item];            
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
