//
//  EditGroupDescriptionViewController.m
//  eRTCApp
//
//  Created by Ashish Vani on 30/08/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import "EditGroupDescriptionViewController.h"

@interface EditGroupDescriptionViewController ()<UITextViewDelegate> {
    __weak IBOutlet UIButton                  *_bntSave;
    __weak IBOutlet UIButton                  *_bntCancel;
    __weak IBOutlet UILabel                   *_lblNavTitle;
    __weak IBOutlet UILabel                   *_lblLimit;
    __weak IBOutlet UILabel                   *_lblPlaceholder;
    __weak IBOutlet UITextView               *_tvGroupDescription;
    __weak IBOutlet NSLayoutConstraint       *_lcViewHeight;
    NSInteger                  _intLimit;
    
    
}

@end

@implementation EditGroupDescriptionViewController

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
    _intLimit = 500;
    [_tvGroupDescription setDelegate:self];
    [_tvGroupDescription setTextColor:[UIColor  colorWithRed:0.13 green:0.13 blue:0.13 alpha: 1.0]];
    [_tvGroupDescription setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:15]];
    
    [_lblPlaceholder setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:15]];
    [_lblPlaceholder setText:NSLocalizedString(@"Channel Description", nil)];
    [_lblPlaceholder setTextAlignment:NSTextAlignmentLeft];
    [_lblPlaceholder setBackgroundColor:[UIColor clearColor]];
    [_lblPlaceholder setTextColor:[UIColor  colorWithRed:0.72 green:0.72 blue:0.72 alpha: 1]];
    [_lblPlaceholder setHidden:[_tvGroupDescription hasText]];
    
    [_lblLimit setFont:[UIFont fontWithName:@"SFProDisplay" size:8]];
    [_lblLimit setBackgroundColor:[UIColor clearColor]];
    [_lblLimit setTextColor:[UIColor  colorWithRed:0.72 green:0.72 blue:0.72 alpha: 1]];
    [_lblLimit setText:[NSString stringWithFormat:@"%ld",(long)_intLimit]];
    
    if (self.dictGroupInfo[@"description"]) {
        [_tvGroupDescription setText:[NSString stringWithFormat:@"%@",self.dictGroupInfo[@"description"]]];
    }
    [self setupLimitViewWithString:[_tvGroupDescription text]];
}

- (void)setupNavigationBar {
    [_bntSave.titleLabel setFont:[UIFont fontWithName:@"SFProDisplay-Medium" size:16]];
    [_bntCancel.titleLabel setFont:[UIFont fontWithName:@"SFProDisplay-Medium" size:16]];
    [_lblNavTitle setFont:[UIFont fontWithName:@"SFProDisplay-Medium" size:18]];
    [_lblNavTitle setBackgroundColor:[UIColor clearColor]];
    [self.navigationItem setTitleView:_lblNavTitle];
    
    [_bntSave setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    [_bntCancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [_lblNavTitle setText:NSLocalizedString(@"Description", nil)];
    [_bntSave setEnabled:NO];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:_bntCancel]];
}

- (void)setupLimitViewWithString:(NSString *) string {
    NSString *strName = string;
    [_bntSave setEnabled:([strName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length>0)];
    [_lblLimit setText:[NSString stringWithFormat:@"%d", (int)((strName.length<501)?_intLimit-strName.length:0)]];
}

#pragma mark Text Field Delegate
- (void)textViewDidEndEditing:(UITextView *) textView {
    [_lblPlaceholder setHidden:[textView hasText]];
}

- (void) textViewDidChange:(UITextView *)textView {
    [_lblPlaceholder setHidden:[textView hasText]];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView == _tvGroupDescription) {
        NSString * stringToRange = [textView.text substringWithRange:NSMakeRange(0,range.location)];
        stringToRange = [stringToRange stringByAppendingString:text];
        [self setupLimitViewWithString:stringToRange];
        [_lblPlaceholder setHidden:stringToRange.length>0];
        return stringToRange.length<501;
    }
    return NO;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField == _tvGroupDescription) {
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
        [dictParam setValue:_tvGroupDescription.text forKey:Group_description];
        [dictParam setValue:self.dictGroupInfo[@"groupId"] forKey:Group_GroupId];
        [[eRTCChatManager sharedChatInstance]
         updateGroup:dictParam  andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
             [KVNProgress dismiss];
             [dictParam setValue:self.dictGroupInfo[@"groupId"] forKey:Group_GroupId];

             NSDictionary *dictResponse = (NSDictionary *)json;
             if (dictResponse[@"success"] != nil) {
                 BOOL success = (BOOL)dictResponse[@"success"];
                 if (success) {
                     if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                         NSDictionary *result = (NSDictionary *)dictResponse[@"result"];
                         if ([result count]>0){
                             self.dictGroupInfo = [[NSMutableDictionary alloc] initWithDictionary:result];
                             if (self.completion != nil) { self.completion(YES, self.dictGroupInfo);}
                             NSString *imageURL = [NSString stringWithFormat:@"%@",self.dictGroupInfo[User_ProfilePic_Thumb]];
                             NSString *strUrl = [imageBaseUrl stringByAppendingString:imageURL];
                             [self.dictGroupInfo setObject:strUrl forKey:User_ProfilePic_Thumb];
                             [self dismissViewControllerAnimated:YES completion:nil];
                             [[NSNotificationCenter defaultCenter] postNotificationName:UpdateGroupProfileSuccessfully object:self.dictGroupInfo];
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
