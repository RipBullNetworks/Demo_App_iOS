//
//  NotificationSettingViewController.m
//  eRTCApp
//
//  Created by rakesh  palotra on 12/05/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import "NotificationSettingViewController.h"
#import "NotificationPopUpViewController.h"

@interface NotificationSettingViewController ()<UITableViewDelegate, UITableViewDataSource, NotificationSettingDelegate> {
      __weak IBOutlet UITableView *tblNotification;
    __weak IBOutlet UIView *viewShadow;
    __weak IBOutlet UIView *viewInner;
    __weak IBOutlet UILabel *lblPopUpMsg;
    NSMutableArray *arrNotificaitons;
}
@property (weak, nonatomic) IBOutlet UIButton *doTapBtnTurnOFF;
- (IBAction)doTapOnBtnCancel:(id)sender;
@end

@implementation NotificationSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self->arrNotificaitons = [NSMutableArray new];
    [self configureNavigationBar];
    [self getNotificationStatus];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleGlobalNotification:)
                                                 name:DidUpdateGlobalNotificationSetting
                                               object:nil];
}

-(void)getNotificationStatus{
    if (self.isFromGroup) {
        if (self.strGroupThreadID != nil) {
            
            [[eRTCChatManager sharedChatInstance] getThreadsNotificationStatus:self.strGroupThreadID andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                
                if (![Helper stringIsNilOrEmpty:json[@"notificationSettings"]]){
                    NSString *strStatus = json[@"notificationSettings"];
                    if ([strStatus isEqualToString:All_Message]){
                        [self->arrNotificaitons addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
                        [self.imgNewMessage setImage:[UIImage imageNamed:@"radiocheck"]];
                        [self.imgMention setImage:[UIImage imageNamed:@"radioUncheck"]];
                        [self.imgNothing setImage:[UIImage imageNamed:@"radioUncheck"]];
                    }
                    else if ([strStatus isEqualToString:Mention_Message]){
                        [self->arrNotificaitons addObject:[NSIndexPath indexPathForRow:1 inSection:0]];
                        [self.imgNewMessage setImage:[UIImage imageNamed:@"radioUncheck"]];
                        [self.imgMention setImage:[UIImage imageNamed:@"radiocheck"]];
                        [self.imgNothing setImage:[UIImage imageNamed:@"radioUncheck"]];
                    }
                    else if ([strStatus isEqualToString:Nothing_Message]){
                        [self->arrNotificaitons addObject:[NSIndexPath indexPathForRow:2 inSection:0]];
                        [self.imgNewMessage setImage:[UIImage imageNamed:@"radioUncheck"]];
                        [self.imgMention setImage:[UIImage imageNamed:@"radioUncheck"]];
                        [self.imgNothing setImage:[UIImage imageNamed:@"radiocheck"]];
                    }
                }else{
                    [self->arrNotificaitons addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
                }
            } andFailure:^(NSError * _Nonnull error) {
                NSLog(@"send error--> %@",error);
            }];
        }
   
    }else{
        [[eRTCCoreDataManager sharedInstance] getLoggedInUserInfo:^(id  _Nonnull userInfo) {
               [[UserModel sharedInstance] saveUserDetailsWith:userInfo];
           }];
           
           if ([[UserModel sharedInstance] getUserDetailsUsingKey:@"notificationSettings"] != nil){
            
               NSString *strStatus = [[UserModel sharedInstance] getUserDetailsUsingKey:@"notificationSettings"];
               
               if ([strStatus isEqualToString:All_Message]){
                   [self->arrNotificaitons addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
                   [self.imgNewMessage setImage:[UIImage imageNamed:@"radiocheck"]];
                   [self.imgMention setImage:[UIImage imageNamed:@"radioUncheck"]];
                   [self.imgNothing setImage:[UIImage imageNamed:@"radioUncheck"]];
               }
               else if ([strStatus isEqualToString:Mention_Message]){
                   [self->arrNotificaitons addObject:[NSIndexPath indexPathForRow:1 inSection:0]];
                   [self.imgNewMessage setImage:[UIImage imageNamed:@"radioUncheck"]];
                   [self.imgMention setImage:[UIImage imageNamed:@"radiocheck"]];
                   [self.imgNothing setImage:[UIImage imageNamed:@"radioUncheck"]];
                      
               }
               else if ([strStatus isEqualToString:Nothing_Message]){
                   [self->arrNotificaitons addObject:[NSIndexPath indexPathForRow:2 inSection:0]];
                   [self.imgNewMessage setImage:[UIImage imageNamed:@"radioUncheck"]];
                   [self.imgMention setImage:[UIImage imageNamed:@"radioUncheck"]];
                   [self.imgNothing setImage:[UIImage imageNamed:@"radiocheck"]];
               }
           }else{
               [self->arrNotificaitons addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
               
           }
    }
   }

- (void)handleGlobalNotification:(NSNotification *) notification{
    NSDictionary *data = [notification object];
    
    if ([data[@"allowFrom"] isEqualToString:All_Message]){
        [self->arrNotificaitons addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
        [self.imgNewMessage setImage:[UIImage imageNamed:@"radiocheck"]];
        [self.imgMention setImage:[UIImage imageNamed:@"radioUncheck"]];
        [self.imgNothing setImage:[UIImage imageNamed:@"radioUncheck"]];
    }
    else if ([data[@"allowFrom"] isEqualToString:Mention_Message]){
        [self->arrNotificaitons addObject:[NSIndexPath indexPathForRow:1 inSection:0]];
        [self.imgNewMessage setImage:[UIImage imageNamed:@"radioUncheck"]];
        [self.imgMention setImage:[UIImage imageNamed:@"radiocheck"]];
        [self.imgNothing setImage:[UIImage imageNamed:@"radioUncheck"]];
    }
    else if ([data[@"allowFrom"] isEqualToString:Nothing_Message]){
        [self->arrNotificaitons addObject:[NSIndexPath indexPathForRow:2 inSection:0]];
        [self.imgNewMessage setImage:[UIImage imageNamed:@"radioUncheck"]];
        [self.imgMention setImage:[UIImage imageNamed:@"radioUncheck"]];
        [self.imgNothing setImage:[UIImage imageNamed:@"radiocheck"]];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"";
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
- (void)configureNavigationBar {
    self.navigationItem.title = @"Notifications";
    
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
        
    } else {
        // Fallback on earlier versions
    }
    self->tblNotification.layer.cornerRadius = 16.0;
    self->tblNotification.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor;
    self->tblNotification.layer.borderWidth = 1.0;
    self->viewShadow.backgroundColor = [UIColor whiteColor];
    self->viewShadow.layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4].CGColor;
   // self->viewShadow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
    [self->viewShadow setHidden:YES];
    self->viewInner.backgroundColor = [UIColor whiteColor];
    self->viewInner.layer.borderColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0].CGColor;
    self->viewInner.layer.cornerRadius = 16;
    self->lblPopUpMsg.textColor = [UIColor colorWithRed:0.125 green:0.129 blue:0.123 alpha:1.0];
}

-(void)openNotificationPOPUp{
    NotificationPopUpViewController *_vcNotiPopUp = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"NotificationPopUpViewController"];
   // _vcNotiPopUp.view.backgroundColor = [UIColor clearColor];
    _vcNotiPopUp.delegate = self;
    _vcNotiPopUp.view.backgroundColor = [UIColor whiteColor];
    _vcNotiPopUp.view.layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4].CGColor;
    _vcNotiPopUp.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:_vcNotiPopUp animated:NO completion:nil];
}

