//
//  ChatReactionsViewController.h
//  eRTCApp
//
//  Created by rakesh  palotra on 21/06/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HWPanModal/HWPanModal.h>
#import "ReactionsTableViewCell.h"

typedef NS_ENUM(NSUInteger, ReactType) {
    Copy,
    FavUnFav,
    StartThread,
    More,
    Forward,
    Delete,
    Edit,
    Report,
    Follow
};

@class ChatReactionsViewController;
@protocol ChatReactionsDelegateDelegate <NSObject>
- (void)recentChatReactionDelegate:(int)tagId selectedIndexPath:(NSIndexPath *_Nullable)indexPath emojiCode:(NSString *_Nullable)message;
- (void)chatReactDelegate: (ReactType)sender;
@end //end protocol

NS_ASSUME_NONNULL_BEGIN

@interface ChatReactionsViewController : UIViewController
@property (nonatomic, weak) id <ChatReactionsDelegateDelegate> delegate; //define MyClassDelegate as delegate
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *arrayDataSource;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (weak, nonatomic) IBOutlet UIView *vWContainerMessage;

@property (weak, nonatomic) IBOutlet UILabel *lblShowMessage;
@property (strong, nonatomic) NSMutableDictionary *dictTableText;
@property (nonatomic) BOOL isThread;
@property (nonatomic) NSString *message;
@property (nonatomic) NSString *userMessage;
-(void) setMessageType:(NSString*)type;
@end
NS_ASSUME_NONNULL_END
