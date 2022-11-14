//
//  AppDelegate.m
//  eRTCApp
//
//  Created by rakesh  palotra on 24/12/18.
//  Copyright © 2018 Ripbull Network. All rights reserved.
//

#import "AppDelegate.h"
#import "NameSpaceViewController.h"
#import "eRTCTabBarViewController.h"
#import "SingleChatViewController.h"
#import "GroupChatViewController.h"
#import "Reachability.h"
#import <Bugsnag/Bugsnag.h>
#import "Helper.h"
#import "InfoGroupViewController.h"
#import "RecentChatViewController.h"
#import "chatRecentTabVc.h"
#import "ChatRestorationViewController.h"//LoginViewController
#import "LoginViewController.h"


//chatRecentTabVc

@import Firebase;
@import UserNotifications;

@interface AppDelegate () {
    Reachability *_reachable;
    NSString *InstanceID;
    UIView *AnnouncementView;
    UIView *backGroundView;
    NSMutableDictionary *dictAnnouncements;
    NSMutableArray *_arrAnnounceMent;
}

@property (nonatomic, strong) NSString *strUUID;
@property (nonatomic, strong) NSString *strDeviceToken;

@end

@implementation AppDelegate
NSString *const kGCMMessageIDKey = @"gcm.message_id";



+ (AppDelegate *)sharedAppDelegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

NSString *KeyPublic_Private = @"";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _arrAnnounceMent = [NSMutableArray new];
   // UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Title1" message:[NSString stringWithFormat:@"%@",launchOptions] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
   // [alertView show];
//    [application setStatusBarStyle:];
    if (@available(iOS 13.0, *)) {
        application.statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
        // Fallback on earlier versions
    }
    
  // [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//    [UINavigationBar appearance].shadowImage = [UIImage new];
//    [UINavigationBar appearance].backgroundColor = [UIColor clearColor];
   // [UINavigationBar appearance].translucent = NO;
    [[UINavigationBar appearance]setTitleTextAttributes:@{
        NSFontAttributeName:[UIFont fontWithName:@"SFProDisplay-Bold" size:20]}];
    //UIBarButtonItem *navBarButtonAppearance = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]];

//    [navBarButtonAppearance setTitleTextAttributes:@{
//        NSFontAttributeName:            [UIFont systemFontOfSize:18],
//        NSForegroundColorAttributeName: [UIColor blueColor] }
//                                          forState:UIControlStateNormal];
    
    

    NSLog(@"AppDelegate.m -> didFinishLaunchingWithOptions -> launchOptions :%@",launchOptions);
   // Fabric.with([Crashlytics.self])
    // Override point for customization after application launch.
   // [Bugsnag startBugsnagWithApiKey:@"xrawtjlvu3a17xlljmja5m65f9c1kxm0"];
    
    // for testing error log on portal
   // [Bugsnag notifyError:[NSError errorWithDomain:@"com.example" code:408 userInfo:nil]];
    
    [FIRApp configure];
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    [FIRMessaging messaging].delegate = self;
#endif
    [self registerRemoteNotification];
    
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    /* Reachability */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    _reachable = [Reachability reachabilityForInternetConnection];
    [_reachable startNotifier];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(tokenRefreshCallback:)
     name:kFIRInstanceIDTokenRefreshNotification object:nil ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogout:) name:@"didUserDeactivated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAnnouncement:) name:DidGetChatAnnounceMentNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAnnounceMent:) name:DidRefreshAnnouncementpopup object:nil];
    
        if (launchOptions != nil)
        {
             //opened from a push notification when the app is closed
            NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
            if (userInfo != nil)
            {
                 NSLog(@"userInfo->%@",[userInfo objectForKey:@"aps"]);
                 //write you push handle code here
               // if (application.applicationState == UIApplicationStateActive) {
    //            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Title2" message:[NSString stringWithFormat:@"%@",userInfo] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
    //                 [alertView show];

            //        [self processRemotePushNotifications:userInfo];
              //  }

            }

        }
    /* eRTCSDK initialization */
    //self.ertcObj = [[eRTCSDK alloc] initWithApiKey:@"54j60ilimxo6s6hlru8ruy1w067boo6f"];
    
   // work2 // ninjacoderrakesh@gmail.com
//    self.ertcObj = [[eRTCSDK alloc] initWithApiKey:APIKEY];
    
    // work2 // rakesh.palotra@gmal.com
  //  self.ertcObj = [[eRTCSDK alloc] initWithApiKey:@"dr2kb5uflk8t0ai8l3r0awlvtunbog3l"];

    // work3
