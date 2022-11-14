//
//  ThreadChatGroupViewController.h
//  eRTCApp
//
//  Created by rakesh  palotra on 05/05/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSQMessagesViewController/JSQMessagesViewController.h>
#import <AVKit/AVKit.h>
#import "ChatReactionsViewController.h"
#import "EmojisViewController.h"
#import "ChatReactionUserListViewController.h"
#import "GroupChatThreadHeaderView.h"
NS_ASSUME_NONNULL_BEGIN


typedef void (^LoadPreviouseMessageCompletion)(void);
@interface NSData (Download)
@end

@interface ThreadChatGroupViewController : JSQMessagesViewController
@property (strong, nonatomic) NSDictionary *dictGroupinfo;
@property (strong, nonatomic) NSDictionary *dictGroupThreadMsgDetails;

@property (strong, nonatomic) IBOutlet UITableView *tblMention;
@property (nonatomic) BOOL isUserSearchActive;
@property (nonatomic) BOOL isGroupDeleted;
@property (strong, nonatomic) NSString *strNonSearchText;
@property (strong, nonatomic) NSString *searchText;
@property (nonatomic) NSString *longPressMessage;
@property (strong, nonatomic) NSMutableArray *aryDomainFilter;
@property (strong, nonatomic) NSMutableArray *aryProfinityFilter;
@property (nonatomic) BOOL isFrozenthreadChannel;

@property (strong, nonatomic) AVPlayerViewController *playerViewController;
- (void)actionPlayVideo:(NSURL*)videoUrl;
@end

NS_ASSUME_NONNULL_END
