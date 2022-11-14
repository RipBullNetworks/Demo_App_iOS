//  Created by Apple on 28/08/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.

#import "GroupListViewController.h"
#import "SearchViewController.h"
#import "UserContactsCell.h"
#import "SingleChatViewController.h"
#import "InfoGroupViewController.h"
#import "GroupChatViewController.h"
#import "ChannelPrivacyViewController.h"
#import "RecentChatTableViewCell.h"
#import "ObserverRemovable.h"

@interface GroupListViewController (){
    NSArray * arrGroups;
    NSArray * arrChatUsers;
    NSMutableArray * arrTableData;
    SearchViewController * vcSearch;
    UIRefreshControl *refreshControl;
    UISearchController *searchController;
}

@end

@implementation GroupListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addObservers];
    // Do any additional setup after loading the view.
    self.tblGroupList.estimatedRowHeight = 70;
    self.tblGroupList.rowHeight = UITableViewAutomaticDimension;
    [self.tblGroupList registerNib:[UINib nibWithNibName:RecentChatCellIdentifier bundle:[NSBundle mainBundle]] forCellReuseIdentifier:RecentChatCellIdentifier];
    [self configureNavigationBar];
    
    if (@available(iOS 10.0, *)) {
        self.tblGroupList.refreshControl = refreshControl;
    } else {
        [self.tblGroupList addSubview:refreshControl];
    }
    [self performSelector:@selector(getRecentChat) withObject:nil afterDelay:1.1];

}
-(void)dealloc{
    [self removeObservers];
}


-(void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:DidRecievedTypingStatusNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:DidReceivedGroupEvent];
   // [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTypingStatusNotification:)
                                                 name:DidRecievedTypingStatusNotification
                                               object:nil];
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
}



- (void)didReceiveTypingStatusNotification:(NSNotification *) notification{
    NSDictionary *dictTypingData = notification.userInfo;
    if ([dictTypingData isKindOfClass:[NSDictionary class]]){
        [arrTableData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj[@"threadId"]  isEqual:dictTypingData[@"threadId"]] && dictTypingData[@"name"] != NULL){
//                 RecentChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RecentChatCellIdentifier];
               RecentChatTableViewCell *cell = [_tblGroupList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
                if (cell){
                    if ([dictTypingData[@"typingStatusEvent"] isEqualToString:@"on"]){
                        cell.lblMessage.text = [NSString stringWithFormat:@"%@ is typing...",  dictTypingData[@"name"]];
                    }else {
                        cell.lblMessage.text = obj[@"message"];
                    }
                }
            }
        }];
    }
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    arrChatUsers = [NSArray new];
    arrTableData = [NSMutableArray new];
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
    } else {
        // Fallback on earlier versions
    }
    self.title = @"Groups";
    if (searchController != NULL && searchController.isActive){
        searchController.searchBar.text = @"";
        [searchController setActive:FALSE];
    }
    
//     self.navigationController.navigationBar.topItem.title=@"Messages";
  

    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
    } else {
        // Fallback on earlier versions
    }

    if (self->arrTableData.count>0) {
        [self->arrTableData removeAllObjects];
    }
    
    [self performSelector:@selector(getRecentChat) withObject:nil afterDelay:0.5];
    
    if (searchController  != NULL && searchController.isActive){
           searchController.searchBar.text = @"";
        [searchController setActive:FALSE];
    }

    //[self callAPIForGetGroupList];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
    } else {
        // Fallback on earlier versions
    }
    self.title = nil;
    if (self.navigationController.tabBarController != NULL && self.navigationController.tabBarController.viewControllers.count > 1){
        self.navigationController.tabBarController.tabBar.items[1].title = @"Contacts";
    }
}

- (void)refreshTable{
    //TODO: refresh your data
    [refreshControl endRefreshing];
}

