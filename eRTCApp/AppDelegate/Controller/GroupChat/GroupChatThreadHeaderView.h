//
//  GroupChatThreadHeaderView.h
//  eRTCApp
//
//  Created by Rakesh on 06/08/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GroupChatThreadHeaderView : UICollectionReusableView

@property (nonatomic,retain)IBOutlet UIImageView *imgUser;
@property (nonatomic,retain)IBOutlet UILabel *lblName;
@property (nonatomic,retain)IBOutlet UILabel *lblTime;
@property (nonatomic,retain)IBOutlet UILabel *lblMessage;
@property (nonatomic,retain)IBOutlet UIButton *btnFav;

@end

NS_ASSUME_NONNULL_END
