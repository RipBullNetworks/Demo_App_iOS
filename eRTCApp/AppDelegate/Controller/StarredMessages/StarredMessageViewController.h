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


NS_ASSUME_NONNULL_BEGIN
@interface StarredMessageViewController : JSQMessagesViewController
@property (strong, nonatomic) NSDictionary *dictUserDetails;

@property (strong, nonatomic) AVPlayerViewController *playerViewController;
- (void)actionPlayVideo:(NSURL*)videoUrl;
@property(nonatomic, strong) NSString *strThreadId;
@property(nonatomic, strong) NSString *strGroupThread;
@property (weak, nonatomic) IBOutlet UILabel *lblNoDataFound;


@end

NS_ASSUME_NONNULL_END
