//
//  ChatReactionUserListViewController.h
//  eRTCApp
//
//  Created by Chandra Rao on 26/07/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HWPanModal/HWPanModal.h>
#import "ChatRectionsUserTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatReactionUserListViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *arrayDataSource;
@property (strong, nonatomic) NSString *emoji;
@end

NS_ASSUME_NONNULL_END
