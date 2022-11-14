//
//  RecentChatViewController.m
//  eRTCApp
//
//  Created by rakesh  palotra on 26/12/18.
//  Copyright © 2018 Ripbull Network. All rights reserved.
//

#import "RecentChatViewController.h"
#import "SettingViewController.h"
#import "RecentChatTableViewCell.h"
#import "SearchViewController.h"
#import "SingleChatViewController.h"
#import "NewGroupViewController.h"
#import "MyProfileViewController.h"
#import "GroupChatViewController.h"
#import "InfoGroupViewController.h"
#import "ObserverRemovable.h"
#import "PendingEventLoadingView.h"
#import "SearchHistoryViewController.h"



@interface RecentChatViewController ()<UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate, UIGestureRecognizerDelegate, UISearchControllerDelegate, UISearchResultsUpdating> {
    __weak IBOutlet UITableView *tblRecentChat;
    NSArray * arrChatUsers;
    NSMutableArray * arrTableData;
    SearchViewController * vcSearch;
    __weak IBOutlet UIButton *bntNewGroup;
    __weak IBOutlet UIButton *bntStartConversion;
    __weak IBOutlet UIView *noConversionView;
    UISearchController *searchController;
    NSMutableArray *_controllers;
    PendingEventLoadingView *loadingView;
}

@property (strong, nonatomic) UISearchBar *searchController;

@end

@implementation RecentChatViewController

-(void)addController:(UIViewController*)controller{
    [_controllers addObject:controller];
}

- (void)viewDidLoad {
    _controllers = @[].mutableCopy;
    [super viewDidLoad];
    [noConversionView setHidden:YES];
    // Do any additional setup after loading the view.
    arrChatUsers = [NSArray new];
    arrTableData = [NSMutableArray new];
    
    tblRecentChat.estimatedRowHeight = 60;
    tblRecentChat.tableFooterView = [UIView new];
    tblRecentChat.rowHeight = UITableViewAutomaticDimension;
    [self configureNavigationBar];
    if (@available(iOS 13.0, *)) {
          [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
      } else {
          // Fallback on earlier versions
      }
    
    [self addObservers];
}

-(void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:DidRecievedTypingStatusNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:DidReceivedGroupEvent];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTypingStatusNotification:)
                                                 name:DidRecievedTypingStatusNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didupdateStatus:)
                                                 name:DidUpdateUserBlockStatusNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateOtheruserPro:)
                                                 name:DidUpdateOtherUserProfile
                                               object:nil];
}

- (void)didupdateStatus:(NSNotification *) notification{
    NSDictionary *dictTypingData = notification.userInfo;
    [self performSelector:@selector(getRecentChat) withObject:nil afterDelay:1.0];
}

- (void)didReceiveTypingStatusNotification:(NSNotification *) notification{
    NSDictionary *dictTypingData = notification.userInfo;
    if ([dictTypingData isKindOfClass:[NSDictionary class]]){
        [arrTableData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj[@"threadId"]  isEqual:dictTypingData[@"threadId"]] && dictTypingData[@"name"] != NULL){
//                 RecentChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RecentChatCellIdentifier];
               RecentChatTableViewCell *cell = [tblRecentChat cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
                cell.imgPrivateChannel.hidden = true;
               // cell.imgBlock.hidden = true;
                if (cell){
                    if ([dictTypingData[@"typingStatusEvent"] isEqualToString:@"on"]){
                        cell.lblMessage.text = [NSString stringWithFormat:@"%@ is typing...",  dictTypingData[@"name"]];
                    }else {
                        cell.lblMessage.text = obj[@"message"];
                    }
                    
                }
                
            }
        }];
        
        
//        if (self.strThreadId!= nil && dictTypingData[ThreadID] != [NSNull null]) {
//            if ([self.strThreadId isEqualToString:dictTypingData[ThreadID]]){
//                if ([[dictTypingData valueForKey:@"typingStatusEvent"]isEqualToString:@"on"]) {
//                    if (self.showTypingIndicator!=true) {
//                        [self setShowTypingIndicator:YES];
//                    }
//                } else {
//                    [self setShowTypingIndicator:NO];
//                }
//                [self scrollToBottomAnimated:YES];
//            }
//        }
    }
}

