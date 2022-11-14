//
//  GroupParticipantsCollectionViewCell.h
//  eRTCApp
//
//  Created by Ashish Vani on 27/06/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GroupParticipantsCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *btnCross;

@end

NS_ASSUME_NONNULL_END