- (void)configureNavigationBar {
    UIBarButtonItem *navRightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(bntNewGroupTapped:)];
    self.navigationItem.rightBarButtonItem = navRightButton;
    vcSearch = vcSearch = [[SearchViewController alloc] init];
    vcSearch.searchType = 2;
    searchController = [[UISearchController alloc] initWithSearchResultsController:vcSearch];
    searchController.searchResultsUpdater = self;
    searchController.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController = searchController;
        self.navigationItem.hidesSearchBarWhenScrolling = YES;
    } else {
        // Fallback on earlier versions
        self.tblGroupList.tableHeaderView = searchController.searchBar;
    }
    searchController.delegate = self;
    searchController.dimsBackgroundDuringPresentation = NO;
    searchController.searchBar.delegate = self;
    self.definesPresentationContext = YES;
}

#pragma mark - @API Call
- (void)callAPIForGetGroupList {
    
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        NSMutableDictionary*dict = [[NSMutableDictionary alloc]init];
       // [KVNProgress show];
        if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_ID] != nil) {
            [[eRTCChatManager sharedChatInstance] getuserGroups:dict andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                [KVNProgress dismiss];
                NSDictionary *dictResponse = (NSDictionary *)json;
                if (dictResponse[@"success"] != nil) {
                    BOOL success = (BOOL)dictResponse[@"success"];
                    if (success) {
                        if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *result = (NSDictionary *)dictResponse[@"result"];
                            NSArray *groups = (NSArray *)result[@"groups"];
                            [self refreshTableDataWith:groups];
                            return;
                        }
                    }
                }
                if (dictResponse[@"msg"] != nil) {
                    NSString *message = (NSString *)dictResponse[@"msg"];
                    if ([message length]>0) {
                        [Helper showAlertOnController:@"eRTC" withMessage:message onController:self];
                    }
                }
            }andFailure:^(NSError * _Nonnull error) {
                [KVNProgress dismiss];
                NSLog(@"GroupListViewController ->  callAPIForGetGroupList -> %@",error);
                [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
            }];
        }
    }else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
    
}

- (void)refreshTableDataWith:(NSArray *) ary {
    NSString *strAppUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"appUserId != %@",strAppUserId];
    NSArray *filteredArr = [ary filteredArrayUsingPredicate:predicate];
    if (filteredArr.count > 0) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        NSArray *sortedArray=[filteredArr sortedArrayUsingDescriptors:@[sort]];
        self->arrGroups = [NSArray arrayWithArray:sortedArray];
        self->arrTableData = [NSArray arrayWithArray:sortedArray];
        self->vcSearch.searchResults = [NSMutableArray arrayWithArray:sortedArray];
    }else{
        if (self->arrGroups.count>0) {
            self->arrGroups = [NSArray new];
            self->arrTableData = [NSArray new];
            [self->vcSearch.searchResults removeAllObjects];
        }
    }
    
    NSTimeInterval delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.tblGroupList reloadData];
    });
}


#pragma mark - UITableView Delegates and DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    [tableView setBackgroundView:[UIView new]];
    if (arrTableData.count > 0)
        return arrTableData.count;
    UILabel *lblNoGroup = [[UILabel alloc] initWithFrame:tableView.bounds];
    [lblNoGroup setBackgroundColor:[UIColor clearColor]];
    [lblNoGroup setTextAlignment:NSTextAlignmentCenter];
    [lblNoGroup setFont:[UIFont systemFontOfSize:14]];
    [lblNoGroup setText:@"No Channel Available"];
    [tableView setBackgroundView:lblNoGroup];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (arrTableData.count > indexPath.row) {
        NSDictionary * dict = [arrTableData objectAtIndex:indexPath.row];
        [self getGroupDetails:dict];
        if (dict[Group_GroupId] != nil && dict[Group_GroupId] != [NSNull null]) {
          
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle bundleForClass:InfoGroupViewController.class]];
            GroupChatViewController *vcInfo = [story instantiateViewControllerWithIdentifier:NSStringFromClass(GroupChatViewController.class)];
            vcInfo.dictGroupinfo = dict;
            [self.navigationController pushViewController:vcInfo animated:YES];
        }
    }
}

#pragma mark - Actions
- (IBAction)bntNewGroupTapped:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *nvcNewGroup = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"NewGroupNavigationViewController"];
    [nvcNewGroup setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:nvcNewGroup animated:YES completion:nil];
}

