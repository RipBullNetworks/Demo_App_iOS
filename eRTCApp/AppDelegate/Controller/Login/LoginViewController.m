
//  LoginViewController.m
//  eRTCApp
//  Created by rakesh  palotra on 26/12/18.
//  Copyright © 2018 Ripbull Network. All rights reserved.


#import "LoginViewController.h"
#import "RecentChatViewController.h"
#import "ForgotViewController.h"
#import <objc/runtime.h>
#import "ChatRestorationViewController.h"
#import "eRTC-Swift.h"


@interface LoginViewController ()<UITextFieldDelegate,FIRMessagingDelegate> {
    __weak IBOutlet UITextField *txtUserName;
    __weak IBOutlet UITextField *txtPassword;
    __weak IBOutlet UILabel *labelError;
    __weak IBOutlet UIButton *btnEye;
     NSString *FcmToken;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *nameSpace = [[NSUserDefaults standardUserDefaults]
        stringForKey:@"nameSpace"];
    NSString *apiKey = [[NSUserDefaults standardUserDefaults]
        stringForKey:@"API_Key"];
    if(apiKey != Nil && nameSpace != Nil){
        [self logingWithNameSpaceWith:nameSpace addApiKey:apiKey];
    }
    
    // Do any additional setup after loading the view.
    Ivar ivar =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
    UILabel *placeholderLabel = object_getIvar(txtUserName, ivar);
    placeholderLabel.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.25];
    
    UILabel *placeholderLabel1 = object_getIvar(txtPassword, ivar);
       placeholderLabel1.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.25];
    [txtPassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [btnEye setSelected:NO];
    [labelError setHidden:YES];
    txtUserName.autocorrectionType = UITextAutocorrectionTypeNo;
    txtPassword.autocorrectionType = UITextAutocorrectionTypeNo;
  
    
 // ----------------------------------------------------------20 Oct ----------------------------------
    //Account i
   // txtUserName.text = @" anduser1@rrrsc0aw.mailosaur.net";
   // txtPassword.text = @"password";
    
     //Account ii
    // txtUserName.text = @"vijay.desk27@mailinator.com";
    // txtPassword.text = @"AQeAYw7u";
    
    
    //Account iii
   // txtUserName.text = @"test_nam@mailinator.com";
   // txtPassword.text = @"TYEQNkIn";
    
    
    //Account dev
   // txtUserName.text = @"devteste11@mailinator.com";
   // txtPassword.text = @"sm6cEJmU";
    
    //Account dev12
   // txtUserName.text = @"devteste12@mailinator.com";
   // txtPassword.text = @"KzDI5l0e";
    
    /*
     Username vijay.desk24@mailinator.com
     Password JvePwTky
     */

    //vijaytest2@mailinator.com
    //   --------------------------------------------------E2E -------------------------------------------
   // Iphone 12
   //  txtUserName.text = @"devtester121@mailinator.com";
   //  txtPassword.text = @"GbLuvDvL";
    
     // Iphone 13
    // txtUserName.text = @"tester.desk6@gmail.com";
    // txtPassword.text = @"wKoBZxkn";

    // Iphone 8
   // txtUserName.text = @"tester.desk4@gmail.com";
   // txtPassword.text = @"tQfft7oh";
    
    
    
    
    
  
    self.vwEmail.layer.borderWidth = 1;
    self.vwPassword.layer.borderWidth = 1;
    
    self.vwEmail.layer.cornerRadius = 8;
    self.vwPassword.layer.cornerRadius = 8;
    
    
    self.vwEmail.layer.borderColor = UIColor.lightGrayColor.CGColor;
    self.vwPassword.layer.borderColor = UIColor.lightGrayColor.CGColor;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self->txtPassword.rightView addSubview:self->btnEye];
        [self->txtPassword.rightView bringSubviewToFront:self->btnEye];
    });
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [KVNProgress show];
    [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result,    NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"LoginViewController -> viewWillAppear  -> instanceIDWithHandler ->  %@",error);
        } else {
            [KVNProgress dismiss];
            NSLog(@"LoginViewController -> viewWillAppear  -> instanceIDWithHandler ->  %@",result.token);
            self->FcmToken = result.token;
        }
    }];
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


- (IBAction)btnGotoAdminPortal:(id)sender {
    NSDictionary *dictConfig = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
    if (dictConfig[ChatServerBaseurl] != nil && dictConfig[ChatServerBaseurl] != [NSNull null]) {
    NSString *baseUrl = dictConfig[ChatServerBaseurl];
   // NSURL* url = [[NSURL alloc] initWithString: baseUrl];
    NSURL* url = [[NSURL alloc] initWithString: @"https://qa.inappchat.io/"];
        NSLog(@"url>>>>>>>>>>>>>>%@",url);
    [[UIApplication sharedApplication] openURL: url];
    }
}

