//
//  LogineRTCBaseViewController.m
//  eRTCApp
//
//  Created by Rakesh Palotra on 06/01/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import "LogineRTCBaseViewController.h"

@interface LogineRTCBaseViewController ()

@end

@implementation LogineRTCBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (BOOL) isValidateNameSpaceScreenWithNameSpace:(NSString *) nameSpace {
   if (nameSpace == nil || [nameSpace length] == 0) {
       return NO;
    } else {
        return YES;
    }
}

- (BOOL) isValidateNameSpaceScreenWithAPIKey:(NSString *) apiKey {
   if (apiKey == nil || [apiKey length] == 0) {
       return NO;
    } else {
        return YES;
    }
}

- (BOOL) isValidateLoginScreenWithUserName:(NSString *)username andPassword:(NSString *) password {
    NSString * msg = nil;
    
    if (username == nil || [username length] == 0) {
        msg = @"Please enter username.";
    } else if (([Helper isValidateEmailWithString:username] || [Helper isValidateMobileWithString:username]) == NO) {
        msg = @"Please enter correct username.";
    } else if ([password length] == 0) {
        msg = @"Please enter password.";
    }
    
    if (msg) {
        [Helper showAlertOnController:@"eRTC" withMessage:msg onController:self];
         return NO;
    } else {
         return YES;
    }
}

- (BOOL) isValidateForgotScreenWithEmail:(NSString *) email {
    
    NSString * msg = nil;
    
    if (email == nil || [email length] == 0) {
        msg = @"Please enter email.";
    } else if (![Helper isValidateEmailWithString:email]) {
        msg = @"Please enter correct email.";
    }
    
    if (msg) {
        [Helper showAlertOnController:@"eRTC" withMessage:msg onController:self];
        return NO;
    } else {
        return YES;
    }
}

@end
