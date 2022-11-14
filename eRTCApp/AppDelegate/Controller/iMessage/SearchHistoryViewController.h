//
//  SearchHistoryViewController.h
//  eRTCApp
//
//  Created by rakesh  palotra on 30/11/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchHistoryViewController : UIViewController

@property (nonatomic) BOOL isSearchStarredMessage;
@property (strong, nonatomic) NSMutableArray *aryStarredMessage;

@end

NS_ASSUME_NONNULL_END
