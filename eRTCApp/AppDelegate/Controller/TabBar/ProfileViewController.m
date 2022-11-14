//
//  ProfileViewController.m
//  eRTCApp
//
//  Created by Rakesh Palotra on 24/01/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import "BFRImageViewController.h"
#import "ProfileViewController.h"
#import "UserProfileCell.h"
#import "StarredMessageViewController.h"
#import "NotificationSettingViewController.h"
#import "channelGalleryVC.h"
#import "ImageParticipantCell.h"
#import "GalleryDetailsShareVC.h"
#import "ChatDetailsTableViewCell.h"
#import "ManageNotificationVC.h"
#import <Toast/Toast.h>





@interface ProfileViewController ()<myGalleryVideoDelegate> {
    NSString                                  *strTitle;
    UIView *bottemView;
    NSString *blockUnblockUser;
    NSString *chatThreadId;
}

@property (strong, nonatomic) NSMutableArray *arrUser;
@property (assign) BOOL status;
@property (strong, nonatomic) NSString *strBlockUnblock;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getNotificationStatus];
    [self setUserDetails];
    [self callApiforGetGalleryData];
        
    [_tblProfile registerNib:[UINib nibWithNibName:@"ImageParticipantCell" bundle:nil] forCellReuseIdentifier:@"ImageParticipantCell"];
    [_tblProfile registerNib:[UINib nibWithNibName:@"ChatDetailsTableViewCell" bundle:nil] forCellReuseIdentifier:@"ChatDetailsTableViewCell"];
    
    if (self.dictUserDetails[BlockedStatus] != nil) {
        if ([self.dictUserDetails[BlockedStatus]isEqualToString:@"blocked"]) {
            self.strBlockUnblock = @"Unblock";
            [self showUserBlock:true];
        }
        else if ([self.dictUserDetails[BlockedStatus]isEqualToString:@"unblocked"]){
            self.strBlockUnblock = @"Block";
            [self showUserBlock:false];
        }
    } else{
        self.strBlockUnblock = @"Block";
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didupdateStatus:)
                                                 name:DidUpdateUserBlockStatusNotification
                                               object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(didUpdateOtheruserPro:)
//                                                 name:DidUpdateOtherUserProfile
//                                               object:nil];
//
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateProfileAndStatus:)
                                                 name:DidupdateProfileAndStatus
                                               object:nil];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Chat Details";
    
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
        
    } else {
        // Fallback on earlier versions
    }
    
    UIImage* imgDot = [UIImage imageNamed:@"Horiz"];
    CGRect frameimg = CGRectMake(15,5, 25,25);
    UIButton *btnDoted = [[UIButton alloc] initWithFrame:frameimg];
    [btnDoted setBackgroundImage:imgDot forState:UIControlStateNormal];
    [btnDoted addTarget:self action:@selector(btnMoreOptions:)
         forControlEvents:UIControlEventTouchUpInside];
    [btnDoted setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem *btnDotMore =[[UIBarButtonItem alloc] initWithCustomView:btnDoted];
    self.navigationItem.rightBarButtonItem = btnDotMore;
}

//DidupdateProfileAndStatus

//- (void)didUpdateOtheruserPro:(NSNotification *) notification {
//    NSDictionary *dictData = notification.userInfo;
//    NSString *appUserId = _dictUserDetails[User_ID];
//    if (dictData[Key_Result] != nil && dictData[Key_Result] != [NSNull null]) {
//        NSDictionary *dictResult = dictData[Key_Result];
//        NSArray *ary = dictResult[@"chatUsers"];
//        NSArray *filteredAudio = [ary filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userId == %@",appUserId]];
//    }
//   // [self callAPIForGetUserData:appId updateType:eventType];
//}

- (void)updateProfileAndStatus:(NSNotification *) notification{
    NSDictionary *dictData = notification.object;
    self->_dictUserDetails = dictData.copy;
    [self setUserDetails];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Chat Details";
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
        
    } else {
        // Fallback on earlier versions
    }
}

