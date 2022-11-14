//
//  threadViewCell.h
//  eRTCApp
//
//  Created by apple on 22/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class threadViewCell;
@protocol MyThreadInfoDelegate <NSObject>
@required
- (void)selectedIndex:(threadViewCell *)cell;

@end

@interface threadViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *btnMoreInfo;

@property (weak, nonatomic) IBOutlet UIView *viewThread;
@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblSubTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) id<MyThreadInfoDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
