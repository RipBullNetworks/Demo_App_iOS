//
//  ChannelSearchViewController.h
//  eRTCApp
//
//  Created by apple on 18/05/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ChannelSearchDelegate <NSObject>
-(void)didSelectedItem:(NSDictionary *)item;
@end

@interface ChannelSearchViewController : UITableViewController
@property (nonatomic, assign) id<ChannelSearchDelegate> CsDelegate;
@property (nonatomic, strong) NSArray *arrChannelSearch;
@property (nonatomic, strong) NSMutableDictionary *dictGroupInfo;

@end

NS_ASSUME_NONNULL_END