-(void)observerCleanUP{
    [_controllers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(ObserverRemovable)]){
            id<ObserverRemovable> removable = (id<ObserverRemovable>)obj;
            [removable removeObservers];
        }
    }];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    arrChatUsers = [NSArray new];
    arrTableData = [NSMutableArray new];
    [self observerCleanUP];
    self.title = @"Messages";
    self.navigationItem.title = @"Messages";
//     self.navigationController.navigationBar.topItem.title=@"Messages";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMessageNotification:)
                                                 name:DidRecievedMessageNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getRecentChat)
                                                 name:DidRecievedReactionNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(didReceivedGroupEvent:)
     name:DidReceivedGroupEvent
     object:nil];

    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
    } else {
        // Fallback on earlier versions
    }
    
    [self performSelector:@selector(getRecentChat) withObject:nil afterDelay:0.1];
 
    if (searchController  != NULL && searchController.isActive){
           searchController.searchBar.text = @"";
        [searchController setActive:FALSE];
    }
}

- (void)didUpdateOtheruserPro:(NSNotification *) notification {
    
    NSDictionary *dictData = notification.userInfo;
    NSString *appId;
    NSString *eventType;
    if (dictData[AppUserIds] != nil && dictData[AppUserIds] != [NSNull null]) {
        NSArray *ary = dictData[AppUserIds];
        appId = ary.firstObject;
    }
    if (dictData[keyEvent] != nil && dictData[keyEvent] != [NSNull null]) {
        eventType = dictData[keyEvent];
    }
 
  // [self callAPIForGetChatUserList:eventType];
    [self callAPIForGetChatUserList:eventType andAppUserID:appId];
    
}

-(void)showPendingEventActivity{
    if (loadingView == nil){
        loadingView = [[PendingEventLoadingView alloc] init];
        loadingView.translatesAutoresizingMaskIntoConstraints = NO;
        self.navigationItem.titleView = loadingView;
        /*
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            self.navigationItem.titleView = nil;
            self->loadingView = nil;
        });
         */
    }
}
-(void)hidePendingEventActivity{
    self.navigationItem.titleView = nil;
    self->loadingView = nil;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.title = nil;
    if (self.navigationController.tabBarController != NULL && self.navigationController.tabBarController.viewControllers.count > 0){
        self.navigationController.tabBarController.tabBar.items[0].title = @"Messages";
    }
    
   // [[NSNotificationCenter defaultCenter] removeObserver:DidRecievedMessageNotification];
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
    } else {
        // Fallback on earlier versions
    }
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
   // [self performSelector:@selector(getRecentChat) withObject:nil afterDelay:0.1];
}

-(void) dealloc {
    [self removeObservers];
}


#pragma mark - @IBAction
- (IBAction)bntStartNewConversionTapped:(id)sender {
       self.tabBarController.selectedIndex = 1;
}

- (IBAction)bntNewGroupTapped:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *nvcNewGroup = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"NewGroupNavigationViewController"];
    [self.navigationController presentViewController:nvcNewGroup animated:YES completion:nil];
}