- (void)didupdateStatus:(NSNotification *) notification{
    NSDictionary *dictData = notification.object;
    if (dictData[@"eventData"] != nil && dictData[@"eventData"] != [NSNull null]) {
        NSDictionary *eventData = dictData[@"eventData"];
        NSMutableDictionary *_dic = self->_dictUserDetails.mutableCopy;
        if([eventData[@"blockedStatus"] isEqualToString:@"blocked"]) {
            _dic[BlockedStatus] = @"blocked";
            self->_dictUserDetails = _dic;
            [self showUserBlock:true];
        }else{
            _dic[BlockedStatus] = @"unblocked";
            self->_dictUserDetails = _dic;
            [self showUserBlock:false];
        }
    }
    [self setUserDetails];
    [_tblProfile reloadData];
    
}

-(void)getNotificationStatus{
 if (self.isSingleChat) {
     if (self.strThreadId != nil) {
         [[eRTCChatManager sharedChatInstance] getThreadsNotificationStatus:self.strThreadId andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
             self.status = YES;
             if (![Helper stringIsNilOrEmpty:json[@"notificationSettings"]]){
                 NSString *strStatus = json[@"notificationSettings"];
                 if ([strStatus isEqualToString:All_Message]){
                     self.status = YES;
                     [self.tblProfile reloadData];
                 }else {
                     self.status = NO;
                     [self.tblProfile reloadData];
                 }
             }
         } andFailure:^(NSError * _Nonnull error) {
             NSLog(@"send error--> %@",error);
             self.status = NO;
             [self.tblProfile reloadData];
         }];
     }
 }else{
     self.status = NO;
     [[eRTCCoreDataManager sharedInstance] getLoggedInUserInfo:^(id  _Nonnull userInfo) {
            [[UserModel sharedInstance] saveUserDetailsWith:userInfo];
        }];
        
        if ([[UserModel sharedInstance] getUserDetailsUsingKey:@"notificationSettings"] != nil){
            NSString *strStatus = [[UserModel sharedInstance] getUserDetailsUsingKey:@"notificationSettings"];
            if ([strStatus isEqualToString:All_Message]){
                self.status = YES;
                [self.tblProfile reloadData];
            }
        }
 }
}

