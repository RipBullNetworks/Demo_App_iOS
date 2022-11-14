//
//  InfoGroupViewController.m
//  eRTCApp
//
//  Created by Ashish Vani on 04/07/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import "InfoGroupViewController.h"
#import "NewGroupViewController.h"
#import "BasicInfoTableViewCell.h"
#import "ActionInfoTableViewCell.h"
#import "ParticipantInfoTableViewCell.h"
#import "SingleChatViewController.h"
#import "ProfileViewController.h"
#import "EditGroupSubjectViewController.h"
#import "EditGroupDescriptionViewController.h"
#import "AddParticipantsTableViewCell.h"
#import "GroupChatViewController.h"
#import "GroupListViewController.h"
#import "NotificationSettingViewController.h"
#import <Toast/Toast.h>
#import "UserProfileCell.h"
#import "StarredMessageViewController.h"
#import "ReportsViewController.h"
#import "ManageNotificationVC.h"
#import "ImageParticipantCell.h"
#import "GalleryDetailsShareVC.h"
#import "GroupMemberViewController.h"
#import "EditChannelInfo.h"
#import "ChannelPrivacyViewController.h"
#import "InvitationViewController.h"
#import "ThreadViewController.h"
#import "CreateNewAdminViewController.h"
#import "channelGalleryVC.h"
#import "InfoStaredCell.h"

 

@interface InfoGroupViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,myGalleryVideoDelegate> {
    __weak IBOutlet UIView                    *_viewNavTitle;
    __weak IBOutlet UICollectionView          *_cvImageVideo;
    __weak IBOutlet UILabel                   *_lblNavTitle;
    __weak IBOutlet UIButton                  *_btnCamera;
    __weak IBOutlet UIImageView               *_imgProfile;
    __weak IBOutlet UILabel                   *_lblParticipants;
    __weak IBOutlet UIView                    *_viewParticipants;
    __weak IBOutlet UITableView               *_tblInfo;
    __weak IBOutlet UIButton                  *_btnExitGroup;
    BOOL                                       _isImageSet;
    BOOL                                       _isEditModeOn;
    BOOL                                       _isLoggedUserAdmin;
    NSInteger                                  _indexOfLoggedUser;
    NSString                                  *_strAppLoggedInUserID;
    NSString                                  *_strPrivacyKey;
    NSString                                  *_strGroupID;
    UIView *frozenView;
    BOOL                                      _isFrozenChannel;
    NSString                                  *_selectAdminType;
    NSString                                  *strAlertTitle;
    __weak IBOutlet NSLayoutConstraint        *_ImageCollectionHeight;
    UIImage *imageReduced;
    UIView *deactivatedView;
    BOOL  isGroupActivated;
    
}
@end

@implementation InfoGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self setupExitGroup];
    [self setupNavigationBar];
    [self setupCameraView];
    [self setupCollectionView];
    _isEditModeOn = FALSE;
    [_btnCamera setHidden:true];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(goBacktoGroupList)
                                                 name:kGroupUpdateSuccessfully
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(didReceivedGroupEvent:)
                                                name:DidReceivedGroupEvent
                                              object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivedImage:)
                                                 name:ActionReceivedonVideoAndImage
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didupdatePrivacyKey:)
                                                 name:UpdatePrivacyKey
                                               object:nil];
    [self.vwInvitationSent setHidden:TRUE];
    
  
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didupdateGroupProfile:)
                                                 name:UpdateGroupProfileSuccessfully
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivedGroupInfo:)
                                                 name:DidReceveNameAndDescription
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivedInvitationInfo:)
                                                 name:DidSendInvitationMessage
                                               object:nil];
    
//    NSTimeInterval delayInSeconds = 2.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [self.vwInvitationSent setHidden:TRUE];
//    });
    
    NSLog (@"_dictGroupInfo %@",_dictGroupInfo);
    [self callApiforGetGalleryData];
    
    
}

- (void)setupCollectionView {
    _ImageCollectionHeight.constant = 0;
    //if (![self arySelectedParticipants]) { [self setArySelectedParticipants:[NSMutableArray new]];}
    [_cvImageVideo updateConstraints];
    [_cvImageVideo registerNib:[UINib nibWithNibName:@"ImageAndVideoCell" bundle:nil] forCellWithReuseIdentifier:@"ImageAndVideoCell"];
    [_cvImageVideo reloadData];
    __block NSLayoutConstraint *lcCH = _ImageCollectionHeight;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupTableView];
    self.navigationController.navigationBar.topItem.title = @"";
    
    if ([_dictGroupInfo[@"isActivated"] boolValue] == true){
        [self showDeactivated:true];
        self->isGroupActivated = true;
    }else{
        [self showDeactivated:false];
        self->isGroupActivated = false;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [frozenView removeFromSuperview];
   // [[NSNotificationCenter defaultCenter] removeObserver:DidReceivedGroupEvent];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [frozenView removeFromSuperview];
   // [[NSNotificationCenter defaultCenter] removeObserver:DidReceivedGroupEvent];
}

#pragma mark - Setup
- (void)setupInfoWithView {
    _isImageSet = NO;
    [_btnCamera setSelected:_isImageSet];
}

- (void)setupExitGroup {
    [_btnExitGroup setTitleColor:[UIColor colorWithRed:1.0 green:0.12 blue:0.12 alpha:1.0] forState:UIControlStateNormal];
    [_btnExitGroup.titleLabel setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:17]];
    [_btnExitGroup setTitle:NSLocalizedString(@"Exit Group", nil) forState:UIControlStateNormal];
}