-(void)callNotificationUpdateAPI:(NSString*)strNotificationType{
    if (self.isFromGroup){
        [self updateThreadNotificationStatus:strNotificationType];
    }else{
        [self updateGlobalNotificationStatus:strNotificationType];
    }
}

-(void)updateGlobalNotificationStatus:(NSString*)strNotificationType{
    if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil) {
        [[eRTCAppUsers sharedInstance] updateUserByUserId:strNotificationType andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            [self->tblNotification reloadData];
        } andFailure:^(NSError * _Nonnull error) {
            NSLog(@"error--> %@",error);
            NSString *errMsg = [NSString stringWithFormat:@"%@", error.localizedDescription];
            [Helper showAlertOnController:@"eRTC" withMessage:errMsg onController:self];
        }];
    }
}

-(void)updateThreadNotificationStatus:(NSString*)strNotificationType{
    if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil) {
        if (self.strGroupThreadID != nil) {
            [[eRTCChatManager sharedChatInstance] updateNotificationSettings:strNotificationType withThreadId:self.strGroupThreadID andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                [self->tblNotification reloadData];
            } andFailure:^(NSError * _Nonnull error) {
                NSLog(@"error--> %@",error);
                NSString *errMsg = [NSString stringWithFormat:@"%@", error.localizedDescription];
                [Helper showAlertOnController:@"eRTC" withMessage:errMsg onController:self];
            }];
        }
    }
}

