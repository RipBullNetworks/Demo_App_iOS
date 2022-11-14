//
//  ChannelPrivacyViewController.m
//  eRTCApp
//
//  Created by Apple on 07/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "ChannelPrivacyViewController.h"
#import "NewGroupViewController.h"

@interface ChannelPrivacyViewController () {
NSString                                  *_strChannelKey;

}

@property (weak, nonatomic) IBOutlet UIView *vwPublicChannel;
@property (weak, nonatomic) IBOutlet UIView *vwPrivateChannel;
@property (weak, nonatomic) IBOutlet UIButton *btnPublic;
@property (weak, nonatomic) IBOutlet UIButton *btnPrivate;

@end

@implementation ChannelPrivacyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES animated:false];
    if (_isEditModeOn) {
        [_btnNextRightBar setTitle:Save];
        self.navigationController.navigationItem.title = @"Edit Channel Privacy";
    }else{
        [_btnNextRightBar setTitle:Next];
        self.navigationController.navigationItem.title = @"Channel Privacy";
    }
    
    if ([_privacyKeyType isEqualToString:Private]) {
        [self setRadioButton:false];
    }else{
        [self setRadioButton:true];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (IBAction)btnNext:(UIBarButtonItem *)sender {
    if (_isEditModeOn) {
    [[NSNotificationCenter defaultCenter] postNotificationName:UpdatePrivacyKey object:_strChannelKey];
    [self dismissViewControllerAnimated:true completion:nil];
        [self.navigationController setNavigationBarHidden:NO animated:false];
   // [self callAPIForUpdateKeyGroup];
    }else{
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UINavigationController *nvcNewGroup = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"NewGroupNavigationViewController"];
//    [nvcNewGroup setModalPresentationStyle:UIModalPresentationFullScreen];
//    [self presentViewController:nvcNewGroup animated:YES completion:nil];
        NewGroupViewController * viewController =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"NewGroupViewController"];
        //UINavigationController *nvcNewGroup = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"NewGroupNavigationViewController"];
        [viewController setModalPresentationStyle:UIModalPresentationFullScreen];
        [[NSUserDefaults standardUserDefaults] setObject:_strChannelKey forKey:ChannelKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.navigationController pushViewController:viewController animated:true];
       
    }
}

- (IBAction)btnCancel:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
    [self.navigationController setNavigationBarHidden:NO animated:false];
}

- (IBAction)btnPublic:(UIButton *)sender {
    [self setRadioButton:true];
}


- (IBAction)btnPrivate:(UIButton *)sender {
    [self setRadioButton:false];
}

-(void)setRadioButton:(BOOL)isRadio {
    _vwPublicChannel.layer.borderWidth = 1;
    if (isRadio) {
        [_btnPublic setImage:[UIImage imageNamed:@"radiocheck"] forState:UIControlStateNormal];
        [_btnPrivate setImage:[UIImage imageNamed:@"radioUncheck"] forState:UIControlStateNormal];
        _vwPublicChannel.layer.borderColor = [self colorWithHexString:@"5691C8"].CGColor;
        _vwPrivateChannel.layer.borderColor = [UIColor colorWithRed:0.86 green:0.91 blue:0.91 alpha:1.0].CGColor;
        _strChannelKey = Public;
        [_btnPublic setTitleColor:[self colorWithHexString:@"5691C8"] forState:UIControlStateNormal];
        [_btnPrivate setTitleColor:[self colorWithHexString:@"212429"] forState:UIControlStateNormal];
    }else{
        [_btnPublic setTitleColor:[self colorWithHexString:@"212429"] forState:UIControlStateNormal];
        [_btnPrivate setTitleColor:[self colorWithHexString:@"5691C8"] forState:UIControlStateNormal];
        [_btnPublic setImage:[UIImage imageNamed:@"radioUncheck"] forState:UIControlStateNormal];
        [_btnPrivate setImage:[UIImage imageNamed:@"radiocheck"] forState:UIControlStateNormal];
        _vwPublicChannel.layer.borderColor = [UIColor colorWithRed:0.86 green:0.91 blue:0.91 alpha:1.0].CGColor;
        _vwPrivateChannel.layer.borderColor = [self colorWithHexString:@"5691C8"].CGColor;
        _strChannelKey = Private;
    }
}

#pragma mark API
-(void)callAPIForUpdateKeyGroup {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        NSMutableDictionary*dictParam = [[NSMutableDictionary alloc]init];
        [KVNProgress show];
        [dictParam setValue:self.groupId forKey:Group_GroupId];
        [dictParam setValue:_strChannelKey forKey:Group_Type];
        [[eRTCChatManager sharedChatInstance]
         updateGroup:dictParam  andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
             [KVNProgress dismiss];
             NSDictionary *dictResponse = (NSDictionary *)json;
             if (dictResponse[@"success"] != nil) {
                 BOOL success = (BOOL)dictResponse[@"success"];
                 if (success) {
                     if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                         NSDictionary *result = (NSDictionary *)dictResponse[@"result"];
                         if ([result count]>0){
                            self.dictGroupkey = [[NSMutableDictionary alloc] initWithDictionary:result];
                            if (self.completion != nil) { self.completion(YES, self.dictGroupkey);}
                           //  [self dismissViewControllerAnimated:YES completion:nil];
                             [self dismissViewControllerAnimated:YES completion:^{
                                 [[NSNotificationCenter defaultCenter] postNotificationName:kGroupUpdateSuccessfully object:dictResponse[@"result"]];
                             }];
                         }
                     }
                 }
             }
             if (dictResponse[@"msg"] != nil) {
                 NSString *message = (NSString *)dictResponse[@"msg"];
                 if ([message length]>0) {
                     [Helper showAlertOnController:@"eRTC" withMessage:message onController:self];
                 }
             }
         } andFailure:^(NSError * _Nonnull error) {
             [KVNProgress dismiss];
             [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
         }];
    }else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}


-(UIColor*)colorWithHexString:(NSString*)hex
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



@end
