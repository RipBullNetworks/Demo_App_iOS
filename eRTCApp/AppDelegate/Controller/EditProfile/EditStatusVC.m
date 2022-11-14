//
//  EditStatusVC.m
//  eRTCApp
//
//  Created by apple on 13/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//
#import "EditStatusVC.h"

@interface EditStatusVC () {
    UIBarButtonItem *EditBarButtonItem;
    UIImage *imageReduced;
}

@end

@implementation EditStatusVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationItem.backBarButtonItem setTitle:@""];
    self.navigationItem.title = @"Edit Status";
    
    EditBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(clickSaveButton:)];
    self.navigationItem.rightBarButtonItem=EditBarButtonItem;
    _tfStatus.text = [[UserModel sharedInstance] getUserDetailsUsingKey:User_ProfileStatus];
    NSString*imageURL = [[UserModel sharedInstance] getUserDetailsUsingKey:User_ProfilePic_Thumb];
    if([[UserModel sharedInstance] getUserDetailsUsingKey:User_ProfilePic_Thumb] != nil && [[UserModel sharedInstance] getUserDetailsUsingKey:User_ProfilePic_Thumb] != [NSNull null]) {
        NSURL *aURL = [NSURL URLWithString:[imageURL stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        imageReduced = [UIImage imageWithData:[NSData dataWithContentsOfURL:aURL]];
    }else{
    }
    if([[UserModel sharedInstance] getUserDetailsUsingKey:User_ProfileStatus] != nil && [[UserModel sharedInstance] getUserDetailsUsingKey:User_ProfileStatus] != [NSNull null]) {
    _tfStatus.text = [[UserModel sharedInstance] getUserDetailsUsingKey:User_ProfileStatus];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"";
   
}



-(IBAction)clickSaveButton:(id)sender{
    if (_tfStatus.text.length > 0) {
        [self userUpdateProfile];
    }
    
}

-(void)userUpdateProfile {
if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
    if (imageReduced != nil || (_tfStatus.text != nil && [_tfStatus.text length] > 0)) {
        [KVNProgress show];
        NSMutableDictionary *updateUserProfile = [[NSMutableDictionary alloc]init];
        NSString* UserID = [[UserModel sharedInstance] getUserDetailsUsingKey:User_ID];
        [updateUserProfile setObject:_tfStatus.text forKey:User_ProfileStatus];
        [updateUserProfile setObject:@"email" forKey:Login_Type];
        NSData *imageData = UIImageJPEGRepresentation(imageReduced, 1.0);
        [[eRTCAppUsers sharedInstance] updateUserProfileData:updateUserProfile andFileData:imageData andCompletion:^(id  json, NSString * errMsg) {
            [KVNProgress dismiss];
            self->imageReduced = nil;
            NSDictionary *dictResponse = (NSDictionary *)json;
            
            if (dictResponse[@"success"] != nil) {
                BOOL success = (BOOL)dictResponse[@"success"];
                if (success) {
                    if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                        [[eRTCCoreDataManager sharedInstance] getLoggedInUserInfo:^(id  _Nonnull userInfo) {
                            [[UserModel sharedInstance] saveUserDetailsWith:userInfo];
                            [self.navigationController popViewControllerAnimated:true];
                        }];
                       // [[NSNotificationCenter defaultCenter] postNotificationName:updateuser object:userInfo];
                        return;
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
    }
} else {
    [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
}
}



@end

