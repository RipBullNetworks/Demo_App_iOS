//
//  StarredMessageVC.h
//  eRTCApp
//
//  Created by Apple on 30/11/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StarredMessageVC : UIViewController

@property (nonatomic) BOOL isSearchStarredMessage;
@property (strong, nonatomic) NSMutableArray *aryStarredMessage;


@property (weak, nonatomic) IBOutlet UITableView *tblFavouriteLIst;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarView;


@end

NS_ASSUME_NONNULL_END