- (void)configureNavigationBar {
    self.navigationItem.title = @"Messages";
    
  // UIBarButtonItem *navRightButton  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(navRightButtonClicked)];
    UIImage *rightBarImage = [[UIImage imageNamed:@"startChatnew"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *navRightButton  = [[UIBarButtonItem alloc] initWithImage:rightBarImage style:UIBarButtonItemStylePlain target:self action:@selector(navRightButtonClicked)];
    self.navigationItem.rightBarButtonItem = navRightButton;
    NSString*imageURL = [[UserModel sharedInstance] getUserDetailsUsingKey:User_ProfilePic_Thumb];
    
   /* UIView *titleHeaderView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 35, 35)];
     UIImage *img = [UIImage imageNamed:@"DefaultUserIcon"];
     UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,4, 35, 35)];
    // imgView.center = titleView.center;
     [imgView setImage:img];
     [imgView setContentMode:UIViewContentModeScaleAspectFill];
     imgView.layer.cornerRadius= imgView.frame.size.height/2;
     imgView.layer.masksToBounds = YES;
    [imgView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
    [titleHeaderView addSubview:imgView];
    UIButton *btn = [[UIButton alloc] initWithFrame:titleHeaderView.frame];
    [titleHeaderView addSubview:btn];
    [btn addTarget:self action:@selector(pushToMyProfile) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *navLeftButton = [[UIBarButtonItem alloc] initWithCustomView:titleHeaderView];
    //UIBarButtonItem *navLeftButton  = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"avatar.png"] style:UIBarButtonItemStylePlain target:self action:@selector(pushToMyProfile)];
    self.navigationItem.leftBarButtonItem = navLeftButton;*/

    vcSearch = [[SearchViewController alloc] init];
    vcSearch.searchType = 1;
    
    searchController = [[UISearchController alloc] initWithSearchResultsController:vcSearch];

   // [searchController.searchBar setSearchFieldBackgroundImage:
   // [UIImage imageNamed:@"SearchField.png"]
     //          forState:UIControlStateNormal];
    searchController.searchResultsUpdater = self;
    searchController.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController = searchController;
        self.navigationItem.hidesSearchBarWhenScrolling = YES;
    } else {
        // Fallback on earlier versions
        tblRecentChat.tableHeaderView = searchController.searchBar;
    }
    searchController.delegate = self;
    searchController.dimsBackgroundDuringPresentation = NO;
    searchController.searchBar.delegate = self;
    self.definesPresentationContext = YES;
}

#pragma mark - @API Call

- (void)callAPIForGetChatUserList:(NSString *)updateType andAppUserID:(NSString *)userID {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [[eRTCAppUsers sharedInstance] getUserListWithLastUserID:@"" andLastCallTime:@"" andUpdateType:updateType andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            if (![Helper stringIsNilOrEmpty:json[Key_Success]] && [json[Key_Success] integerValue] == 1) {
                if (![Helper stringIsNilOrEmpty:json[Key_Result]]) {
                    NSArray * ary = json[Key_Result][Key_ChatUsers];
                    if (ary.count > 0) {
                        [self performSelector:@selector(getRecentChat) withObject:nil afterDelay:0.2];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            if (self->arrTableData.count > 0) {
                            NSArray *arrData = [self->arrTableData.mutableCopy filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"appUserId == %@",userID]];
                                NSLog(@"print arrData %@",arrData);
                            [[NSNotificationCenter defaultCenter] postNotificationName:DidupdateProfileAndStatus object:arrData.firstObject];
                            }
                        });
                    }
                }
            } else {
                if (![Helper stringIsNilOrEmpty:json[Key_Message]]) {
                    [Helper showAlertOnController:@"eRTC" withMessage:json[Key_Message] onController:self];
                }
            }
        } andFailure:^(NSError * _Nonnull error) {
            [Helper showAlertOnController:@"eRTC" withMessage:[error localizedDescription] onController:self];
        }];
    } else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}

-(void)refereshData {
    [self getRecentChat];
}


-(void)getRecentChat {
    [[eRTCChatManager sharedChatInstance] getActiveThreads:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        
        [self refreshTableDataWith:json];
    } andFailure:^(NSError * _Nonnull error) {
        NSLog(@"RecentChatViewController -> getRecentChat --> getActiveThreads -> %@",error);
    }];
}


