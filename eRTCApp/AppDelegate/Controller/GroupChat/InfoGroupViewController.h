//
//  InfoGroupViewController.h
//  eRTCApp
//
//  Created by Ashish Vani on 04/07/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN


@interface InfoGroupViewController : UIViewController
@property(nonatomic, strong) NSMutableArray *aryParticipants;
@property (weak, nonatomic) IBOutlet UIView *vwInvitationSent;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnEditAndSave;
@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property(nonatomic, strong) NSMutableDictionary *dictGroupInfo;
@property(nonatomic, strong) NSMutableArray *arrGalleryData;

@end

NS_ASSUME_NONNULL_END