- (void)setUserDetails {
    if (self.isSingleChat) {
        self.arrUser = [NSMutableArray new];
        NSMutableDictionary *dictData = [NSMutableDictionary new];
        if (self.dictUserDetails[App_User_ID] != nil) {
            if (self.dictUserDetails[@"profileStatus"] != nil){
                dictData[@"placeHolder"] = @"Status";
                dictData[@"title"] = self.dictUserDetails[@"profileStatus"];
                [self.arrUser addObject:dictData];
                dictData = [NSMutableDictionary new];
                dictData[@"placeHolder"] = @"Email Address";
                dictData[@"title"] = self.dictUserDetails[App_User_ID];
                [self.arrUser addObject:dictData];
            }
        }
        
        dictData = [NSMutableDictionary new];
        dictData[@"placeHolder"] = @"";
        dictData[@"title"] = @"Favorite Messages";
        [self.arrUser addObject:dictData];
        dictData = [NSMutableDictionary new];
        if (self.dictUserDetails[BlockedStatus] != nil) {
            if ([self.dictUserDetails[BlockedStatus]isEqualToString:@"blocked"]) {
                self.strBlockUnblock = @"Unblock";
            strTitle = [NSString stringWithFormat:@"%@", @"Unblock"];
            }
            else if ([self.dictUserDetails[BlockedStatus]isEqualToString:@"unblocked"]){
                self.strBlockUnblock = @"Block";
                strTitle = [NSString stringWithFormat:@"%@", @"Block"];
            }
        } else{
            self.strBlockUnblock = @"Block";
            self->strTitle = @"Block";
        }
        
//        dictData[@"placeHolder"] = @"";
//        dictData[@"title"] = self.strBlockUnblock;
//        [self.arrUser addObject:dictData];
        
        dictData = [NSMutableDictionary new];
        dictData[@"placeHolder"] = @"";
        dictData[@"title"] = @"Manage Notifications";
        [self.arrUser addObject:dictData];
        
    } else {
        self.arrUser = [NSMutableArray new];
        NSMutableDictionary *dictData = [NSMutableDictionary new];
        
        dictData[@"placeHolder"] = @"Email Address";
        dictData[@"title"] = self.dictUserDetails[App_User_ID];
        [self.arrUser addObject:dictData];
        dictData = [NSMutableDictionary new];
        if (self.dictUserDetails[BlockedStatus] != nil) {
            if ([self.dictUserDetails[BlockedStatus]isEqualToString:@"blocked"]) {
                self.strBlockUnblock = @"Unblock";
                [self showUserBlock:true];
            }
            else if ([self.dictUserDetails[BlockedStatus]isEqualToString:@"unblocked"]){
                self.strBlockUnblock = @"Block";
                [self showUserBlock:false];
            }
        } else{
            self.strBlockUnblock = @"Block";
        }
        
        dictData[@"placeHolder"] = @"";
        dictData[@"title"] = self.strBlockUnblock;
        [self.arrUser addObject:dictData];
        
        dictData = [NSMutableDictionary new];
        dictData[@"placeHolder"] = @"";
        dictData[@"title"] = @"Favorite Messages";
        [self.arrUser addObject:dictData];
    }
    
//    if (self.strThreadId != nil && [self.strThreadId length] > 0) {
//         self.arrUser = [NSMutableArray arrayWithObjects:@{@"placeHolder":@"",@"title":@"Starred Messages"},
//                @{@"placeHolder":@"",@"title":@"Notifications"}, nil];
//    } else {
//        self.arrUser = [NSMutableArray arrayWithObjects:@{@"placeHolder":@"",@"title":@"Starred Messages"}, nil];
//    }

//    if (self.dictUserDetails[App_User_ID] != nil) {
//        if (self.dictUserDetails[@"profileStatus"] != nil){
//            [self.arrUser insertObject:@{@"placeHolder":@"Status",@"title":self.dictUserDetails[@"profileStatus"]} atIndex:0];
//            [self.arrUser insertObject:@{@"placeHolder":@"Email Address",@"title":self.dictUserDetails[App_User_ID]} atIndex:1];
//        } else {
//            [self.arrUser insertObject:@{@"placeHolder":@"Email Address",@"title":self.dictUserDetails[App_User_ID]} atIndex:0];
//        }
//    }
    
    if (self.dictUserDetails[User_Name] != nil) {
        self.lblUserName.text = self.dictUserDetails[User_Name];
    }
    
//    if (self.dictUserDetails[BlockedStatus] != nil) {
//        if ([self.dictUserDetails[BlockedStatus]isEqualToString:@"blocked"]) {
//            self.strBlockUnblock = @"Unblock";
//        }
//        else if ([self.dictUserDetails[BlockedStatus]isEqualToString:@"unblocked"]){
//            self.strBlockUnblock = @"Block";
//
//        }
//    }else{
//        self.strBlockUnblock = @"Block";
//    }
    
    if (self.dictUserDetails[User_ProfilePic_Thumb] != nil && self.dictUserDetails[User_ProfilePic_Thumb] != [NSNull null]) {
        NSString *imageURL = [NSString stringWithFormat:@"%@",self.dictUserDetails[User_ProfilePic_Thumb]];
        [self.imgUser sd_setImageWithURL:[NSURL URLWithString:imageURL]
                        placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
        self.imgUser.layer.cornerRadius= self.imgUser.frame.size.height/2;
        self.imgUser.layer.masksToBounds = YES;
    } else {
        self.imgUser.image =  [UIImage imageNamed:@"DefaultUserIcon"];
    }
    

    // Crash Fix on profile view controlller.
    if ([self.arrUser count] >= 3 && self.isSingleChat) {
        [self.arrUser insertObject:@{@"placeHolder":@"",@"title":strTitle} atIndex:3];
      //  [self.arrUser insertObject:@{@"placeHolder":@"",@"title":@"Block"} atIndex:self.arrUser.count];
    }
   else if ([self.arrUser count] > 1 && self.isSingleChat) {
        [self.arrUser insertObject:@{@"placeHolder":@"",@"title":@"Block"} atIndex:self.arrUser.count];
    }
    else if (self.isSingleChat) {
        [self.arrUser addObject:@{@"placeHolder":@"",@"title":@"Block"}];
    }
    self.tblProfile.estimatedRowHeight = 44;
    self.tblProfile.rowHeight = UITableViewAutomaticDimension;
    self.tblProfile.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tblProfile reloadData];
}

