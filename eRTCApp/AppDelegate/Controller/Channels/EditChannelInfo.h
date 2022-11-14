//
//  EditChannelInfo.h
//  eRTCApp
//
//  Created by apple on 20/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EditChannelInfo : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;
@property (weak, nonatomic) IBOutlet UIButton *btnEditImage;
@property (weak, nonatomic) IBOutlet UILabel *lblGroupName;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;

@property(nonatomic, strong) NSMutableDictionary *dictEditInfo;


@end

NS_ASSUME_NONNULL_END
