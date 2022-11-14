//
//  Helper.m
//  eRTCApp
//
//  Created by rakesh  palotra on 27/12/18.
//  Copyright © 2018 Ripbull Network. All rights reserved.
//


#import "Helper.h"
#import "Constants.h"
#import "UserModel.h"
#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>


@implementation Helper

+ (UIStoryboard *)mainStoryBoard {
    return [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
}

+ (UIStoryboard *)ChatRestorationStoryBoard {
    return [UIStoryboard storyboardWithName:@"ChatRestoration" bundle:[NSBundle mainBundle]];
}

+ (UIStoryboard *)newFeaturesStoryBoard; {
    return [UIStoryboard storyboardWithName:@"NewFeatures" bundle:[NSBundle mainBundle]];
}

+ (void)showAlertOnControllerLogOut:(NSString *)title withMessage:(NSString *)message onController:(UIViewController *)vc {
    if (message == nil || [message length] == 0) {
        message = @"Some error occurred. Please try again";
    }
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:IsLoggedIn];
        [[NSUserDefaults standardUserDefaults] synchronize];
       // [[UserModel sharedInstance]logOutUser];
       // [[AppDelegate sharedAppDelegate] willChangeLoginAsRootOfApplication];
    }]];
    [vc presentViewController:alert animated:YES completion:nil];
}

+(void)showAlert:(NSString *)title message:(NSString *)msg btnYes:(NSString *)isbtnYes btnNo:(NSString *)isBtnNo inViewController:(id)vc completedWithBtnStr:(void(^)(NSString* btnString))completedWithBtnStr {
    UIAlertController *alertController = [UIAlertController
    alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:isBtnNo style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
      completedWithBtnStr(isBtnNo);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:isbtnYes style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
      completedWithBtnStr(isbtnYes);
    }]];
    [vc presentViewController:alertController animated:YES completion:nil];
}

+(void)showAlertViewController:(NSString *)title message:(NSString *)msg btnYes:(NSString *)isbtnYes btnNo:(NSString *)isBtnNo inViewController:(id)vc completedWithBtnStr:(void (^)(NSString * _Nonnull))completedWithBtnStr {
    UIAlertController *alertController = [UIAlertController
    alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:isBtnNo style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
      completedWithBtnStr(isBtnNo);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:isbtnYes style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
      completedWithBtnStr(isbtnYes);
    }]];
    [vc presentViewController:alertController animated:YES completion:nil];
}

+ (void)showAlertOnController:(NSString *)title withMessage:(NSString *)message onController:(UIViewController *)vc {
    
    if (message == nil || [message length] == 0) {
        message = @"Some error occurred. Please try again";
    }
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [vc presentViewController:alert animated:YES completion:nil];
}


+ (void)DeleteAlertOnController:(NSString *)title withMessage:(NSString *)message onController:(UIViewController *)vc completion:(void (^)(void))completion {
    if (message == nil || [message length] == 0) {
        message = @"Some error occurred. Please try again";
    }
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completion();
    }]];
    [vc presentViewController:alert animated:YES completion:nil];
}




+ (void)showAlertOnController:(NSString *)title withMessage:(NSString *)message onController:(UIViewController *)vc completion:(void (^)(void))completion {
    if (message == nil || [message length] == 0) {
        message = @"Some error occurred. Please try again";
    }
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completion();
    }]];
    [vc presentViewController:alert animated:YES completion:nil];
}

+ (BOOL)isValidateEmailWithString:(NSString*)email {
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)isValidateMobileWithString:(NSString*)mobile {
    NSString *mobileRegex = @"^[0-9]{10,14}$";
    NSPredicate *mobileTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobileRegex];
    return [mobileTest evaluateWithObject:mobile];
}

+ (BOOL)isValidatePasswordWithString:(NSString*)strPWD {
    NSString *regEx = @"^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&])[A-Za-z\\d$@$!%*?&]{6,14}";
    NSPredicate *regExTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx];
    return [regExTest evaluateWithObject:strPWD];
}

+ (NSString *) generateUniqueRequestID {
    return [NSString stringWithFormat:@"%@-%f",[self randomStringWithLength:9],[[NSDate date] timeIntervalSince1970] * 1000];
}

+ (NSString *) randomStringWithLength: (int) len {
    NSString * letter = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letter characterAtIndex: arc4random_uniform((int)[letter length])]];
    }
    return randomString;
}

+ (NSString *)getEpochTime {
    NSDate *now = [NSDate date];
    NSTimeInterval nowEpochSeconds = [now timeIntervalSince1970];
    return [NSString stringWithFormat:@"%.f", nowEpochSeconds];
}

