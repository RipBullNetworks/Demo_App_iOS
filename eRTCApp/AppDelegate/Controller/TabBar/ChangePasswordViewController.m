//
//  ChangePasswordViewController.m
//  eRTCApp
//
//  Created by Rakesh Palotra on 06/01/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import <objc/runtime.h>
#import "UIFloatLabelTextField.h"

@interface ChangePasswordViewController () {
    UIBarButtonItem *EditBarButtonItem;
}

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    self.navigationController.navigationBarHidden = NO;
    [self.navigationItem.backBarButtonItem setTitle:@""];
    self.navigationItem.title = @"Change Password";
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
        
    } else {
        // Fallback on earlier versions
    }
    [self setUpView];
    
    EditBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(clickdButton:)];
        self.navigationItem.rightBarButtonItem=EditBarButtonItem;
        //[self.buttonImage setUserInteractionEnabled:NO];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"";
}

#pragma mark - @IBAction

- (IBAction)btnSettingsClicked:(id)sender {
     [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnChangeClicked:(id)sender {
    
}

-(IBAction)clickdButton:(id)sender{
    [self callAPIForChangePassword];
}

- (void)setUpView {
    Ivar ivar =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
    UILabel *placeholderLabel1 = object_getIvar(_txtNewPassword, ivar);
    placeholderLabel1.textColor = [UIColor colorWithRed:.44 green:.53 blue:.61 alpha:1.0];//    txtNameSpace.text = @"testappstore.stage.ertc.com";//@"qatest.qa.ertc.com";//@"mqttprojtest.qa.ertc.com";

    UILabel *placeholderLabel2 = object_getIvar(_txtOldPassword, ivar);
    placeholderLabel2.textColor = [UIColor colorWithRed:.44 green:.53 blue:.61 alpha:1.0];//    txtNameSpace.text = @"testappstore.stage.ertc.com";//@"qatest.qa.ertc.com";//@"mqttprojtest.qa.ertc.com";

    UILabel *placeholderLabel3 = object_getIvar(_txtConfirmPassword, ivar);
    placeholderLabel3.textColor = [UIColor colorWithRed:.44 green:.53 blue:.61 alpha:1.0];//    txtNameSpace.text = @"testappstore.stage.ertc.com";//@"qatest.qa.ertc.com";//@"mqttprojtest.qa.ertc.com";

//    [_txtNewPassword setValue:[UIColor colorWithRed:.44 green:.53 blue:.61 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
//    [_txtOldPassword setValue:[UIColor colorWithRed:.44 green:.53 blue:.61 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
//    [_txtConfirmPassword setValue:[UIColor colorWithRed:.44 green:.53 blue:.61 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];

    _txtNewPassword.textColor = [UIColor colorWithRed:.44 green:.53 blue:.61 alpha:1.0];
    _txtOldPassword.textColor = [UIColor colorWithRed:.44 green:.53 blue:.61 alpha:1.0];
    _txtConfirmPassword.textColor = [UIColor colorWithRed:.44 green:.53 blue:.61 alpha:1.0];
    
    /*
   // self.containerView.layer.cornerRadius = 5.0;
    self.containerView.layer.borderWidth = 0.8;
    self.containerView.layer.masksToBounds = NO;
    self.containerView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.14].CGColor;
    
    self.border1.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.16];
    self.border2.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.16];
     */
}

- (void)callAPIForChangePassword {
     NSString * msg = nil;
    
    if ([self.txtOldPassword.text length] == 0) {
        msg = @"Please enter old password.";
    } else if ([self.txtNewPassword.text length] == 0) {
        msg = @"Please enter new password.";
    } else if ([self.txtConfirmPassword.text length] == 0) {
        msg = @"Please confim password.";
    } else if (![self.txtNewPassword.text isEqualToString:self.txtConfirmPassword.text]) {
        msg = @"Confirm password not match.";
    }
    
    if (msg) {
        [Helper showAlertOnController:@"eRTC" withMessage:msg onController:self];
    } else {
        NSString * userName = @"email";
        [KVNProgress show];
        if ([[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID] != nil) {
            NSString * appUserID = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
            NSDictionary *dictParam = @{@"loginType": userName, @"appUserId": appUserID, @"currentPassword": self.txtOldPassword.text, @"newPassword": self.txtNewPassword.text};
            [[eRTCUserAuthentication sharedInstance] changePasswordWithParam:dictParam andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                [KVNProgress dismiss];
                NSString * strMessage = nil;
                if (![Helper stringIsNilOrEmpty:json[Key_Message]]) {
                    strMessage = json[Key_Message];
                }
                if (![Helper stringIsNilOrEmpty:json[Key_Success]] && [json[Key_Success] integerValue] == 1) {
                    [self logoutOtherDevice];
                } else {
                    [Helper showAlertOnController:@"eRTC" withMessage:strMessage onController:self];
                }
            } andFailure:^(NSError * _Nonnull error) {
                [Helper showAlertOnController:@"eRTC" withMessage:[error localizedDescription] onController:self];
            }];
        }
    }
}

-(void)logoutOtherDevice {
    [KVNProgress show];
    NSString *strAppUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
    UIDevice *device = [UIDevice currentDevice];
    NSString  *currentDeviceId = [eRTCHelper getUUID];//[[device identifierForVendor]UUIDString];
    NSMutableDictionary * dictParam = [NSMutableDictionary new];
    [dictParam setObject:strAppUserId forKey:App_User_ID];
    [dictParam setObject:currentDeviceId forKey:KeydeviceId];
    [[eRTCChatManager sharedChatInstance] logoutOtherDevice:dictParam andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg){
        [KVNProgress dismiss];
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"eRTC" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    } andFailure:^(NSError * _Nonnull error) {
        [KVNProgress dismiss];
       
    }];
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
