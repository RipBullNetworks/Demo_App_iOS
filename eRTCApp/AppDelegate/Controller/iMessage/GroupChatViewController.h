//
//  GroupChatViewController.h
//  eRTCApp
//
//  Created by rakesh  palotra on 24/02/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSQMessagesViewController/JSQMessages.h>
#import <AVKit/AVKit.h>
#import "ChatReactionsViewController.h"
#import "EmojisViewController.h"
#import "ChatReactionUserListViewController.h"
#import "ForwardToViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupChatViewController : JSQMessagesViewController
@property (strong, nonatomic) NSDictionary *dictGroupinfo;
@property (nonatomic) BOOL isUserSearchActive;
@property (nonatomic) BOOL isUserSearchText;
@property (strong, nonatomic) NSString *strNonSearchText;
@property (strong, nonatomic) NSString *searchText;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraints;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewheightConstraint;
@property (strong, nonatomic) IBOutlet UITableView *tblMention;
@property(nonatomic, strong) NSString *strThreadId;
@property (strong, nonatomic) AVPlayerViewController *playerViewController;
@property (strong, nonatomic) NSDictionary *searchMessage;
@property (strong, nonatomic) NSMutableArray *aryDomainFilter;//dictImage
@property (strong, nonatomic) NSMutableArray *aryProfinityFilter;
@property (nonatomic) BOOL isEmojiResponse;


@property (nonatomic) NSString *longPressMessage;

- (void)actionPlayVideo:(NSURL*)videoUrl;
-(void)refreshChatData;
@end


NS_ASSUME_NONNULL_END
