//
//  GroupMemberViewController.m
//  eRTCApp
//
//  Created by apple on 19/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "GroupMemberViewController.h"
#import "AddGroupMemberCell.h"
#import "NewGroupViewController.h"
#import <Toast/Toast.h>
#import "AddParticipantsTableViewCell.h"
#import "SingleChatViewController.h"
#import "ProfileViewController.h"

@interface GroupMemberViewController ()<UITableViewDelegate,UITableViewDataSource> {
    NSString                                  *_strAppLoggedInUserID;
    NSInteger                                  _indexOfLoggedUser;
    BOOL                                       _isLoggedUserAdmin;
}

@end

@implementation GroupMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Group Members";
    [_tblGroupMember registerNib:[UINib nibWithNibName:@"AddParticipantsTableViewCell" bundle:nil] forCellReuseIdentifier:@"AddParticipantsTableViewCell"];
    [self reloadTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"";
    self.navigationItem.title = @"Group Members";
    _strAppLoggedInUserID = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
}

- (void)reloadTableView {
    if ([self.dictGroupInfo[@"participants"] isKindOfClass:[NSArray class]]) {
        self.aryParticipants = self.dictGroupInfo[@"participants"];
    }
    //_isLoggedUserAdmin = [self isLoggedUserAdmin];
    [_tblGroupMember reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *groupType = _dictGroupInfo[Group_Type];
     if ([groupType isEqualToString:Private]) {
     if (section == 0 && _isLogged == true){
        return 1;
    }else if (section == 0 && _isLogged == false) {
        return 0;
    }else if (section ==  1){
        return self.aryParticipants.count;
    }
 }else if ([groupType isEqualToString:Public]) {
     if (section == 0) {
         return 1;
     }else if (section == 1){
         return self.aryParticipants.count;
     }
 }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        AddParticipantsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddParticipantsTableViewCell"];
        [cell.lblTitle setText:NSLocalizedString(@"Add Participants", nil)];
        return cell;
    }else{
        AddGroupMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddGroupMemberCell"];
        NSDictionary * dict = [self.aryParticipants objectAtIndex:indexPath.row];
        NSString *role;
        if (dict[@"role"] != nil && dict[@"role"] != [NSNull null] && [dict[@"role"] isKindOfClass:[NSString class]]) {
            role = [NSString stringWithFormat:@"%@", dict[@"role"]];
            if ([role.lowercaseString isEqualToString:@"admin"]) {
                [cell.imgAdmin setHidden:false];
            }else{
                [cell.imgAdmin setHidden:true];
            }
            if (dict[App_User_ID] != nil && dict[User_eRTCUserId] != [NSNull null]) {
                NSString *appUserID = [NSString stringWithFormat:@"%@", dict[App_User_ID]];
                cell.lblSubTitle.text = dict[App_User_ID];
                if ([appUserID isEqualToString:_strAppLoggedInUserID]){
                    cell.lblTitle.text = NSLocalizedString(@"You", nil);
                }else {
                    cell.lblTitle.text = dict[User_Name];
                }
            }
            if (dict[User_ProfilePic_Thumb] != nil && dict[User_ProfilePic_Thumb] != [NSNull null]) {
                NSString *imageURL = [NSString stringWithFormat:@"%@",dict[User_ProfilePic_Thumb]];
                [cell.imgProfile sd_setImageWithURL:[NSURL URLWithString:imageURL]
                placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
                cell.imgProfile.layer.cornerRadius= cell.imgProfile.frame.size.height/2;
                cell.imgProfile.layer.masksToBounds = YES;
                cell.imgProfile.layer.cornerRadius= cell.imgProfile.frame.size.height/2;
                cell.imgProfile.layer.masksToBounds = YES;
            }else{
                cell.imgProfile.image =  [UIImage imageNamed:@"DefaultUserIcon"];
            }
        return cell;
        }
    }
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && indexPath.section == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        NewGroupViewController *vcNG = (NewGroupViewController *)[storyboard instantiateViewControllerWithIdentifier:@"NewGroupViewController"];
        [vcNG setIsAddParticipants:YES];
        [vcNG setDictGroupInfo:self.dictGroupInfo];
        NSMutableArray *ary = [self.aryParticipants mutableCopy];
        if (_indexOfLoggedUser>-1 && _indexOfLoggedUser<ary.count) {
            [ary removeObjectAtIndex:_indexOfLoggedUser];
            [vcNG setArySelectedParticipants:ary];
        }
        [vcNG setCompletion:^(BOOL isEdit, NSMutableDictionary * _Nullable dictInfo) {
            if (isEdit) {
                self.dictGroupInfo = dictInfo;
                [self reloadInputViews];
                [self reloadTableView];
                [self.navigationController popViewControllerAnimated:true];
            }
        }];
        vcNG.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self.navigationController pushViewController:vcNG animated:true];
    }else{
       // [self setBlockUserAccount];
        
        NSDictionary * dict = [self.aryParticipants objectAtIndex:indexPath.row];
        NSString *appUserID = [NSString stringWithFormat:@"%@", dict[App_User_ID]];
        if (![appUserID isEqualToString:_strAppLoggedInUserID]){
            [self actionSheetForParticipantsWithIndexPath:indexPath];
        }
    }
}

