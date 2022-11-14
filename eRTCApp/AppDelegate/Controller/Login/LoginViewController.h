//
//  LoginViewController.h
//  eRTCApp
//
//  Created by rakesh  palotra on 26/12/18.
//  Copyright © 2018 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FirebaseMessaging/FirebaseMessaging.h>
#import <Firebase/Firebase.h>

NS_ASSUME_NONNULL_BEGIN
@class AuthManager;
@class InAppChatWebServices;

@interface LoginViewController : LogineRTCBaseViewController
@property (weak, nonatomic) IBOutlet UIView *vwPassword;

@property (weak, nonatomic) IBOutlet UIView *vwEmail;

@end

NS_ASSUME_NONNULL_END
