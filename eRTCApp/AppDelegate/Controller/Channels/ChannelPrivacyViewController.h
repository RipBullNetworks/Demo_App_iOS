//
//  ChannelPrivacyViewController.h
//  eRTCApp
//
//  Created by Apple on 07/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CompletionBlock)(BOOL isEdit, NSMutableDictionary * _Nullable dictInfo);

NS_ASSUME_NONNULL_BEGIN

@interface ChannelPrivacyViewController : UIViewController
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationTitle;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnNextRightBar;
@property (nonatomic) BOOL isEditModeOn;
@property (nonatomic) NSString *privacyKeyType;
@property (nonatomic) NSString *groupId;
@property (nonatomic) CompletionBlock completion;
@property(nonatomic, strong) NSMutableDictionary *dictGroupkey;
@end

NS_ASSUME_NONNULL_END
