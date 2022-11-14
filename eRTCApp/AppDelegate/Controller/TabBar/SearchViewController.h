//
//  SearchViewController.h
//  eRTCApp
//
//  Created by Rakesh Palotra on 08/01/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactsViewController.h"
NS_ASSUME_NONNULL_BEGIN
typedef void (^LoadMore)(void);
@protocol ContactsSearchDelegate <NSObject>
-(void)didSelectedItem:(NSDictionary *)item;
@end
@interface SearchViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, assign) id<ContactsSearchDelegate> gsDelegate;

@property (nonatomic, assign) NSInteger searchType;

-(void)setRefereshCallBack:(LoadMore) loadMore;
-(void)isShowMoreHidden:(BOOL)isShowMoreHidden;
-(void)searchText:(NSString*)searchText;
-(void)showDeactivatedMessage:(NSString *)msg;

@end

NS_ASSUME_NONNULL_END
