//
//  MyProfileViewController.h
//  eRTCApp
//
//  Created by Apple on 26/07/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyProfileViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tblProfile;
@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UIButton *buttonImage;
@property (weak, nonatomic) IBOutlet UIImageView *imgIndicator;

@property (strong, nonatomic) NSDictionary *dictUserDetails;


@end

NS_ASSUME_NONNULL_END