- (void)refreshTableDataWith:(NSArray *) ary {
    NSMutableArray * recentChatAry = [NSMutableArray new];
    for(NSObject *_obj in ary) {
        NSMutableDictionary * dict = [NSMutableDictionary new];
        NSString *chatUserId = [_obj valueForKey:RecipientAppUserId];
        NSString *threadId = [_obj valueForKey:ThreadID];
        if([_obj valueForKey:@"threadType"] != nil) {
            [dict setObject:[NSString stringWithFormat:@"%@", [_obj valueForKey:@"threadType"]] forKey:@"threadType"];
        }
        if([_obj valueForKey:NotificationSettings] != nil) {
            [dict setObject:[NSString stringWithFormat:@"%@", [_obj valueForKey:NotificationSettings]] forKey:NotificationSettings];
        }
        
        //[[eRTCAppUsers sharedInstance] fetchUserDetailWithAppUserId:chatUserId andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        [[eRTCAppUsers sharedInstance] fetchUserDetailWithAppUserId:_obj andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            
            
            if(json[User_Name] != nil) {
                [dict setObject:[NSString stringWithFormat:@"%@", json[User_Name]] forKey:User_Name];
            }
            if(json[TenantID] != nil) {
                [dict setObject:[NSString stringWithFormat:@"%@", json[TenantID]] forKey:TenantID];
            }
            if(json[User_ID] != nil) {
                [dict setObject:[NSString stringWithFormat:@"%@", json[User_ID]] forKey:User_ID];
            }
            if(json[User_ProfileStatus] != nil) {
                [dict setObject:[NSString stringWithFormat:@"%@", json[User_ProfileStatus]] forKey:User_ProfileStatus];
            }
            if(json[User_ProfilePic] != nil) {
                [dict setObject:[NSString stringWithFormat:@"%@", json[User_ProfilePic]] forKey:User_ProfilePic];
                      
            }
            if(json[User_ProfilePic_Thumb] != nil) {
                [dict setObject:[NSString stringWithFormat:@"%@", json[User_ProfilePic_Thumb]] forKey:User_ProfilePic_Thumb];
                      
            }
            if(json[App_User_ID] != nil) {
                [dict setObject:[NSString stringWithFormat:@"%@", json[App_User_ID]] forKey:App_User_ID];
            }
            if(json[ThreadID] != nil) {
                [dict setObject:[NSString stringWithFormat:@"%@", json[ThreadID]] forKey:ThreadID];
            }
            if(json[AvailabilityStatus] != nil) {
                [dict setObject:[NSString stringWithFormat:@"%@", json[AvailabilityStatus]] forKey:AvailabilityStatus];
            }
            
            if(json[Group_GroupId] != nil) {
                [dict setObject:[NSString stringWithFormat:@"%@", json[Group_GroupId]] forKey:Group_GroupId];
            }
            if(json[Group_Type] != nil) {
                [dict setObject:[NSString stringWithFormat:@"%@", json[Group_Type]] forKey:Group_Type];
            }
            if(json[User_eRTCUserId] != nil) {
                [dict setObject:[NSString stringWithFormat:@"%@", json[User_eRTCUserId]] forKey:User_eRTCUserId];
            }
            
            NSString *unReadMsg = [_obj valueForKey:UnReadMessageCount];
            
            if(unReadMsg != nil && [unReadMsg length] > 0) {
                [dict setObject:[NSString stringWithFormat:@"%@", unReadMsg] forKey:UnReadMessageCount];
            }
            if(json[@"availabilityStatus"] != nil) {
            [dict setObject:[NSString stringWithFormat:@"%@", json[@"availabilityStatus"]] forKey:@"availabilityStatus"];
            }

            if(json[@"blockedStatus"] != nil) {
            [dict setObject:[NSString stringWithFormat:@"%@", json[@"blockedStatus"]] forKey:@"blockedStatus"];
            }

        } andFailure:^(NSError * _Nonnull error) {
            [Helper showAlertOnController:@"eRTC" withMessage:[error localizedDescription] onController:self];
        }];
        
        [[eRTCCoreDataManager sharedInstance] getUserChatHistoryWithThreadID:threadId andCompletionHandler:^(id ary, NSError *err) {
            
            NSUInteger chatCount = [ary count];
            if(chatCount > 0) {
                NSDictionary * _chatObj = [ary objectAtIndex:chatCount -1];
                if(_chatObj[Message] != nil) {
                    [dict setObject:[NSString stringWithFormat:@"%@", _chatObj[Message]] forKey:Message];
                }
                /*
                if(_chatObj[ThreadID] != nil && _chatObj[MsgUniqueId] != nil) {
                    [[eRTCCoreDataManager sharedInstance] getUserReplyThreadChatHistoryWithThreadID:_chatObj[ThreadID] withParentID:_chatObj[MsgUniqueId] andCompletionHandler:^(id ary, NSError *err) {
                        NSLog(@"RecentChatViewController ->  refreshTableDataWith -> getUserReplyThreadChatHistoryWithThreadID -> %@",ary);
                        NSUInteger threadChatCount = [ary count];
                        if(threadChatCount > 0) {
                            NSDictionary * _threadChatObj = [ary objectAtIndex:threadChatCount -1];
                            if(_threadChatObj[Message] != nil) {
                                NSString *threadMsg = [NSString stringWithFormat:@"%@", _threadChatObj[Message]];
                                NSString *chatMsg = [NSString stringWithFormat:@"%@", _chatObj[Message]];
                                NSString *strMessage = [chatMsg stringByAppendingFormat:@" %@",threadMsg];
                                [dict setObject:strMessage forKey:Message];
                            }
                        }else{
                            if(_chatObj[Message] != nil) {
                                [dict setObject:[NSString stringWithFormat:@"%@", _chatObj[Message]] forKey:Message];
                            }
                        }
                    }];
                }*/
               /* if(_chatObj[Message] != nil) {
                    [dict setObject:[NSString stringWithFormat:@"%@", _chatObj[Message]] forKey:Message];
                }*/
                 if(_chatObj[@"createdAt"] != nil) {
                    [dict setObject:[NSString stringWithFormat:@"%@", _chatObj[@"createdAt"]] forKey:@"createdAt"];
                }
                if(_chatObj[MsgType] != nil) {
                    [dict setObject:[NSString stringWithFormat:@"%@", _chatObj[MsgType]] forKey:MsgType];
                }
                if(_chatObj[MsgStatusEvent] != nil) {
                    [dict setObject:[NSString stringWithFormat:@"%@", _chatObj[MsgStatusEvent]] forKey:MsgStatusEvent];
                }
            }
            else if(chatCount == 0) {
                [dict removeAllObjects];
            }
        }];
        
        if (dict.count>0) {
            [recentChatAry addObject:dict];
        }
    }
    
    NSString *strAppUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"appUserId != %@",strAppUserId];
    NSArray *filteredArr = [[NSArray arrayWithArray:recentChatAry] filteredArrayUsingPredicate:predicate];
    NSPredicate *threadPredicate = [NSPredicate predicateWithFormat:@"threadType != %@",@"group"];
    NSArray *filteredArrThread = [[NSArray arrayWithArray:filteredArr] filteredArrayUsingPredicate:threadPredicate];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:FALSE];
    filteredArrThread=[filteredArrThread sortedArrayUsingDescriptors:@[sort]];
    if (filteredArr.count > 0) {
        self->arrTableData = [[NSArray arrayWithArray:filteredArrThread] mutableCopy];
        self->arrChatUsers = [NSArray arrayWithArray:filteredArrThread];
        self->vcSearch.searchResults = [NSMutableArray arrayWithArray:filteredArrThread];
       /* dispatch_async(dispatch_get_main_queue(), ^{
            if (self->arrTableData.count>0) {
                [self->noConversionView setHidden:YES];
            } else {
                [self->noConversionView setHidden:NO];
            }
            [self->tblRecentChat reloadData];
        });*/
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->arrTableData.count>0) {
            [self->noConversionView setHidden:YES];
        } else {
            [self->noConversionView setHidden:NO];
        }
        [self->tblRecentChat reloadData];
    });
}