#pragma mark - @IBAction
- (IBAction)btnLoginWithAuth0Clicked:(id)sender {
    AuthManager *authManager = [AuthManager sharedInstance];
    InAppChatWebServices *webService = [InAppChatWebServices sharedInstance];

    [KVNProgress show];
    
    // Retrieve cached credentials
//    [authManager isAuthed:^(NSString * _Nullable errorMsg) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [KVNProgress dismiss];
//        });
//        if (errorMsg == NULL) {
//            NSString * userEmail = [authManager getEmail];
//            NSString * userID = [authManager getID];
//            NSLog(@"user id--> %@",userID);
//            NSLog(@"email  --> %@",userEmail);
//            NSString *msg = [NSString stringWithFormat:@"Success\nID: %@\nEmail: %@", userID, userEmail];
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//
//
//
//
//                [Helper showAlertOnController:@"Auth0"
//                                  withMessage:msg                             onController:self];
//            });
//
//        }else{
//        }
//    }];
    
    
    // Login in case no credential found or credentials are invalid
    [authManager login:^(NSString * _Nullable errorMsg){
        [KVNProgress dismiss];
        
        if (errorMsg == NULL) {
            NSString * appUserId = [authManager getEmail];
            NSString * userID = [authManager getID];
            NSString * idToken = [authManager getIdToken];
            NSLog(@"user id--> %@",userID);
            NSLog(@"email  --> %@",appUserId);
            NSLog(@"idToken  --> %@",idToken);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *dictParam = @{
                    @"appState": @"active",
                    @"userId": userID,
                    @"appUserId": appUserId,
                    @"fcmToken":self->FcmToken};
                /**{
                 "name": "test2",
                 "appUserId": "inapptest2.nrvjj@yopmail.com",
                 "profilePic": null,
                 "profilePicThumb": null,
                 "loginTimeStamp": 1666186661,
                 "profileStatus": "I am using eRTC",
                 "appState": "active",
                 "userId": "634db698434b2e0013bd3785"
                 }*/
                
                NSLog(@"getting user...%@", dictParam);
                
                [self getChatUserListWithUserId:dictParam];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [Helper showAlertOnController:@"Auth0"
                                  withMessage:errorMsg onController:self];
            });
        }
    }];
}

-(IBAction)btnLoginClicked:(id)sender {
    if ([self isValidateLoginScreenWithUserName:txtUserName.text andPassword:txtPassword.text]) {
        if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
            NSString * userName = @"";
            if ([Helper isValidateEmailWithString:txtUserName.text]) {
                userName = @"email";
            } else if ([Helper isValidateMobileWithString:txtUserName.text]) {
                userName = @"phone number";
            }
            
            NSLog(@"dictParam>>>>>>>>>>>>>>> %@ ",userName);
            NSLog(@"[txtUserName text], [txtPassword text] %@ pass%@",[txtUserName text],[txtPassword text]);
            NSLog(@"dictParam>>>>>>>>>>>>>>> %@",FcmToken);
           
            NSDictionary *dictParam = @{@"loginType": userName, @"appUserId": [txtUserName text], @"password": [txtPassword text], @"fcmToken":FcmToken};
            [KVNProgress show];
            [[eRTCUserAuthentication sharedInstance] userAuthenticationWithParam:dictParam andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                NSLog(@"LoginViewController -> btnLoginClicked  -> userAuthenticationWithParam ->  %@",json);
                   [KVNProgress dismiss];
                
                if (![Helper stringIsNilOrEmpty:json[Key_Success]] && [json[Key_Success] integerValue] == 1) {
                    if (![Helper stringIsNilOrEmpty:json[Key_Result]]) {
                        [self getChatUserListWithUserId:json[Key_Result]];
                    }
                } else {
                    if (![Helper stringIsNilOrEmpty:json[Key_Message]]) {
                        [self->labelError setHidden:NO];
                        self->labelError.text = json[Key_Message];
//                        [Helper showAlertOnController:@"eRTC" withMessage:json[Key_Message] onController:self];
                    }
                }
                
            } andFailure:^(NSError * _Nonnull error) {
                   [KVNProgress dismiss];
                [self->labelError setHidden:YES];
                self->labelError.text = @"";
//                [Helper showAlertOnController:@"eRTC" withMessage:[error localizedDescription] onController:self];
            }];
    
        } else {
            [self->labelError setHidden:YES];
            self->labelError.text = @"";
            [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
        }
    }
}

