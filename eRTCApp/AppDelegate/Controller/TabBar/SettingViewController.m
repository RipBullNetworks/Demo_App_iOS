//
//  SettingViewController.m
//  eRTCApp
//
//  Created by rakesh  palotra on 26/12/18.
//  Copyright © 2018 Ripbull Network. All rights reserved.
//

#import "SettingViewController.h"
#import "GlobalSearchSettingCell.h"
#import "LoginViewController.h"
#import "ChangePasswordViewController.h"
#import "MyProfileViewController.h"
#import "NotificationSettingViewController.h"
#import "GlobalSearchSettingCell.h"
#import "PreferencesVC.h"
#import "ReportsViewController.h" 
#import "DraftsControllerVC.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "ManageNotificationVC.h"


//PreferencesVC
@interface SettingViewController ()<UITableViewDelegate, UITableViewDataSource,MFMailComposeViewControllerDelegate,globalSearchDelegate> {
    
    __weak IBOutlet UITableView *tblSetting;
    NSArray *arrSetting;
    NSString *strThreadId;
    BOOL  isShowLogsButton;
}

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [tblSetting registerNib:[UINib nibWithNibName:@"GlobalSearchSettingCell" bundle:nil] forCellReuseIdentifier:@"GlobalSearchSettingCell"];
    
    NSString *appUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
    if (appUserId){
        [[eRTCAppUsers sharedInstance] fetchUserDetailByAppUserId:appUserId andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            NSLog(@"json>>>>>>>>>>>>>>>>%@",json);
        } andFailure:^(NSError * _Nonnull error) {
        }];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self->isShowLogsButton = false;
    NSDictionary *dictConfig = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
    if ([dictConfig isKindOfClass:[NSDictionary class]]){
        if ([dictConfig[ProductionEnable] isEqual:@1]) {
            self->isShowLogsButton = true;
        }
    }
    [self configureNavigationBar];
}

- (void)configureNavigationBar {
    self.navigationItem.title = @"Profile";
    
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
    } else {
    }
    
}
#pragma mark - UITableView Delegates and DataSource
-(void) globalSearchSwitchDidChange: (UISwitch*) sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"isGlobalSearchEnable"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (isShowLogsButton == true) {
        return 5;
    }else{
        return 6;
    }
    
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil) {
        if (indexPath.row == 3) {
            GlobalSearchSettingCell *_cell = [tableView dequeueReusableCellWithIdentifier:@"GlobalSearchSettingCell"];
            BOOL isGlobalSearchEnable = [[NSUserDefaults standardUserDefaults] boolForKey:@"isGlobalSearchEnable"];
            [_cell.btnSwitch setOn:isGlobalSearchEnable];
            _cell.delegate = self;
            return _cell;
        }else{
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyIdentifier"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.font = [UIFont fontWithName:@"SFProDisplay-Medium" size:16];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"My Profile";
            cell.imageView.image = [UIImage imageNamed:@"Profile"];
            break;
        case 1:
            cell.textLabel.text = @"Manage Notifications";
            cell.imageView.image = [UIImage imageNamed:@"notification"];
            break;
        case 2:
            cell.textLabel.text = @"Change Password";
            cell.imageView.image = [UIImage imageNamed:@"Password"];
            break;
        case 3:
            break;
        case 4:
            cell.textLabel.text = @"Logout";
            cell.imageView.image = [UIImage imageNamed:@"logout"];
            break;
        case 5:
            cell.textLabel.text = @"Send logs via Email";
            cell.imageView.image = [UIImage imageNamed:@"profileEmail"];
        default:
            break;
    }
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            [self pushToMyProfile];
            break;
        case 1:
            [self pushToManageNotification];
            break;
        case 2:
            [self pushToChangePassword];
            break;
        case 3:
            break;
        case 4:
            [self logoutButtonPressed];
            break;
        case 5:
            [self sendLogsViewEmail];
            break;
        default:
            break;
    }
}

-(void)globalSearchSwitch:(bool)isGlobalSearch {
    [[NSUserDefaults standardUserDefaults] setBool:isGlobalSearch forKey:@"isGlobalSearchEnable"];
}

- (void)pushToChangePassword {
    ChangePasswordViewController *_vcChangePwd = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"ChangePasswordViewController"];
    [self.navigationController pushViewController:_vcChangePwd animated:YES];
}

- (void)pushToPreferencesVC {
    PreferencesVC *_vcChangePwd = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"PreferencesVC"];
    [self.navigationController pushViewController:_vcChangePwd animated:YES];
}

