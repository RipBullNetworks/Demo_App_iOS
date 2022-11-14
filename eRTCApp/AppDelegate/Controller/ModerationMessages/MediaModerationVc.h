//
//  MediaModerationVc.h
//  eRTCApp
//
//  Created by apple on 14/05/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MediaModerationVc : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;
@property (strong, nonatomic) NSDictionary *dictMedia;

@end

NS_ASSUME_NONNULL_END