//    self.ertcObj = [[eRTCSDK alloc] initWithApiKey:@"exkuhf2l0lzfi5vnhv50pljod1j21a31"];
    /* set root controller */
    
    //[self willChangeLoginAsRootOfApplication];
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:IsLoggedIn] isEqualToString:@"YES"]) {
        NSString *strStoredKey = [[NSUserDefaults standardUserDefaults]valueForKey:@"API_Key"];
        [[eRTCSDK alloc] initWithApiKey:strStoredKey];
        [[eRTCAppUsers sharedInstance] connectMQTT];
        [self willChangeTabBarAsRootOfApplication];
  } else {
        [self willChangeLoginAsRootOfApplication];
    }
    
    /* IQKeyboardManager */
    //    [[IQKeyboardManager sharedManager] setEnable:NO];

    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[NSUserDefaults standardUserDefaults]setValue:@"0" forKey:@"badgeCount"];
    if (@available(iOS 13.0, *)) {
        self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    } else {
        // Fallback on earlier versions
    }
    
    [UITextView appearance].linkTextAttributes = @{ NSForegroundColorAttributeName : UIColor.blueColor };
   // [self announcementPopup];
    return YES;
}

- (void)getPendingEventData{
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:IsLoggedIn] isEqualToString:@"YES"]) {
        UIDevice *device = [UIDevice currentDevice];

        NSString  *currentDeviceId = [eRTCHelper getUUID];//[[device identifierForVendor] UUIDString];
        NSString *useruuid = [eRTCHelper getUUID];//[[[UIDevice currentDevice] identifierForVendor] UUIDString];

        NSDictionary *dictParam = @{@"deviceId": currentDeviceId};
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        chatRecentTabVc *rcv = [self getRecentChatViewController];
        if (rcv != NULL){
            [rcv showPendingEventActivity];
        }
        
        [[eRTCChatManager sharedChatInstance] getPendingEvents:nil andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
            if (rcv != NULL){
                [rcv hidePendingEventActivity];
                [rcv refereshData];
            }
        } andFailure:^(NSError * _Nonnull error) {
            NSLog(@"error = %@",error);
            [rcv hidePendingEventActivity];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        }];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"AppDelegate.m -> applicationDidEnterBackground");
    [[FIRMessaging messaging] setShouldEstablishDirectChannel:NO];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"AppDelegate.m -> applicationDidBecomeActive");
    // jump to the custom connectToFirebase method defination
    [self connetToFireBase];
    
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:IsLoggedIn] isEqualToString:@"YES"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [[eRTCAppUsers sharedInstance] resetNotificationBadgeCount:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            } andFailure:^(NSError * _Nonnull error) {
                NSLog(@"AppDelegate[Error] --> applicationDidBecomeActive -> %@",error);
            }];
        });
        [self getPendingEventData];
  }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"AppDelegate.m -> applicationWillEnterForeground");
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[NSUserDefaults standardUserDefaults]setValue:@"0" forKey:@"badgeCount"];
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:IsLoggedIn] isEqualToString:@"YES"]) {
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:RestorationAvailability] isEqualToString:@"YES"]) {
//            UINavigationController *CurrentNavController = ((UITabBarController*)[AppDelegate sharedAppDelegate].window.rootViewController).selectedViewController;
//               id CurrentViewController = CurrentNavController.viewControllers.lastObject;
//               if ([CurrentViewController isKindOfClass:[ChatRestorationViewController class]] || [CurrentViewController isKindOfClass:[ChatRestorationViewController class]]) {
//                   [[NSNotificationCenter defaultCenter] postNotificationName:UpdatChatWindowNotification object:nil userInfo:nil];
//               }
       }else{
        UINavigationController *CurrentNavController = ((UITabBarController*)[AppDelegate sharedAppDelegate].window.rootViewController).selectedViewController;
           id CurrentViewController = CurrentNavController.viewControllers.lastObject;
           if ([CurrentViewController isKindOfClass:[SingleChatViewController class]] || [CurrentViewController isKindOfClass:[GroupChatViewController class]]) {
               [[NSNotificationCenter defaultCenter] postNotificationName:UpdatChatWindowNotification object:nil userInfo:nil];
           }
        }
    }
    
    /*
     -(void)navigateToLoginScreen{
         [[NSUserDefaults standardUserDefaults]setValue:@"YES" forKey:IsLoggedIn];
         ChatRestorationViewController *crVC =  [[Helper ChatRestorationStoryBoard] instantiateViewControllerWithIdentifier:@"ChatRestorationViewController"];
        [self.navigationController pushViewController:crVC animated:TRUE];
        // [[AppDelegate sharedAppDelegate] willChangeTabBarAsRootOfApplication];

     }
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"AppDelegate.m -> applicationWillTerminate");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
   // [eRTCSDK saveDB];
}

-(void)registerRemoteNotification
{
    NSLog(@"AppDelegate.m -> registerRemoteNotification");
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        UIUserNotificationType allNotificationTypes =(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =[UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        // iOS 10 or later
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert| UNAuthorizationOptionSound| UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
            NSLog(@"AppDelegate.m -> registerRemoteNotification -> %@",error);
        }];
        [FIRMessaging messaging].delegate = self;
    }
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSLog(@"AppDelegate.m -> didRegisterForRemoteNotificationsWithDeviceToken ->  = %@",deviceToken);
    [FIRMessaging messaging].APNSToken = deviceToken;
    
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSLog(@"content>>>>>>>>>>>>123>>>>>>---%@", token);
    NSString *str2 = [self fetchDeviceToken:deviceToken];
    NSLog(@"str2>>>>>>>>>>>>str2>>>>>>---%@", str2);
    
    NSUInteger dataLength = deviceToken.length;
    const unsigned char *dataBuffer = (const unsigned char *)deviceToken.bytes;
    NSMutableString *deviceTokenString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for (int i = 0; i < dataLength; ++i) {
        [deviceTokenString appendFormat:@"%02x", dataBuffer[i]];
    }
    
    NSLog(@"The generated device token string is : %@",deviceTokenString);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"AppDelegate.m -> didFailToRegisterForRemoteNotificationsWithError ->  = %@",@"Push notifications are not supported in the iOS Simulator.");
    }
    else {
        NSLog(@"AppDelegate.m -> didFailToRegisterForRemoteNotificationsWithError ->  = %@",@"Push notifications are not supported in the iOS Simulator.");
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void(^)(UIBackgroundFetchResult))completionHandler {
    
    // Handle of push notification on state
//    if(application.applicationState == UIApplicationStateActive) {
//        }else{
            NSLog(@"AppDelegate.m -> didReceiveRemoteNotification -> %@",userInfo);
            NSString * jsonString = [userInfo valueForKey:@"message"];
            NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary  *jsonnew = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSString *eventType = userInfo[@"eventType"];
            if ([userInfo[@"eventType"] isEqualToString:@"logout"]) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:IsLoggedIn];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:IsRestoration];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[UserModel sharedInstance]logOutUser];
                [[AppDelegate sharedAppDelegate] willChangeLoginAsRootOfApplication];
            }
            
            [[UIApplication sharedApplication] registerForRemoteNotifications];
            int badgeValue = [[[NSUserDefaults standardUserDefaults]valueForKey:@"badgeCount"] intValue];
            badgeValue = badgeValue +1;
            NSString *strUpdatedBadgeCount =[NSString stringWithFormat:@"%d",badgeValue];
            [[NSUserDefaults standardUserDefaults]setValue:strUpdatedBadgeCount forKey:@"badgeCount"];

            NSLog(@"badgeValue--%d",badgeValue);
            [UIApplication sharedApplication].applicationIconBadgeNumber = badgeValue;
            [application setApplicationIconBadgeNumber:[[[userInfo objectForKey:@"aps"] objectForKey:@"badge"] intValue]];

            if ( application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground)
            {
                completionHandler(UIBackgroundFetchResultNewData | UIBackgroundFetchResultNoData | UIBackgroundFetchResultFailed);
            }
            if ( application.applicationState == UIApplicationStateActive){
                
                NSString *message = userInfo[@"message"];
                if (!message) return;
                
                NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *threadObj  = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (threadObj == NULL  || ![threadObj isKindOfClass:NSDictionary.class])
                    return;
                [[NSNotificationCenter defaultCenter] postNotificationName:DidRecievedMessageNotification object:nil userInfo:threadObj];
            }
       // }
}

-(chatRecentTabVc*)getRecentChatViewController {
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:RestorationAvailability] isEqualToString:@"YES"]) {
    }else{
        UIViewController *tabController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        UINavigationController *nvc  = ((UITabBarController*)tabController).viewControllers.firstObject;
        UIViewController *recentVC = [[nvc viewControllers] firstObject];
        if ([recentVC isKindOfClass:RecentChatViewController.class]){
            return (chatRecentTabVc*)recentVC;
        }
    }
    return NULL;
}
-(void)openChatScreen:(NSDictionary*) notiMSG {
    
    
    BOOL isChatMessage = FALSE;
    if (notiMSG != NULL && [notiMSG[@"eventType"] isEqual:@"chat"]){
        isChatMessage = TRUE;
    }
    NSString *message = notiMSG[@"message"];
    if (!message) return;
    if (!isChatMessage){return;}
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *threadObj  = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (threadObj == NULL  || ![threadObj isKindOfClass:NSDictionary.class]) return;
    NSDictionary *object = [self getRecentChat:threadObj];
    if (object == NULL) return;
    
    UIViewController *tabController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    
    BOOL isSingleChat = FALSE;
    
    if (threadObj[@"thread"] != NULL && [threadObj[@"thread"][@"threadType"] isEqual:@"single"]){
        isSingleChat = TRUE;
    }
    
    BOOL isGroupChat = FALSE;
    if (threadObj[@"thread"] != NULL && [threadObj[@"thread"][@"threadType"] isEqual:@"group"]){
        isSingleChat = FALSE;
        isGroupChat = TRUE;
    }
    
    UINavigationController *nvc  = ((UITabBarController*)tabController).viewControllers.firstObject;
    if ([tabController isKindOfClass:UITabBarController.class] && [nvc isKindOfClass:UINavigationController.class]){
        NSUInteger selectedIndex = ((UITabBarController*)tabController).selectedIndex;
        if (selectedIndex != 0){
            ((UITabBarController*)tabController).selectedIndex = 0;
        }else {
            [nvc popToRootViewControllerAnimated:FALSE];
        }
        
        UIViewController *vc;
        //push new controller with thread
        if (isSingleChat){
            SingleChatViewController * scs = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"SingleChatViewController"];
            scs.dictUserDetails = object;
            vc = scs;
        }
        if (isGroupChat){
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle bundleForClass:InfoGroupViewController.class]];
            GroupChatViewController *gcs = [story instantiateViewControllerWithIdentifier:NSStringFromClass(GroupChatViewController.class)];
            gcs.dictGroupinfo = object;
            vc = gcs;
        }
        
        if (vc != NULL){
           UIViewController *recentVC = [[nvc viewControllers] firstObject];
            if ([recentVC isKindOfClass:RecentChatViewController.class]){
                [((RecentChatViewController*)recentVC) addController:vc];
                [nvc pushViewController:vc animated:TRUE];
            }
            
        }
    }
}

- (NSDictionary*)getRecentChat:(NSDictionary*)_obj  {
    __block NSDictionary * _dict = NULL;
    NSString *chatUserId = [_obj valueForKey:RecipientAppUserId];
    NSString *threadId = NULL;
    NSString *threadType = NULL;
    if (_obj[@"thread"] != NULL && _obj[@"thread"][@"threadId"] != NULL){
        threadId = _obj[@"thread"][@"threadId"];
    }
    if (_obj[@"thread"] != NULL && _obj[@"thread"][@"threadType"] != NULL){
        threadType = _obj[@"thread"][@"threadType"];
    }
    if (threadId == NULL || threadType == NULL)return NULL;
    
    [[eRTCChatManager sharedChatInstance] getActiveThreads:^(NSArray *list, NSString * _Nonnull errMsg) {
        [list enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj[@"threadId"] isEqual:threadId]){
                NSMutableDictionary *dict = @{}.mutableCopy;
                
                [[eRTCAppUsers sharedInstance] fetchUserDetailWithAppUserId:obj andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                    NSLog(@"RecentChatViewController -> refreshTableDataWith --> fetchUserDetailWithAppUserId -> %@",json);
                    
                    if(json[User_Name] != nil) {
                        [dict setObject:[NSString stringWithFormat:@"%@", json[User_Name]] forKey:User_Name];
                    }
                    if(json[TenantID] != nil) {
                        [dict setObject:[NSString stringWithFormat:@"%@", json[TenantID]] forKey:TenantID];
                    }
                    if(json[User_ID] != nil) {
                        [dict setObject:[NSString stringWithFormat:@"%@", json[User_ID]] forKey:User_ID];
                    }
                    if(json[User_ProfileStatus] != nil) {
                        [dict setObject:[NSString stringWithFormat:@"%@", json[User_ProfileStatus]] forKey:User_ProfileStatus];
                    }
                    if(json[User_ProfilePic] != nil) {
                        [dict setObject:[NSString stringWithFormat:@"%@", json[User_ProfilePic]] forKey:User_ProfilePic];
                    }
                    if(json[User_ProfilePic_Thumb] != nil) {
                        [dict setObject:[NSString stringWithFormat:@"%@", json[User_ProfilePic_Thumb]] forKey:User_ProfilePic_Thumb];
                    }
                    if(json[App_User_ID] != nil) {
                        [dict setObject:[NSString stringWithFormat:@"%@", json[App_User_ID]] forKey:App_User_ID];
                    }
                    if(json[ThreadID] != nil) {
                        [dict setObject:[NSString stringWithFormat:@"%@", json[ThreadID]] forKey:ThreadID];
                    }
                    if(json[AvailabilityStatus] != nil) {
                        [dict setObject:[NSString stringWithFormat:@"%@", json[AvailabilityStatus]] forKey:AvailabilityStatus];
                    }
                    if(json[Group_GroupId] != nil) {
                        [dict setObject:[NSString stringWithFormat:@"%@", json[Group_GroupId]] forKey:Group_GroupId];
                    }
                    
                    if(json[Group_Type] != nil) {
                        [dict setObject:[NSString stringWithFormat:@"%@", json[Group_Type]] forKey:Group_Type];
                    }
                    
                    NSString *unReadMsg = [_obj valueForKey:UnReadMessageCount];
                    if(unReadMsg != nil && [unReadMsg length] > 0) {
                        [dict setObject:[NSString stringWithFormat:@"%@", unReadMsg] forKey:UnReadMessageCount];
                    }
                    
                    if(json[@"availabilityStatus"] != nil) {
                    [dict setObject:[NSString stringWithFormat:@"%@", json[@"availabilityStatus"]] forKey:@"availabilityStatus"];
                    }

                    if(json[@"blockedStatus"] != nil) {
                    [dict setObject:[NSString stringWithFormat:@"%@", json[@"blockedStatus"]] forKey:@"blockedStatus"];
                    }

                } andFailure:^(NSError * _Nonnull error) {
                    return;
                }];
                
                [[eRTCCoreDataManager sharedInstance] getUserChatHistoryWithThreadID:threadId andCompletionHandler:^(id ary, NSError *err) {
                    NSLog(@"RecentChatViewController -> refreshTableDataWith --> getUserChatHistoryWithThreadID -> %@",ary);

                    NSUInteger chatCount = [ary count];
                    if(chatCount > 0) {
                        NSDictionary * _chatObj = [ary objectAtIndex:chatCount -1];
                        if(_chatObj[Message] != nil) {
                            [dict setObject:[NSString stringWithFormat:@"%@", _chatObj[Message]] forKey:Message];
                        }
                        /*
                        if(_chatObj[ThreadID] != nil && _chatObj[MsgUniqueId] != nil) {
                            [[eRTCCoreDataManager sharedInstance] getUserReplyThreadChatHistoryWithThreadID:_chatObj[ThreadID] withParentID:_chatObj[MsgUniqueId] andCompletionHandler:^(id ary, NSError *err) {
                                NSLog(@"RecentChatViewController ->  refreshTableDataWith -> getUserReplyThreadChatHistoryWithThreadID -> %@",ary);
                                NSUInteger threadChatCount = [ary count];
                                if(threadChatCount > 0) {
                                    NSDictionary * _threadChatObj = [ary objectAtIndex:threadChatCount -1];
                                    if(_threadChatObj[Message] != nil) {
                                        NSString *threadMsg = [NSString stringWithFormat:@"%@", _threadChatObj[Message]];
                                        NSString *chatMsg = [NSString stringWithFormat:@"%@", _chatObj[Message]];
                                        NSString *strMessage = [chatMsg stringByAppendingFormat:@" %@",threadMsg];
                                        [dict setObject:strMessage forKey:Message];
                                    }
                                }else{
                                    if(_chatObj[Message] != nil) {
                                        [dict setObject:[NSString stringWithFormat:@"%@", _chatObj[Message]] forKey:Message];
                                    }
                                }
                            }];
                        }*/
                       /* if(_chatObj[Message] != nil) {
                            [dict setObject:[NSString stringWithFormat:@"%@", _chatObj[Message]] forKey:Message];
                        }*/
                         if(_chatObj[@"createdAt"] != nil) {
                            [dict setObject:[NSString stringWithFormat:@"%@", _chatObj[@"createdAt"]] forKey:@"createdAt"];
                        }
                        if(_chatObj[MsgType] != nil) {
                            [dict setObject:[NSString stringWithFormat:@"%@", _chatObj[MsgType]] forKey:MsgType];
                        }
                        if(_chatObj[MsgStatusEvent] != nil) {
                            [dict setObject:[NSString stringWithFormat:@"%@", _chatObj[MsgStatusEvent]] forKey:MsgStatusEvent];
                        }
                    }
                    else if(chatCount == 0) {
                        [dict removeAllObjects];
                    }
                }];
                dict[@"threadType"] = threadType;
                _dict = dict.copy;
                
            }
        }];
        

        
    } andFailure:^(NSError * _Nonnull error) {
        NSLog(@"RecentChatViewController -> getRecentChat --> getActiveThreads -> %@",error);
    }];
    
    return _dict;

}
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler{
    NSLog(@"AppDelegate.m -> didReceiveNotificationResponse -> %@",response.notification.request.content.userInfo);
    //[eRTCSDK didReceiveRemoteNotification:response.notification.request.content.userInfo];
    [self openChatScreen:response.notification.request.content.userInfo];
    completionHandler();
}



