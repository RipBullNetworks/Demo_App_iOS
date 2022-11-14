//
//  RecentChatViewController.h
//  eRTCApp
//
//  Created by rakesh  palotra on 26/12/18.
//  Copyright © 2018 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecentChatViewController : UIViewController
-(void)addController:(UIViewController*)controller;
-(void)hidePendingEventActivity;
-(void)showPendingEventActivity;
-(void)refereshData;
@end

NS_ASSUME_NONNULL_END
