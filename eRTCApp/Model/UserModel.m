//
//  UserModel.m
//  eRTCApp
//
//  Created by rakesh  palotra on 05/01/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import "UserModel.h"
#import "eRTC-Swift.h"

@implementation UserModel

+ (id)sharedInstance {
    static dispatch_once_t once;
    static UserModel *instance;
    dispatch_once(&once, ^{
        instance = [[UserModel alloc] init];
       
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

-(void)saveUserDetailsWith:(NSDictionary *) dictUser  {
    NSLog(@"json saveUserDetailsWith-->>>>>>>>>>>>%@",dictUser);
    if (_userDefaults != nil) {
        if (dictUser[User_ID] != nil && dictUser[User_ID] != [NSNull null]) {
            [_userDefaults setObject:dictUser[User_ID] forKey:User_ID];
        }
        
        if (dictUser[App_User_ID] != nil && dictUser[App_User_ID] != [NSNull null]) {
            [_userDefaults setObject:dictUser[App_User_ID] forKey:App_User_ID];
        }
        
        if (dictUser[User_Name] != nil && dictUser[User_Name] != [NSNull null]) {
            [_userDefaults setObject:dictUser[User_Name] forKey:User_Name];
        }
        
        if (dictUser[User_LoginTimeStamp] != nil && dictUser[User_LoginTimeStamp] != [NSNull null]) {
            [_userDefaults setObject:dictUser[User_LoginTimeStamp] forKey:User_LoginTimeStamp];
        }
        
        if (dictUser[User_ProfilePic] != nil && dictUser[User_ProfilePic] != [NSNull null]) {
            [_userDefaults setObject:dictUser[User_ProfilePic] forKey:User_ProfilePic];
        }else {
            [_userDefaults setObject:NULL forKey:User_ProfilePic];
        }
        
        if (dictUser[User_ProfilePic_Thumb] != nil && dictUser[User_ProfilePic_Thumb] != [NSNull null]) {
            [_userDefaults setObject:dictUser[User_ProfilePic_Thumb] forKey:User_ProfilePic_Thumb];
        }else {
            [_userDefaults setObject:NULL forKey:User_ProfilePic_Thumb];
        }
        
        if (dictUser[User_eRTCUserId] != nil && dictUser[User_eRTCUserId] != [NSNull null]) {
            [_userDefaults setObject:dictUser[User_eRTCUserId] forKey:User_eRTCUserId];
        }
        
        if (dictUser[TenantID] != nil && dictUser[TenantID] != [NSNull null]) {
            [_userDefaults setObject:dictUser[TenantID] forKey:TenantID];
        }
        if (dictUser[User_ProfileStatus] != nil && dictUser[User_ProfileStatus] != [NSNull null]) {
            [_userDefaults setObject:dictUser[User_ProfileStatus] forKey:User_ProfileStatus];
        }
        if (dictUser[User_ProfileStatus] != nil && dictUser[User_ProfileStatus] != [NSNull null]) {
                   [_userDefaults setObject:dictUser[AvailabilityStatus] forKey:AvailabilityStatus];
            }
        if (dictUser[User_ProfileStatus] != nil && dictUser[User_ProfileStatus] != [NSNull null]) {
               [_userDefaults setObject:dictUser[@"notificationSettings"] forKey:@"notificationSettings"];
        }
        [_userDefaults synchronize];
    }
}

-(void)logOutUser  {
    AuthManager* auth0Manager = [AuthManager sharedInstance];
    [auth0Manager logout];
    if (_userDefaults != nil) {
        if ([_userDefaults objectForKey:User_ID] != nil) {
            [_userDefaults removeObjectForKey:User_ID];
        }
        
        if ([_userDefaults objectForKey:App_User_ID] != nil) {
            [_userDefaults removeObjectForKey:App_User_ID];
        }
        
        if ([_userDefaults objectForKey:User_Name] != nil) {
            [_userDefaults removeObjectForKey:User_Name];
        }
        
        if ([_userDefaults objectForKey:User_LoginTimeStamp] != nil) {
            [_userDefaults removeObjectForKey:User_LoginTimeStamp];
        }

        if ([_userDefaults objectForKey:User_ProfilePic] != nil) {
            [_userDefaults removeObjectForKey:User_ProfilePic];
        }
        
        if ([_userDefaults objectForKey:User_ProfilePic_Thumb] != nil) {
            [_userDefaults removeObjectForKey:User_ProfilePic_Thumb];
        }
        
        if ([_userDefaults objectForKey:User_LoginTimeStamp] != nil) {
            [_userDefaults removeObjectForKey:User_LoginTimeStamp];
        }
        
        if ([_userDefaults objectForKey:User_eRTCUserId] != nil) {
            [_userDefaults removeObjectForKey:User_eRTCUserId];
        }
        
        if ([_userDefaults objectForKey:TenantID] != nil) {
            [_userDefaults removeObjectForKey:TenantID];
        }
        if ([_userDefaults objectForKey:User_ProfileStatus] != nil) {
            [_userDefaults removeObjectForKey:User_ProfileStatus];
        }
        [_userDefaults synchronize];
    }
    [[FIRInstanceID instanceID] deleteIDWithHandler:^(NSError *error) {
        if (error != nil) {
        }
    }];
}

- (id)getUserDetailsUsingKey:(NSString *) strKey {
    if ([_userDefaults objectForKey:strKey] != nil) {
        return [_userDefaults objectForKey:strKey];
    }
    return nil;
}

-(NSDictionary*)getUserDetails{
    NSMutableDictionary *details = @{}.mutableCopy;
    NSString *_id = [_userDefaults objectForKey:User_ID];
    if (_id != NULL){
        details[User_ID] = _id;
    }
    
    NSString *app_User_ID = [_userDefaults objectForKey:App_User_ID];
    if (app_User_ID != NULL){
        details[App_User_ID] = app_User_ID;
    }
    NSString *user_Name = [_userDefaults objectForKey:User_Name];
    if (user_Name != NULL){
        details[User_Name] = user_Name;
    }
    NSString *user_LoginTimeStamp = [_userDefaults objectForKey:User_LoginTimeStamp];
    if (user_LoginTimeStamp != NULL){
        details[User_LoginTimeStamp] = user_LoginTimeStamp;
    }
    
    NSString *user_ProfilePic = [_userDefaults objectForKey:User_ProfilePic];
    if (user_ProfilePic != NULL){
        details[User_ProfilePic] = user_ProfilePic;
    }
    NSString *user_ProfilePic_Thumb = [_userDefaults objectForKey:User_ProfilePic_Thumb];
    if (user_ProfilePic_Thumb != NULL){
        details[User_ProfilePic_Thumb] = user_ProfilePic_Thumb;
    }
    NSString *user_eRTCUserId = [_userDefaults objectForKey:User_eRTCUserId];
    if (user_eRTCUserId != NULL){
        details[User_eRTCUserId] = user_eRTCUserId;
    }
    NSString *tenantID = [_userDefaults objectForKey:TenantID];
    if (tenantID != NULL){
        details[TenantID] = tenantID;
    }
    NSString *user_ProfileStatus = [_userDefaults objectForKey:User_ProfileStatus];
    if (user_ProfileStatus != NULL){
        details[User_ProfileStatus] = user_ProfileStatus;
    }
    return  details.copy;
}
@end
