//
//  ThreadViewController.h
//  eRTCApp
//
//  Created by apple on 22/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSQMessagesViewController/JSQMessages.h>
#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThreadViewController : JSQMessagesViewController

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
