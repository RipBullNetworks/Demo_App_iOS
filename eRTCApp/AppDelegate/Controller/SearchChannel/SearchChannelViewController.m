//
//  SearchChannelViewController.m
//  eRTCApp
//
//  Created by apple on 17/05/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "SearchChannelViewController.h"
#import "SearchViewController.h"
#import "ChannelSearchViewController.h"
#import "RecentChatTableViewCell.h"
#import "GroupParticipantsCollectionViewCell.h"
#import "tblSearchListCell.h"
#import "GroupChatViewController.h"
#import "InfoGroupViewController.h"
#import "NewGroupViewController.h"
#import "NotificationSettingViewController.h"
#import <Toast/Toast.h>


@interface SearchChannelViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate, UISearchControllerDelegate, UISearchResultsUpdating, ContactsSearchDelegate,MyChanneldelegate> {
    SearchChannelViewController *_vcSearchChannel;
    NSString                                  *strTitle;
    SearchViewController * vcSearch;
    NSString                                  *_strAppLoggedInUserID;
    UISearchController *searchController;
}

@end

@implementation SearchChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_tblSearchChannels registerNib:[UINib nibWithNibName:@"tblSearchListCell" bundle:nil] forCellReuseIdentifier:@"tblSearchListCell"];
    [_tblSearchChannels reloadData];
    self.txtSerarch.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(didReceivedGroupEvent:)
                                                name:DidReceivedGroupEvent
                                              object:nil];
}

-(void) setupNavigationSearchBar {
    
    _vcSearchChannel = [[SearchChannelViewController alloc] init];
    //_vcSearchChannel.CsDelegate = self;
    UISearchController *sc = [[UISearchController alloc] initWithSearchResultsController:_vcSearchChannel];
    sc.searchResultsUpdater = self;
    sc.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController = sc;
        self.navigationItem.hidesSearchBarWhenScrolling = NO;
    }
     sc.delegate = self;
     sc.dimsBackgroundDuringPresentation = NO;
     sc.searchBar.delegate = self;
     self.definesPresentationContext = YES;
  
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
   
    [self callAPIForGetGroupList:false];
    self.navigationController.navigationBar.topItem.title = @"";
    [self configureNavigationBar];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self configureNavigationBar];
}


-(void) setupTableView {
    [self.tblSearchChannels setEstimatedRowHeight:56];
    [self.tblSearchChannels setRowHeight:UITableViewAutomaticDimension];
    self.tblSearchChannels.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tblSearchChannels registerNib:[UINib nibWithNibName:@"tblSearchListCell" bundle:nil] forCellReuseIdentifier:@"tblSearchListCell"];
}

-(void)selectedJoinButton:(UITableViewCell *)cell andselectType:(NSString *)type {
    
    NSIndexPath *indexPath = [self.tblSearchChannels indexPathForCell:cell];
    NSDictionary *dictInfo = _arrChannels[indexPath.row];
    self.dictGroupInfo = [[NSMutableDictionary alloc]init];
   
    self.dictGroupInfo = _arrChannels[indexPath.row];
    if ([type isEqualToString:@"Join"]) {
        [self callAPIForAddPraticipantsInGroup:dictInfo[Group_GroupId]];
    }else if ([type isEqualToString:@"Private"]) {
        
    }else{
        BOOL  isFrozenChannel;
        if (dictInfo[Key_Freeze] != nil && dictInfo[Key_Freeze] != [NSNull null]) {
            NSDictionary *dictFreez = dictInfo[Key_Freeze];
            isFrozenChannel = [dictFreez[Enabled] boolValue];
        }
        if (isFrozenChannel == true) {
            [self.view makeToast:Key_frozen];
        }else{
        [self JoinChannel:dictInfo];
        }
    }
}

- (void)configureNavigationBar {
    self.navigationItem.title = @"Search";
    
//    if (@available(iOS 11.0, *)) {
//        self.navigationController.navigationBar.prefersLargeTitles = YES;
//
//    } else {
//        // Fallback on earlier versions
//    }
    
}