- (void)pushToNotification {
    NotificationSettingViewController *_vcProfile = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"NotificationSettingViewController"];
    [self.navigationController pushViewController:_vcProfile animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   // self.navigationController.navigationBar.topItem.title = @"";
    self.navigationController.title = @"Chat Details";
}

#pragma mark Table Delegate and DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.arrUser.count;
    }else if (section == 1){
        return 2;
    }else if (section == 2){
        return 1;
    }
    return 0;
}


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
if (section == 1){
  UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tblProfile.bounds.size.width, 40)];
  UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 7, _tblProfile.bounds.size.width-48, 20)];
  [headerView setBackgroundColor:[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0]];
  [headerTitle setTextColor:[UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0]];
  [headerTitle setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:14.0]];
        [headerTitle setText:@"Participants"];
        [headerView addSubview:headerTitle];
    return headerView;
}else if (section == 2) {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tblProfile.bounds.size.width, 40)];
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 7, _tblProfile.bounds.size.width-48, 20)];
     CGRect buttonFrame = CGRectMake(_tblProfile.bounds.size.width-86, 0, 70, 40 );
      UIButton *btnViewAll = [[UIButton alloc] initWithFrame: buttonFrame];
      UIButton *btnParticipants = [[UIButton alloc] initWithFrame: buttonFrame];
      [btnViewAll setTitle: @"View All" forState: UIControlStateNormal];
      [btnViewAll addTarget:self action:@selector(btnViewAllAction:) forControlEvents:UIControlEventTouchUpInside];
      [btnViewAll setTitleColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
    [headerView setBackgroundColor:[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0]];
    [headerTitle setTextColor:[UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0]];
    [headerTitle setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:14.0]];
          [headerTitle setText:@"Images & Videos"];
          [headerView addSubview:btnViewAll];
      [headerView addSubview:headerTitle];
      return headerView;
}
    return [UIView new];
 
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 40;
    } else if (section == 2) {
        return 40;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 4) {
            return 60;
        }
    }else if (indexPath.section == 1) {
        return 60;
    }else if (indexPath.section == 2) {
        return 240;
    }
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSDictionary * dict = [self.arrUser objectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        UserProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserProfileCellStatus" forIndexPath:indexPath];
        cell.lblPlaceholder.text = dict[@"placeHolder"];
        cell.lblTitle.text = dict[@"title"];
        cell.lblTitle.textColor = [UIColor blackColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    UserProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:UserProfileCellIdentifier forIndexPath:indexPath];
    if (indexPath.row == 1) {
        [cell.switchNotifications setHidden:YES];
        if (self.isSingleChat) {
            cell.img.image = [UIImage imageNamed:@"profileEmail"];
        } else {
            cell.img.image = [UIImage imageNamed:@"profileBlock"];
        }
        cell.lblPlaceholder.text = dict[@"placeHolder"];
        cell.lblTitle.text = dict[@"title"];
        cell.lblTitle.textColor = [UIColor blackColor];
    } else if (indexPath.row == 2) {
        [cell.switchNotifications setHidden:YES];
        cell.img.image = [UIImage imageNamed:@"favNew"];
        cell.lblPlaceholder.text = dict[@"placeHolder"];
        cell.lblTitle.text = dict[@"title"];
        cell.lblTitle.textColor = [UIColor blackColor];
    } else if (indexPath.row == 3) {
        [cell.switchNotifications setHidden:YES];
        cell.lblPlaceholder.text = dict[@"placeHolder"];
        cell.lblTitle.text = dict[@"title"];
        cell.lblTitle.textColor = [UIColor colorWithRed:.95 green:.15 blue:.15 alpha:1.0];
        cell.img.image = [UIImage imageNamed:@"profileBlock"];
    } else if (indexPath.row == 4) {
        [cell.switchNotifications setHidden:YES];
        [cell.switchNotifications addTarget:self action:@selector(updateThreadNotificationStatus:) forControlEvents:UIControlEventValueChanged];
        NSLog(@"self.status--%d",self.status);
        [cell.switchNotifications setOn:self.status];
        cell.lblTitle.text = dict[@"title"];
        cell.lblTitle.textColor = [UIColor blackColor];
        cell.img.image = [UIImage imageNamed:@"profileNotifications"];
        if ([_dictUserDetails[BlockedStatus] isEqualToString:@"blocked"]){
            cell.switchNotifications.userInteractionEnabled = FALSE;
        }else {
            cell.switchNotifications.userInteractionEnabled = TRUE;
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    }else if (indexPath.section == 1) {
        ChatDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatDetailsTableViewCell"];
        if (indexPath.row == 0) {
            NSString *userName = [[UserModel sharedInstance] getUserDetailsUsingKey:User_Name];
            NSString *imgUrl = [[UserModel sharedInstance] getUserDetailsUsingKey:User_ProfilePic_Thumb];
            NSString *email = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
            cell.lblName.text = userName;
            cell.lblUserEmailId.text = email;
            cell.imgCurrentUser.hidden = false;
            if (imgUrl != nil && imgUrl != [NSNull null]) {
                [cell.imgProfile sd_setImageWithURL:[NSURL URLWithString:imgUrl]
                placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
                cell.imgProfile.layer.cornerRadius= cell.imgProfile.frame.size.height/2;
                cell.imgProfile.layer.masksToBounds = YES;
            }else{
                cell.imgProfile.image =  [UIImage imageNamed:@"DefaultUserIcon"];
            }
        }else if (indexPath.row == 1) {
            if (_dictUserDetails[App_User_ID] != nil && _dictUserDetails[User_eRTCUserId] != [NSNull null]) {
                    cell.lblName.text = _dictUserDetails[User_Name];
                }
            if (_dictUserDetails[App_User_ID] != nil && _dictUserDetails[User_eRTCUserId] != [NSNull null]) {
                    cell.lblUserEmailId.text = _dictUserDetails[App_User_ID];
                }
            cell.imgCurrentUser.hidden = true;
            if (_dictUserDetails[AvailabilityStatus] != nil && _dictUserDetails[AvailabilityStatus] != [NSNull null]) {
                
                if ([_dictUserDetails[AvailabilityStatus] isEqualToString:@"online"]) {
                    cell.imgDot.image =  [UIImage imageNamed:@"greenIndicator"];
                }else if ([_dictUserDetails[AvailabilityStatus] isEqualToString:@"away"]) {
                    cell.imgDot.image =  [UIImage imageNamed:@"yelloIndicator"];
                }else if ([_dictUserDetails[AvailabilityStatus] isEqualToString:@"offline"]) {
                    cell.imgDot.image =  [UIImage imageNamed:@"redIndicator"];
                }
            }
            
            if (_dictUserDetails[User_ProfilePic_Thumb] != nil && _dictUserDetails[User_ProfilePic_Thumb] != [NSNull null]) {
                NSString *imageURL = [NSString stringWithFormat:@"%@",_dictUserDetails[User_ProfilePic_Thumb]];
                [cell.imgProfile sd_setImageWithURL:[NSURL URLWithString:imageURL]
                placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
                cell.imgProfile.layer.cornerRadius= cell.imgProfile.frame.size.height/2;
                cell.imgProfile.layer.masksToBounds = YES;
            }else{
                cell.imgProfile.image =  [UIImage imageNamed:@"DefaultUserIcon"];
            }
            if (_dictUserDetails[App_User_ID] != nil && _dictUserDetails[User_eRTCUserId] != [NSNull null]) {
                    cell.lblUserEmailId.text = _dictUserDetails[App_User_ID];
                }
        }
     
        return cell;
    }else if (indexPath.section == 2) {
        ImageParticipantCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageParticipantCell"];
        cell.arrGallerycollectionData = self.arrGalleryData;
        cell.delegate = self;
        cell.cvVideoImageList.reloadData;
        [cell getGalleryData:self.arrGalleryData];
        return cell;
    }
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserProfileCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.row == 2) {
        StarredMessageViewController * _vcStarredMessage = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"StarredMessageViewController"];
        _vcStarredMessage.dictUserDetails = self.dictUserDetails;
        _vcStarredMessage.strGroupThread = self.strGroupThread;
        _vcStarredMessage.strThreadId = _dictUserDetails[ThreadID];
        [self.navigationController pushViewController:_vcStarredMessage animated:YES];
    }else if (indexPath.row == 4) {
        [self pushToManageNotification];
    }
    int indexValue = 0;
    if (self.isSingleChat) {
        indexValue = 3;
    } else {
        indexValue = 1;
    }
    if (indexPath.row == indexValue){
        NSString*blockUnblock;
        NSMutableDictionary *copy = _dictUserDetails.mutableCopy;
        if ([cell.lblTitle.text  isEqual: @"Block"]){
            blockUnblock = @"block";
            copy[BlockedStatus] = @"blocked";
            
        }else{
            copy[BlockedStatus] = @"unblocked";
            blockUnblock = @"unblock";
        }
        
        [Helper showAlert:Block_user message:Block_Msg btnYes:cell.lblTitle.text btnNo:@"Cancel" inViewController:self completedWithBtnStr:^(NSString* btnString) {
            if ([btnString isEqualToString:cell.lblTitle.text]) {
                [KVNProgress show];
                NSString*strAppUserID  =   self.dictUserDetails[App_User_ID];
                NSMutableDictionary*dict = [[NSMutableDictionary alloc]init];
                [dict setValue:strAppUserID forKey:App_User_ID];
                [dict setValue:blockUnblock forKey:@"blockUnblock"];
                
                [[eRTCAppUsers sharedInstance] ContactblockUnblock:dict andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                    [KVNProgress dismiss];
                    if ([cell.lblTitle.text  isEqual: @"Block"]){
                        cell.lblTitle.text = @"Unblock";
                        [self showUserBlock:true];
                        [self.arrUser insertObject:@{@"placeHolder":@"",@"title":@"Unblock"} atIndex:2];
                    }else{
                        cell.lblTitle.text = @"Block";
                        [self showUserBlock:false];
                        [self.arrUser insertObject:@{@"placeHolder":@"",@"title":@"Block"} atIndex:2];
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"blockUnblockUser" object:@{@"blockUnblock": blockUnblock}];
                    self->_dictUserDetails = copy.copy;
                    self.arrUser = @[].mutableCopy;
                    [self setUserDetails];
                    
                } andFailure:^(NSError * _Nonnull error) {
                    [KVNProgress dismiss];
                    NSString *errMsg = [NSString stringWithFormat:@"%@", error.localizedDescription];
                    [self performSelector:@selector(showAlert:) withObject:errMsg afterDelay:0.3];
                }] ;
            }
        }];
    }else{
        
    }
}

