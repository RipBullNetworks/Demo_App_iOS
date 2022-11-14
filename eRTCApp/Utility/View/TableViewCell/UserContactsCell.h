//
//  UserContactsCell.h
//  eRTCApp
//
//  Created by Rakesh Palotra on 05/01/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserContactsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblUserEmailId;
@property (weak, nonatomic) IBOutlet UIImageView *imgUserAwailability;
@property (weak, nonatomic) IBOutlet UIImageView *imageBlock;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgheight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgWidth;

@end

NS_ASSUME_NONNULL_END