-(void)tokenRefreshCallback:(NSNotification *)notification {
    [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result,    NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"AppDelegate.m -> tokenRefreshCallback -> %@",error);
        } else {
            NSLog(@"AppDelegate.m -> tokenRefreshCallback -> %@",result.token);
        }
    }];
    [self connetToFireBase];
}

-(void)connetToFireBase
{
    NSLog(@"AppDelegate.m -> connetToFireBase");

//    NSLog(@"AppDelegate.m -> connetToFireBase);
    [[FIRMessaging messaging] setShouldEstablishDirectChannel:YES];

}

/*
 Push Notification will be shown while app is in foregroung from iOS 10 Onwards
 First  Include            #import <UserNotifications/UserNotifications.h>
 second Include            <UNUserNotificationCenterDelegate>
 */
- (void)userNotificationCenter:(UNUserNotificationCenter* )center
       willPresentNotification:(UNNotification* )notification
         withCompletionHandler:(void (^)
                                (UNNotificationPresentationOptions options))completionHandler {
    NSLog(@"AppDelegate.m -> willPresentNotification ->%@",notification.request.content.userInfo);
    //[eRTCSDK didReceiveRemoteNotification:notification.request.content.userInfo];

    completionHandler(UNNotificationPresentationOptionAlert |
                      UNNotificationPresentationOptionBadge |
                      UNNotificationPresentationOptionSound);
}

