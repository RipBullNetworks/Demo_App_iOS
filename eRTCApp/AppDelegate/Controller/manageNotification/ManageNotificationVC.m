

#import "ManageNotificationVC.h"
#import "manageNotificationCell.h"
#import <Toast/Toast.h>

@interface ManageNotificationVC ()<UITableViewDelegate, UITableViewDataSource> {
    UIBarButtonItem *ApplyBarButtonItem;
    NSInteger                                       _isIndexPath;
    NSInteger                                       _manageSelectedNotification;
    NSInteger                                       _isNotificationIndexPath;
    NSInteger                                       _isSection;
    NSString *notificationLevel;
    NSString *notificationSettings;
    NSString *applyNotification;
    NSString *notificationDays;
    NSMutableArray *arrSettingsData;
    BOOL                                       _isNotificationAlreadySave;
}

@end

@implementation ManageNotificationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    [self.navigationItem.backBarButtonItem setTitle:@""];
    self.navigationItem.title = @"Manage Notifications";
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
        
    } else {
        // Fallback on earlier versions
    }
    
    ApplyBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(applybtnAction:)];
    self.navigationItem.rightBarButtonItem=ApplyBarButtonItem;
    self->notificationLevel = All_Message;
    self->notificationDays = @"always";
    self->notificationSettings = [self selectedDateAccordingtoTime:@"0"];
    self.hgtConsTantView.constant = 0;
    
    if([_strType isEqualToString:@"global"]) {
        [self getGlobalNotificationData];
    }else{
        [self getManageNotification];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.tblManageNotification reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
    } else {
    }
    //self.navigationController.navigationBar.topItem.title = @"";
}

