//
//  GlobalSearchSettingCell.h
//  eRTCApp
//
//  Created by Apple on 21/12/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GlobalSearchSettingCell;
@protocol globalSearchDelegate <NSObject>
@required
- (void)globalSearchSwitch:(bool)isGlobalSearch;
@end

@interface GlobalSearchSettingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch *btnSwitch;
@property (nonatomic, weak) id<globalSearchDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