- (void) actionSendMessage:(NSDictionary *) participant {
//    GroupChatViewController *_vcMessage = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"GroupChatViewController"];
//    _vcMessage.dictGroupinfo = participant;
//    [self.navigationController pushViewController:_vcMessage animated:YES];
    
    SingleChatViewController * _vcMessage = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"SingleChatViewController"];
    NSString *appUserId = participant[App_User_ID];
    if (appUserId){
        [[eRTCAppUsers sharedInstance] fetchUserDetailByAppUserId:appUserId andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
           // _vcMessage.isSingleChat = true;
            _vcMessage.dictUserDetails = json;
            _vcMessage.strThreadId = self.dictGroupInfo[ThreadID];
            [self.navigationController pushViewController:_vcMessage animated:YES];
        } andFailure:^(NSError * _Nonnull error) {
            [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
        }];
    }
}

- (void) actionViewProfile:(NSDictionary *) participant {
    ProfileViewController * _vcProfile = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    NSString *appUserId = participant[App_User_ID];
    if (appUserId){
        [[eRTCAppUsers sharedInstance] fetchUserDetailByAppUserId:appUserId andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            _vcProfile.isSingleChat = true;
            _vcProfile.dictUserDetails = json;
            _vcProfile.strThreadId = self.dictGroupInfo[ThreadID];
            _vcProfile.strGroupThread = self.dictGroupInfo[ThreadID];
            [self.navigationController pushViewController:_vcProfile animated:YES];
        } andFailure:^(NSError * _Nonnull error) {
            [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
        }];
    }
}

- (void) actionMakeAsAdmin:(NSDictionary *) participant  makeAdmin:(BOOL) isMakeAdmin{
    [self callAPIForParticipant:participant makeAdmin:isMakeAdmin];
}

- (void) actionRemoveFromGroup:(NSDictionary *) participant {
    [self callAPIForRemoveParticipant:participant andExitGroup:NO];
}



- (void) actionSheetForParticipantsWithIndexPath:(NSIndexPath *) indexPath {
    if (indexPath.row<self.aryParticipants.count) {
        if (_indexOfLoggedUser == indexPath.row && indexPath.section == 0) { return; }
        NSDictionary * participant = [self.aryParticipants objectAtIndex:indexPath.row];
        if (participant == nil || participant.count == 0) { return; }
        UIAlertController *activitySheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *actionSendMessage = [UIAlertAction actionWithTitle:NSLocalizedString(@"Send Message", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self actionSendMessage:participant];
        }];
        [activitySheet addAction:actionSendMessage];
        UIAlertAction *actionViewProfile = [UIAlertAction actionWithTitle:NSLocalizedString(@"View Profile", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self actionViewProfile:participant];
        }];
        [activitySheet addAction:actionViewProfile];
        NSString *strAdmin = NSLocalizedString(@"Make Channel Admin", nil);
        BOOL isParticipantAdmin = NO;
       
        if (_isLoggedUserAdmin) {
            if (participant[@"role"] != nil && participant[@"role"] != [NSNull null] && [participant[@"role"] isKindOfClass:[NSString class]]) {
                NSString *role = [NSString stringWithFormat:@"%@", participant[@"role"]];
                if ( [role.lowercaseString isEqualToString:@"admin"] ) {
                    strAdmin = NSLocalizedString(@"Remove Admin", nil);
                    isParticipantAdmin = YES;
                }else {
                    isParticipantAdmin = NO;
                }
                UIAlertAction *actionAdmin = [UIAlertAction actionWithTitle:strAdmin style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self actionMakeAsAdmin:participant makeAdmin:!isParticipantAdmin];
                }];
                [activitySheet addAction:actionAdmin];
                UIAlertAction *actionRemoveFromGroup = [UIAlertAction actionWithTitle:NSLocalizedString(@"Remove From Channel", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    [self actionRemoveFromGroup:participant];
                }];
                [activitySheet addAction:actionRemoveFromGroup];
            }
        }
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
        [activitySheet addAction:cancel];
        [self presentViewController:activitySheet animated:YES completion:nil];
    }
}


