//
//  EditGroupDescriptionViewController.h
//  eRTCApp
//
//  Created by Ashish Vani on 30/08/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CompletionBlock)(BOOL isEdit, NSMutableDictionary * _Nullable dictInfo);

NS_ASSUME_NONNULL_BEGIN

@interface EditGroupDescriptionViewController : UIViewController
@property(nonatomic, strong) NSMutableDictionary *dictGroupInfo;
@property (nonatomic) CompletionBlock completion;

NS_ASSUME_NONNULL_END


@end
