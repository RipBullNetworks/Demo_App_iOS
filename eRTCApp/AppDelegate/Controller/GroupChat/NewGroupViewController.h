//
//  NewGroupViewController.h
//  eRTCApp
//
//  Created by Ashish Vani on 27/06/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CompletionBlock)(BOOL isAdd, NSMutableDictionary * _Nullable dictInfo);

NS_ASSUME_NONNULL_BEGIN

@interface NewGroupViewController : UIViewController

@property (assign) BOOL isAddParticipants;
@property (nonatomic, strong) NSMutableArray *arySelectedParticipants;
@property (nonatomic, strong) NSMutableDictionary *dictGroupInfo;
@property (assign) BOOL isAddAdmin;

@property (nonatomic) CompletionBlock completion;
@end

NS_ASSUME_NONNULL_END
