//
//  UserModel.h
//  eRTCApp
//
//  Created by rakesh  palotra on 05/01/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class AuthManager;

@interface UserModel : NSObject {
    NSUserDefaults * _userDefaults;
}

+ (id)sharedInstance;

-(void)saveUserDetailsWith:(NSDictionary *) dictUser;

- (id)getUserDetailsUsingKey:(NSString *) strKey;

-(void)logOutUser;
-(NSDictionary*)getUserDetails;
@end

NS_ASSUME_NONNULL_END