+(BOOL)stringIsNilOrEmpty:(NSString*)aString {
    if (aString != nil && aString != [NSNull null]) {
        return NO;
    }
    return YES;
}
+(BOOL)objectIsNilOrEmpty:(id)obj andKey:(NSString *) key {
    if (obj[key] != nil && obj[key] != [NSNull null]) {
        return NO;
    }
    return YES;
}

+(NSAttributedString*)getAttributedString:(NSAttributedString *)attrString font:(UIFont*)font{
    NSMutableAttributedString *mString = [[NSMutableAttributedString alloc] initWithAttributedString:attrString];
    [mString addAttributes:@{NSFontAttributeName : font} range:NSMakeRange(0, attrString.length)];
    return mString.copy;
}



+(CNContact*) getCNContactFrom:(NSDictionary*)msgObject{
     CNMutableContact *contact = [CNMutableContact new];
     if (msgObject[@"contact"] != NULL) {
         NSString *name = msgObject[@"contact"][@"name"];
         NSArray *emails = msgObject[@"contact"][@"emails"];
         NSMutableArray *emailValues = @[].mutableCopy;
         if (emails != NULL && [emails isKindOfClass:NSArray.class]){
             [emails enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                 CNLabeledValue *value = [CNLabeledValue labeledValueWithLabel:CNLabelWork value:obj[@"email"]];
                 
                 [emailValues addObject:value];
             }];
             contact.emailAddresses = emailValues.copy;
         }
         
         NSArray *numbers = msgObject[@"contact"][@"numbers"];
         NSMutableArray *phoneValues = @[].mutableCopy;
          if (numbers != NULL && [numbers isKindOfClass:NSArray.class]){
              [numbers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                  CNLabeledValue *number =  [CNLabeledValue labeledValueWithLabel: CNLabelPhoneNumberMobile value:[CNPhoneNumber phoneNumberWithStringValue:obj[@"number"]]];;
                
                  [phoneValues addObject:number];
              }];
              
          }
         contact.givenName = name;
         contact.phoneNumbers = phoneValues.copy;
         return contact.copy;
     }
     
     return NULL;
 }
+(NSString*)getContactNameString:(NSDictionary*)contactDetails {
    NSString *strContactPersonName = contactDetails[User_Name];
    if ((strContactPersonName == NULL || [strContactPersonName isEqual:@""]) && contactDetails[@"numbers"]){
        NSArray *numbers = contactDetails[@"numbers"];
        NSDictionary *firstNumber = numbers.firstObject;
        strContactPersonName = firstNumber[@"number"];
        
    }
    return strContactPersonName;
}
+(NSString*)getRemoveMentionTags:(NSString*)message {
    NSMutableString *_message = message.mutableCopy;
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?<=<).*?(?=>)" options:0 error:&error];
    NSArray *matches = [regex matchesInString:message options:0 range:NSMakeRange(0, message.length)];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:0];
        NSMutableString *name = [message substringWithRange:wordRange].mutableCopy;
        NSString *str = [NSString stringWithFormat:@"<%@>", name];
       _message = [[_message stringByReplacingOccurrencesOfString:str withString:name] mutableCopy];
    }
    return _message.copy;
}


+(NSString*)getUsersName:(NSString*)message userNames:(NSSet*)userNames {
    NSMutableString *_message = message.mutableCopy;
    NSError *error = nil;
    NSMutableString *userName;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?<=<).*?(?=>)" options:0 error:&error];
    NSArray *matches = [regex matchesInString:message options:0 range:NSMakeRange(0, message.length)];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:0];
        userName = [message substringWithRange:wordRange].mutableCopy;
    }
    if (userName == Nil) {
        NSString *mentionString = [self getNamesTaggedStringFromNames:userNames message:message];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?<=<).*?(?=>)" options:0 error:&error];
        NSArray *matches = [regex matchesInString:mentionString options:0 range:NSMakeRange(0, mentionString.length)];
        for (NSTextCheckingResult *match in matches) {
            NSRange wordRange = [match rangeAtIndex:0];
            userName = [mentionString substringWithRange:wordRange].mutableCopy;
        }
    }
    
    return userName.copy;
}

