//
//  ForgotViewController.m
//  eRTCApp
//
//  Created by Rakesh Palotra on 06/01/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import "ForgotViewController.h"
#import <objc/runtime.h>



@interface ForgotViewController ()

@end

@implementation ForgotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    Ivar ivar =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
    UILabel *placeholderLabel = object_getIvar(_txtEmail, ivar);
    placeholderLabel.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.25];
    
    self.imgBorder.layer.borderWidth = 1;
    self.imgBorder.layer.borderColor = UIColor.lightGrayColor.CGColor;
    self.imgBorder.layer.cornerRadius = 5;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - @IBAction

- (IBAction)btnSignInClicked:(id)sender {
     [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSendClicked:(id)sender {
    [self callAPIForForgotPassword];
 
}

- (IBAction)btnGotoAdminPortal:(id)sender {
    NSDictionary *dictConfig = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
    if (dictConfig[ChatServerBaseurl] != nil && dictConfig[ChatServerBaseurl] != [NSNull null]) {
    NSString *baseUrl = dictConfig[ChatServerBaseurl];
   // NSURL* url = [[NSURL alloc] initWithString: baseUrl];
    NSURL* url = [[NSURL alloc] initWithString: @"https://dev.inappchat.io/"];
        NSLog(@"url>>>>>>>>>>>>>>%@",url);
    [[UIApplication sharedApplication] openURL: url];
    }
}

- (void)callAPIForForgotPassword {
    
    if ([self isValidateForgotScreenWithEmail:_txtEmail.text]) {
       
        NSString * userName = @"";
        if ([Helper isValidateEmailWithString:self.txtEmail.text]) {
            userName = @"email";
        } else if ([Helper isValidateMobileWithString:self.txtEmail.text]) {
            userName = @"phone number";
        }
        
        if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
               [KVNProgress show];
            NSDictionary *dictParam = @{@"loginType": userName, @"appUserId": [self.txtEmail text]};
            
            [[eRTCUserAuthentication sharedInstance] forgotPasswordWithParam:dictParam andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                [KVNProgress dismiss];
                NSString * strMessage = nil;
                if (![Helper stringIsNilOrEmpty:json[Key_Message]]) {
                    strMessage = json[Key_Message];
                }
                
                if (![Helper stringIsNilOrEmpty:json[Key_Success]] && [json[Key_Success] integerValue] == 1) {
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"eRTC" message:strMessage preferredStyle:UIAlertControllerStyleAlert];
                    
                    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self.navigationController popViewControllerAnimated:YES];
                    }]];
                    [self presentViewController:alert animated:YES completion:nil];
                } else {
                    [Helper showAlertOnController:@"eRTC" withMessage:strMessage onController:self];
                }
            } andFailure:^(NSError * _Nonnull error) {
                [Helper showAlertOnController:@"eRTC" withMessage:[error localizedDescription] onController:self];
            }];
        } else {
            [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
        }
    }
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


@end
