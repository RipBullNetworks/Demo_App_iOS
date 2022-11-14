//
//  ChatRestorationViewController.m
//  eRTCApp
//
//  Created by rakesh  palotra on 18/11/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import "ChatRestorationViewController.h"
#import <Toast/Toast.h>




#define COMPLETE_TEXT @"Restore your message history from backup. \nBy choosing not to restore, you will not be able to access these messages later. \n\nThis may take a while. You can choose to let the restoration process complete in the background."
#define RESTORING_TEXT @"Restore your message history from backup. \nBy choosing not to restore, you will not be able to access these messages later."
@interface ChatRestorationViewController (){
    BOOL isRestored;
}
@property (weak, nonatomic) IBOutlet UIView *progressViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *progressTitleLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progressActivityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *restorationInstructionLabel;
@property UIButton *skipButton;
@end

@implementation ChatRestorationViewController
@synthesize skipButton, progressActivityIndicator, progressViewContainer, progressTitleLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
    [self setupUI];
    [[NSUserDefaults standardUserDefaults]setValue:@"YES" forKey:RestorationAvailability];
   // [self callAPIScallAPIS];
}


-(void) setup{
    isRestored = FALSE;
}
-(void) setupUI{
    self.progressViewContainer.hidden = TRUE;
}
- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"Restore messages";
    self.restorationInstructionLabel.text = COMPLETE_TEXT;
    self.restorationInstructionLabel.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:14];
    skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [skipButton setTitle:@"Skip" forState:UIControlStateNormal];
    [skipButton.titleLabel setFont:[UIFont fontWithName:@"SFProDisplay-Medium" size:17]];
    [skipButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [skipButton addTarget:self action:@selector(skipPress:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *skipButtonItem = [[UIBarButtonItem alloc] initWithCustomView:skipButton];
    self.navigationItem.leftBarButtonItems =  @[skipButtonItem];
    
    UIButton *restoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [restoreButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [restoreButton setTitle:@"Restore" forState:UIControlStateNormal];
    [restoreButton.titleLabel setFont:[UIFont fontWithName:@"SFProDisplay-Bold" size:17]];
    [restoreButton addTarget:self action:@selector(restorePress:) forControlEvents:UIControlEventTouchUpInside];
   
    UIBarButtonItem *restoreButtonItem = [[UIBarButtonItem alloc] initWithCustomView:restoreButton];
    self.navigationItem.rightBarButtonItems = @[restoreButtonItem];
}
-(void)skipPress:(UIButton*)button {
    [KVNProgress show];
    [[eRTCChatManager sharedChatInstance] getuserGroups:@{}.mutableCopy andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        [[AppDelegate sharedAppDelegate] willChangeTabBarAsRootOfApplication];
        [KVNProgress dismiss];
    }
    andFailure:^(NSError * _Nonnull error) {
        [KVNProgress dismiss];
        [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
    }];
}


-(void)restorePress:(UIButton*)button {
    NSDictionary *dictConfig = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
    
    if ([dictConfig[@"e2eChat"] boolValue] == false || [dictConfig[@"e2eLocation"] boolValue] == false || [dictConfig[@"e2eGify"] boolValue] == false || [dictConfig[@"e2eContact"] boolValue] == false) {
        self.navigationItem.hidesBackButton = TRUE;
        [self.navigationItem.leftBarButtonItem.customView setHidden:YES];
        if (isRestored){
            [[NSUserDefaults standardUserDefaults]setValue:@"YES" forKey:IsRestoration];
            //show next screen;
            [[AppDelegate sharedAppDelegate] willChangeTabBarAsRootOfApplication];
        }else {
            self.navigationItem.leftBarButtonItems = nil;
            self.restorationInstructionLabel.text = RESTORING_TEXT;
            //call restore api
            self.progressViewContainer.hidden = FALSE;
            [button setTitle:@"Next" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            
            NSMutableDictionary *details = @{}.mutableCopy;
            details[@"limit"] = @50;
            details[@"skip"] = @0;
            //        details[@"threadType"] = @"single";
            //    details[@"lastChatCount"] = @1;
            if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_ID] != nil) {
                [[eRTCChatManager sharedChatInstance] getuserGroups:@{}.mutableCopy andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                    [[eRTCChatManager sharedChatInstance] restoreChatHistory: details andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                        self->isRestored = TRUE;
                        self.restorationInstructionLabel.text = COMPLETE_TEXT;
                        [self->progressActivityIndicator stopAnimating];
                        self->progressTitleLabel.text = @"Restoration Complete";
                        self.navigationItem.leftBarButtonItems = nil;
                        self.navigationItem.hidesBackButton = TRUE;
                        [button setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
                    } andFailure:^(NSError * _Nonnull error) {
                        UIBarButtonItem *skipButtonItem = [[UIBarButtonItem alloc] initWithCustomView:skipButton];
                        self.navigationItem.leftBarButtonItems =  @[skipButtonItem];
                        NSLog(@" something went wrong!!!");
                        [self.navigationItem.rightBarButtonItem.customView setHidden:NO];
                    }];
                    
                }andFailure:^(NSError * _Nonnull error) {
                    [KVNProgress dismiss];
                    NSLog(@"GroupListViewController ->  callAPIForGetGroupList -> %@",error);
                    [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
                }];
            }
            
        }
    }else{
        [self.view makeToast:GlobalSearch_msg];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:TRUE animated:NO];
}


@end