#pragma mark - TableViewDelegate&DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tblSearchChannels.bounds.size.width, self.tblSearchChannels.bounds.size.height)];
    noDataLabel.textColor        = [UIColor blueColor];
    noDataLabel.textAlignment    = NSTextAlignmentCenter;
    self.tblSearchChannels.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (_arrChannels.count > 0) {
        noDataLabel.text             = @"";
        self.tblSearchChannels.backgroundView = noDataLabel;
        return _arrChannels.count;
    }else{
        noDataLabel.text             = @"Channel not found";
        self.tblSearchChannels.backgroundView = noDataLabel;
        return 0;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tblSearchListCell *cell = [tableView dequeueReusableCellWithIdentifier:TblSearchListCell];
    //freeze
    NSDictionary*dictData = _arrChannels[indexPath.row];
    
    if (dictData[ParticipantsCount] != nil && dictData[ParticipantsCount] != [NSNull null]) {
    NSString *memberCount = dictData[ParticipantsCount];
    cell.lblSubTitle.text = [NSString stringWithFormat:@"%@%@",memberCount,@" Members"];
    }
    
    if (dictData[Group_Name] != nil && dictData[Group_Name] != [NSNull null]) {
    cell.lblChannelName.text = dictData[Group_Name];
    }
    
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
    NSDictionary * dict = [_arrChannels objectAtIndex:indexPath.row];
    if (_arrChannels.count > indexPath.row) {
        BOOL isJoined = [dict[Joined_Channel] boolValue];
        if ([dict[Group_Type] isEqualToString:Public]) {
            if (isJoined) {
                NSDictionary *dictSearch = dict;
                if (dictSearch.count > 0) {
                    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle bundleForClass:InfoGroupViewController.class]];
                    GroupChatViewController *vcInfo = [story instantiateViewControllerWithIdentifier:NSStringFromClass(GroupChatViewController.class)];
                    vcInfo.dictGroupinfo = dictSearch;
                    [self.navigationController pushViewController:vcInfo animated:YES];
                }else{
                    [self callAPIForGetGroupList:TRUE];
                }
            }else{
            [self.view makeToast:Join_Channel];
            }
        }else if ([dict[Group_Type] isEqualToString:Private]) {
            NSDictionary *dictSearch = dict;
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle bundleForClass:InfoGroupViewController.class]];
            GroupChatViewController *vcInfo = [story instantiateViewControllerWithIdentifier:NSStringFromClass(GroupChatViewController.class)];
            vcInfo.dictGroupinfo = dictSearch;
            [self.navigationController pushViewController:vcInfo animated:YES];
        }
    }
}



#pragma mark - SearchBar Delegates
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
   // NSString *searchString = searchController.searchBar.text;
    strTitle = searchController.searchBar.text;
    [self searchForText:strTitle];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    strTitle = searchBar.text;
    //NSString *searchString = searchBar.text;
    [self searchForText:strTitle];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    strTitle = searchText;
    [self searchForText:strTitle];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:true];
    strTitle = @"";
    [self searchForText:@""];
}

#pragma mark Private
- (void)searchForText:(NSString*)searchString {
    if (self.arrSearchChannels.count > 0 && [searchString length] > 0) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@",searchString];
        NSArray * _arrFiltered = [self.arrSearchChannels filteredArrayUsingPredicate:predicate];
        _arrChannels = [NSMutableArray arrayWithArray:_arrFiltered];
    } else {
        _arrChannels = [NSMutableArray arrayWithArray:self.arrSearchChannels];
    }
    [self.tblSearchChannels reloadData];
}

- (IBAction)btnCreateGroup:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *nvcNewGroup = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"NewGroupNavigationViewController"];
    [nvcNewGroup setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:nvcNewGroup animated:YES completion:nil];
}

