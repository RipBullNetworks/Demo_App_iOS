//
//  GroupListViewController.h
//  eRTCApp
//
//  Created by Apple on 28/08/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GroupListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate, UISearchControllerDelegate, UISearchResultsUpdating>
@property (weak, nonatomic) IBOutlet UITableView *tblGroupList;
@end

NS_ASSUME_NONNULL_END