-(void)updateThreadNotificationStatus:(UISwitch *)sender {
    NSString *strNotificationType = @"";
    if (sender.isOn) {
        strNotificationType = @"all";
    } else {
        strNotificationType = @"none";
    }
    if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil) {
        if (self.strThreadId != nil) {
            [[eRTCChatManager sharedChatInstance] updateNotificationSettings:strNotificationType withThreadId:self.strThreadId andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            } andFailure:^(NSError * _Nonnull error) {
                NSLog(@"error--> %@",error);
                NSString *errMsg = [NSString stringWithFormat:@"%@", error.localizedDescription];
                [Helper showAlertOnController:@"eRTC" withMessage:errMsg onController:self];
            }];
        }
    }
}

-(void)getblockeduser {
    [[eRTCAppUsers sharedInstance] getContactblockUnblock:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        
    } andFailure:^(NSError * _Nonnull error) {
        
        
    }];
}

- (IBAction)btnShowProfileImage:(id)sender {
    if (self.dictUserDetails[User_ProfilePic_Thumb] != nil && self.dictUserDetails[User_ProfilePic_Thumb] != [NSNull null]) {
        BFRImageViewController *imageVC = [[BFRImageViewController alloc] initWithImageSource:[NSArray arrayWithObjects:self.imgUser.image, nil]];
        [self presentViewController:imageVC animated:YES completion:nil];
    }
}