/*
 Call this method when user want to open app while in
 foreground on tapping push notification
 */
- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"AppDelegate.m -> applicationWillResignActive");

    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:fcmToken forKey:@"token"];
    NSLog(@"AppDelegate.m -> didReceiveRegistrationToken ->%@",dataDict);
    [[NSNotificationCenter defaultCenter] postNotificationName:
     @"FCMToken" object:nil userInfo:dataDict];
}

- (void)messaging:(FIRMessaging *)messaging didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    NSLog(@"AppDelegate.m -> didReceiveMessage ->%@",remoteMessage.appData);

    [self processRPN:remoteMessage.appData];

//    if (remoteMessage.appData != nil && [remoteMessage.appData count] > 0) {
//        if([remoteMessage.appData[@"eventType"] isEqualToString:@"userDBUpdated"]) {
//            NSString * jsonString = remoteMessage.appData[@"message"];
//            NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//         //   NSLog(@"AppDelegate.m -> didReceiveMessage - JSON -> %@",json);
//            NSDictionary  *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//            [[eRTCAppUsers sharedInstance] syncChatUserListWithUpdateType:json[@"event"]];
//        }else if (remoteMessage.appData[@"message"] != nil) {
//            NSString * jsonString = remoteMessage.appData[@"message"];
//            NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//            NSDictionary  *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//            NSLog(@"AppDelegate.m -> didReceiveMessage - JSON2 -> %@",json);
//            [[eRTCChatManager sharedChatInstance] insertChatMessagesWith:json];
//        }
//    }
}

