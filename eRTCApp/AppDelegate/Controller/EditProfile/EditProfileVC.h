//
//  EditProfileVC.h
//  eRTCApp
//
//  Created by apple on 13/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EditProfileVC : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tblProfileData;
@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;
@property (weak, nonatomic) IBOutlet UIButton *btnEditProfile;
@property (weak, nonatomic) IBOutlet UITextField *txtViewStatus;

@end

NS_ASSUME_NONNULL_END