- (void)setupTableView {
    [_tblInfo registerNib:[UINib nibWithNibName:@"AddParticipantsTableViewCell" bundle:nil] forCellReuseIdentifier:@"AddParticipantsTableViewCell"];
    [_tblInfo registerNib:[UINib nibWithNibName:@"ParticipantInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"ParticipantInfoTableViewCell"];
    [_tblInfo registerNib:[UINib nibWithNibName:@"BasicInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"BasicInfoTableViewCell"];
    [_tblInfo registerNib:[UINib nibWithNibName:@"ActionInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"ActionInfoTableViewCell"];
    [_tblInfo registerNib:[UINib nibWithNibName:@"ImageParticipantCell" bundle:nil] forCellReuseIdentifier:@"ImageParticipantCell"];
    [_tblInfo registerNib:[UINib nibWithNibName:@"InfoStaredCell" bundle:nil] forCellReuseIdentifier:@"InfoStaredCell"];
    [_tblInfo setEstimatedRowHeight:UITableViewAutomaticDimension];
    [_tblInfo setRowHeight:48];
    [_tblInfo setDelegate:self];
    [_tblInfo setDataSource:self];
    [_tblInfo setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self reloadTableView];
}

- (void)reloadTableView {
    if ([self.dictGroupInfo[@"participants"] isKindOfClass:[NSArray class]]) {
        
        self.aryParticipants = self.dictGroupInfo[@"participants"];
        
    }
    _isLoggedUserAdmin = [self isLoggedUserAdmin];
    _strPrivacyKey = _dictGroupInfo[@"groupType"];
    [_tblInfo reloadData];
}

- (void)setupCameraView {
    if (self.dictGroupInfo[User_ProfilePic_Thumb] != nil && self.dictGroupInfo[User_ProfilePic_Thumb] != [NSNull null]) {
        NSString *imageURL = [NSString stringWithFormat:@"%@",self.dictGroupInfo[User_ProfilePic_Thumb]];
        [_imgProfile sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
        _isImageSet = YES;
    } else {
        [_imgProfile setImage:[UIImage imageNamed:@"DefaultUserIcon"]];
        [_btnCamera setSelected:YES];
        //[self->_imgProfile setImage:nil];
    }
    _imgProfile.layer.masksToBounds = YES;
    _imgProfile.layer.cornerRadius = _imgProfile.bounds.size.width/2;
    _btnCamera.layer.cornerRadius = _btnCamera.bounds.size.width/2;
}

- (void)setupImageView {
    if (self.dictGroupInfo[User_ProfilePic_Thumb] != nil && self.dictGroupInfo[User_ProfilePic_Thumb] != [NSNull null]) {
        NSString *imageURL = [NSString stringWithFormat:@"%@",self.dictGroupInfo[User_ProfilePic_Thumb]];
        NSString *strUrl = [imageBaseUrl stringByAppendingString:imageURL];
        [_imgProfile sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
        _isImageSet = YES;
    } else {
        [_imgProfile setImage:[UIImage imageNamed:@"DefaultUserIcon"]];
        [_btnCamera setSelected:YES];
        //[self->_imgProfile setImage:nil];
    }
    _imgProfile.layer.masksToBounds = YES;
    _imgProfile.layer.cornerRadius = _imgProfile.bounds.size.width/2;
    _btnCamera.layer.cornerRadius = _btnCamera.bounds.size.width/2;
}


- (void)setupNavigationBar {
    [_lblNavTitle setFont:[UIFont fontWithName:@"SFProDisplay-Medium" size:18]];
    [self.navigationItem setTitleView:_viewNavTitle];
    [_lblNavTitle setText:NSLocalizedString(@"Channel Details", nil)];
}

- (BOOL) isLoggedUserAdmin {
    _strAppLoggedInUserID = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
    if (_strAppLoggedInUserID.length > 0) {
        NSPredicate *pLoggedAdmin = [NSPredicate predicateWithFormat:@"role contains[cd] %@ AND appUserId contains[cd] %@", @"admin", _strAppLoggedInUserID];
        
        NSCompoundPredicate *cp = [NSCompoundPredicate orPredicateWithSubpredicates:@[pLoggedAdmin]];
        NSArray *ary = [self.aryParticipants filteredArrayUsingPredicate:cp];
        
        if ([ary count]>0){
            _indexOfLoggedUser = [self.aryParticipants indexOfObject:[ary firstObject]];
            return YES;
        }
    }
    _indexOfLoggedUser = -1;
    return NO;
}

-(void)didupdateGroupProfile:(NSNotification *) notification{
    NSDictionary *dictChannelInfo = notification.object;
    if (dictChannelInfo[User_ProfilePic_Thumb] != nil && dictChannelInfo[User_ProfilePic_Thumb] != [NSNull null]) {
        NSString*imgProfile = dictChannelInfo[@"profilePicThumb"];
        [self.dictGroupInfo setValue:imgProfile forKey:@"profilePicThumb"];
        NSString *imageURL = [NSString stringWithFormat:@"%@",self.dictGroupInfo[User_ProfilePic_Thumb]];
       // NSString *strUrl = [imageBaseUrl stringByAppendingString:imageURL];
        [_imgProfile sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
        _isImageSet = YES;
       // [self setupExitGroup];
        [self setupNavigationBar];
        [self setupCollectionView];
        _isEditModeOn = FALSE;
    } else {
        [_imgProfile setImage:[UIImage imageNamed:@"DefaultUserIcon"]];
        [_btnCamera setSelected:YES];
        //[self->_imgProfile setImage:nil];
    }
}

-(void)didReceivedGroupInfo:(NSNotification *) notification{
    NSDictionary *dictUserName = notification.userInfo;
    NSString *strType = notification.object;
    
    NSDictionary *dictChangeData = dictUserName[@"changeData"];
    if ([strType isEqualToString:@"description"]) {
    NSDictionary *dictDescription = dictChangeData[@"description"];
    [self.dictGroupInfo setValue:dictDescription[@"new"] forKey:@"description"];
    }else{
    NSDictionary *dictChangeName = dictChangeData[@"name"];
    [self.dictGroupInfo setValue:dictChangeName[@"new"] forKey:@"name"];
    }
    [_tblInfo reloadData];
}

#pragma mark - IBAction

-(IBAction)btnExitGroupTapped:(id)sender {
    [self callAPIForRemoveParticipant:nil andExitGroup:YES];
}

- (IBAction)btnSaveAndMore:(UIBarButtonItem *)sender {
    if (_isEditModeOn) {
    [self btnSave:false];
        [self isChangeNavigationTitle:false];
        [self reloadTableView];
        //[self callAPIForUpdateGroup];
    }else{
    [self btnSave:true];
    }
}

- (IBAction)switchNotification:(id)sender {
    
}

- (void)pushToEditChannelInfoVC {
    [self callApiGetGroupByGroupId:false];
}

-(void)isEditChannelInfo:(BOOL)isOnoffEditMode {
    
}

-(void)isChangeNavigationTitle:(BOOL)isNavigationTitle {
    [_btnEditAndSave setImage:[UIImage imageNamed:@""]];
    if (isNavigationTitle) {
        [_btnEditAndSave setTitle:@"Save"];
        [_lblNavTitle setText:NSLocalizedString(@"Edit Channel Info", nil)];
        _isEditModeOn = true;
        [_btnCamera setHidden:false];
    }else{
        UIImage *imgNil = [UIImage imageNamed:@"moreChannel"];
        [_btnEditAndSave setImage:imgNil];
        [_btnEditAndSave setTitle:@""];
        [_lblNavTitle setText:NSLocalizedString(@"Channel Details", nil)];
        _isEditModeOn = false;
        [_btnCamera setHidden:true];
    }
    [_lblNavTitle setFont:[UIFont fontWithName:@"SFProDisplay-Medium" size:18]];
    [self.navigationItem setTitleView:_viewNavTitle];
}

-(void)btnSave:(BOOL)isChangeCondition {
    if(isChangeCondition == true && _isFrozenChannel == false) {
        if (isGroupActivated == false) {
        UIAlertController *activitySheet = [UIAlertController alertControllerWithTitle:nil
                                                                               message:nil
                                                                        preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *manageNotification = [UIAlertAction actionWithTitle:NSLocalizedString(@"Manage notifications", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self pushToManageNotification];
        }];
        
        UIAlertAction *editChannelInfo = [UIAlertAction actionWithTitle:NSLocalizedString(@"Edit channel info", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [self isChangeNavigationTitle:true];
//            [self reloadTableView];
            [self pushToEditChannelInfoVC];
        }];
        
        UIAlertAction *viewReports = [UIAlertAction actionWithTitle:NSLocalizedString(@"View Reports", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self pushToReportsViewController];
        }];
        UIAlertAction *clearChat = [UIAlertAction actionWithTitle:NSLocalizedString(@"Clear chat history", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [Helper showAlert:Clear_Chat_History message:msgClearChatHistory btnYes:@"Clear" btnNo:@"Cancel" inViewController:self completedWithBtnStr:^(NSString* btnString) {
                if ([btnString isEqualToString:@"Clear"]) {
                    [self clearChatHistory];
                }
            }];
        }];
//        UIAlertAction *deleteChannel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete Channel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [self ExitGroupChannelPressButton];
//        }];
        
        NSIndexSet *indexes = [self.aryParticipants indexesOfObjectsPassingTest:^BOOL(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
            if ([obj[@"role"] isEqualToString:@"admin"] && [obj[@"appUserId"] isEqualToString:userId]) {
                [activitySheet addAction:editChannelInfo];
                [activitySheet addAction:viewReports];
            }
            return obj[@"role"];
        }];
        [activitySheet addAction:manageNotification];
        [activitySheet addAction:clearChat];
        //[activitySheet addAction:deleteChannel];
        UIAlertAction *leaveChannel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Leave Channel", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"role = %@",@"admin"];
            NSArray *filteredArr = [[NSArray arrayWithArray:self.aryParticipants] filteredArrayUsingPredicate:predicate];
            
            if (filteredArr.count > 1) {
                    NSIndexSet *indexes = [self.aryParticipants indexesOfObjectsPassingTest:^BOOL(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                        NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
                        if ([obj[@"role"] isEqualToString:@"admin"] && [obj[@"appUserId"] isEqualToString:userId]) {
                            self->_selectAdminType = @"";
                        }else{
                            self->_selectAdminType = @"";
                        }
                        return obj[@"role"];
                    }];
            }else{
                NSIndexSet *indexes = [self.aryParticipants indexesOfObjectsPassingTest:^BOOL(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                    NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
                    if ([obj[@"role"] isEqualToString:@"admin"] && [obj[@"appUserId"] isEqualToString:userId]) {
                        self->_selectAdminType = obj[@"role"];
                    }
                    return obj[@"role"];
                }];
            }

            if ([_selectAdminType isEqualToString:@"admin"]) {
                [self leaveChannelPressButton:true strMessage:msgContinueGroup];
            }else{
                [self leaveChannelPressButton:false strMessage:msgLeaveGroup];
            }
        }];
        [activitySheet addAction:leaveChannel];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
        [activitySheet addAction:cancel];
        [self presentViewController:activitySheet animated:YES completion:nil];
        }
    }else{

    }
}

-(IBAction)btnCameraTapped:(id)sender {
    UIAlertController *activitySheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Media messages", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *camera = [UIAlertAction actionWithTitle:NSLocalizedString(@"Camera", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self takeImageFromCamera];
    }];
    
    UIAlertAction *library = [UIAlertAction actionWithTitle:NSLocalizedString(@"Photo Library", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self takeImageFromLibrary];
    }];
    
    [activitySheet addAction:camera];
    [activitySheet addAction:library];
    
    if (_isImageSet) {
        UIAlertAction *delete = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            //[self->_btnCamera setSelected:self->_isImageSet];
            [self removeGroupProfile];
        }];
        [activitySheet addAction:delete];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [activitySheet addAction:cancel];
    [self presentViewController:activitySheet animated:YES completion:nil];
}

-( void)removeGroupProfile{
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        //if (imageReduced != nil || (userStatus != nil && [userStatus length] > 0)) {
            [KVNProgress show];
        NSString *groupId = [NSString stringWithFormat:@"%@",self.dictGroupInfo[@"groupId"]];
        [[eRTCAppUsers sharedInstance] removeGroupProfile:groupId andCompletion:^(id  json, NSString * errMsg) {
            [KVNProgress dismiss];
            NSDictionary *dictResponse = (NSDictionary *)json;
            if (dictResponse[@"success"] != nil) {
                self->_isImageSet = NO;
                [self removeProfilePic];
                [Helper showAlertOnController:@"eRTC" withMessage:@"Group Profile removed successfully." onController:self];
                BOOL success = (BOOL)dictResponse[@"success"];
                if (success) {
                    if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *result = (NSDictionary *)dictResponse[@"result"];
                        if ([result count]>0){
                            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateGroupProfileSuccessfully object:result];
                            return;
                        }
                    }
                }
            }
        } andFailure:^(NSError * _Nonnull error) {
            [KVNProgress dismiss];
            [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
        }];
       // }
    } else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}

