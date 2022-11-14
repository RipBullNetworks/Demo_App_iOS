

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol MyChanneldelegate <NSObject>
@required
- (void)selectedJoinButton:(UITableViewCell *)cell andselectType:(NSString *)type;
@end

@interface tblSearchListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *btnJoin;
@property (weak, nonatomic) IBOutlet UILabel *lblChannelName;
@property (weak, nonatomic) IBOutlet UILabel *lblSubTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgGroupIcon;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (nonatomic, weak) id<MyChanneldelegate> delegate;

@end

NS_ASSUME_NONNULL_END