#pragma mark - UITableView Delegates and DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (arrTableData.count > 0)
        return arrTableData.count;
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RecentChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RecentChatCellIdentifier];
    
    if (cell == nil) {
        NSArray *arrNib = [[NSBundle mainBundle] loadNibNamed:RecentChatCellIdentifier owner:self options:nil];
        cell = [arrNib objectAtIndex:0];
    }
    
    if (arrTableData.count > indexPath.row) {
        NSDictionary * dict = [arrTableData objectAtIndex:indexPath.row];
        if (dict[User_Name] != nil && dict[User_Name] != [NSNull null]) {
            cell.lblName.text = dict[User_Name];
            [cell.lblName setHidden:NO];
        } else {
            cell.lblName.text = @"";
            [cell.lblName setHidden:YES];
        }
        
        if (dict[@"createdAt"] != nil && dict[@"createdAt"] != [NSNull null]) {
            double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
            NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
            JSQMessage*  newMessage = [[JSQMessage alloc] initWithSenderId:@"" senderDisplayName:@"" date:msgdate text:@""];
            cell.lblTime.attributedText =  [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:newMessage.date];
            [cell.lblTime setHidden:NO];
        }else{
            cell.lblTime.text = @"";
            [cell.lblTime setHidden:YES];
        }
        
        if(dict[Message] != nil && dict[Message] != [NSNull null]) {
            cell.lblMessage.text = [Helper getRemoveMentionTags: dict[Message]];
            [cell.lblMessage setHidden:NO];
        } else {
            cell.lblMessage.text = @"";
            [cell.lblMessage setHidden:YES];
            if (dict[@"msgType"] != nil && dict[@"msgType"] != [NSNull null]) {
                cell.lblMessage.attributedText = [self setMediaMessageTypeInMessageLabel:dict[@"msgType"]];
                [cell.lblMessage setHidden:NO];
            }
        }
        if (dict[User_ProfilePic_Thumb] != nil && dict[User_ProfilePic_Thumb] != [NSNull null]) {
            NSString *imageURL = [NSString stringWithFormat:@"%@",dict[User_ProfilePic_Thumb]];
            [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:imageURL]
            placeholderImage:[UIImage imageNamed:@"recentChatuser"]];
            cell.profileImageView.layer.cornerRadius= cell.profileImageView.frame.size.height/2;
            cell.profileImageView.layer.masksToBounds = YES;
        }else{
            cell.profileImageView.image =  [UIImage imageNamed:@"recentChatuser"];
        }
        
        NSLog(@"RecentChatViewController -> cellForRowAtIndexPath  -> %@",dict[UnReadMessageCount]);
        if(dict[UnReadMessageCount] != nil && dict[UnReadMessageCount] != [NSNull null] && ([dict[UnReadMessageCount] integerValue] > 0)) {
            cell.unReadMessage.hidden = NO;
            NSString *unReadMessage = dict[UnReadMessageCount];
            cell.unReadMessage.layer.masksToBounds = YES;
            cell.unReadMessage.layer.cornerRadius = 8.0;
            cell.unReadMessage.text = unReadMessage;
            [cell.unReadMessage sizeToFit];
            cell.imgBlock.hidden = YES;
            
        } else {
            cell.unReadMessage.hidden = YES;
            cell.imgBlock.hidden = NO;
        }
        cell.imgRightArrow.hidden = YES;
        cell.lblAvailabilityStatus.layer.cornerRadius= cell.lblAvailabilityStatus.frame.size.height/2;
        cell.lblAvailabilityStatus.layer.masksToBounds = YES;
        
        if (dict[AvailabilityStatus] != nil && dict[AvailabilityStatus] != [NSNull null]) {
            if ([dict[AvailabilityStatus] isEqualToString:Online]) {
                cell.lblAvailabilityStatus.backgroundColor = [UIColor greenColor];
            }
           else if ([dict[AvailabilityStatus] isEqualToString:Away])
           {
                cell.lblAvailabilityStatus.backgroundColor = [UIColor colorWithRed:255/255.0f green:215/255.0f blue:73/255.0f alpha:1.0];

            }
            else if ([dict[AvailabilityStatus] isEqualToString:Invisible])
            {
                cell.lblAvailabilityStatus.backgroundColor = [UIColor colorWithRed:133/255.0f green:142/255.0f blue:153/255.0f alpha:1.0];

            }
            else if ([dict[AvailabilityStatus] isEqualToString:Dnd])
            {
                cell.lblAvailabilityStatus.backgroundColor = [UIColor redColor];
            }
        }else{
            cell.lblAvailabilityStatus.hidden =YES;
        }
        
         cell.muteIMG.hidden = YES;

     if (dict[BlockedStatus] != nil && dict[BlockedStatus] != [NSNull null]) {

        if ([dict[BlockedStatus] isEqualToString:@"blocked"]) {
            [cell.muteIMG setImage:[UIImage imageNamed:@"profileBlock"]];
             cell.muteIMG.hidden = NO;
             cell.unReadMessage.hidden = YES;
        }
     }
    if (dict[NotificationSettings] != nil && dict[NotificationSettings] != [NSNull null]) {

           if ([dict[NotificationSettings] isEqualToString:@"none"]) {
               [cell.muteIMG setImage:[UIImage imageNamed:@"muteImg"]];
                cell.muteIMG.hidden = NO;
           }
        }
    }
    cell.imgBlock.hidden = true;
    cell.imgPrivateChannel.hidden = true;
    return cell;
}