-(void) removeProfilePic {
     [_imgProfile sd_setImageWithURL:[UIImage imageNamed:@"DefaultUserIcon"] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
}

-(void)selectedImageIndex:(ImageParticipantCell *)cell selectDict:(NSMutableDictionary *)dict {
    if (_isFrozenChannel == true || isGroupActivated == true) {
   
    }else{
        GalleryDetailsShareVC *_galleryVC = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"GroupDetailsVC"];
        _galleryVC.dictGalleryInfo = dict;
       [self.navigationController pushViewController:_galleryVC animated:YES];
    }
}

-(void)didReceivedImage:(NSNotification *)notification {
    [self pushToGroupDetailsVC];
}

- (void)pushToReportsViewController {
    ReportsViewController *_vcChangePwd = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"ReportsViewController"];
    _vcChangePwd.dictGroupInfo = _dictGroupInfo;
    [self.navigationController pushViewController:_vcChangePwd animated:YES];
}

- (void)pushToGroupDetailsVC {
    GalleryDetailsShareVC *_vcmanageNotification = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"GroupDetailsVC"];
   [self.navigationController pushViewController:_vcmanageNotification animated:YES];
}

-(void)didReceivedGroupEvent:(NSNotification *)notification {
    NSLog (@"Successfully received the Group Event notification! %@",[notification userInfo]);
    NSDictionary *data = [notification userInfo];
    NSString *groupId = [NSString stringWithFormat:@"%@",self.dictGroupInfo[Group_GroupId]];
    if ([groupId isEqualToString:data[Group_GroupId]]) {
        if (data && data[@"eventList"] && [data[@"eventList"] isKindOfClass:NSArray.class]){
            NSDictionary *eventObj =  [(NSArray*)data[@"eventList"] firstObject];
            
            if (eventObj[@"eventType"] != nil && eventObj[@"eventType"] != [NSNull null]) {
                if ([eventObj[@"eventType"] isEqualToString:@"frozen"]) {
                    self->_isFrozenChannel = true;
                    [self Frozen_Channel:true];
                }else if ([eventObj[@"eventType"] isEqualToString:@"unfrozen"]) {
                    self->_isFrozenChannel = false;
                    [self Frozen_Channel:false];
                }else if ([eventObj[@"eventType"] isEqualToString:@"deactivated"]) {
                    [self showDeactivated:true];
                    self->isGroupActivated = true;
                    [_dictGroupInfo setValue:@true forKey:@"isActivated"];
                }else if ([eventObj[@"eventType"] isEqualToString:@"activated"]) {
                    [deactivatedView removeFromSuperview];
                    [self showDeactivated:false];
                    [_dictGroupInfo setValue:@false forKey:@"isActivated"];
                    self->isGroupActivated = false;
                }
            }
            NSString *reMoveProfile = eventObj[@"eventType"];
            if ([reMoveProfile isEqualToString:ProfilePicChanged])
            {
                NSDictionary *changeData = eventObj[@"eventData"][@"changeData"];
                NSDictionary *profilePicThumb = changeData[@"profilePicThumb"];
                NSString *imageURL = [NSString stringWithFormat:@"%@",profilePicThumb[@"new"]];
                NSString *strUrl = [imageBaseUrl stringByAppendingString:imageURL];
                [_imgProfile sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
                [self->_btnCamera setImage: nil forState: UIControlStateNormal];
                self->_isImageSet = YES;
            }else{
                //[_imgProfile sd_setImageWithURL:[UIImage imageNamed:@"DefaultUserIcon"] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
            }
            if ([eventObj[@"eventType"] isEqualToString:@"participantsAdded"]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self callApiGetGroupByGroupId:TRUE];
                });
            }else if ([eventObj[@"eventType"] isEqualToString:@"participantsRemoved"]) {
                NSArray *eventTriggeredOnUserList = eventObj[@"eventData"][@"eventTriggeredOnUserList"];
                if (eventTriggeredOnUserList && [eventTriggeredOnUserList isKindOfClass:NSArray.class]){
                    NSDictionary*dictuser = eventTriggeredOnUserList[0];
                    for (int i = 0; i < [self->_aryParticipants count]; i++)
                    {
                        NSMutableDictionary * user = [NSMutableDictionary new];
                        user = [_aryParticipants objectAtIndex:i];
                        if ([user[User_eRTCUserId] isEqualToString:dictuser[User_eRTCUserId]]) {
                            [_aryParticipants removeObject:user];
                            [_tblInfo reloadData];
                        }
                    }
                }
            }else if ([eventObj[@"eventType"] isEqualToString:@"adminMade"]) {
                NSArray *eventTriggeredOnUserList = eventObj[@"eventData"][@"eventTriggeredOnUserList"];
                if (eventTriggeredOnUserList && [eventTriggeredOnUserList isKindOfClass:NSArray.class]){
                    NSDictionary*dictuser = eventTriggeredOnUserList[0];
                    for (int i = 0; i < [self->_aryParticipants count]; i++)
                    {
                        NSMutableDictionary * user = [NSMutableDictionary new];
                        user = [_aryParticipants objectAtIndex:i];
                        if ([user[User_eRTCUserId] isEqualToString:dictuser[User_eRTCUserId]]) {
                            NSDictionary *dictData = [NSMutableDictionary new];
                            [dictData setValue:@"admin" forKey:@"role"];
                            
                            if (user[User_eRTCUserId] != nil && user[User_eRTCUserId] != [NSNull null]) {
                                [dictData setValue:user[User_eRTCUserId] forKey:User_eRTCUserId];
                            }
                            
                            if (user[App_User_ID] != nil && user[App_User_ID] != [NSNull null]) {
                                [dictData setValue:user[App_User_ID] forKey:App_User_ID];
                            }
                            
                            if (user[JoinedAtDate] != nil && user[JoinedAtDate] != [NSNull null]) {
                                [dictData setValue:user[JoinedAtDate] forKey:JoinedAtDate];
                            }
                            
                            if (user[User_Name] != nil && user[User_Name] != [NSNull null]) {
                                [dictData setValue:user[User_Name] forKey:User_Name];
                            }
                            
                           // [user setValue:@"admin" forKey:@"role"];
                            [_aryParticipants replaceObjectAtIndex:i withObject:dictData];
                            
                            [_tblInfo reloadData];
                        }
                    }
                }
            }else if ([eventObj[@"eventType"] isEqualToString:@"adminDismissed"]) {
                NSArray *eventTriggeredOnUserList = eventObj[@"eventData"][@"eventTriggeredOnUserList"];
                if (eventTriggeredOnUserList && [eventTriggeredOnUserList isKindOfClass:NSArray.class]){
                    NSDictionary*dictuser = eventTriggeredOnUserList[0];
                    for (int i = 0; i < [self->_aryParticipants count]; i++)
                    {
                        NSMutableDictionary * user = [NSMutableDictionary new];
                        user = [_aryParticipants objectAtIndex:i];
                        if ([user[User_eRTCUserId] isEqualToString:dictuser[User_eRTCUserId]]) {
                            [user setValue:@"user" forKey:@"role"];
                            [_aryParticipants replaceObjectAtIndex:i withObject:user];
                            [_tblInfo reloadData];
                        }
                    }
                }
            }
        }
    }
}