- (void)pushToDraftsVC {
    DraftsControllerVC *_vcChangePwd = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"DraftsControllerVC"];
    [self.navigationController pushViewController:_vcChangePwd animated:YES];
}

- (void)pushToMyProfile {
    MyProfileViewController *_vcProfile = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"MyProfileViewController"];
    [self.navigationController pushViewController:_vcProfile animated:YES];
}

- (void)pushToNotification {
    NotificationSettingViewController *_vcProfile = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"NotificationSettingViewController"];
    _vcProfile.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:_vcProfile animated:YES];
}

- (void)pushToReportsViewController {
    ReportsViewController *_vcChangePwd = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"ReportsViewController"];
    [self.navigationController pushViewController:_vcChangePwd animated:YES];
}

-(void)sendLogsViewEmail {
    NSString *txtFilePath = [LogFile getLogFilePath];
    
    if ([MFMailComposeViewController canSendMail])
    {
        NSString *txtFilePath = [LogFile getLogFilePath];
        NSData *noteData = [NSData dataWithContentsOfFile:txtFilePath];
        MFMailComposeViewController *_mailController = [[MFMailComposeViewController alloc] init];
        [_mailController setSubject:[NSString stringWithFormat:@"eRTC Logs"]];
        [_mailController setMessageBody:@"Logs from eRTC" isHTML:NO];
        [_mailController setMailComposeDelegate:self];
        [_mailController addAttachmentData:noteData mimeType:@"text/plain" fileName:@"abc.txt"];
        [self presentViewController:_mailController animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)logoutButtonPressed
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:nil
                                 message:@"Are you sure you want to log out?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Cancel"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
        //Handle your yes please button action here
    }];
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Log out"
                               style:UIAlertActionStyleDestructive
                               handler:^(UIAlertAction * action) {
        [self logOutUser];
    }];
    //Add your buttons to alert controller
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)logOutUser{
    NSString *apiKey = [[NSUserDefaults standardUserDefaults]
        stringForKey:@"API_Key"];
    NSString *nameSpace = [[NSUserDefaults standardUserDefaults]
        stringForKey:@"nameSpace"];
    
    [KVNProgress show];
    [[eRTCAppUsers sharedInstance] logoutUserWithCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        [KVNProgress dismiss];
        [[NSUserDefaults standardUserDefaults]setValue:@"NO" forKey:RestorationAvailability];
        if(![Helper stringIsNilOrEmpty:json[Key_Success]] && [json[Key_Success] integerValue] == 1) {
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:IsLoggedIn];
            [[NSUserDefaults standardUserDefaults]setValue:@"NO" forKey:IsLoggedIn];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:IsRestoration];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[UserModel sharedInstance]logOutUser];
            [[AppDelegate sharedAppDelegate] willChangeLogoutAsRootOfApplication];
            [self clearSearchHistory];
            [[NSUserDefaults standardUserDefaults]setValue:apiKey forKey:@"API_Key"];
            [[NSUserDefaults standardUserDefaults]setValue:nameSpace forKey:@"nameSpace"];
            [[NSUserDefaults standardUserDefaults]setValue:@"isLogout" forKey:@"logOut"];
        }
    } andFailure:^(NSError * _Nonnull error) {
        [KVNProgress dismiss];
        if (error.code == 403) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:IsLoggedIn];
            [[NSUserDefaults standardUserDefaults]setValue:@"NO" forKey:IsLoggedIn];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:IsRestoration];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[UserModel sharedInstance]logOutUser];
            [[AppDelegate sharedAppDelegate] willChangeLoginAsRootOfApplication];
            [self clearSearchHistory];
        }
    }];
}


-(void)clearSearchHistory {
    NSString *appUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
    [[eRTCChatManager sharedChatInstance] getRecentChatData:appUserId withData:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        NSMutableArray *arrRecentSearch = [NSMutableArray new];
        arrRecentSearch = json;
        for (NSDictionary *dictRecentmessage in arrRecentSearch) {
            if (dictRecentmessage[MsgUniqueId] != nil && dictRecentmessage[MsgUniqueId] != [NSNull null]) {
            [[eRTCChatManager sharedChatInstance] deleterecentChatRecord:dictRecentmessage[MsgUniqueId]];
            }
        }
    } andFailure:^(NSError * _Nonnull error) {
    }];
}


- (void)pushToManageNotification {
   ManageNotificationVC *_vcmanageNotification = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"ManageNotificationVC"];
    _vcmanageNotification.strType = @"global";
   [self.navigationController pushViewController:_vcmanageNotification animated:YES];
}


@end
