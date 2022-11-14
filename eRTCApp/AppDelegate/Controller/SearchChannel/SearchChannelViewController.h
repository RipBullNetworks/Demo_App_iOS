//
//  SearchChannelViewController.h
//  eRTCApp
//
//  Created by apple on 17/05/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchChannelViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tblSearchChannels;
@property (nonatomic, strong) NSMutableArray *arrChannels;
@property (weak, nonatomic) IBOutlet UISearchBar *txtSerarch;
@property (nonatomic, strong) NSMutableArray *arrSearchChannels;
@property (nonatomic, strong) NSMutableDictionary *dictGroupInfo;
@property (nonatomic, strong) NSString *strGroupThreadID;

@end

NS_ASSUME_NONNULL_END
