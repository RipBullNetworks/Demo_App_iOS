//
//  threadImageCell.h
//  eRTCApp
//
//  Created by apple on 09/08/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface threadImageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgProduct;
@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblName;

@end

NS_ASSUME_NONNULL_END