-(void)showAlert:(NSString *)strMessage{
    [Helper showAlertOnController:@"eRTC" withMessage:strMessage onController:self];
}

-(void)showUserBlock:(BOOL *)blockUnBlock {
    if (blockUnBlock) {
        NSTimeInterval delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self->bottemView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-70, self.view.bounds.size.width, 70)];
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 70)];
        [self->bottemView setBackgroundColor:UIColor.redColor];
            lblTitle.textColor = UIColor.whiteColor;
            lblTitle.text = @"You have blocked this user";
            lblTitle.textAlignment = NSTextAlignmentCenter;
        [lblTitle setFont:[UIFont fontWithName:@"SFProDisplay-Semibold" size:18.0]];
        lblTitle.numberOfLines = 0;
            [self->bottemView addSubview:lblTitle];
           [self.view addSubview:self->bottemView];
        });
    }else{
        [bottemView removeFromSuperview];
    }
}


-(IBAction)btnViewAllAction:(id)sender{
    if ([self.dictUserDetails[BlockedStatus]isEqualToString:@"blocked"]) {
    }
    else if ([self.dictUserDetails[BlockedStatus]isEqualToString:@"unblocked"]){
        NSMutableDictionary *dictDetails = @{}.mutableCopy;
        [dictDetails setValue:_strThreadId forKey:ThreadID];
        channelGalleryVC *vcChannel = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"channelGalleryVC"];
        vcChannel.dictGroupInfo = dictDetails;
        [self.navigationController pushViewController:vcChannel animated:true];
    }
   
}

