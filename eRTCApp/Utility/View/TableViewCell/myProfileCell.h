//
//  myProfileCell.h
//  eRTCApp
//
//  Created by Apple on 26/07/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface myProfileCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblPlaceholder;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtStatus;

@end

NS_ASSUME_NONNULL_END
