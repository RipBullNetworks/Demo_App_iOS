//
//  ReportsMessageViewController.m
//  eRTCApp
//
//  Created by apple on 10/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "ReportsMessageViewController.h"
#import <Toast/Toast.h>
#import "Helper.h"

@interface ReportsMessageViewController () {

NSMutableString                     *category;
UIBarButtonItem *rightBarButton;
}
@end

@implementation ReportsMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Report Message";
    [self.vwReportReason setHidden:true];
    
    rightBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(btnSubmit:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
   // rightBarButton.action = false;
    rightBarButton.tintColor = UIColor.grayColor;
    
    NSLog(@"_dictMessage -->%@", _dictMessage);
    self.txtReportReason.delegate = self;
}

- (IBAction)btnSpam:(UIButton *)sender {
    [self setRadioButton:101];
}

- (IBAction)btnInappropriate:(UIButton *)sender {
    [self setRadioButton:102];
}

- (IBAction)btnAbuse:(UIButton *)sender {
    [self setRadioButton:103];
}

- (IBAction)btnOther:(UIButton *)sender {
    [self setRadioButton:104];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return true;
}




-(IBAction)btnSubmit:(id)sender
{
    [self.view endEditing:true];
    if ([category isEqualToString:@""]) {
        [self.view makeToast:EnterCategory];
    }else if (_txtReportReason.text.length == 0)  {
        [self.view makeToast:ReasonMessage];
        }else{
        [self chatReportsMessage];
        }
}

-(void)setRadioButton:(NSInteger)isRadio {
    if (isRadio == 101) {
        [_btnSpam setImage:[UIImage imageNamed:@"CheckCircle"] forState:UIControlStateNormal];
        [_btnAbuse setImage:[UIImage imageNamed:@"radioUncheck"] forState:UIControlStateNormal];
        [_btnOther setImage:[UIImage imageNamed:@"radioUncheck"] forState:UIControlStateNormal];
        [_btnInappropriate setImage:[UIImage imageNamed:@"radioUncheck"] forState:UIControlStateNormal];
        [self.vwReportReason setHidden:false];
        category = @"spam";
    }else if (isRadio == 102) {
        [_btnSpam setImage:[UIImage imageNamed:@"radioUncheck"] forState:UIControlStateNormal];
        [_btnAbuse setImage:[UIImage imageNamed:@"radioUncheck"] forState:UIControlStateNormal];
        [_btnOther setImage:[UIImage imageNamed:@"radioUncheck"] forState:UIControlStateNormal];
        [_btnInappropriate setImage:[UIImage imageNamed:@"CheckCircle"] forState:UIControlStateNormal];
        [self.vwReportReason setHidden:false];
        category = @"inappropriate";
    }else if (isRadio == 103) {
        [_btnSpam setImage:[UIImage imageNamed:@"radioUncheck"] forState:UIControlStateNormal];
        [_btnAbuse setImage:[UIImage imageNamed:@"CheckCircle"] forState:UIControlStateNormal];
        [_btnOther setImage:[UIImage imageNamed:@"radioUncheck"] forState:UIControlStateNormal];
        [_btnInappropriate setImage:[UIImage imageNamed:@"radioUncheck"] forState:UIControlStateNormal];
        [self.vwReportReason setHidden:false];
        category = @"abuse";
    }else if (isRadio == 104) {
        [_btnSpam setImage:[UIImage imageNamed:@"radioUncheck"] forState:UIControlStateNormal];
        [_btnAbuse setImage:[UIImage imageNamed:@"radioUncheck"] forState:UIControlStateNormal];
        [_btnOther setImage:[UIImage imageNamed:@"CheckCircle"] forState:UIControlStateNormal];
        [_btnInappropriate setImage:[UIImage imageNamed:@"radioUncheck"] forState:UIControlStateNormal];
        [self.vwReportReason setHidden:false];
        category = @"other";
    }
    rightBarButton.tintColor = [self colorWithHexString:@"007AFF"];
}

-(void)chatReportsMessage {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
        NSMutableDictionary*dictParam = [[NSMutableDictionary alloc]init];
        [dictParam setValue:self.txtReportReason.text forKey:Reason];
        [dictParam setValue:category forKey:Category];
        [dictParam setValue:_dictMessage[@"msgUniqueId"] forKey:MsgUniqueId];
//        if (_dictMessage[ParentID] != nil && _dictMessage[ParentID] != [NSNull null]) {
//        [dictParam setValue:_dictMessage[ParentID] forKey:ParentID];
//        }
        //[dictParam setValue:_dictMessage[ThreadID] forKey:ThreadID];
        [[eRTCChatManager sharedChatInstance] chatReport:dictParam andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            [KVNProgress dismiss];
            NSDictionary *dictResponse = (NSDictionary *)json;
            if (dictResponse[@"success"] != nil) {
                BOOL success = (BOOL)dictResponse[@"success"];
                if (success) {
                    if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *result = (NSDictionary *)dictResponse[@"result"];
                        if ([result count]>0){
                            self.txtReportReason.text = @"";
                            [[NSNotificationCenter defaultCenter] postNotificationName:ChatReportSuccessfully object:result];
                            [self.navigationController popViewControllerAnimated:true];
                            return;
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
        }andFailure:^(NSError * _Nonnull error) {
            [KVNProgress dismiss];
            [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
        }];
    } else {
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