- (NSMutableAttributedString *)setMediaMessageTypeInMessageLabel:(NSString *)msgType {
    NSString *img = @"";
    NSString *text = @"";
    if ([msgType isEqualToString:@"image"]) {
        img = @"recentChahtImgIcon";
        text = @"Image";
    } else if ([msgType isEqualToString:@"video"]) {
        img = @"recentChatVideoIcon";
        text = @"Video";
    } else if ([msgType isEqualToString:@"audio"]) {
        img = @"recentChatAudioIcon";
        text = @"Audio";
    } else if ([msgType isEqualToString:@"location"]) {
        img = @"recentChatLocationIcon";
        text = @"Location";
    } else if ([msgType isEqualToString:@"gify"]) {
        img = @"recentChahtImgIcon";
        text = @"GIF";
    } else if ([msgType isEqualToString:@"contact"]) {
        img = @"recentChatContactIcon";
        text = @"Contact";
    } else {
        NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:@" "];
        return myString;
    }
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:img];

    NSMutableAttributedString *attachmentString = [NSMutableAttributedString attributedStringWithAttachment:attachment];

    NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", text]];
    [attachmentString appendAttributedString:myString];
    return attachmentString;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 75;
//}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 1;
//}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 75.0;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (arrTableData.count > indexPath.row) {
    NSDictionary * dict = [arrTableData objectAtIndex:indexPath.row];
    SingleChatViewController * _vcMessage = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"SingleChatViewController"];
    _vcMessage.dictUserDetails = dict;
    [self.navigationController pushViewController:_vcMessage animated:YES];
    }
    
    /*
        if (![Helper stringIsNilOrEmpty:dict[@"threadType"]]) {
            if ([dict[@"threadType"] isEqualToString:@"single"]){
               
            }
            else{
                UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle bundleForClass:InfoGroupViewController.class]];
                GroupChatViewController *vcInfo = [story instantiateViewControllerWithIdentifier:NSStringFromClass(GroupChatViewController.class)];
                vcInfo.dictGroupinfo = dict;
                [self.navigationController pushViewController:vcInfo animated:YES];
            }
        }
    }*/
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath  API_AVAILABLE(ios(11.0)){
    UIContextualAction *delete = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
                                                                         title:@"DELETE"
                                                                       handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [Helper showAlert:Delete_conversation message:msg_Delete_conversation btnYes:@"Delete" btnNo:@"Cancel" inViewController:self completedWithBtnStr:^(NSString* btnString) {
            if ([btnString isEqualToString:@"Delete"]) {
             NSDictionary * dict = [arrTableData objectAtIndex:indexPath.row];
                [self clearChatHistory:dict[ThreadID]];
                [self performSelector:@selector(getRecentChat) withObject:nil afterDelay:0.2];
            }
        }];
    }];
    delete.title = @"Delete";
     // delete.image = [UIImage imageNamed:@"DeleteSwipe"];
   // delete.backgroundColor = UIColor.redColor;                                                               completionHandler(YES);
    UISwipeActionsConfiguration *swipeActionConfig = [UISwipeActionsConfiguration configurationWithActions:@[delete]];
    swipeActionConfig.performsFirstActionWithFullSwipe = NO;
    return swipeActionConfig;
}


