//
//  Helper.h
//  eRTCApp
//
//  Created by rakesh  palotra on 27/12/18.
//  Copyright © 2018 Ripbull Network. All rights reserved.
//

typedef enum {
    RecentSearch  = 1,
    ContactsSearch = 2
} SearchType;


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Contacts/Contacts.h>

NS_ASSUME_NONNULL_BEGIN

@interface Helper : NSObject

+ (UIStoryboard *)mainStoryBoard;
+ (UIStoryboard *)newFeaturesStoryBoard;
+ (UIStoryboard *)ChatRestorationStoryBoard;

+ (void)showAlertOnController:(NSString *)title withMessage:(NSString *)message onController:(UIViewController *)vc;

+ (void)showAlertOnControllerLogOut:(NSString *)title withMessage:(NSString *)message onController:(UIViewController *)vc;

+(void)showAlert:(NSString *)title message:(NSString *)msg btnYes:(NSString *)isbtnYes btnNo:(NSString *)isBtnNo inViewController:(id)vc completedWithBtnStr:(void(^)(NSString* btnString))completedWithBtnStr;

+(void)showAlertViewController:(NSString *)title message:(NSString *)msg btnYes:(NSString *)isbtnYes btnNo:(NSString *)isBtnNo inViewController:(id)vc completedWithBtnStr:(void(^)(NSString* btnString))completedWithBtnStr;

+ (void)showAlertOnController:(NSString *)title withMessage:(NSString *)message onController:(UIViewController *)vc completion:(void (^)(void))completion;

+ (BOOL)isValidateEmailWithString:(NSString*)email;

+ (BOOL)isValidateMobileWithString:(NSString*)mobile;



+ (BOOL)isValidatePasswordWithString:(NSString*)strPWD;

+ (NSString *) generateUniqueRequestID;

+(BOOL)stringIsNilOrEmpty:(NSString*)aString;

+(BOOL)objectIsNilOrEmpty:(id)obj andKey:(NSString *) key;

+ (NSString *)getEpochTime;
+(NSAttributedString*)getAttributedString:(NSAttributedString *)attrString font:(UIFont*)font;
+(NSAttributedString*)getEmailAttributedString:(NSAttributedString *)emailstr font:(UIFont*)font;
+(CNContact*) getCNContactFrom:(NSDictionary*)msgObject;
+(NSString*)getRemoveMentionTags:(NSString*)message;
+(NSString*)getNamesTaggedStringFromNames:(NSSet*)nameSat message:(NSString*)message;
+(NSURL*)getFirstUrlIfExistInMessage:(NSString*)message;
+(NSAttributedString*)mentionHighlightedAttributedStringByNames:(NSSet*)userNames message:(NSString*)mentionNameString;
+(NSString*)getContactNameString:(NSDictionary*)contactDetails;
+ (UIImage *)thumbnailFromVideoAtURL:(NSURL *)contentURL;
+(UIColor*)colorWithHexString:(NSString*)hex;
+(NSString*)notificatioinDateCalculation:(NSString*)DateOfJoin;
+(CGFloat)requiredHeight:(NSString*)labelText;
+(NSAttributedString*)colorHashtag:(NSString*)message;
+(NSString*)getuserMentionName:(NSSet*)Nameset message:(NSString *)message;
+(NSMutableAttributedString*)getRemoveTags:(NSMutableAttributedString*)message;
+(NSString *)stringByStrippingHTML:(NSString*)str;

@end

NS_ASSUME_NONNULL_END
