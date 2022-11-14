//
//  ManageNotificationVC.h
//  eRTCApp
//
//  Created by apple on 14/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ManageNotificationVC : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tblManageNotification;
@property(nonatomic, strong) NSString *strGroupThread;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hgtConsTantView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (nonatomic, strong) NSString *strType;

@end

NS_ASSUME_NONNULL_END
