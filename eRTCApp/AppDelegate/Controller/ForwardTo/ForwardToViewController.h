//
//  ForwardToViewController.h
//  eRTCApp
//
//  Created by Rakesh Palotra on 28/08/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForwardToTableViewCell.h"
#import "RecentChatViewController.h"
#import "eRTCTabBarViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ForwardToViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
//@property (weak, nonatomic) IBOutlet UIButton *btnContacts;
//@property (weak, nonatomic) IBOutlet UIButton *btnGroups;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *arraySelectedParticipantsContacts;
@property (strong, nonatomic) NSMutableArray *arraySelectedParticipantsGroups;
@property (strong, nonatomic) NSMutableDictionary *dictMessageDetails;
@property (strong, nonatomic) NSMutableDictionary *dictUserDetails;
@property (strong, nonatomic) NSString *threadId;
@property (nonatomic, assign) BOOL isGroup;
@property (nonatomic, assign) BOOL isGallery;

@end

NS_ASSUME_NONNULL_END