+(NSAttributedString*)mentionHighlightedAttributedStringByNames:(NSSet*)userNames message:(NSString*)mentionNameString
{
    
    NSString *userName = [self getUsersName:mentionNameString userNames:userNames];
    NSString* stringNew = [mentionNameString stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    NSString *message = [self getRemoveMentionTags:mentionNameString];
    NSSet *_userNames = userNames;
    if (!userNames){
        _userNames = NSSet.new;
    }
NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:message attributes:@{
    NSFontAttributeName: [UIFont fontWithName:@"SFProDisplay-Regular" size:18]
}];
    
NSString *str = message;
NSError *error = nil;
    NSRegularExpression *regex;
    NSArray *matches;
    regex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)(\\s+)(\\w+)|@(\\w+)(\\s+)" options:0 error:&error];
    matches = [regex matchesInString:message options:0 range:NSMakeRange(0, message.length)];
    
    for (NSTextCheckingResult *match in matches) {
    NSRange wordRange = [match rangeAtIndex:0];
    NSString *name = [message substringWithRange:wordRange];
        
    NSArray *list = [name componentsSeparatedByString:@" "];
    NSMutableSet *set = [[NSMutableSet alloc] initWithObjects:[name stringByReplacingOccurrencesOfString:@"@" withString:@""], nil];
        
    if (list.count > 1){
        [set addObject:[list.firstObject stringByReplacingOccurrencesOfString:@"@" withString:@""]];
    }
        
    for(NSString *item in set)
    {
        if ([name isKindOfClass:[NSString class]]){
            wordRange.length = item.length - userName.length;
            wordRange.length = item.length - wordRange.length;
           [string addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:wordRange];
        }
    }
    NSLog(@"Search DATA %@", [message substringWithRange:wordRange]);
  }
  return string;;

}

+(NSString*)getNamesTaggedStringFromNames:(NSSet*)nameSat message:(NSString*)message
{
    
    NSString *str = message;
    NSError *error = nil;
    NSRegularExpression *regex = nil;
    NSArray *matches = nil;
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"@[A-Z0-9a-z\\._%+-]" options:0 error:&error];
    matches = [regex matchesInString:message options:0 range:NSMakeRange(0, message.length)];
    
    if (matches.count == 0) {
    regex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)(\\s+)(\\w+)|@(\\w+)" options:0 error:&error];
    matches = [regex matchesInString:message options:0 range:NSMakeRange(0, message.length)];
    }
    
    NSMutableString *string = message.mutableCopy;
    NSUInteger counter = 0;
    for (NSTextCheckingResult *match in matches) {
       
        NSRange wordRange = [match rangeAtIndex:0];
        NSRange _range = wordRange;
        _range.location = _range.location + counter;
        NSString *name = [message substringWithRange:wordRange];
        NSArray *list = [name componentsSeparatedByString:@" "];
        NSMutableSet *set = [[NSMutableSet alloc] init];
        
        if (list.count > 1){
            [set addObject:[list.firstObject stringByReplacingOccurrencesOfString:@"@" withString:@""]];
        }
        
        name = [name stringByReplacingOccurrencesOfString:@"@" withString:@""];
        BOOL _found = FALSE;
        
        if ([nameSat containsObject:name]){
            _range.length = name.length + 1;
            [string replaceCharactersInRange:_range withString:[NSString stringWithFormat:@"<@%@>", name]];
            _found = TRUE;
            counter += 2;
        }else {
            for(NSString *item in set)
            {
                for (NSString *__name in nameSat) {
                    if ([item isEqualToString:__name] && !_found){
                        _range.length = __name.length + 1;
                        //[string replaceCharactersInRange:_range withString:[NSString stringWithFormat:@"<%@>", name]];
                        [string replaceCharactersInRange:_range withString:[NSString stringWithFormat:@"<@%@>", __name]];
                        //                        string = [[string stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"@%@", __name] withString:[NSString stringWithFormat:@"<@%@>", __name]] mutableCopy];
                        _found = TRUE;
                        counter += 2;
                    }
                }
            }
        }
    }
    
    return string;;
}

+(NSURL*)getFirstUrlIfExistInMessage:(NSString*)message {
    if (message == nil) return NULL;
    NSDataDetector* detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray* matches = [detector matchesInString:message options:0 range:NSMakeRange(0, [message length])];
    if (matches.count < 1){return NULL;}
    return [matches.firstObject URL];
}

+(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];

    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];

    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];

    if ([cString length] != 6) return  [UIColor grayColor];

    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];

    range.location = 2;
    NSString *gString = [cString substringWithRange:range];

    range.location = 4;
    NSString *bString = [cString substringWithRange:range];

    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

+(NSString*)notificatioinDateCalculation:(NSString*)DateOfJoin

