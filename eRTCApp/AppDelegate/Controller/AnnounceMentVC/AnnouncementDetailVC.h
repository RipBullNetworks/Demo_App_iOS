//
//  AnnouncementDetailVC.h
//  eRTCApp
//
//  Created by apple on 19/05/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnnouncementDetailVC : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *txtView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) NSDictionary *dictData;


@end

NS_ASSUME_NONNULL_END
