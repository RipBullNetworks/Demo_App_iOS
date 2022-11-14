//
//  chatRecentTabVc.h
//  eRTCApp
//
//  Created by apple on 23/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface chatRecentTabVc : UIViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *sgSigment;
@property (weak, nonatomic) IBOutlet UIView *vwContainerChannel;
@property (weak, nonatomic) IBOutlet UIView *vwContainerSingle;

-(void)addController:(UIViewController*)controller;
-(void)hidePendingEventActivity;
-(void)showPendingEventActivity;
-(void)refereshData;

@end

NS_ASSUME_NONNULL_END