#pragma mark API
-(void)callAPIForUpdateGroupInfo:(UIImage *)updatedImage {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        NSMutableDictionary*dictParam = [[NSMutableDictionary alloc]init];
        [KVNProgress show];
        
//        if (self.aryParticipants.count > 0 && [self.aryParticipants valueForKey:App_User_ID] != nil) {
//            [dictParam setValue:[self.aryParticipants valueForKey:App_User_ID] forKey:Group_Participants];
//        }
//        [dictParam setValue:_tfGroupSubject.text forKey:Group_Name];
        
//        if (_tfGroupDecription.text.length>0) { [dictParam setValue:_tfGroupDecription.text forKey:Group_description];}
        
//        [dictParam setValue:@"private" forKey:Group_Type];
        NSData *groupProfileData = UIImageJPEGRepresentation(updatedImage, 1.0);
        [dictParam setValue:self.dictGroupInfo[@"groupId"] forKey:Group_GroupId];
        [[eRTCChatManager sharedChatInstance] CreatePrivateGroup:dictParam withGroupImage:groupProfileData  andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            [KVNProgress dismiss];
            NSDictionary *dictResponse = (NSDictionary *)json;
            if (dictResponse[@"success"] != nil) {
                BOOL success = (BOOL)dictResponse[@"success"];
                if (success) {
                    if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *result = (NSDictionary *)dictResponse[@"result"];
                        if ([result count]>0){
                            [Helper showAlertOnController:@"eRTC" withMessage:@"Group Profile Update successfully." onController:self];
                            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateGroupProfileSuccessfully object:result];
//                            [self.navigationController popViewControllerAnimated:<#(BOOL)#>];
                            return;
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
    }else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
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

#pragma mark Private
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
        if (_indexOfLoggedUser == indexPath.row) { return; }
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

- (void) takeImageFromCamera{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"Device has no camera.", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == AVAuthorizationStatusAuthorized) {
          // do your logic
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:nil];
            
        } else if(authStatus == AVAuthorizationStatusDenied ||  authStatus == AVAuthorizationStatusRestricted){
          // denied
            [self.view makeToast:@"Please enable the camera permissions."];
        } else if(authStatus == AVAuthorizationStatusNotDetermined){
          // not determined?!
          [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            if(granted){
              NSLog(@"Granted access to %@", mediaType);
            } else {
              NSLog(@"Not granted access to %@", mediaType);
            }
          }];
        }
    }
}