-(void)callApiforGetGalleryData {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
        NSMutableDictionary *details = @{}.mutableCopy;
        [details setValue:@20 forKey:@"pageSize"];
        [details setValue:@"true" forKey:@"deep"];
       // details[@"msgType"] = @"image,video,gif";
        [[eRTCChatManager sharedChatInstance] chatHistoryGet:_strThreadId parameters:details.copy
                                                                    andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            
            [KVNProgress dismiss];
            NSDictionary *dictResponse = (NSDictionary *)json;
            if (dictResponse[Key_Success] != nil) {
                BOOL success = (BOOL)dictResponse[Key_Success];
                if (success) {
                    if ([dictResponse[Key_Result] isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *result = (NSDictionary *)dictResponse[Key_Result];
                        if ([result count]>0){
                            NSArray *arr = result[Key_chats];
                            self.arrGalleryData = [[NSMutableArray alloc] init];
                            NSArray *filteredAudio = [arr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"msgType == %@",AudioFileName]];
                            NSArray *filteredImage = [arr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"msgType == %@",Image]];
                            NSArray *filteredVideo = [arr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"msgType == %@",Key_video]];
                            [self.arrGalleryData addObjectsFromArray:filteredAudio];
                            [self.arrGalleryData addObjectsFromArray:filteredImage];
                            [self.arrGalleryData addObjectsFromArray:filteredVideo];
                            if ([self.arrGalleryData count]>0){
                                [self.tblProfile reloadData];
                              }
                        }
                    }
                }
            }
        }andFailure:^(NSError * _Nonnull error) {
            [KVNProgress dismiss];
        }];
        
    }else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
        [KVNProgress dismiss];
    }
}

-(void)selectedImageIndex:(ImageParticipantCell *)cell selectDict:(NSMutableDictionary *)dict {
    if ([self.dictUserDetails[BlockedStatus]isEqualToString:@"blocked"]) {
        
    }
    else if ([self.dictUserDetails[BlockedStatus]isEqualToString:@"unblocked"]){
        GalleryDetailsShareVC *_galleryVC = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"GroupDetailsVC"];
        _galleryVC.dictGalleryInfo = dict;
       [self.navigationController pushViewController:_galleryVC animated:YES];
    }
}