-(void)processRPN:(NSDictionary *)remoteMessage{
    NSString * strEvent = [remoteMessage valueForKey:@"eventType"];
    NSLog(@"strEvent %@", strEvent);
    if([strEvent isEqualToString:@"userDBUpdated"]){
          NSString * jsonString = [remoteMessage valueForKey:@"message"];
         NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
         NSDictionary  *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"AppDelegate.m -> didReceiveMessage - JSON -> %@",json);
         [[eRTCAppUsers sharedInstance] syncChatUserListWithUpdateType:[json valueForKey:@"event"]];
    }else if([[remoteMessage valueForKey:@"eventType"]isEqualToString:@"tenantConfigModified"]) {
        
        [eRTCSDK updateFeatureConfig:^(BOOL isValid, NSString *errMsg) {
            NSLog(@"Feature config updated");
        } andFailure:^(NSError *error) {
            NSLog(@"Failed to update Feature config");
        }];
    }

}

-(void)processRemotePushNotifications:(NSDictionary *)remoteMessage{
    
    if ([remoteMessage valueForKey:@"aps"] != nil && [[remoteMessage valueForKey:@"aps"] count] > 0) {
        if([[remoteMessage valueForKey:@"eventType"] isEqualToString:@"userDBUpdated"]){
              NSString * jsonString = [remoteMessage valueForKey:@"message"];
             NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
             NSDictionary  *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"AppDelegate.m -> didReceiveMessage - JSON -> %@",json);
             [[eRTCAppUsers sharedInstance] syncChatUserListWithUpdateType:[json valueForKey:@"event"]];
        }else if([[remoteMessage valueForKey:@"eventType"]isEqualToString:@"tenantConfigModified"]) {
            
            [eRTCSDK updateFeatureConfig:^(BOOL isValid, NSString *errMsg) {
                NSLog(@"Feature config updated");
            } andFailure:^(NSError *error) {
                NSLog(@"Failed to update Feature config");
            }];
        }
        else if([remoteMessage valueForKey:@"message"]!=nil){
            NSString * jsonString = [remoteMessage valueForKey:@"message"];
            NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary  *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"AppDelegate.m -> didReceiveMessage - JSON2 -> %@",json);
//            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"AppDelegate" message:@"ForcQuitDB function" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            [alert show];
            [[eRTCChatManager sharedChatInstance] insertChatMessagesWith:json];
            [[NSNotificationCenter defaultCenter] postNotificationName:DidRecievedMessageNotification object:nil userInfo:json];
        }
    }
}

