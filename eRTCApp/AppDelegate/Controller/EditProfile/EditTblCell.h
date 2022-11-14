//
//  EditTblCell.h
//  eRTCApp
//
//  Created by apple on 13/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EditTblCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblCannedTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSubTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgRight;

@end

NS_ASSUME_NONNULL_END
