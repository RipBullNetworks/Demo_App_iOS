//
//  NotificationPopUpViewController.h
//  eRTCApp
//
//  Created by Taresh Jain on 31/05/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol NotificationSettingDelegate <NSObject>
@optional
- (void)dismissPopUp;
@end

@interface NotificationPopUpViewController : UIViewController
@property (nonatomic, weak) id <NotificationSettingDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