- (void) takeImageFromLibrary {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)pushToNotificationVC {
    if (_isEditModeOn) {
        UIViewController * vc = [UIViewController new];
        ChannelPrivacyViewController *_channelVC = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"ChannelPrivacyViewController"];
        _channelVC.isEditModeOn = TRUE;
        _channelVC.groupId = _dictGroupInfo[Group_GroupId];
        _channelVC.privacyKeyType = self.dictGroupInfo[@"groupType"];
        [_channelVC setModalPresentationStyle:UIModalPresentationFullScreen];
        [_channelVC setCompletion:^(BOOL isEdit, NSMutableDictionary * _Nullable dictInfo) {
            if (isEdit) {
                self.dictGroupInfo = dictInfo;
                [self reloadInputViews];
            }
        }];
        vc = _channelVC;
    [self presentViewController:_channelVC animated:TRUE completion:Nil];
    }else{
        if ([self.dictGroupInfo isKindOfClass:[NSDictionary class]]){
            if  (![Helper stringIsNilOrEmpty:self.dictGroupInfo[ThreadID]]) {
                [self pushToManageNotification];
//                   NotificationSettingViewController *_vcProfile = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"NotificationSettingViewController"];
//                   _vcProfile.isFromGroup = YES;
//                   _vcProfile.strGroupThreadID = self.dictGroupInfo[ThreadID];
//                   [self.navigationController pushViewController:_vcProfile animated:YES];
            }
        }
    }
}

- (void)pushToManageNotification {
   ManageNotificationVC *_vcmanageNotification = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"ManageNotificationVC"];
    _vcmanageNotification.strGroupThread = _dictGroupInfo[ThreadID];
   [self.navigationController pushViewController:_vcmanageNotification animated:YES];
}

#pragma mark Table Delegate and DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _isLoggedUserAdmin? 4 : 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 40;
    }else if (section == 1) {
        return 40;
    }else if (section == 3) {
        return 40;
    }
    return 0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tblInfo.bounds.size.width, 40)];
  UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 7, _tblInfo.bounds.size.width-48, 20)];
   CGRect buttonFrame = CGRectMake(_tblInfo.bounds.size.width-86, 0, 70, 40 );
    UIButton *btnViewAll = [[UIButton alloc] initWithFrame: buttonFrame];
    UIButton *btnParticipants = [[UIButton alloc] initWithFrame: buttonFrame];
    [btnViewAll setTitle: @"View All" forState: UIControlStateNormal];
    [btnViewAll addTarget:self action:@selector(btnViewAllAction:) forControlEvents:UIControlEventTouchUpInside];
    [btnViewAll setTitleColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
    
    [btnParticipants setTitle: @"View All" forState: UIControlStateNormal];
    [btnParticipants addTarget:self action:@selector(btnViewAllParticipants:) forControlEvents:UIControlEventTouchUpInside];
    [btnParticipants setTitleColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
    
  [headerView setBackgroundColor:[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0]];
  [headerTitle setTextColor:[UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0]];
  [headerTitle setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:14.0]];
   
    if (section == 1) {
        NSString *participants = [NSString stringWithFormat:@"%lu %@", (unsigned long)self.aryParticipants.count, NSLocalizedString(@"Participants", nil)];
        [headerTitle setText:participants];
        [headerView addSubview:btnParticipants];
    }else if (section == 3){
        [headerTitle setText:@"Images & Videos"];
        [headerView addSubview:btnViewAll];
       // [headerView addSubview:btnParticipants];
    }
     [headerView addSubview:headerTitle];
  return headerView;
}

