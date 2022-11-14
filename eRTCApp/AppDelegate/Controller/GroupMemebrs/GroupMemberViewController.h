//
//  GroupMemberViewController.h
//  eRTCApp
//
//  Created by apple on 19/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GroupMemberViewController : UIViewController

@property(nonatomic, strong) NSMutableArray *aryParticipants;
@property (weak, nonatomic) IBOutlet UITableView *tblGroupMember;
@property(nonatomic, strong) NSMutableDictionary *dictGroupInfo;
@property (nonatomic) BOOL isLogged;

@end

NS_ASSUME_NONNULL_END