#pragma mark - UITableView Delegates and DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:16];
        cell.textLabel.textColor = [UIColor colorWithRed:.44 green:.53 blue:.61 alpha:1.0];
    }
    
    cell.accessoryType = ([self->arrNotificaitons containsObject:indexPath]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Every new message";
            break;
            case 1:
            cell.textLabel.text = @"Just @mentions";
            break;
        case 2:
            cell.textLabel.text = @"Nothing";
            break;
            
        default:
            break;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [cell setSelected:YES animated:NO];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath   *)indexPath
{
    
    if (self->arrNotificaitons.count > 0){
        [self->arrNotificaitons replaceObjectAtIndex:0 withObject:indexPath];
    }else{
        [self->arrNotificaitons addObject:indexPath];
    }
   // [self->tblNotification reloadData];
    //[self->tblNotification cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
     switch (indexPath.row) {
            case 0:
                [self callNotificationUpdateAPI:All_Message];
                break;
            case 1:
                [self callNotificationUpdateAPI:Mention_Message];
                break;
            case 2:
             [self openNotificationPOPUp];
          // [self->viewShadow setHidden:NO];
                break;
    
            default:
                break;
        }
    //[self->tblNotification reloadData];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self->tblNotification cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark - Custom Action
- (IBAction)doTapOnBtnCancel:(id)sender {
    [self->viewShadow setHidden:YES];
}

- (IBAction)btnSelecttag:(UIButton *)sender {
    if (sender.tag == 101) {
        [self.imgNewMessage setImage:[UIImage imageNamed:@"radiocheck"]];
        [self.imgMention setImage:[UIImage imageNamed:@"radioUncheck"]];
        [self.imgNothing setImage:[UIImage imageNamed:@"radioUncheck"]];
        [self callNotificationUpdateAPI:All_Message];
    }else if (sender.tag == 102){
        [self.imgNewMessage setImage:[UIImage imageNamed:@"radioUncheck"]];
        [self.imgMention setImage:[UIImage imageNamed:@"radiocheck"]];
        [self.imgNothing setImage:[UIImage imageNamed:@"radioUncheck"]];
        [self callNotificationUpdateAPI:Mention_Message];
    }else if (sender.tag == 103){
        [self.imgNewMessage setImage:[UIImage imageNamed:@"radioUncheck"]];
        [self.imgMention setImage:[UIImage imageNamed:@"radioUncheck"]];
        [self.imgNothing setImage:[UIImage imageNamed:@"radiocheck"]];
        [self openNotificationPOPUp];
    }
}

- (IBAction)doTapOnBtnTurnOff:(id)sender {
    [self->viewShadow setHidden:YES];
    [self callNotificationUpdateAPI:Nothing_Message];
}

#pragma mark - Notification Popup custom delegate
-(void)dismissPopUp{
    NSLog(@"call delegate");
    [self dismissViewControllerAnimated:NO completion:nil];
    [self callNotificationUpdateAPI:Nothing_Message];
    
}
@end