/*!
 * Called by user Deactivated
 */
-(void) userLogout:(NSNotification *) note {
    UIWindow* topWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    topWindow.rootViewController = [UIViewController new];
    topWindow.windowLevel = UIWindowLevelAlert + 1;
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"eRTC" message:@"Your account got deactivated. Please contact your administrator" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:IsLoggedIn];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[UserModel sharedInstance]logOutUser];
        [[AppDelegate sharedAppDelegate] willChangeLoginAsRootOfApplication];
        topWindow.hidden = YES;
    }]];
    [topWindow makeKeyAndVisible];
    [topWindow.rootViewController presentViewController:alert animated:YES completion:nil];
 }

-(void)getAnnouncement:(NSNotification *) dictAnnounce {
    NSDictionary *dict = dictAnnounce.object;
    [_arrAnnounceMent addObject:dict];
//    NSArray* reversedArray = [[_arrAnnounceMent reverseObjectEnumerator] allObjects];
//    _arrAnnounceMent = [NSMutableArray new];
//    _arrAnnounceMent = reversedArray.mutableCopy;
     //[AnnouncementView removeFromSuperview];
     [self announcementPopup:dict];
}

- (void) reachabilityChanged:(NSNotification *)note
{
    NSLog(@"AppDelegate.m -> reachabilityChanged");

    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    _reachable = curReach;
}

