//
//  RecentSearchCell.h
//  eRTCApp
//
//  Created by Apple on 25/12/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN




@class RecentSearchCell;
@protocol MyRecentMessageDelegate <NSObject>
@required
- (void)selectedIndex:(RecentSearchCell *)cell;
- (void)selectedClearRecentChat:(RecentSearchCell *)cell;
@end





@interface RecentSearchCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblMessages;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentDate;
@property (weak, nonatomic) IBOutlet UIButton *btnCross;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constantBtnSearchHistory;
@property (nonatomic, weak) id<MyRecentMessageDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
