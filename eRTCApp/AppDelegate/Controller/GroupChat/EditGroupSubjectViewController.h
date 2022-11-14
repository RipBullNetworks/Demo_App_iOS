//
//  EditGroupViewController.h
//  eRTCApp
//
//  Created by Ashish Vani on 27/08/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CompletionBlock)(BOOL isEdit, NSMutableDictionary * _Nullable dictInfo);

NS_ASSUME_NONNULL_BEGIN

@interface EditGroupSubjectViewController : UIViewController
@property(nonatomic, strong) NSMutableDictionary *dictGroupInfo;
@property (nonatomic) CompletionBlock completion;

@end

NS_ASSUME_NONNULL_END