-(IBAction)btnMoreOptions:(id)sender{
    if ([_dictUserDetails[BlockedStatus] isEqualToString:@"blocked"]){
        self->blockUnblockUser = @"Unblock";
    }else {
        self->blockUnblockUser = @"Block";
    }
    
    UIAlertController *activitySheet = [UIAlertController alertControllerWithTitle:nil
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *manageNotification = [UIAlertAction actionWithTitle:NSLocalizedString(@"Manage Notifications", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
       
    UIAlertAction *clearChat = [UIAlertAction actionWithTitle:NSLocalizedString(@"Clear chat history", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [Helper showAlert:Clear_Chat_History message:msgClearChatHistory btnYes:@"Clear" btnNo:@"Cancel" inViewController:self completedWithBtnStr:^(NSString* btnString) {
            if ([btnString isEqualToString:@"Clear"]) {
                [self clearChatHistory];
            }
        }];
    }];
    UIAlertAction *preferences = [UIAlertAction actionWithTitle:NSLocalizedString(@"Preferences", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       
    }];
    
    //[activitySheet addAction:manageNotification];
    //[activitySheet addAction:preferences];
    [activitySheet addAction:clearChat];
    UIAlertAction *blockUser = [UIAlertAction actionWithTitle:NSLocalizedString([self->blockUnblockUser.capitalizedString stringByAppendingString:@" user"], nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self BlockUnBlock:self->blockUnblockUser];
    }];
   // [activitySheet addAction:blockUser];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [activitySheet addAction:cancel];
    [self presentViewController:activitySheet animated:YES completion:nil];
}

-(void)clearChatHistory {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
        if (_dictUserDetails[ThreadID] != nil){
            self->chatThreadId = _dictUserDetails[ThreadID];
        }else{
            self->chatThreadId = self.strThreadId;
        }
        [[eRTCChatManager sharedChatInstance] clearChatHistoryBy:self->chatThreadId andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        [KVNProgress dismiss];
        [self.view makeToast:ChatMsgClearSuccess];
        [self.navigationController popToRootViewControllerAnimated:NO];
        }andFailure:^(NSError * _Nonnull error) {
        }];
     
    } else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
        [KVNProgress dismiss];
    }
  }


-(void)BlockUnBlock:(NSString *)isBlock {
        [KVNProgress show];
        NSString*strAppUserID  =   self.dictUserDetails[App_User_ID];
        NSMutableDictionary*dict = [[NSMutableDictionary alloc]init];
        [dict setValue:strAppUserID forKey:App_User_ID];
        [dict setValue:isBlock forKey:@"blockUnblock"];
        [[eRTCAppUsers sharedInstance] ContactblockUnblock:dict andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            [KVNProgress dismiss];
        } andFailure:^(NSError * _Nonnull error) {
            [KVNProgress dismiss];
            NSString *errMsg = [NSString stringWithFormat:@"%@", error.localizedDescription];
            [self performSelector:@selector(showAlert:) withObject:errMsg afterDelay:0.3];
        }] ;
}

/*
- (void)callAPIForGetUserData:(NSString *)userID updateType:(NSString *)type {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [[eRTCAppUsers sharedInstance] getUserListWithLastUserID:@"" andLastCallTime:@"" andUpdateType:type andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            if (![Helper stringIsNilOrEmpty:json[Key_Success]] && [json[Key_Success] integerValue] == 1) {
                [[eRTCCoreDataManager sharedInstance] getLoggedInUserInfo:^(id  _Nonnull userInfo) {
                    [[UserModel sharedInstance] saveUserDetailsWith:userInfo];
                }];
                [self showUserDefoultData];
                
            } else {
                if (![Helper stringIsNilOrEmpty:json[Key_Message]]) {
                    [Helper showAlertOnController:@"eRTC" withMessage:json[Key_Message] onController:self];
                }
            }
        } andFailure:^(NSError * _Nonnull error) {
            [Helper showAlertOnController:@"eRTC" withMessage:[error localizedDescription] onController:self];
        }];
    } else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}*/


- (void)pushToManageNotification {
   ManageNotificationVC *_vcmanageNotification = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"ManageNotificationVC"];
    _vcmanageNotification.strGroupThread = _strThreadId;
   [self.navigationController pushViewController:_vcmanageNotification animated:YES];
}

@end
