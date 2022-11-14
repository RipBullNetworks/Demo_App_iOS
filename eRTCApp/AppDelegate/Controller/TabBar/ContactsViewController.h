//
//  ContactsViewController.h
//  eRTCApp
//
//  Created by rakesh  palotra on 01/01/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (weak, nonatomic) IBOutlet UITableView *tblContacts;

@end

NS_ASSUME_NONNULL_END
