//
//  ForgotViewController.h
//  eRTCApp
//
//  Created by Rakesh Palotra on 06/01/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ForgotViewController : LogineRTCBaseViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgBorder;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;

@end

NS_ASSUME_NONNULL_END