//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//    }
//}

#pragma mark - UISearchBar Delegates

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
//    SearchHistoryViewController *sVC = [[SearchHistoryViewController alloc] init];
//    sVC.hidesBottomBarWhenPushed = TRUE;
//    [self.navigationController pushViewController:sVC animated:true];
    return TRUE;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString *searchString = searchBar.text;
    [self searchForText:searchString];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self searchForText:searchText];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:YES];
    [self searchForText:@""];
}

- (void)searchForText:(NSString*)searchString {
    if (arrChatUsers.count > 0 && [searchString length] > 0) {
       // NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@",searchString];
        NSString* filter = @"%K CONTAINS[cd] %@ || %K CONTAINS[cd] %@";
        NSArray* args = @[@"name",searchString, @"message",searchString];
        NSPredicate* predicate = [NSPredicate predicateWithFormat:filter argumentArray:args];
        NSArray * _arrFiltered = [arrChatUsers filteredArrayUsingPredicate:predicate];
        vcSearch.searchResults = [NSMutableArray arrayWithArray:_arrFiltered];
    } else {
        vcSearch.searchResults = [NSMutableArray arrayWithArray:arrChatUsers];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->vcSearch.tableView reloadData];
    });
    
    UITableView *tableView = self->vcSearch.tableView;
    NSUInteger *searchResultCount = vcSearch.searchResults.count;
    if (searchResultCount > 0){
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.backgroundView = nil;
        
    }else{
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height)];
        noDataLabel.text = @"No Results Found!";
        noDataLabel.font = [UIFont fontWithName:@"SFProDisplay-Semibold" size:18];
        noDataLabel.textAlignment = NSTextAlignmentCenter;
        noDataLabel.textColor = [UIColor darkGrayColor];
        noDataLabel.backgroundColor = [UIColor whiteColor];
        tableView.backgroundView = noDataLabel;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
}

