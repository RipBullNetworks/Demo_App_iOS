//
//  GroupSearchViewController.h
//  eRTCApp
//
//  Created by Ashish Vani on 28/06/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol GroupSearchDelegate <NSObject>
-(void)didSelectedItem:(NSDictionary *)item;
@end

@interface GroupSearchViewController : UITableViewController

@property (nonatomic, strong) NSArray *arySearchResults;
@property (nonatomic, assign) id<GroupSearchDelegate> gsDelegate;
@property (nonatomic) NSString *searchChannel;
@end

NS_ASSUME_NONNULL_END