/*
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        [_lblParticipants setTextColor:[UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0]];
        [_lblParticipants setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:14.0]];
        [_viewParticipants setBackgroundColor:[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0]];
        NSString *participants = [NSString stringWithFormat:@"%lu %@", (unsigned long)self.aryParticipants.count, NSLocalizedString(@"Participants", nil)];
        [_lblParticipants setText:participants];
        return _viewParticipants;
    }else if (section == 3) {
        [_lblParticipants setTextColor:[UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0]];
        [_lblParticipants setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:14.0]];
        [_viewParticipants setBackgroundColor:[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0]];
        NSString *participants = @"Images & Videos";
        [_lblParticipants setText:participants];
        return _viewParticipants;
    }
    return [UIView new];
}*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *groupType = _dictGroupInfo[Group_Type];
   // if (_isLoggedUserAdmin == true && [groupType isEqualToString:Private]) {
    if (indexPath.section == 0) {
        return 65;
    }else if (indexPath.section == 1 || indexPath.section == 2) {
        return 56;
    }else if (indexPath.section == 3) {
        return 240;
    }
    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *groupType = _dictGroupInfo[Group_Type];
     if ([groupType isEqualToString:Private]) {
    if (section == 0) {
        return 4;
    }else if (section == 1 && _isLoggedUserAdmin == true){
        return 1;
    }else if (section == 1 && _isLoggedUserAdmin == false) {
        return 0;
    }else if (section == 2){
        if (self.aryParticipants.count == 1)
        {
            return 1;
        }
        else if (self.aryParticipants.count == 2)
        {
            return 2;
        }
        else if (self.aryParticipants.count >= 3)
        {
            return 3;
        }
        return 3;
        //return self.aryParticipants.count;
    }else if (section == 3) {
        return 1;
    }
 }else if ([groupType isEqualToString:Public]) {
     if (section == 0) {
         return 4;
     }else if (section == 1 ){
         return 1;
     }else if (section == 2){
         if (self.aryParticipants.count == 1)
         {
             return 1;
         }
         else if (self.aryParticipants.count == 2)
         {
             return 2;
         }
         else if (self.aryParticipants.count >= 3)
         {
             return 3;
         }
         return 3;
     }else if (section == 3) {
         return 1;
     }
 }
         
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *groupType = _dictGroupInfo[Group_Type];
    if (indexPath.section == 0) {
        if (indexPath.row == 0 || indexPath.row == 1) {
            BasicInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BasicInfoTableViewCell"];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            switch (indexPath.row) {
                case 0:
                    [cell.lblTitle setText:NSLocalizedString(@"Channel Name", nil)];
                    if (self.dictGroupInfo[@"name"]) {
                        [cell.lblSubTitle setText:[NSString stringWithFormat:@"%@",self.dictGroupInfo[@"name"]]];
                    }
                    break;
                case 1:
                    [cell.lblTitle setText:NSLocalizedString(@"Channel Description", nil)];
                    if (self.dictGroupInfo[@"description"]) {
                        [cell.lblSubTitle setText:[NSString stringWithFormat:@"%@",self.dictGroupInfo[@"description"]]];
                    }
                    break;
                default:
                    break;
            }
          
            return cell;
        }else if (indexPath.row == 2) {
                ActionInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActionInfoTableViewCell"];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                if (_isEditModeOn) {
                    cell.switchActionable.hidden = YES;
                    cell.imgRight.hidden = YES;
                    switch (indexPath.row) {
                        case 2:
                            [cell.lblTitle setText:NSLocalizedString(@"Channel Privacy", nil)];
                            [cell.lblSubTitle setText:NSLocalizedString(_dictGroupInfo[Group_Type], nil)];
                            [cell.lblSubTitle setTextColor:UIColor.blackColor];
                            break;
                        default:
                            break;
                    }
                }else{
                    cell.switchActionable.hidden = YES;
                    cell.imgRight.hidden = NO;
                    switch (indexPath.row) {
                        case 2:
                            [cell.lblTitle setText:NSLocalizedString(@"Notifications", nil)];
                            [cell.lblSubTitle setText:NSLocalizedString(@"Turn off notifications for this group", nil)];
                            [cell.lblSubTitle setTextColor:UIColor.blackColor];
                            break;
                        default:
                            break;
                    }
                }
            return cell;
        }else if ( indexPath.row == 3){
            InfoStaredCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InfoStaredCell"];
           // cell.img.image = [UIImage imageNamed:@"favNew"];
            //cell.lblPlaceholder.text = @"";
            //cell.lblTitle.text =@"Starred Messages";
            return cell;
        }
    }else if (indexPath.section == 1){
        AddParticipantsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddParticipantsTableViewCell"];
        [cell.lblTitle setText:NSLocalizedString(@"Add Participants", nil)];
        return cell;
    }else if (indexPath.section == 2) {
        ParticipantInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ParticipantInfoTableViewCell"];
        [cell.btnRole setHidden:YES];
        [cell.btnRole setTitle:@"" forState:UIControlStateNormal];
        
        if (self.aryParticipants.count>indexPath.row) {
            NSLog(@"aryParticipants access to %@", _aryParticipants);
            NSDictionary * dict = [self.aryParticipants objectAtIndex:indexPath.row];
            
            NSString *role;
            if (dict[@"role"] != nil && dict[@"role"] != [NSNull null] && [dict[@"role"] isKindOfClass:[NSString class]]) {
                role = [NSString stringWithFormat:@"%@", dict[@"role"]];
                if ([role.lowercaseString isEqualToString:@"admin"]) {
                    [cell.btnRole setHidden:NO];
                    [cell.btnRole setImage:[UIImage imageNamed:@"adminIcon"] forState:UIControlStateNormal];
                   // [cell.btnRole setBackgroundColor:[self colorWithHexString:@"e1e2e4"]];
                   // cell.btnRole.layer.cornerRadius = cell.btnRole.frame.size.height/2;
                   // [cell.btnRole setTitle:NSLocalizedString(@"Admin", nil) forState:UIControlStateNormal];
                }
            }
            
            if (dict[App_User_ID] != nil && dict[User_eRTCUserId] != [NSNull null]) {
                NSString *appUserID = [NSString stringWithFormat:@"%@", dict[App_User_ID]];
                if ([appUserID isEqualToString:_strAppLoggedInUserID]){
                    cell.lblName.text = NSLocalizedString(@"You", nil);
                }else {
                    cell.lblName.text = dict[User_Name];
                }
            }
            
            if (dict[App_User_ID] != nil && dict[App_User_ID] != [NSNull null]) {
                cell.lblEmail.text = dict[App_User_ID];
                cell.lblEmail.textColor = [Helper colorWithHexString:@"5691C8"];
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
        }
        
        [cell.lblSeprater setHidden:(indexPath.row+1==self.aryParticipants.count)];
        return cell;
    }else if (indexPath.section == 3) {
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
    if (_isFrozenChannel == true || isGroupActivated == true) {
   
    }else{
        if (indexPath.section == 0 ) {
            if (indexPath.row == 2) {
                [self pushToNotificationVC];
                return;
            }
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle bundleForClass:EditGroupSubjectViewController.class]];
            UIViewController * vc = [UIViewController new];
            if (indexPath.row == 0) {
                EditGroupSubjectViewController *vcEGS = [story instantiateViewControllerWithIdentifier:NSStringFromClass(EditGroupSubjectViewController.class)];
                [vcEGS setDictGroupInfo:self.dictGroupInfo];
                [vcEGS setCompletion:^(BOOL isEdit, NSMutableDictionary * _Nullable dictInfo) {
                    if (isEdit) {
                        self.dictGroupInfo = dictInfo;
                        [self reloadInputViews];
                        [self setupImageView];
                    }
                }];
                vc = vcEGS;
            }else if (indexPath.row == 1) {
                EditGroupDescriptionViewController *vcEGD = [story instantiateViewControllerWithIdentifier:NSStringFromClass(EditGroupDescriptionViewController.class)];
                [vcEGD setDictGroupInfo:self.dictGroupInfo];
                [vcEGD setCompletion:^(BOOL isEdit, NSMutableDictionary * _Nullable dictInfo) {
                    if (isEdit) {
                        self.dictGroupInfo = dictInfo;
                        [self reloadInputViews];
                        [self setupImageView];
                    }
                }];
                vc = vcEGD;
            }else if (indexPath.row == 3){
                StarredMessageViewController * _vcStarredMessage = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"StarredMessageViewController"];
                _vcStarredMessage.dictUserDetails = self.dictGroupInfo;
                _vcStarredMessage.strThreadId = _dictGroupInfo[ThreadID];
                if ( self.dictGroupInfo[ThreadID] != nil){
                    _vcStarredMessage.strThreadId = self.dictGroupInfo[ThreadID];
                }
                [self.navigationController pushViewController:_vcStarredMessage animated:YES];
                return;
            }
            UINavigationController *ncEG = [[UINavigationController alloc] initWithRootViewController:vc];
            ncEG.modalPresentationStyle = UIModalPresentationFullScreen;
            // [self presentViewController:ncEG animated:YES completion:nil];
        }else if (indexPath.section == 1){
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
                    [self.navigationController popViewControllerAnimated:true];
                }
            }];
            vcNG.modalPresentationStyle = UIModalPresentationCurrentContext;
            [self.navigationController pushViewController:vcNG animated:true];
        }else if (indexPath.section == 1 || indexPath.section == 2) {
            NSDictionary * dict = [self.aryParticipants objectAtIndex:indexPath.row];
            NSString *appUserID = [NSString stringWithFormat:@"%@", dict[App_User_ID]];
            if (![appUserID isEqualToString:_strAppLoggedInUserID]){
                [self actionSheetForParticipantsWithIndexPath:indexPath];
            }
        }
    }
}
/*
#pragma mark Collection Delegate and DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 4;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageAndVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageAndVideoCell" forIndexPath:indexPath];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(103, 103);
}*/


