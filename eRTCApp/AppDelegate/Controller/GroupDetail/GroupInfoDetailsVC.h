//
//  GroupInfoDetailsVC.h
//  eRTCApp
//
//  Created by apple on 16/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GroupInfoDetailsVC : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblName;

@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UIImageView *imgDetails;
@property (weak, nonatomic) IBOutlet UILabel *lblImageName;
@property (weak, nonatomic) IBOutlet UILabel *lblImageSize;

@property (nonatomic, strong) NSDictionary *dictGalleryInfo;
@property (strong, nonatomic) NSDictionary *dictUserDetails;

@end

NS_ASSUME_NONNULL_END
