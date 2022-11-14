//
//  EditGroupViewController.m
//  eRTCApp
//
//  Created by Ashish Vani on 27/08/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import "EditGroupSubjectViewController.h"

@interface EditGroupSubjectViewController ()<UITextFieldDelegate> {
    __weak IBOutlet UIButton                  *_bntSave;
    __weak IBOutlet UIButton                  *_bntCancel;
    __weak IBOutlet UILabel                   *_lblNavTitle;
    __weak IBOutlet UILabel                   *_lblLimit;
    __weak IBOutlet UITextField               *_tfGroupSubject;
                    NSInteger                  _intLimit;
    
        
}

@end

@implementation EditGroupSubjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
    [self setupOtherUI];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupOtherUI];
}

#pragma mark - setup UI
-(IBAction)btnCancelTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];    
}

-(IBAction)btnSaveTapped:(id)sender {
    [self callAPIForEditUpdateGroup];
}

#pragma mark - setup UI
- (void)setupOtherUI {
    _intLimit = 25;
    [_tfGroupSubject setDelegate:self];
    [_tfGroupSubject setPlaceholder:NSLocalizedString(@"Channel Name", nil)];
    [_tfGroupSubject setTextColor:[UIColor  colorWithRed:0.13 green:0.13 blue:0.13 alpha: 1.0]];
    [_tfGroupSubject setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:15]];

    [_lblLimit setFont:[UIFont fontWithName:@"SFProDisplay" size:8]];
    [_lblLimit setBackgroundColor:[UIColor clearColor]];
    [_lblLimit setTextColor:[UIColor  colorWithRed:0.72 green:0.72 blue:0.72 alpha: 1]];
    [_lblLimit setText:[NSString stringWithFormat:@"%ld",(long)_intLimit]];
    
    if (self.dictGroupInfo[@"name"]) {
        [_tfGroupSubject setText:[NSString stringWithFormat:@"%@",self.dictGroupInfo[@"name"]]];
    }
    [self setupLimitViewWithString:[_tfGroupSubject text]];
}

- (void)setupNavigationBar {
    [_bntSave.titleLabel setFont:[UIFont fontWithName:@"SFProDisplay-Medium" size:16]];
    [_bntCancel.titleLabel setFont:[UIFont fontWithName:@"SFProDisplay-Medium" size:16]];
    [_lblNavTitle setFont:[UIFont fontWithName:@"SFProDisplay-Medium" size:18]];
    [_lblNavTitle setBackgroundColor:[UIColor clearColor]];
    [self.navigationItem setTitleView:_lblNavTitle];
    
    [_bntSave setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    [_bntCancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [_lblNavTitle setText:NSLocalizedString(@"Channel Name", nil)];
    [_bntSave setEnabled:NO];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:_bntCancel]];
}

- (void)setupLimitViewWithString:(NSString *) string {
    NSString *strName = string;
    [_bntSave setEnabled:([strName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length>0)];
    [_lblLimit setText:[NSString stringWithFormat:@"%d", (int)((strName.length<26)?_intLimit-strName.length:0)]];
    
}

#pragma mark Text Field Delegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == _tfGroupSubject) {
        NSString *strName = [textField.text stringByReplacingCharactersInRange:range withString:string];
        [self setupLimitViewWithString:strName];
        return strName.length<26;
    }
    return NO;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField == _tfGroupSubject) {
        _bntSave.enabled = NO;
        [_lblLimit setText:[NSString stringWithFormat:@"%lu",(long)_intLimit]];
    }
    return YES;
}

#pragma mark API
-(void)callAPIForEditUpdateGroup {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        NSMutableDictionary*dictParam = [[NSMutableDictionary alloc]init];
        [KVNProgress show];
        [dictParam setValue:_tfGroupSubject.text forKey:Group_Name];
        [dictParam setValue:self.dictGroupInfo[@"groupId"] forKey:Group_GroupId];
        //[dictParam setValue:@"public" forKey:Group_Type];
        [[eRTCChatManager sharedChatInstance]
         updateGroup:dictParam  andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
             [KVNProgress dismiss];
             NSDictionary *dictResponse = (NSDictionary *)json;
             if (dictResponse[@"success"] != nil) {
                 BOOL success = (BOOL)dictResponse[@"success"];
                 if (success) {
                     if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                         NSMutableDictionary *result = (NSMutableDictionary *)dictResponse[@"result"];
                         if ([result count]>0){
                             self.dictGroupInfo = [[NSMutableDictionary alloc] initWithDictionary:result];
                             if (self.completion != nil) { self.completion(YES, self.dictGroupInfo);}
                             NSString *imageURL = [NSString stringWithFormat:@"%@",self.dictGroupInfo[User_ProfilePic_Thumb]];
                             NSString *strUrl = [imageBaseUrl stringByAppendingString:imageURL];
                             [self.dictGroupInfo setObject:strUrl forKey:User_ProfilePic_Thumb];
                             
                           //  [self dismissViewControllerAnimated:YES completion:nil];
                             [self dismissViewControllerAnimated:YES completion:^{
                                 [[NSNotificationCenter defaultCenter] postNotificationName:kGroupUpdateSuccessfully object:dictResponse[@"result"]];
                                 [[NSNotificationCenter defaultCenter] postNotificationName:UpdateGroupProfileSuccessfully object:self.dictGroupInfo];
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

@end