- (BOOL)isNetworkReachable {
    
    if (_reachable == nil || [_reachable currentReachabilityStatus] == NotReachable) {
        return NO;
    }
    return YES;
}

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"eRTCApp"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        abort();
    }
}

#pragma mark - change rootViewController
- (void)willChangeLoginAsRootOfApplication {
    NameSpaceViewController * _vcNameSpace = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"NameSpaceViewController"];
    UINavigationController *_navController = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"LoginNavigation"];
    _navController = [_navController initWithRootViewController:_vcNameSpace];
    [UIView transitionWithView:self.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        self.window.rootViewController = _navController;
                        [self.window makeKeyAndVisible];
                    } completion:^(BOOL finished) {
                        // Code to run after animation
                    }];
}

#pragma mark - change rootViewController
- (void)willChangeLogoutAsRootOfApplication {
    LoginViewController * _vcNameSpace = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    UINavigationController *_navController = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"LoginNavigation"];
    _navController = [_navController initWithRootViewController:_vcNameSpace];
    [UIView transitionWithView:self.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        self.window.rootViewController = _navController;
                        [self.window makeKeyAndVisible];
                    } completion:^(BOOL finished) {
                        // Code to run after animation
                    }];
}



- (void)willChangeTabBarAsRootOfApplication {
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:IsLoggedIn] isEqualToString:@"YES"]) {
    eRTCTabBarViewController * _vcTabBar = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"eRTCTabBarViewController"];
    _vcTabBar.selectedIndex = 0;
    [UIView transitionWithView:self.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        self.window.rootViewController = _vcTabBar;
                        [self.window makeKeyAndVisible];
                    } completion:^(BOOL finished) {
                        // Code to run after animation
                    }];
    
    }
}


#pragma mark -

-(void)didRecievedMessage:(id)message {
    NSLog(@"AppDelegate.m -> didRecievedMessage ->%@",message);
}