#pragma mark ImagePicker Delegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [self dismissViewControllerAnimated:YES completion:^{
        UIImage *original = info[UIImagePickerControllerEditedImage];
        [self->_imgProfile setImage:original];
        self->_isImageSet = YES;
        self->imageReduced = [self reduceImageSize:original];
        [self->_btnCamera setSelected:!(self->_isImageSet)];
        [self callAPIForUpdateGroupInfo:original];
    }];
}

- (UIImage *)reduceImageSize:(UIImage *)image{
    CGSize size= CGSizeMake(640, 640);
    if (image.size.height < image.size.width)
    {
        float ratio = size.height / image.size.height;
        CGSize newSize = CGSizeMake(image.size.width * ratio, size.height);
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 1);
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    }
    else
    {
        float ratio = size.width / image.size.width;
        CGSize newSize = CGSizeMake(size.width, image.size.height * ratio);
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 1);
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    }
    UIImage *aspectScaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return aspectScaledImage;
}

- (void)leaveChannelPressButton:(BOOL)isAdmin strMessage:(NSString*)strTypeMsg
{
    if (isAdmin) {
        self->strAlertTitle = msgContinueGroup;
    }else{
        self->strAlertTitle = msgLeaveGroup;
    }
     UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Leave Channel?"
                                  message:strAlertTitle
                                 preferredStyle:UIAlertControllerStyleAlert];
   
    UIAlertAction* btnCancell = [UIAlertAction
                                actionWithTitle:@"Cancel"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                }];
    UIAlertAction* btnLeaveChannel = [UIAlertAction
                               actionWithTitle:@"Leave"
                               style:UIAlertActionStyleDestructive
                               handler:^(UIAlertAction * action) {
        [self callAPIForRemoveParticipant:nil andExitGroup:YES];
                               }];
    UIAlertAction* btnContinueChannel = [UIAlertAction
                               actionWithTitle:@"Continue"
                               style:UIAlertActionStyleDestructive
                               handler:^(UIAlertAction * action) {
        CreateNewAdminViewController * viewController =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CreateNewAdminViewController"];
        viewController.arrParticipants = _dictGroupInfo[@"participants"];
        viewController.groupId = _dictGroupInfo[Group_GroupId];
        [self.navigationController pushViewController:viewController animated:true];
                               }];
    //Add your buttons to alert controller
    [alert addAction:btnCancell];
    if (isAdmin) {
    [alert addAction:btnContinueChannel];
    }else{
    [alert addAction:btnLeaveChannel];
    }
    [self presentViewController:alert animated:YES completion:nil];
}


-(void)didupdatePrivacyKey:(NSNotification *) notification{
    NSDictionary *privacyKey = notification.object;
    [_dictGroupInfo setValue:privacyKey forKey:Group_Type];
    
    [_tblInfo reloadData];
}

-(IBAction)btnViewAllAction:(id)sender{
    if (_isFrozenChannel == true || isGroupActivated == true) {
   
    }else{
    channelGalleryVC *vcChannel = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"channelGalleryVC"];
    vcChannel.dictGroupInfo = self.dictGroupInfo;
    [self.navigationController pushViewController:vcChannel animated:true];
    }
}

- (IBAction)btnBack:(UIBarButtonItem *)sender {
    if (_isEditModeOn) {
    [self isChangeNavigationTitle:false];
    [self reloadTableView];
    }else {
    [self.navigationController popViewControllerAnimated:TRUE];
    }
}

-(IBAction)btnViewAllParticipants:(id)sender{
    if (_isFrozenChannel == true || isGroupActivated == true) {
   
    }else{
    [self pushToGroupMemberViewController];
    }
}


- (void)pushToGroupMemberViewController {
    GroupMemberViewController *_vcGroup = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"GroupMemberViewController"];
    _vcGroup.aryParticipants = self.aryParticipants;
    _vcGroup.dictGroupInfo = self.dictGroupInfo;
    _vcGroup.isLogged = _isLoggedUserAdmin;
    [self.navigationController pushViewController:_vcGroup animated:YES];
     
}