-(void)setBlockUserAccount {
    UIAlertController *activitySheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(nil, nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *blockUser = [UIAlertAction actionWithTitle:NSLocalizedString(@"Block User", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setAlertController];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [activitySheet addAction:blockUser];
    [activitySheet addAction:cancel];
    [self presentViewController:activitySheet animated:YES completion:nil];
}

-(void)setAlertController {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Block John Doe?"
    message:@"This user will not be able to contact you until you have un-blocked them"
    preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
    handler:^(UIAlertAction * action) {
                                   
    }];
   UIAlertAction* noButton = [UIAlertAction actionWithTitle:@"Block" style:UIAlertActionStyleDestructive
   handler:^(UIAlertAction * action) {
                              
    }];
   [alert addAction:yesButton];
   [alert addAction:noButton];
   [self presentViewController:alert animated:YES completion:nil];
}


-(void)callAPIForParticipant:(NSDictionary *) participant makeAdmin:(BOOL) isMakeAdmin{
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        NSMutableDictionary*dict = [[NSMutableDictionary alloc]init];
        [KVNProgress show];
        if (participant[User_eRTCUserId] != nil && participant[App_User_ID] != nil && self.dictGroupInfo[Group_GroupId] != nil) {
            [dict setValue:participant[User_eRTCUserId] forKey:User_eRTCUserId];
            [dict setValue:self.dictGroupInfo[Group_GroupId] forKey:Group_GroupId];
            [dict setValue:participant[App_User_ID] forKey:@"targetAppUserId"];
            [dict setValue:(isMakeAdmin?@"make":@"dismiss") forKey:Action];
            [[eRTCChatManager sharedChatInstance]groupmakeDismissAdmin:dict andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                [KVNProgress dismiss];
                NSDictionary *dictResponse = (NSDictionary *)json;
                if (dictResponse[@"success"] != nil) {
                    BOOL success = (BOOL)dictResponse[@"success"];
                    if (success) {
                        if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *result = (NSDictionary *)dictResponse[@"result"];
                            if (result.count>0) {
                                self.dictGroupInfo = [[NSMutableDictionary alloc] initWithDictionary:result];
                                [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:YES];
                            }
                            if(dictResponse[@"errorCode"] != NULL && [dictResponse[@"errorCode"] isEqualToString:@"GR0004"] && dictResponse[@"msg"] != nil){
                                [self.view makeToast:dictResponse[@"msg"]];
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
                [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
            }];
        }
    }else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}

-(void)callAPIForRemoveParticipant:(NSDictionary *) participant  andExitGroup:(BOOL) isExitGroup {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
        NSMutableDictionary*dict = [[NSMutableDictionary alloc]init];
        if (participant[User_eRTCUserId] != nil && participant[App_User_ID] != nil) {
            [dict setValue:@[participant[App_User_ID]] forKey:Group_Participants];
        }
        if(self.dictGroupInfo[Group_GroupId] != nil) {
            [dict setValue:self.dictGroupInfo[Group_GroupId] forKey:Group_GroupId];
        }
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
                        if (result.count>0) {
                            self.dictGroupInfo = [[NSMutableDictionary alloc] initWithDictionary:result];
                            [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:YES];
                        }
                        
                        if(isExitGroup == YES) {
                            [self.navigationController popToRootViewControllerAnimated:NO];
                            [[NSNotificationCenter defaultCenter] postNotificationName:RefreshRecentChatList object:nil userInfo:nil];
                            return;
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
          //  NSLog(@"InfoGroupViewController ->  callAPIForRemoveParticipant -> groupRemoveParticipants -> %@",errMsg);
            [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
        }];
    }else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}

@end
