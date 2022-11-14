//
//  ActionInfoTableViewCell.h
//  eRTCApp
//
//  Created by Ashish Vani on 04/07/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface ActionInfoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSubTitle;
@property (weak, nonatomic) IBOutlet UISwitch *switchActionable;
@property (weak, nonatomic) IBOutlet UIImageView *imgRight;


@end

NS_ASSUME_NONNULL_END
