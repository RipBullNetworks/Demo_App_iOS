//
//  ReportsMessageViewController.h
//  eRTCApp
//
//  Created by apple on 10/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReportsMessageViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnSpam;
@property (weak, nonatomic) IBOutlet UIButton *btnInappropriate;
@property (weak, nonatomic) IBOutlet UIButton *btnAbuse;
@property (weak, nonatomic) IBOutlet UIButton *btnOther;
@property (weak, nonatomic) IBOutlet UIView *vwReportReason;
@property (weak, nonatomic) IBOutlet UITextField *txtReportReason;
@property(nonatomic, strong) NSMutableDictionary *dictMessage;

@end

NS_ASSUME_NONNULL_END
