//
//  ProfileViewController.h
//  eRTCApp
//
//  Created by Rakesh Palotra on 24/01/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProfileViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tblProfile;
@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (strong, nonatomic) NSDictionary *dictUserDetails;
@property(nonatomic, strong) NSString *strThreadId;
@property (assign) BOOL isSingleChat;
@property (nonatomic, strong) NSString *strProfileId;
@property(nonatomic, strong) NSMutableDictionary *dictGroupInfo;
@property(nonatomic, strong) NSMutableArray *arrGalleryData;
@property(nonatomic, strong) NSString *strGroupThread;

@end

NS_ASSUME_NONNULL_END
