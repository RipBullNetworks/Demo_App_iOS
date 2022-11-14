//
//  ThreadChatViewController.h
//  eRTCApp
//
//  Created by Taresh Jain on 25/04/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSQMessagesViewController/JSQMessages.h>
#import <AVKit/AVKit.h>
#import "ChatReactionsViewController.h"
#import "EmojisViewController.h"
#import "ChatReactionUserListViewController.h"
#import "GroupChatThreadHeaderView.h"

typedef void (^LoadPreviouseMessageCompletion)(void);
@interface NSData (Download)
@end


NS_ASSUME_NONNULL_BEGIN
@interface ThreadChatViewController : JSQMessagesViewController
@property (strong, nonatomic) NSDictionary *dictUserDetails;
@property (strong, nonatomic) NSDictionary *dictThreadMsgDetails;

@property (strong, nonatomic) IBOutlet UITableView *tblMention;
@property (nonatomic) BOOL isUserSearchActive;
@property (strong, nonatomic) NSString *strNonSearchText;
@property (strong, nonatomic) NSString *searchText;
@property (nonatomic) NSString *longPressMessage;
@property (strong, nonatomic) NSMutableArray *aryDomainFilter;
@property (strong, nonatomic) NSMutableArray *aryProfinityFilter;

@property (strong, nonatomic) AVPlayerViewController *playerViewController;
- (void)actionPlayVideo:(NSURL*)videoUrl;
@end

NS_ASSUME_NONNULL_END
