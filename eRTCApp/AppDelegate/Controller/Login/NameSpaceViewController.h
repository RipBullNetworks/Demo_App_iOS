//
//  NameSpaceViewController.h
//  eRTCApp
//
//  Created by rakesh  palotra on 27/12/18.
//  Copyright © 2018 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class AuthManager;

@interface NameSpaceViewController : LogineRTCBaseViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *vwNAmeSpace;
@property (weak, nonatomic) IBOutlet UIImageView *vwAccessCode;

@end

NS_ASSUME_NONNULL_END
