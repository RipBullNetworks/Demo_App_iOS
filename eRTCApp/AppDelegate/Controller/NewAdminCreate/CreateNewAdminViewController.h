//
//  CreateNewAdminViewController.h
//  eRTCApp
//
//  Created by apple on 13/05/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CompletionBlock)(BOOL isAdd, NSMutableDictionary * _Nullable dictInfo);

NS_ASSUME_NONNULL_BEGIN

@interface CreateNewAdminViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *arySelectedParticipants;
@property (nonatomic, strong) NSMutableDictionary *dictAdminSelected;
@property (nonatomic, strong) NSMutableArray *arrParticipants;
@property (nonatomic) NSString *groupId;
@property (nonatomic) CompletionBlock completion;

@end

NS_ASSUME_NONNULL_END
