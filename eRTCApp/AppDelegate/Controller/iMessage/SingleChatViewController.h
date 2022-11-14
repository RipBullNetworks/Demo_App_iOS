//
//  SingleChatViewController.h
//  eRTCApp
//
//  Created by rakesh  palotra on 28/03/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSQMessagesViewController/JSQMessages.h>
#import <AVKit/AVKit.h>
#import "ChatReactionsViewController.h"
#import "EmojisViewController.h"
#import "ChatReactionUserListViewController.h"
#import "ForwardToViewController.h"

NS_ASSUME_NONNULL_BEGIN
@interface SingleChatViewController : JSQMessagesViewController
@property (strong, nonatomic) NSDictionary *dictUserDetails;
@property (strong, nonatomic) NSMutableArray *arrAllUsers;
@property (strong, nonatomic) IBOutlet UITableView *tblMention;
@property (nonatomic) BOOL isUserSearchActive;
@property (nonatomic) BOOL isUserSearchText;
@property (strong, nonatomic) NSString *strNonSearchText;
@property (strong, nonatomic) NSString *searchText;
@property(nonatomic, strong) NSString *strThreadId;
@property (strong, nonatomic) AVPlayerViewController *playerViewController;
@property (strong, nonatomic) NSDictionary *searchMessage;
@property (nonatomic) NSString *longPressMessage;
@property (strong, nonatomic) NSMutableArray *aryDomainFilter;
@property (strong, nonatomic) NSMutableArray *aryProfinityFilter;
@property (strong, nonatomic) NSDictionary *dictSelectedMessage;
@property (strong, nonatomic) NSDictionary *dictFilters;



- (void)actionPlayVideo:(NSURL*)videoUrl;
- (void)refreshChatData;
@end

NS_ASSUME_NONNULL_END
