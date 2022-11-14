//
//  ReportsViewController.h
//  eRTCApp
//
//  Created by apple on 09/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReportsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tblMessagesList;
@property (strong, nonatomic) NSMutableArray *arrModerationList;
@property (strong, nonatomic) NSMutableArray *arrMediaList;
@property (strong, nonatomic) NSMutableDictionary *dictGroupInfo;


@end

NS_ASSUME_NONNULL_END
