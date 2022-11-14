//
//  ImageVideoCell.h
//  eRTCApp
//
//  Created by apple on 15/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageVideoCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *imgMediaType;

@end

NS_ASSUME_NONNULL_END