-(void)logingWithNameSpaceWith:(NSString *)txtNameSpace addApiKey:(NSString *)txtAPIKey {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        if ([self isValidateNameSpaceScreenWithNameSpace:txtNameSpace]) {
          if ([self isValidateNameSpaceScreenWithAPIKey:txtAPIKey]) {
//            [AppDelegate sharedAppDelegate].ertcObj =
              [[eRTCSDK alloc] initWithApiKey:txtAPIKey];
                [eRTCSDK validateNameSpaceWithWorkSpaceName:txtNameSpace withSuccess:^(BOOL isValid, NSString *errMsg) {
                    if (isValid) {
                    } else {
                        [Helper showAlertOnController:@"eRTC" withMessage:errMsg onController:self];
                    }
                } andFailure:^(NSError *error) {
                    [KVNProgress dismiss];
                    [Helper showAlertOnController:@"eRTC" withMessage:[error localizedDescription] onController:self];
                }];
            } else {
                [Helper showAlertOnController:@"eRTC" withMessage:@"Please enter access code." onController:self];
            }
        } else {
            [Helper showAlertOnController:@"eRTC" withMessage:@"Please enter Namespace." onController:self];
        }
    }
}

-(void) getChatUserListWithUserId:(NSDictionary *)dict {
    NSMutableDictionary * dictUser = [[NSMutableDictionary dictionaryWithDictionary:dict] mutableCopy];
    if(dictUser[App_User_ID] != nil && dict[App_User_ID]!=[NSNull null]) {
        NSDictionary * dictParam = @{@"appUserId":dictUser[App_User_ID],@"fcmToken":FcmToken};
       
        NSLog(@"getuser user id exist %@", dictUser);
        [[eRTCAppUsers sharedInstance] chatUserListWithParam:dictParam andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            NSLog(@"getuser %@", json);
            if (![Helper stringIsNilOrEmpty:json[Key_Success]] && [json[Key_Success] integerValue] == 1) {
                if (![Helper stringIsNilOrEmpty:json[Key_Result]]) {
                    NSDictionary * dictChat = json[Key_Result];
                    
                    if(![Helper stringIsNilOrEmpty:dictChat[User_eRTCUserId]]) {
                        [dictUser setObject:[NSString stringWithFormat:@"%@",dictChat[User_eRTCUserId]] forKey:User_eRTCUserId];
                    }
                    
                    if(![Helper stringIsNilOrEmpty:dictChat[TenantID]]) {
                        [dictUser setObject:[NSString stringWithFormat:@"%@",dictChat[TenantID]] forKey:TenantID];
                    }
                    
                    if(![Helper stringIsNilOrEmpty:dictChat[User_ProfileStatus]]) {
                        [dictUser setObject:[NSString stringWithFormat:@"%@",dictChat[User_ProfileStatus]] forKey:User_ProfileStatus];
                    }
                    
                    [[eRTCCoreDataManager sharedInstance] getLoggedInUserInfo:^(id  _Nonnull userInfo) {
                        [[UserModel sharedInstance] saveUserDetailsWith:userInfo];
                    }];
//                    [[NSUserDefaults standardUserDefaults]setValue:@"YES" forKey:IsLoggedIn];
//                    [[AppDelegate sharedAppDelegate] willChangeTabBarAsRootOfApplication];
                    [self->labelError setHidden:YES];
                    self->labelError.text = @"";
                    [self navigateToLoginScreen];
                }
            } else {
                if (![Helper stringIsNilOrEmpty:json[Key_Message]]) {
                    [self->labelError setHidden:YES];
                    self->labelError.text = @"";
                    [Helper showAlertOnController:@"eRTC" withMessage:json[Key_Message] onController:self];
                }
            }
        } andFailure:^(NSError * _Nonnull error) {
            NSLog(@"getuser %@", error);
            [self->labelError setHidden:YES];
            self->labelError.text = @"";
             [Helper showAlertOnController:@"eRTC" withMessage:[error localizedDescription] onController:self];
        }];
    }else{
        NSLog(@"Error get user %@", dictUser);
    }
}

-(void)navigateToLoginScreen{
    [[NSUserDefaults standardUserDefaults]setValue:@"YES" forKey:IsLoggedIn];
    ChatRestorationViewController *crVC =  [[Helper ChatRestorationStoryBoard] instantiateViewControllerWithIdentifier:@"ChatRestorationViewController"];
    [self.navigationController pushViewController:crVC animated:TRUE];
    
    //[[AppDelegate sharedAppDelegate] willChangeTabBarAsRootOfApplication];

}
- (IBAction)btnForgotClicked:(id)sender {
    ForgotViewController *_vcForgot = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"ForgotViewController"];
    [self.navigationController pushViewController:_vcForgot animated:YES];
}

- (IBAction)btnWorgNameSpaceClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnEyeClicked:(id)sender {
    if ([btnEye isSelected]) {
        [btnEye setSelected:NO];
        [txtPassword setSecureTextEntry:YES];
    } else {
        [txtPassword setSecureTextEntry:NO];
        [btnEye setSelected:YES];
    }
}

    #pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidChange:(UITextField *) textField {
    if ([[textField text] length] > 0) {
        [btnEye setHidden:NO];
    } else {
        [btnEye setHidden:YES];
    }
}

@end