{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormat setTimeZone:gmt];
    NSDate *ExpDate = [dateFormat dateFromString:DateOfJoin];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit|NSWeekCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit|NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:ExpDate toDate:[NSDate date] options:0];
    NSString *time;
    if(components.month!=0)
    {
        if(components.month==1)
        {
            time=[NSString stringWithFormat:@"%ld M remaining",(long)components.month];
        }
        else
        {
            time=[NSString stringWithFormat:@"%ld M remaining",(long)components.month];
        }
    }
    else if(components.week!=0)
    {
        if(components.week==1)
        {
            time=[NSString stringWithFormat:@"%ld w remaining",(long)components.week];
        }
        else
        {
            time=[NSString stringWithFormat:@"%ld w remaining",(long)components.week];
        }
    }
    else if(components.day!=0)
    {
        if(components.day==2)
        {
            time=[NSString stringWithFormat:@"%ld d remaining",(long)components.day];
        }
        else
        {
            time=[NSString stringWithFormat:@"%ld d remaining",(long)components.day];
        }
    }
    else if(components.hour!=0)
    {
        if(components.hour==2)
        {
            time=[NSString stringWithFormat:@"%ld h remaining",(long)components.hour];
        }
        else
        {
            time=[NSString stringWithFormat:@"%ld h remaining",(long)components.hour];
        }
    }
    else if(components.minute!=0)
    {
        if(components.minute==2)
        {
            time=[NSString stringWithFormat:@"%ld min remaining",(long)components.minute];
        }
        else
        {
            time=[NSString stringWithFormat:@"%ld min remaining",(long)components.minute];
        }
    }
    
    NSString * datetime = [time stringByReplacingOccurrencesOfString:@"-" withString:@" "];
    return [NSString stringWithFormat:@"%@",datetime];
}

+(CGFloat)requiredHeight:(NSString*)labelText{
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:14.0];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, CGFLOAT_MAX)];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.font = font;
    label.text = labelText;
    [label sizeToFit];
    return label.frame.size.height+20;
}

+(NSAttributedString*)colorHashtag:(NSAttributedString*)message
{
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:message];
   // NSString *str = message;
    NSError *error = nil;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<@+[a-zA-Z0-9._ @-]+>|<@channel>|<@here>" options:0 error:&error];
            NSArray *matches = [regex matchesInString:message options:0 range:NSMakeRange(0, message.length)];
        for (NSTextCheckingResult *match in matches) {
            NSRange wordRange = [match rangeAtIndex:0];
            NSString *name = [message attributedSubstringFromRange:wordRange];
            NSArray *list = [name componentsSeparatedByString:@" "];
            NSMutableSet *set = [[NSMutableSet alloc] initWithObjects:[name stringByReplacingOccurrencesOfString:@"@" withString:@""], nil];
            if (list.count > 1){
                [set addObject:[list.firstObject stringByReplacingOccurrencesOfString:@"@" withString:@""]];
            }
            for(NSString *item in set){
                if ([name isKindOfClass:[NSString class]] ){
                    wordRange.length = item.length + 2;
                   [string addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:wordRange];
                }
            }
            NSLog(@"Search DATA %@", [message attributedSubstringFromRange:wordRange]);
        }
    return string;
}


+(NSString*)getuserMentionName:(NSSet*)Nameset message:(NSString *)message {
    NSMutableAttributedString *stringMessage = [[NSMutableAttributedString alloc] initWithString:message];
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<@+[a-zA-Z0-9._ @-]+>|<@channel>|<@here>" options:0 error:&error];
    NSArray *matchData = [regex matchesInString:message options:0 range:NSMakeRange(0, message.length)];
     NSString *mentionString = [stringMessage.mutableString stringByReplacingOccurrencesOfString:@"<" withString:@" "];
     NSString *strMention = [mentionString stringByReplacingOccurrencesOfString:@">" withString:@" "];
     stringMessage = [[NSMutableAttributedString alloc] initWithString:strMention];
    for (NSTextCheckingResult *match in matchData) {
    NSRange wordRange = [match rangeAtIndex:0];
    NSString *name = [message substringWithRange:wordRange];
    NSArray *list = [name componentsSeparatedByString:@" "];
    NSMutableSet *set = [[NSMutableSet alloc] initWithObjects:[name stringByReplacingOccurrencesOfString:@"@" withString:@""], nil];
    for(NSString *item in set)
    {
        if ([name isKindOfClass:[NSString class]]){
            wordRange.length = item.length;
            [stringMessage addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:wordRange];
        }
    }
  }
    return stringMessage;
}

+(NSString*)getRemoveTags:(NSString*)message {
    NSMutableString *_message = message.mutableCopy;
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?<=<).*?(?=>)" options:0 error:&error];
    NSArray *matches = [regex matchesInString:message options:0 range:NSMakeRange(0, message.length)];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:0];
        NSMutableString *name = [message substringWithRange:wordRange].mutableCopy;
        NSString *str = [NSString stringWithFormat:@"<%@>", name];
       _message = [[_message stringByReplacingOccurrencesOfString:str withString:name] mutableCopy];
    }
    return _message.copy;
}

@end