- (void)callAPIForGetGroupList:(BOOL)isJoined  {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        NSMutableDictionary*dict = [[NSMutableDictionary alloc]init];
        //[KVNProgress show];
        if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_ID] != nil) {
            [[eRTCChatManager sharedChatInstance] getAllGroups:dict andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                
                [KVNProgress dismiss];
                NSDictionary *dictResponse = (NSDictionary *)json;
                if (dictResponse[@"success"] != nil) {
                    BOOL success = (BOOL)dictResponse[@"success"];
                    if (success) {
                        if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *result = (NSDictionary *)dictResponse[@"result"];
                            NSArray *groups = (NSArray *)result[@"groups"];
                            self.arrSearchChannels = result[@"groups"];
                            [self searchForText:self->strTitle];
                            return;
                        }
                    }
                }
                if (dictResponse[@"msg"] != nil) {
                    NSString *message = (NSString *)dictResponse[@"msg"];
                    if ([message length]>0) {
                        if (isJoined) {
                            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle bundleForClass:InfoGroupViewController.class]];
                            GroupChatViewController *vcInfo = [story instantiateViewControllerWithIdentifier:NSStringFromClass(GroupChatViewController.class)];
                            [self.navigationController pushViewController:vcInfo animated:YES];
                        }
                        [Helper showAlertOnController:@"eRTC" withMessage:message onController:self];
                    }
                }
            }andFailure:^(NSError * _Nonnull error) {
               // [KVNProgress dismiss];
                NSLog(@"GroupListViewController ->  callAPIForGetGroupList -> %@",error);
                [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
            }];
        }
    }else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}

-(void)callApiGetGroupByGroupId:(NSDictionary *)dictGroup {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        NSMutableDictionary*dict = [[NSMutableDictionary alloc]init];
        [KVNProgress show];
        if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_ID] != nil) {
            [dict setValue:dictGroup[Group_GroupId] forKey:Group_GroupId];
            [[eRTCChatManager sharedChatInstance] getGroupByGroupId:dict andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                [KVNProgress dismiss];
                NSDictionary *dictResponse = (NSDictionary *)json;
                if (dictResponse[@"success"] != nil) {
                    BOOL success = (BOOL)dictResponse[@"success"];
                    if (success) {
                        if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *result = (NSDictionary *)dictResponse[@"result"];
                            if (result.count > 0) {
                                UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle bundleForClass:InfoGroupViewController.class]];
                                InfoGroupViewController *vcInfo = [story instantiateViewControllerWithIdentifier:NSStringFromClass(InfoGroupViewController.class)];
                                vcInfo.dictGroupInfo = [NSMutableDictionary dictionaryWithDictionary:result];
                                [self.navigationController pushViewController:vcInfo animated:YES];
                            }else{
                                // [self removeChannel:true];
                                // isRemovedChannel = true;
                            }
                            return;
                        }
                    }
                }
                if (dictResponse[@"msg"] != nil) {
                    NSString *message = (NSString *)dictResponse[@"msg"];
                    if ([message length]>0) {
                        [Helper showAlertOnController:@"eRTC" withMessage:message onController:self];
                    }
                }
            }andFailure:^(NSError * _Nonnull error) {
                [KVNProgress dismiss];
                NSLog(@"GroupListViewController ->  callAPIForGetGroupByGroupID -> %@",error);
                [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
            }];
        }
    }else {
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
                            [self callAPIForGetGroupList:TRUE];
                        }
                    }
                }
            }
            if (dictResponse[@"msg"] != nil) {
                NSString *message = (NSString *)dictResponse[@"msg"];
                if ([message length]>0) {
                    [self.view makeToast:message];
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

-(void)JoinChannel:(NSDictionary*)dictInfo {
    
    UIAlertController *activitySheet = [UIAlertController alertControllerWithTitle:nil
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *muteChannel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Manage Notifications", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if  (![Helper stringIsNilOrEmpty:dictInfo[ThreadID]]) {
            //self.strGroupThreadID = dictInfo[ThreadID];
            if ([dictInfo isKindOfClass:[NSDictionary class]]){
                       NotificationSettingViewController *_vcProfile = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"NotificationSettingViewController"];
                       _vcProfile.isFromGroup = YES;
                    _vcProfile.strGroupThreadID = dictInfo[ThreadID];
                       [self.navigationController pushViewController:_vcProfile animated:YES];
            }
        }
    }];
    UIAlertAction *invitePeople = [UIAlertAction actionWithTitle:NSLocalizedString(@"Invite people", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self callApiGetGroupByGroupId:dictInfo];
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
        [self callAPIForRemoveParticipant:dictInfo andExitGroup:true];
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

-(void)callAPIForRemoveParticipant:(NSDictionary *) dictParticipants  andExitGroup:(BOOL) isExitGroup {
    
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
        NSMutableDictionary*dict = [[NSMutableDictionary alloc]init];
        if (dictParticipants[User_eRTCUserId] != nil && dictParticipants[App_User_ID] != nil) {
            //[dict setValue:@[dictParticipants[App_User_ID]] forKey:Group_Participants];
        }
        if(self.dictGroupInfo[Group_GroupId] != nil) {
            [dict setValue:dictParticipants[Group_GroupId] forKey:Group_GroupId];
        }
        _strAppLoggedInUserID = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
        if(isExitGroup == YES) {
            
            [dict setValue:@[_strAppLoggedInUserID] forKey:Group_Participants];
         //   [dict setValue:[[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] forKey:User_eRTCUserId];
        }
        
        [[eRTCChatManager sharedChatInstance] groupRemoveParticipants:dict andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            [KVNProgress dismiss];
            NSDictionary *dictResponse = (NSDictionary *)json;
            if (dictResponse[@"success"] != nil) {
                BOOL success = (BOOL)dictResponse[@"success"];
                if (success) {
                    if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *result = (NSDictionary *)dictResponse[@"result"];
                        if (dictResponse[@"msg"] != nil) {
                            NSString *message = (NSString *)dictResponse[@"msg"];
                            if ([message length]>0) {
                                [self.view makeToast:message];
                            }
                        }
                        if (result.count>0) {
                            [self callAPIForGetGroupList:TRUE];
                        }
                        return;
                    }
                }
            }
            
            if (dictResponse[@"msg"] != nil) {
                NSString *message = (NSString *)dictResponse[@"msg"];
                if ([message length]>0) {
                    [self.view makeToast:message];
                }
            }
        }andFailure:^(NSError * _Nonnull error) {
            [KVNProgress dismiss];
          //  NSLog(@"InfoGroupViewController ->  callAPIForRemoveParticipant -> groupRemoveParticipants -> %@",errMsg);
            [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
        }];
    }else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}