#pragma mark Table Delegate and DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self->notificationLevel isEqualToString:All_Message]){
        return 1;
    }else{
        return 2;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    }else if (section == 1) {
        return 6;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        if (indexPath.section == 0) {
    manageNotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"manageNotificationCell"];
            if (indexPath.row == 0) {
                cell.lblTitle.text = Manage_Allow_all.capitalizedString;
            }else if (indexPath.row == 1) {
                cell.lblTitle.text = Manage_Mentions_only.capitalizedString;
            }else if (indexPath.row == 2) {
                cell.lblTitle.text = Nothing_Message.capitalizedString;
            }
            if (_isIndexPath == indexPath.row) {
                [cell.imgCircle setImage:[UIImage imageNamed:@"radiocheck"]];
                cell.lblSetCustomNotification.text = @"";
            }else{
                [cell.imgCircle setImage:[UIImage imageNamed:@"radioUncheck"]];
                cell.lblSetCustomNotification.text = @"";
            }
        return  cell;
        }else if (indexPath.section == 1) {
    manageNotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"manageNotificationCell"];
            if (indexPath.row == 0) {
                cell.lblTitle.text = Nothing_Always.capitalizedString;
                self->_hgtConsTantView.constant = 0;
            }else if (indexPath.row == 1) {
                cell.lblTitle.text = Manage_OneDay;
            }else if (indexPath.row == 2) {
                cell.lblTitle.text = Manage_threeday;
            }else if (indexPath.row == 3) {
                cell.lblTitle.text = Manage_oneWeek;
            }else if (indexPath.row == 4) {
                cell.lblTitle.text = Manage_twoWeek;
            }else if (indexPath.row == 5) {
                cell.lblTitle.text = Manage_oneMonth;
            }
            
            if (_manageSelectedNotification == indexPath.row) {
            cell.lblSetCustomNotification.text = [self showTimeAccordingtoManage:_manageSelectedNotification];
            }else{
                if ([notificationDays isEqualToString:@"always"]) {
                    cell.lblSetCustomNotification.text == @"";
            }
        }
            if (_isNotificationIndexPath == indexPath.row) {
                [cell.imgCircle setImage:[UIImage imageNamed:@"radiocheck"]];
                NSString *srtTitle = [@"Note that after " stringByAppendingString:self->notificationDays];
                self->_lblTitle.text = [srtTitle stringByAppendingString:@" the notification settings will be reset to allow all."];
                    self->_hgtConsTantView.constant = 70;
                if (indexPath.row == 0) {
                self->_hgtConsTantView.constant = 0;
                }
            }else{
                [cell.imgCircle setImage:[UIImage imageNamed:@"radioUncheck"]];
                cell.lblSetCustomNotification.text = @"";
            }
        return  cell;
        }
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        _isIndexPath = indexPath.row;
        _isSection = indexPath.section;
        if (indexPath.row == 0) {
            self->notificationLevel = All_Message;
            self->_hgtConsTantView.constant = 0;
            self->notificationDays = @"always";
        }else if (indexPath.row == 1) {
            self->notificationLevel = Mention_Message;
        }else if (indexPath.row == 2) {
            self->_hgtConsTantView.constant = 0;
            self->notificationLevel = Nothing_Message;
            self->notificationSettings = [self selectedDateAccordingtoTime:@"0"];
        }
  
    }else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            self->notificationSettings = [self selectedDateAccordingtoTime:@"0"];
            self->notificationDays = @"always";
            self->_hgtConsTantView.constant = 0;
        }else if (indexPath.row == 1) {
            self->notificationSettings = [self selectedDateAccordingtoTime:@"1"];
            self->notificationDays = @"1 Day";
        }else if (indexPath.row == 2) {
            self->notificationSettings = [self selectedDateAccordingtoTime:@"3"];
            self->notificationDays = @"3 Days";
        }else if (indexPath.row == 3) {
            self->notificationSettings = [self selectedDateAccordingtoTime:@"7"];
            self->notificationDays = @"7 Days";
        }else if (indexPath.row == 4) {
            self->notificationSettings = [self selectedDateAccordingtoTime:@"14"];
            self->notificationDays = @"14 Days";
        }else if (indexPath.row == 5) {
            self->notificationSettings = [self selectedDateAccordingtoTime:@"30"];
            self->notificationDays = @"30 Days";
        }
        _isNotificationIndexPath = indexPath.row;
        _isSection = indexPath.section;
    }

    if ([notificationDays isEqualToString: @"always"]) {
        self.hgtConsTantView.constant = 0;
    }else{
       // self.hgtConsTantView.constant = 70;
        NSString *srtTitle = [@"Note that after " stringByAppendingString:self->notificationDays];
        self->_lblTitle.text = [srtTitle stringByAppendingString:@" the notification settings will be reset to allow all."];
    }
    [self.tblManageNotification reloadData];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tblManageNotification.bounds.size.width, 60)];
  UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 7, _tblManageNotification.bounds.size.width-32, 20)];
  [headerView setBackgroundColor:[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0]];
  [headerTitle setTextColor:[UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0]];
  [headerTitle setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:14.0]];
    if (section == 0) {
        [headerTitle setText:@"Notification level"];
    }else{
        [headerTitle setText:@"Apply settings for"];
    }
        [headerView addSubview:headerTitle];
  return headerView;
}