- (void)pressClearChatHistory
{
     UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Clear Chat History?"
                                 message:msgClearChatHistory
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Cancel"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                }];
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Clear"
                               style:UIAlertActionStyleDestructive
                               handler:^(UIAlertAction * action) {
        [self clearChatHistory];
                               }];
    //Add your buttons to alert controller
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
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
-(void) callUpdateByGroupParticipants {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
        NSMutableDictionary*dictParam = [[NSMutableDictionary alloc]init];
        [dictParam setValue:self.dictGroupInfo[@"groupId"] forKey:Group_GroupId];
        [dictParam setValue:self.dictGroupInfo[Group_Name] forKey:Group_Name];
        [dictParam setValue:self.dictGroupInfo[Group_Type] forKey:Group_Type];
        [dictParam setValue:self.dictGroupInfo[Group_description] forKey:Group_description];
        if (self.aryParticipants.count > 0 && [self.aryParticipants valueForKey:App_User_ID] != nil) {
            [dictParam setValue:[self.aryParticipants valueForKey:App_User_ID] forKey:Group_Participants];
        }
        [[eRTCChatManager sharedChatInstance]
         updateGroup:dictParam  andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            
             [KVNProgress dismiss];
             NSDictionary *dictResponse = (NSDictionary *)json;
             if (dictResponse[@"success"] != nil) {
                 BOOL success = (BOOL)dictResponse[@"success"];
                 if (success) {
                     if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                         NSDictionary *result = (NSDictionary *)dictResponse[@"result"];
                         if ([result count]>0) {
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


#pragma mark API
-(void)callAPIForUpdateGroup {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
        NSMutableDictionary*dictParam = [[NSMutableDictionary alloc]init];
        [dictParam setValue:self.dictGroupInfo[@"groupId"] forKey:Group_GroupId];
        [dictParam setValue:self.dictGroupInfo[Group_Name] forKey:Group_Name];
        [dictParam setValue:self.dictGroupInfo[Group_Type] forKey:Group_Type];
        [dictParam setValue:self.dictGroupInfo[Group_description] forKey:Group_description];
        if (self.aryParticipants.count > 0 && [self.aryParticipants valueForKey:App_User_ID] != nil) {
            [dictParam setValue:[self.aryParticipants valueForKey:App_User_ID] forKey:Group_Participants];
        }
        NSData *groupProfileData = UIImageJPEGRepresentation(_imgProfile.image, 1.0);
        
        [[eRTCChatManager sharedChatInstance] CreatePrivateGroup:dictParam withGroupImage:groupProfileData  andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            
            [KVNProgress dismiss];
            NSDictionary *dictResponse = (NSDictionary *)json;
            if (dictResponse[@"success"] != nil) {
                BOOL success = (BOOL)dictResponse[@"success"];
                if (success) {
                    if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *result = (NSDictionary *)dictResponse[@"result"];
                        if ([result count]>0){
                            
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
    }else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}

-(void)goBacktoGroupList{

}


- (void)ExitGroupChannelPressButton
{
     UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Delete Channel?"
                                 message:@"Are you sure you want to delete this channel?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Cancel"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                }];
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Delete"
                               style:UIAlertActionStyleDestructive
                               handler:^(UIAlertAction * action) {
        [self callAPIForRemoveParticipant:nil andExitGroup:YES];
                               }];
    //Add your buttons to alert controller
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)callApiforGetGalleryData {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
        NSMutableDictionary *details = @{}.mutableCopy;
        [details setValue:@20 forKey:@"pageSize"];
        [details setValue:@"true" forKey:@"deep"];
        [[eRTCChatManager sharedChatInstance] chatHistoryGet:_dictGroupInfo[ThreadID] parameters:details.copy
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
                               _tblInfo.reloadData;
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
    }
}

-(void)didReceivedInvitationInfo:(NSNotification *) notification{
    NSDictionary *dictUserInfo = notification.object;
    self.dictGroupInfo = [NSMutableDictionary dictionaryWithDictionary:dictUserInfo];
     [self.vwInvitationSent setHidden:false];
        NSTimeInterval delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.vwInvitationSent setHidden:TRUE];
        });
    [self setupTableView];
  
}

-(void)callApiGetGroupByGroupId:(BOOL)isUpdate {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        NSMutableDictionary*dict = [[NSMutableDictionary alloc]init];
        //[KVNProgress show];
        if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_ID] != nil) {
            [dict setValue:self.dictGroupInfo[Group_GroupId] forKey:Group_GroupId];
            [[eRTCChatManager sharedChatInstance] getGroupByGroupId:dict andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
               // [KVNProgress dismiss];
                NSDictionary *dictResponse = (NSDictionary *)json;
                if (dictResponse[@"success"] != nil) {
                    BOOL success = (BOOL)dictResponse[@"success"];
                    if (success) {
                        if (isUpdate){
                            NSDictionary *result = (NSDictionary *)dictResponse[@"result"];
                            if (result.count>0) {
                                self.dictGroupInfo = [[NSMutableDictionary alloc] initWithDictionary:result];
                                [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:YES];
                            }
                        }else{
                        if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *result = (NSDictionary *)dictResponse[@"result"];
                            EditChannelInfo *vcEditChannelInfo = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"EditChannelInfo"];
                            vcEditChannelInfo.dictEditInfo = [NSMutableDictionary dictionaryWithDictionary:result];
                            [self.navigationController pushViewController:vcEditChannelInfo animated:YES];
                            return;
                        }
                            
                        }
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



-(void)Frozen_Channel:(BOOL *)isFrozenChannel {
    if (isFrozenChannel) {
        NSTimeInterval delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        CGFloat topbarHeight = ([UIApplication sharedApplication].statusBarFrame.size.height +
               (self.navigationController.navigationBar.frame.size.height ?: 0.0));
            self->frozenView = [[UIView alloc] initWithFrame:CGRectMake(0, topbarHeight, self.view.bounds.size.width, 64)];
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(48, 5, self.view.bounds.size.width-54, 60)];
        UIImageView *imageNowifi = [[UIImageView alloc] initWithFrame:CGRectMake(16, 20, 24, 24)];
        
            [self->frozenView setBackgroundColor:[UIColor colorWithRed:255/255.0 green:237/255.0 blue:237/255.0 alpha:1]];
        lblTitle.textColor = UIColor.redColor;
        lblTitle.text = @"This channel is currently frozen, and you are unable to send messages or share media.";
        [imageNowifi setImage:[UIImage imageNamed:@"FrozenChannel"]];
        
        [lblTitle setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:16.0]];
        lblTitle.numberOfLines = 0;
        lblTitle.textAlignment = NSTextAlignmentLeft;
            [self->frozenView addSubview:lblTitle];
            [self->frozenView addSubview:imageNowifi];
            [self.view addSubview:self->frozenView];
        });
        
    }else{
        [frozenView removeFromSuperview];
        
    }
}

-(void)showDeactivated:(BOOL *)isDeactivated {
    if (isDeactivated) {
        NSTimeInterval delayInSeconds = 0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self->deactivatedView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-70, self.view.bounds.size.width, 200)];
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 70)];
        [self->deactivatedView setBackgroundColor:UIColor.redColor];
            lblTitle.textColor = UIColor.whiteColor;
            lblTitle.text = @"Group has been deactivated by admin";
            lblTitle.textAlignment = NSTextAlignmentCenter;
        [lblTitle setFont:[UIFont fontWithName:@"SFProDisplay-Semibold" size:18.0]];
        lblTitle.numberOfLines = 0;
            [self->deactivatedView addSubview:lblTitle];
           [self.view addSubview:self->deactivatedView];
        });
    }else{
        self->deactivatedView.alpha = 1;
        [deactivatedView removeFromSuperview];
    }
}

@end
