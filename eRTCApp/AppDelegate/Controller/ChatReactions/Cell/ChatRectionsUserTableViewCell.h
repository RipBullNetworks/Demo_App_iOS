//
//  ChatRectionsUserTableViewCell.h
//  eRTCApp
//
//  Created by Chandra Rao on 26/07/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatRectionsUserTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelUser;
@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
@property (weak, nonatomic) IBOutlet UILabel *labelEmoji;

@end

NS_ASSUME_NONNULL_END
