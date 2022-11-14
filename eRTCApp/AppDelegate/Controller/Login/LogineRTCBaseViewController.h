//
//  LogineRTCBaseViewController.h
//  eRTCApp
//
//  Created by Rakesh Palotra on 06/01/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LogineRTCBaseViewController : UIViewController

- (BOOL)isValidateNameSpaceScreenWithNameSpace:(NSString *) nameSpace;

- (BOOL) isValidateLoginScreenWithUserName:(NSString *)username andPassword:(NSString *) password;

- (BOOL) isValidateForgotScreenWithEmail:(NSString *) email;
- (BOOL) isValidateNameSpaceScreenWithAPIKey:(NSString *) apiKey ;
@end

NS_ASSUME_NONNULL_END
