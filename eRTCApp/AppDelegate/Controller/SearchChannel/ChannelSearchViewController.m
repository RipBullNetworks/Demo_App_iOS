//
//  ChannelSearchViewController.m
//  eRTCApp
//
//  Created by apple on 18/05/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "ChannelSearchViewController.h"
#import "tblSearchListCell.h"
#import <Toast/Toast.h>
#import "SingleChatViewController.h"
#import "GroupChatViewController.h"
#import "InfoGroupViewController.h"

@interface ChannelSearchViewController ()<MyChanneldelegate> {
    NSString                                  *_selectAdminType;
}

@end

@implementation ChannelSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
}

-(void)selectedJoinButton:(UITableViewCell *)cell andselectType:(NSString *)type {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSDictionary *dictInfo = _arrChannelSearch[indexPath.row];
    self.dictGroupInfo = [[NSMutableDictionary alloc]init];
    self.dictGroupInfo = _arrChannelSearch[indexPath.row];
    if ([type isEqualToString:@"Join"]) {
        [self callAPIForAddPraticipantsInGroup:dictInfo[Group_GroupId]];
    }else if ([type isEqualToString:@"Private"]) {
        
    }else{
        [self JoinChannel:dictInfo];
    }
}

#pragma mark setupView
-(void) setupTableView {
    [self.tableView setEstimatedRowHeight:56];
    [self.tableView setRowHeight:UITableViewAutomaticDimension];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"tblSearchListCell" bundle:nil] forCellReuseIdentifier:@"tblSearchListCell"];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
    noDataLabel.textColor        = [UIColor blueColor];
    noDataLabel.textAlignment    = NSTextAlignmentCenter;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (self.arrChannelSearch.count > 0) {
        noDataLabel.text             = @"";
        self.tableView.backgroundView = noDataLabel;
        return self.arrChannelSearch.count;
    }else{
        noDataLabel.text             = @"Channel not found";
        self.tableView.backgroundView = noDataLabel;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tblSearchListCell *cell = [tableView dequeueReusableCellWithIdentifier:TblSearchListCell];
    NSDictionary*dictData = self.arrChannelSearch[indexPath.row];
    cell.lblChannelName.text = dictData[Group_Name];
    cell.lblSubTitle.text = @"";
    BOOL isJoined = [dictData[Joined_Channel] boolValue];
    if ([dictData[Group_Type] isEqualToString:Public]) {
        UIImage *btnImage = [UIImage imageNamed:@"moreChannel"];
        cell.imgGroupIcon.hidden = true;
        if (isJoined) {
        [cell.btnJoin setImage:btnImage forState:UIControlStateNormal];
        [cell.btnJoin setTitle:@"" forState:UIControlStateNormal];
        }else{
            [cell.btnJoin setTitle:@"Join" forState:UIControlStateNormal];
            [cell.btnJoin setImage:nil forState:UIControlStateNormal];
            [cell.btnJoin setTitleColor:[self colorWithHexString:@"0075FF"] forState:UIControlStateNormal];
        }
    }else{
        cell.imgGroupIcon.hidden = false;
        [cell.btnJoin setImage:nil forState:UIControlStateNormal];
        [cell.btnJoin setTitle:@"Private" forState:UIControlStateNormal];
        [cell.btnJoin setTitleColor:[self colorWithHexString:@"71869C"] forState:UIControlStateNormal];
    }
    cell.btnJoin.tag = indexPath.row;
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary * dict = [_arrChannelSearch objectAtIndex:indexPath.row];
    if (_arrChannelSearch.count > indexPath.row) {
        BOOL isJoined = [dict[Joined_Channel] boolValue];
        if ([dict[Group_Type] isEqualToString:Public]) {
            if (isJoined) {
            [[NSNotificationCenter defaultCenter] postNotificationName:DidUpdateChannelStatus object:dict userInfo:nil];
            }else{
            [self.view makeToast:Join_Channel];
            }
        }
        
       
    }
}


-(void)JoinChannel:(NSDictionary*)dictInfo {
    UIAlertController *activitySheet = [UIAlertController alertControllerWithTitle:nil
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *muteChannel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Mute channel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *invitePeople = [UIAlertAction actionWithTitle:NSLocalizedString(@"Invite people", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *clearChat = [UIAlertAction actionWithTitle:NSLocalizedString(@"Clear chat history", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [Helper showAlert:Clear_Chat_History message:msgClearChatHistory btnYes:@"Clear" btnNo:@"Cancel" inViewController:self completedWithBtnStr:^(NSString* btnString) {
            if ([btnString isEqualToString:@"Clear"]) {
                [self clearChatHistory];
            }
        }];
    }];
    [activitySheet addAction:muteChannel];
    [activitySheet addAction:invitePeople];
    [activitySheet addAction:clearChat];
    UIAlertAction *leaveChannel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Leave Channel", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DidUpdateChannelStatus object:dictInfo userInfo:LeaveChannel];
    }];
    [activitySheet addAction:leaveChannel];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [activitySheet addAction:cancel];
    [self presentViewController:activitySheet animated:YES completion:nil];
}

-(void)clearChatHistory {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
        NSString *threadId = self.dictGroupInfo[ThreadID];
        
        [[eRTCChatManager sharedChatInstance] clearChatHistoryBy:threadId andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        [KVNProgress dismiss];
        [self.view makeToast:ChatMsgClearSuccess];
        [self.navigationController popToRootViewControllerAnimated:NO];
        }andFailure:^(NSError * _Nonnull error) {
            
        }];
    } else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}


#pragma mark API Call
-(void) callAPIForAddPraticipantsInGroup:(NSString *)groupId {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
        NSMutableDictionary*dictParam = [[NSMutableDictionary alloc]init];
        NSString *appUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
        NSMutableArray *aryUser = [[NSMutableArray alloc]init];
        [aryUser addObject:appUserId];
        [dictParam setValue:groupId forKey:Group_GroupId];
        
        [dictParam setValue:aryUser forKey:Group_Participants];
        
        [[eRTCChatManager sharedChatInstance] groupAddParticipants:dictParam andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            [KVNProgress dismiss];
            NSDictionary *dictResponse = (NSDictionary *)json;
            if (dictResponse[@"success"] != nil) {
                BOOL success = (BOOL)dictResponse[@"success"];
                if (success) {
                    if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *result = (NSDictionary *)dictResponse[@"result"];
                        if ([result count]>0){
                        [[NSNotificationCenter defaultCenter] postNotificationName:DidUpdateChannelStatus object:nil userInfo:nil];
                        }
                    }
                }
            }
            if (dictResponse[@"msg"] != nil) {
                NSString *message = (NSString *)dictResponse[@"msg"];
                if ([message length]>0) {
                    [Helper showAlertOnController:@"eRTC" withMessage:message onController:self];
                }
            }
        } andFailure:^(NSError * _Nonnull error) {
            [KVNProgress dismiss];
            [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
        }];
    } else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];

    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];

    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];

    if ([cString length] != 6) return  [UIColor grayColor];

    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];

    range.location = 2;
    NSString *gString = [cString substringWithRange:range];

    range.location = 4;
    NSString *bString = [cString substringWithRange:range];

    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}





@end

