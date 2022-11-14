//
//  NameSpaceViewController.m
//  eRTCApp
//
//  Created by rakesh  palotra on 27/12/18.
//  Copyright © 2018 Ripbull Network. All rights reserved.
//

#import "NameSpaceViewController.h"
#import "LoginViewController.h"
#import <objc/runtime.h>
#import "eRTC-Swift.h"

@interface NameSpaceViewController () {
    __weak IBOutlet UITextField *txtNameSpace;
    __weak IBOutlet UITextField *txtAPIKey;
}

@end

@implementation NameSpaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *nameSpace = [[NSUserDefaults standardUserDefaults]
        stringForKey:@"nameSpace"];
    NSString *apiKey = [[NSUserDefaults standardUserDefaults]
        stringForKey:@"API_Key"];
    if(apiKey != Nil && nameSpace != Nil){
        LoginViewController *historyDetail = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self.navigationController pushViewController:historyDetail animated:YES];

    }
    
    // Do any additional setup after loading the view.
    Ivar ivar =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
    UILabel *placeholderLabel1 = object_getIvar(txtNameSpace, ivar);
    placeholderLabel1.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.25];
    
    UILabel *placeholderLabel2 = object_getIvar(txtAPIKey, ivar);
    placeholderLabel2.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.25];

      
    
   
    
   // txtNameSpace.text = @"g2-aug.qa.ertc.com";
   // txtAPIKey.text = @"4ob6yszet4ps72yvqs0wg4rjtzht2c7x";
    
  //--------------------------------------------------18 Nov -------------------------------------------

    // DevDevelop
   // txtNameSpace.text = @"devjune17.dev.ertc.com";
   // txtAPIKey.text = @"m517plhc";
    
    
    // txtNameSpace.text = @"g2-2022.qa.ertc.com";
    // txtAPIKey.text = @"povr95qu";
    
    
    //txtNameSpace.text = @"development.dev.ertc.com";
   // txtAPIKey.text = @"3j3izy8h";
    
    
   // txtNameSpace.text = @"automate02.dev.ertc.com";
   // txtAPIKey.text = @"x13dogac";

   //--------------------------------------------------E2E -------------------------------------------
 
    // txtNameSpace.text = @"qaaprile2e.qa.ertc.com";
    // txtAPIKey.text = @"r1vib3w1";
    
    // txtNameSpace.text = @"gtwo.dev.ertc.com";
    // txtAPIKey.text = @"22tym1yhdq9md7wyfy249n2s8z1ohp8l";
    
    
    self.navigationController.navigationBarHidden = YES;
    txtNameSpace.autocorrectionType = UITextAutocorrectionTypeNo;
    
    
    self.vwAccessCode.layer.borderWidth = 1;
    self.vwNAmeSpace.layer.borderWidth = 1;
    
    self.vwAccessCode.layer.borderColor = UIColor.lightGrayColor.CGColor;
    self.vwNAmeSpace.layer.borderColor = UIColor.lightGrayColor.CGColor;
    
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
- (IBAction)btnGotoPortal:(id)sender {
    NSURL* url = [[NSURL alloc] initWithString: @"https://qa.inappchat.io/"];
    [[UIApplication sharedApplication] openURL: url];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    
    
}



-(IBAction)btnNextClicked:(id)sender {
    [self logingWithNameSpace];
}


-(IBAction)auth0SignInAction:(id)sender {
    AuthManager *authManager = [AuthManager sharedInstance];
    
    [KVNProgress show];
    
    // Retrieve cached credentials
    [authManager isAuthed:^(NSString * _Nullable errorMsg) {
        [KVNProgress dismiss];
        if (errorMsg == NULL) {
            NSString * userEmail = [authManager getEmail];
            NSString * userID = [authManager getID];
            NSLog(@"user id--> %@",userID);
            NSLog(@"email  --> %@",userEmail);
            NSString *msg = [NSString stringWithFormat:@"Success\nID: %@\nEmail: %@", userID, userEmail];
            [Helper showAlertOnController:@"Auth0"
                              withMessage:msg                             onController:self];
        }else{
            // Login in case no credential found or credentials are invalid
            [authManager login:^(NSString * _Nullable errorMsg){
                if (errorMsg == NULL) {
                    NSString * userEmail = [authManager getEmail];
                    NSString * userID = [authManager getID];
                    NSLog(@"user id--> %@",userID);
                    NSLog(@"email  --> %@",userEmail);
                    [Helper showAlertOnController:@"Auth0" withMessage:@"Login Success!" onController:self];
                }else{
                    [Helper showAlertOnController:@"Auth0"
                                      withMessage:errorMsg onController:self];
                }
            }];
        }
    }];
}



-(void)logingWithNameSpace {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        if ([self isValidateNameSpaceScreenWithNameSpace:[txtNameSpace text]]) {
          if ([self isValidateNameSpaceScreenWithAPIKey:[txtAPIKey text]]) {
//            [AppDelegate sharedAppDelegate].ertcObj =
              [[eRTCSDK alloc] initWithApiKey:[txtAPIKey text]];
                [KVNProgress show];
                [eRTCSDK validateNameSpaceWithWorkSpaceName:[txtNameSpace text] withSuccess:^(BOOL isValid, NSString *errMsg) {
                    [KVNProgress dismiss];
                    if (isValid) {
                        [[NSUserDefaults standardUserDefaults]setValue:[txtAPIKey text] forKey:@"API_Key"];
                        [[NSUserDefaults standardUserDefaults]setValue:[txtNameSpace text] forKey:@"nameSpace"];
                        [[NSUserDefaults standardUserDefaults]setValue:[self->txtAPIKey text] forKey:@"API_Key"];
                        LoginViewController *historyDetail = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"LoginViewController"];
                        [self.navigationController pushViewController:historyDetail animated:YES];
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

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