-(void)updateThreadNotificationStatus:(NSString*)strNotificationType{
    if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil) {
        if (self.strGroupThreadID != nil) {
            [[eRTCChatManager sharedChatInstance] updateNotificationSettings:strNotificationType withThreadId:self.strGroupThreadID andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
               // [self->tblNotification reloadData];
            } andFailure:^(NSError * _Nonnull error) {
                NSLog(@"error--> %@",error);
                NSString *errMsg = [NSString stringWithFormat:@"%@", error.localizedDescription];
                [Helper showAlertOnController:@"eRTC" withMessage:errMsg onController:self];
            }];
        }
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

-(void)didReceivedGroupEvent:(NSNotification *)notification {
    NSLog (@"Search Channel didReceivedGroupEvent %@",[notification userInfo]);
    NSDictionary *data = [notification userInfo];
    
    if (data && data[@"eventList"] && [data[@"eventList"] isKindOfClass:NSArray.class]){
        NSDictionary *eventObj =  [(NSArray*)data[@"eventList"] firstObject];
        if (eventObj[@"eventType"] != nil && eventObj[@"eventType"] != [NSNull null]) {
         if ([eventObj[@"eventType"] isEqualToString:@"deactivated"]) {
                [self callAPIForGetGroupList:false];
            }else if ([eventObj[@"eventType"] isEqualToString:@"activated"]) {
                [self callAPIForGetGroupList:false];
            }
            
        }
    }
}

@end
