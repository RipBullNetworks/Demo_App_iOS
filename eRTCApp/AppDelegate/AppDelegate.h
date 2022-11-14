//
//  AppDelegate.h
//  eRTCApp
//
//  Created by rakesh  palotra on 24/12/18.
//  Copyright © 2018 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <UserNotifications/UserNotifications.h>
#import <FirebaseMessaging/FirebaseMessaging.h>
#import <Firebase/Firebase.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate,FIRMessagingDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

@property (strong, nonatomic) eRTCSDK *ertcObj;

@property ( nonatomic) BOOL isUpdateChatHistory;


- (void)saveContext;
+ (AppDelegate *)sharedAppDelegate;
- (void)willChangeLoginAsRootOfApplication;
- (void)willChangeTabBarAsRootOfApplication;
- (void)willChangeLogoutAsRootOfApplication;
- (BOOL)isNetworkReachable;



@end