#pragma mark - UISearchBar Delegates
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString *searchString = searchBar.text;
    [self searchForText:searchString];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self searchForText:searchText];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:YES];
    [self searchForText:@""];
}

- (void)searchForText:(NSString*)searchString {
    if (arrGroups.count > 0 && [searchString length] > 0) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@",searchString];
        NSArray * _arrFiltered = [arrGroups filteredArrayUsingPredicate:predicate];
        vcSearch.searchResults = [NSMutableArray arrayWithArray:_arrFiltered];
    } else {
        vcSearch.searchResults = [NSMutableArray arrayWithArray:arrGroups];
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

- (void)logOutUser{
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:IsLoggedIn];
  [[NSUserDefaults standardUserDefaults] synchronize];
  [[UserModel sharedInstance]logOutUser];
  [[AppDelegate sharedAppDelegate] willChangeLoginAsRootOfApplication];
}

-(void)getRecentChat {
    [[eRTCChatManager sharedChatInstance] getActiveThreads:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        [self refreshGroupDataWith:json];
    } andFailure:^(NSError * _Nonnull error) {
        NSLog(@"RecentChatViewController -> getRecentChat --> getActiveThreads -> %@",error);
    }];
}

- (void)refreshGroupDataWith:(NSArray *) ary {
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
           
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[_obj valueForKey:@"isActivated"] boolValue] == true) {
                    [dict setObject:@true forKey:@"isActivated"];
                }else{
                    [dict setObject:@false forKey:@"isActivated"];
                }
            });
        
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
    NSPredicate *threadPredicate = [NSPredicate predicateWithFormat:@"threadType != %@",@"single"];
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
        } else {
        }
        [self->_tblGroupList reloadData];
    });
}

#pragma mark - Notification Observer

- (void)didReceiveMessageNotification:(NSNotification *) notification
{
    [self performSelector:@selector(getRecentChat) withObject:nil afterDelay:0.1];
}

- (void)didReceivedGroupEvent:(NSNotification *) notification
{
    NSDictionary *data = [notification userInfo];
        if (data && data[@"eventList"] && [data[@"eventList"] isKindOfClass:NSArray.class]){
        NSDictionary *eventObj =  [(NSArray*)data[@"eventList"] firstObject];
            if ([eventObj[@"eventType"] isEqualToString:@"deactivated"] || [eventObj[@"eventType"] isEqualToString:@"activated"]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self callAPIForGetAllGroupList];
                });
            }else if ([eventObj[@"eventType"] isEqualToString:@"participantsAdded"] || [eventObj[@"eventType"] isEqualToString:@"created"]) {
                [self callAPIForGetGroupList];
            }
        }
    if (self->arrTableData.count>0) {
        self-> arrTableData = [NSMutableArray new];
    }
    
    [self performSelector:@selector(getRecentChat) withObject:nil afterDelay:0.5];
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


-(void)getGroupDetails:(NSDictionary *)dict {
    NSString *gID = dict[Group_GroupId];
        [[eRTCCoreDataManager sharedInstance] fetchGroup:gID andCompletionHandler:^(NSDictionary *data, NSError *err) {
        if ([data isKindOfClass:NSDictionary.class] && [data[@"participants"] isKindOfClass:NSArray.class]){
            NSArray *participants = data[@"participants"];
            BOOL isUserParticipant = false;
            NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
            for (NSDictionary *user in participants) {
                
                if (user[@"eRTCUserId"] && [user[@"eRTCUserId"] isEqualToString:userId]){
                    isUserParticipant = true;
                    break;
                }
            }
            if (isUserParticipant){
               
            }else {
               // [self showBlockUI];
            }
        }
    }];
}




- (void)callAPIForGetAllGroupList {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        NSMutableDictionary*dict = [[NSMutableDictionary alloc]init];
        if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_ID] != nil) {
            [[eRTCChatManager sharedChatInstance] getAllGroups:dict andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                [KVNProgress dismiss];
                [self performSelector:@selector(getRecentChat) withObject:nil afterDelay:1.1];[self performSelector:@selector(getRecentChat) withObject:nil afterDelay:1.1];
            }andFailure:^(NSError * _Nonnull error) {
            }];
        }
    }else {
       
    }
}




@end