-(void)announcementPopup:(NSDictionary *)dictData {
    [self->backGroundView removeFromSuperview];
    NSTimeInterval delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self->AnnouncementView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, (self.window.frame.size.width+120)/2)];
        [self->AnnouncementView setBackgroundColor:[UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1]];
    UIImageView *imgAnnounce = [[UIImageView alloc] initWithFrame:CGRectMake(16, 60, 24, 24)];
    [imgAnnounce setImage:[UIImage imageNamed:@"Announcement"]];
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(55,58, self->AnnouncementView.bounds.size.width-70, 25)];
    lblTitle.textColor = [UIColor colorWithRed:33/255.0 green:36/255.0 blue:41/255.0 alpha:1];
        NSDictionary *dictName = dictData[@"group"];
        if (dictName[@"name"] != nil && dictName[@"name"] != [NSNull null]) {
        lblTitle.text = dictName[@"name"];
        }else{
        lblTitle.text = @"All Users";
        }
    [lblTitle setFont:[UIFont fontWithName:@"SFProDisplay-Bold" size:16.0]];
        UILabel *lblSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(55,85, self->AnnouncementView.bounds.size.width-70, 80)];
    lblSubTitle.textColor = [UIColor colorWithRed:73/255.0 green:80/255.0 blue:87/255.0 alpha:1];
   // lblSubTitle.numberOfLines = 4;
    if (dictData[Details] != nil && dictData[Details] != [NSNull null]) {
        lblSubTitle.text = dictData[Details];
    }
        CGSize expectedLabelSize = [dictData[Details] sizeWithFont:lblSubTitle.font
                                        constrainedToSize:lblSubTitle.frame.size
                                            lineBreakMode:UILineBreakModeWordWrap];
        CGRect newFrame = lblSubTitle.frame;
        newFrame.size.height = expectedLabelSize.height;
        lblSubTitle.frame = newFrame;
        lblSubTitle.numberOfLines = 4;
        [lblSubTitle sizeToFit];
    [lblSubTitle setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:16.0]];
    UIButton *btnViewAll = [[UIButton alloc] initWithFrame:CGRectMake(55,expectedLabelSize.height+10+81, self->AnnouncementView.bounds.size.width-120, 50)];
    [btnViewAll setTitle: @"View full announcement" forState: UIControlStateNormal];
    btnViewAll.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btnViewAll addTarget:self action:@selector(btnViewAll:) forControlEvents:UIControlEventTouchUpInside];
    [btnViewAll setTitleColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
        UIButton *btnDismiss = [[UIButton alloc] initWithFrame:CGRectMake(self->AnnouncementView.frame.size.width-70,btnViewAll.frame.origin.y+20, 120, 40)];
        [btnDismiss setTitle: @"Dismiss" forState: UIControlStateNormal];
        btnDismiss.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btnDismiss addTarget:self action:@selector(btnDismiss:) forControlEvents:UIControlEventTouchUpInside];
        [btnDismiss setTitleColor:[UIColor colorWithRed:73/255.0 green:80/255.0 blue:87/255.0 alpha:1.0] forState:UIControlStateNormal];
        self->AnnouncementView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width,btnViewAll.frame.origin.y+80)];
        [self->AnnouncementView setBackgroundColor:[UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1]];
        self->backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width,self.window.frame.size.height)];
        [self->backGroundView setBackgroundColor:UIColor.clearColor];
        self->AnnouncementView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
        self->AnnouncementView.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
        self->AnnouncementView.layer.shadowOpacity = 1.5f;
        [self->AnnouncementView addSubview:btnDismiss];
        [self->AnnouncementView addSubview:btnViewAll];
        [self->AnnouncementView addSubview:lblSubTitle];
        [self->AnnouncementView addSubview:lblTitle];
        [self->AnnouncementView addSubview:imgAnnounce];
        [self->backGroundView addSubview:self->AnnouncementView];
        [self.window addSubview:self->backGroundView];
    });

}

-(IBAction)btnViewAll:(id)sender {
    if (_arrAnnounceMent.count > 0){
    NSDictionary *dict = _arrAnnounceMent[_arrAnnounceMent.count-1];
        dictAnnouncements = [[NSMutableDictionary alloc]init];
        [dictAnnouncements setValue:_arrAnnounceMent forKey:@"announcement"];
    [[NSNotificationCenter defaultCenter] postNotificationName:DidopenAnnounceMentpopup object:dictAnnouncements.copy userInfo:nil];
    
    }
    [self->backGroundView  removeFromSuperview];
    [self->backGroundView  willRemoveSubview:self.window];
}

-(IBAction)btnDismiss:(id)sender {
    if (_arrAnnounceMent.count > 0){
        [_arrAnnounceMent removeObjectAtIndex:_arrAnnounceMent.count-1];
        if (_arrAnnounceMent.count == 0) {
            [self->backGroundView  willRemoveSubview:self.window];
            [self->backGroundView  removeFromSuperview];
        }
    }
    
    for (int i = 0; i < [self->_arrAnnounceMent count]; i++)
    {
        if (_arrAnnounceMent.count-1 == i) {
        NSDictionary *dict = _arrAnnounceMent[_arrAnnounceMent.count-1];
        [self announcementPopup:dict];
        }
    }
}

-(void)refreshAnnounceMent:(NSDictionary *)dictData {
    if (_arrAnnounceMent.count > 0){
    [_arrAnnounceMent removeObjectAtIndex:_arrAnnounceMent.count-1];
    for (int i = 0; i < [self->_arrAnnounceMent count]; i++)
    {
        if (_arrAnnounceMent.count-1 == i) {
        NSDictionary *dict = _arrAnnounceMent[_arrAnnounceMent.count-1];
        [self announcementPopup:dict];
        }
    }
 }
}

- (NSString *)fetchDeviceToken:(NSData *)deviceToken {
    NSUInteger len = deviceToken.length;
    if (len == 0) {
        return nil;
    }
    const unsigned char *buffer = deviceToken.bytes;
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(len * 2)];
    for (int i = 0; i < len; ++i) {
        [hexString appendFormat:@"%02x", buffer[i]];
    }
    return [hexString copy];
}

@end