#pragma mark - Actions
-(void)navRightButtonClicked {
    self.tabBarController.selectedIndex = 2;
}
- (void)pushToMyProfile {
    MyProfileViewController *_vcProfile = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"MyProfileViewController"];
    [self.navigationController pushViewController:_vcProfile animated:YES];
}

-(IBAction)appSettingsButtonClicked:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    SettingViewController *settingsView = [storyBoard instantiateViewControllerWithIdentifier:@"SettingViewController"];
    [self.navigationController pushViewController:settingsView animated:YES];
}

#pragma mark - Notification Observer
- (void)didReceiveMessageNotification:(NSNotification *) notification
{
    NSDictionary *dictData = notification.userInfo;
    [self performSelector:@selector(getRecentChat) withObject:nil afterDelay:2.0];
   // [[eRTCChatManager sharedChatInstance] updateMessageWithReadStatus:dictData];
}

- (void)didReceivedGroupEvent:(NSNotification *) notification
{
    if (self->arrTableData.count>0) {
        self-> arrTableData = [NSMutableArray new];
    }
    [self performSelector:@selector(getRecentChat) withObject:nil afterDelay:0.5];
}

-(void)clearChatHistory:(NSString *)threadId {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
        [[eRTCChatManager sharedChatInstance] clearChatHistoryBy:threadId andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        [KVNProgress dismiss];
        [self performSelector:@selector(getRecentChat) withObject:nil afterDelay:0.2];
        //[self.view makeToast:ChatMsgClearSuccess];
        [self.navigationController popToRootViewControllerAnimated:NO];
        }andFailure:^(NSError * _Nonnull error) {
            
        }];
    } else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}

@end