-(void)updateManageNotification:(NSString *)msgNotification  {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
        NSMutableDictionary * dictParam = [NSMutableDictionary new];
        NSMutableDictionary * dictNotification = [NSMutableDictionary new];
        [dictParam setValue:self->notificationLevel forKey:@"allowFrom"];
        [dictParam setValue:self->notificationSettings forKey:@"validTill"];
        if ([notificationDays isEqualToString:@"always"]) {
            [dictParam setValue:@"1 Days" forKey:@"validTillDisplayValue"];
        }else{
            [dictParam setValue:self->notificationDays forKey:@"validTillDisplayValue"];
        }
        [dictNotification setValue:dictParam forKey:@"notificationSettings"];
        [dictNotification setValue:self->_strGroupThread forKey:ThreadID];
        
        [[eRTCChatManager sharedChatInstance] updateManageNotification:dictNotification andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            [KVNProgress dismiss];
            NSDictionary *dictResponse = (NSDictionary *)json;
            NSLog(@"json >>>>>>>>>>%@",json);
            if (dictResponse[@"success"] != nil) {
                BOOL success = (BOOL)dictResponse[@"success"];
                if (success) {
                    [self.view makeToast:msgNotification];
                    [[NSUserDefaults standardUserDefaults] setObject:dictParam forKey:@"notificationSettings"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    NSTimeInterval delayInSeconds = 1.0;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [self.navigationController popViewControllerAnimated:true];
                    });
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


-(void)getManageNotification  {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
        NSMutableDictionary * dictNotification = [NSMutableDictionary new];
        [dictNotification setValue:self->_strGroupThread forKey:ThreadID];
        NSLog(@"dictNotification >>>>>>>>>>%@",dictNotification);
        [[eRTCChatManager sharedChatInstance] getManageNotification:dictNotification andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            [KVNProgress dismiss];
            NSDictionary *dictResponse = (NSDictionary *)json;
            NSLog(@"json >>>>>>>>>>%@",json);
            if (dictResponse[@"success"] != nil) {
                BOOL success = (BOOL)dictResponse[Key_Success];
                if (success) {
                    NSString *threadId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
                    if (dictResponse[Key_Result] != nil && dictResponse[Key_Result] != [NSNull null]) {
                        NSDictionary *dictNotify = dictResponse[Key_Result];
                        if (dictNotify[Group_Participants] != nil && dictNotify[Group_Participants] != [NSNull null]) {
                            NSArray *arrNotify = dictNotify[Group_Participants];
                            NSLog(@"arrNotify >>>>>>>>>>%@ %@",arrNotify,threadId);
                            for (NSDictionary *dictParticipants in arrNotify) {
                                NSString *user = dictParticipants[Key_user];
                                if ([threadId isEqualToString:user]) {
                                    if (dictParticipants[@"notificationSettings"] != nil && dictParticipants[@"notificationSettings"] != [NSNull null]) {
                                        NSDictionary *dictManagedNoti = dictParticipants[@"notificationSettings"];
                                        [self getManagedDataSet:dictManagedNoti];
                                    }
                                }
                            }
                        }
                    }
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


-(void)getManagedDataSet:(NSDictionary*) dictData {
    if (dictData[Manage_allowFrom] != nil && dictData[Manage_allowFrom] != [NSNull null]) {
        _isSection = 0;
        if ([dictData[Manage_allowFrom] isEqualToString:All_Message]) {
            _isIndexPath = 0;
            self->notificationDays = @"always";
        }else if ([dictData[Manage_allowFrom] isEqualToString:Mention_Message]) {
            _isIndexPath = 1;
        self->notificationDays = dictData[Manage_validTillDisplayValue];
        }else if ([dictData[Manage_allowFrom] isEqualToString:Nothing_Message]) {
            _isIndexPath = 2;
            self->notificationDays = @"none";
        }
        [self.tblManageNotification reloadData];
   }
    
    if (dictData[Manage_validTillDisplayValue] != nil && dictData[Manage_validTillDisplayValue] != [NSNull null]) {
        _isSection = 1;
        if ([dictData[Manage_validTillDisplayValue] isEqualToString:@"1 Days"]) {
            _isNotificationIndexPath = 0;
            _manageSelectedNotification = 0;
            _isNotificationAlreadySave = false;
        }else if ([dictData[Manage_validTillDisplayValue] isEqualToString:@"1 Day"]) {
                _isNotificationIndexPath = 1;
            _isNotificationAlreadySave = true;
            _manageSelectedNotification = 1;
        }else if ([dictData[Manage_validTillDisplayValue] isEqualToString:@"3 Days"]) {
            _isNotificationIndexPath = 2;
            _manageSelectedNotification = 2;
            _isNotificationAlreadySave = true;
        }else if ([dictData[Manage_validTillDisplayValue] isEqualToString:@"7 Days"]) {
            _isNotificationIndexPath = 3;
            _manageSelectedNotification = 3;
            _isNotificationAlreadySave = true;
        }else if ([dictData[Manage_validTillDisplayValue] isEqualToString:@"14 Days"]) {
            _isNotificationIndexPath = 4;
            _manageSelectedNotification = 4;
            _isNotificationAlreadySave = true;
        }else if ([dictData[Manage_validTillDisplayValue] isEqualToString:@"30 Days"]) {
            _isNotificationIndexPath = 5;
            _manageSelectedNotification = 5;
            _isNotificationAlreadySave = true;
        }
        
        NSString *srtTitle = [@"Note that after " stringByAppendingString:dictData[Manage_validTillDisplayValue]];
        self->_lblTitle.text = [srtTitle stringByAppendingString:@" the notification settings will be reset to allow all."];
        NSTimeInterval delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self->notificationLevel = dictData[Manage_allowFrom];
            if ([dictData[Manage_allowFrom] isEqualToString:Mention_Message]) {
                self->notificationSettings = dictData[Manage_validTill];
                self->_hgtConsTantView.constant = 70;
            }else{
                self->_hgtConsTantView.constant = 0;
                self->notificationDays = @"always";
                self->notificationSettings = [self selectedDateAccordingtoTime:@"0"];
            }
            [self.tblManageNotification reloadData];
        });
   }
}

- (NSString *)selectedDateAccordingtoTime:(NSString*) number
{
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    if ([number isEqualToString:@"1"]){
        dayComponent.day = 1;
    }else if ([number isEqualToString:@"3"]){
        dayComponent.day = 3;
    }else if ([number isEqualToString:@"7"]){
        dayComponent.day = 7;
    }else if ([number isEqualToString:@"14"]){
        dayComponent.day = 14;
    }else if ([number isEqualToString:@"30"]){
        dayComponent.day = 30;
    }
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDate *nextDate = [theCalendar dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
    [dateformate setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"]; // Date formater
    NSString *date = [dateformate stringFromDate:nextDate];
    NSString *componentDate = [date stringByAppendingString:@"Z"];
    return componentDate;
}

-(IBAction)applybtnAction:(id)sender{
    if ([_strType  isEqualToString:@"global"]) {
        if([self->notificationDays isEqualToString: @"always"]) {
            [self setCustomNotificationPOpup];
        }else{
            [self updateGlobalManageNotificationSetting:manageNotificationSuccess];
        }
    }else{
        if([self->notificationDays isEqualToString: @"always"]) {
            [self setCustomNotificationPOpup];
        }else{
            [self updateManageNotification:manageNotificationSuccess];
        }
    }
}

- (NSString *)showTimeAccordingtoManage:(NSInteger)index
{
    NSString *strString = [[NSString alloc] init];
    if (index == 1) {
        strString = [Helper notificatioinDateCalculation:[self selectedDateAccordingtoTime:@"1"]];
    }else if (index == 2) {
        strString = [Helper notificatioinDateCalculation:[self selectedDateAccordingtoTime:@"3"]];
    }else if (index == 3) {
        strString = [Helper notificatioinDateCalculation:[self selectedDateAccordingtoTime:@"7"]];
    }else if (index == 4) {
        strString = [Helper notificatioinDateCalculation:[self selectedDateAccordingtoTime:@"14"]];
    }else if (index == 5) {
        strString = [Helper notificatioinDateCalculation:[self selectedDateAccordingtoTime:@"30"]];
    }
   
    return strString;
}


    
    -(void)setCustomNotificationPOpup {
        if ([_strType isEqualToString:@"global"]) {
            [Helper showAlert:@"Custom Notication Set" message:Notifcation_schedule btnYes:@"Delete" btnNo:@"View" inViewController:self completedWithBtnStr:^(NSString* btnString) {
                if ([btnString isEqualToString:@"View"]) {
                    [self getGlobalNotificationData];
                }else if ([btnString isEqualToString:@"Delete"]) {
                    if ([notificationLevel isEqualToString:All_Message]) {
                        self.hgtConsTantView.constant = 0;
                        _isNotificationAlreadySave = false;
                        self->notificationLevel = All_Message;
                        self->notificationDays = @"365 Days";
                    }else{
                        self->notificationDays = @"always";
                    }
                    _manageSelectedNotification = 0;
                    [self updateGlobalManageNotificationSetting:@"Delete Schedule Successfully"];
                }
            }];
            
        }else{
            [Helper showAlert:@"Custom Notication Set" message:Notifcation_schedule btnYes:@"Delete" btnNo:@"View" inViewController:self completedWithBtnStr:^(NSString* btnString) {
                if ([btnString isEqualToString:@"View"]) {
                    [self getManageNotification];
                }else if ([btnString isEqualToString:@"Delete"]) {
                    if ([notificationLevel isEqualToString:All_Message]) {
                        self.hgtConsTantView.constant = 0;
                        _isNotificationAlreadySave = false;
                        self->notificationLevel = All_Message;
                        self->notificationDays = @"365 Days";
                    }else{
                        self->notificationDays = @"always";
                    }
                    _manageSelectedNotification = 0;
                    [self updateManageNotification:@"Delete Schedule Successfully"];
                }
            }];
        }
    }



-(void)updateGlobalManageNotificationSetting:(NSString *)msgNotification {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
        NSMutableDictionary * dictParam = [NSMutableDictionary new];
        NSMutableDictionary * dictNotification = [NSMutableDictionary new];
        [dictParam setValue:self->notificationLevel forKey:@"allowFrom"];
        [dictParam setValue:self->notificationSettings forKey:@"validTill"];
        if ([notificationDays isEqualToString:@"always"]) {
            [dictParam setValue:@"1 Days" forKey:@"validTillDisplayValue"];
        }else{
            [dictParam setValue:self->notificationDays forKey:@"validTillDisplayValue"];
        }
        [dictNotification setValue:dictParam forKey:@"notificationSettings"];
        
        [[eRTCChatManager sharedChatInstance] updateGlobalManageNotification:dictNotification andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            NSDictionary *dictResponse = (NSDictionary *)json;
            NSLog(@"json >>>>>>>>>>%@",json);
            if (dictResponse[@"success"] != nil) {
                BOOL success = (BOOL)dictResponse[@"success"];
                if (success) {
                    [KVNProgress dismiss];
                    [self.view makeToast:msgNotification];
                    [[NSUserDefaults standardUserDefaults] setObject:dictParam forKey:@"notificationSettings"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    NSTimeInterval delayInSeconds = 1.0;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [self.navigationController popViewControllerAnimated:true];
                    });
                }
            }
        }andFailure:^(NSError * _Nonnull error) {
            
        }];
    } else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}



-(void)getGlobalNotificationData {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
        NSMutableDictionary * dictNotification = [NSMutableDictionary new];
        [dictNotification setValue:self->_strGroupThread forKey:ThreadID];
        NSLog(@"dictNotification >>>>>>>>>>%@",dictNotification);
        [[eRTCChatManager sharedChatInstance] getGlobalManageNotification:dictNotification andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            [KVNProgress dismiss];
            NSDictionary *dictResponse = (NSDictionary *)json;
            NSLog(@"json >>>>>>>>>>%@",json);
            if (dictResponse[@"success"] != nil) {
                BOOL success = (BOOL)dictResponse[Key_Success];
                if (success) {
                    NSString *threadId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
                    if (dictResponse[Key_Result] != nil && dictResponse[Key_Result] != [NSNull null]) {
                        NSDictionary *dictNotify = dictResponse[Key_Result];
                        if (dictNotify[Group_Participants] != nil && dictNotify[Group_Participants] != [NSNull null]) {
                            NSArray *arrNotify = dictNotify[Group_Participants];
                            NSLog(@"arrNotify >>>>>>>>>>%@ %@",arrNotify,threadId);
                            for (NSDictionary *dictParticipants in arrNotify) {
                                NSString *user = dictParticipants[Key_user];
                                if ([threadId isEqualToString:user]) {
                                    if (dictParticipants[@"notificationSettings"] != nil && dictParticipants[@"notificationSettings"] != [NSNull null]) {
                                        NSDictionary *dictManagedNoti = dictParticipants[@"notificationSettings"];
                                        [self getManagedDataSet:dictManagedNoti];
                                    }
                                }
                            }
                        }
                    }
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




@end
