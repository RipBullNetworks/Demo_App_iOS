

#import "SearchHistoryViewController.h"
#import "SearchViewController.h"
#import "RecentChatTableViewCell.h"
#import "SingleChatViewController.h"
#import "GroupChatViewController.h"
#import "InfoGroupViewController.h"
#import "RecentSearchCell.h"
#import <Toast/Toast.h>
#import "ClearSearchHistoryCell.h"


@interface SearchHistoryViewController ()<UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource,MyRecentMessageDelegate>{
    UISearchController *searchController;
    SearchViewController * vcSearch;
    __weak IBOutlet UITableView *tblRecentChat;
    NSArray * arrChatUsers;
    NSMutableArray * arrTableData;
    NSMutableArray * arrRecentSearch;
    NSDictionary *usersMap;
    NSDictionary *threadMap;
    NSDictionary *groupMap;
    UIActivityIndicatorView *searchActivityIndicatorView;
    UIView *defaultSearchTextfieldLeftView;
    NSTimer *timer;
    NSUInteger limit;
    NSUInteger skip;
    NSString *searchText;
    BOOL  appGlobalSearch;
}

@end

@implementation SearchHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureNavigationBar];
    limit = 5;
    skip = 0;
    [tblRecentChat registerNib:[UINib nibWithNibName:RecentSearchWithCell bundle:nil] forCellReuseIdentifier:RecentSearchWithCell];
    [tblRecentChat registerNib:[UINib nibWithNibName:ClearSearchrecentHistoryCell bundle:nil] forCellReuseIdentifier:ClearSearchrecentHistoryCell];
    self->tblRecentChat.delegate = self;
    [self prepareAndSetUsersMap];
    [self prepareAndSetThreadMap];
    [self prepareAndSetGroupMap];
    
    self->tblRecentChat.separatorStyle = UITableViewCellSeparatorStyleNone;
   
   // self->appGlobalSearch = [dictConfig[@"globalSearchEnable"] boolValue];
    
}


//NSUInteger total;
- (void)configureNavigationBar {
    if (_isSearchStarredMessage == true) {
    self.navigationItem.title = @"Starred Message";
    }else{
    self.navigationItem.title = @"Messages";
    }
    vcSearch = [[SearchViewController alloc] init];
    vcSearch.searchType = 1;
    [vcSearch isShowMoreHidden: TRUE];
    BOOL isGlobalSearchEnable = [[NSUserDefaults standardUserDefaults] boolForKey:@"isGlobalSearchEnable"];
    if (isGlobalSearchEnable) {
            [vcSearch setRefereshCallBack:^{
                [KVNProgress show];
                [[eRTCChatManager sharedChatInstance] getHistory: self->searchText   limit:self->limit skip:arrTableData.count isGblobalSearchEnable: isGlobalSearchEnable threadID:NULL completion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                    
                    NSLog(@"getHistory>>>>>22>>> %@", json);
                    [KVNProgress dismiss];
                    self->skip = self.self->arrTableData.count;
                    if (json[@"chats"]){
                        [self addMoreDataWith: json[@"chats"]];
                    }
                    BOOL isHidden = FALSE;
                    if (json[@"total"] && [json[@"total"] isKindOfClass:NSNumber.class]){
//                        total = [json[@"total"] intValue];
                        if (self->arrTableData.count >= [json[@"total"] intValue]){
                            isHidden = TRUE;
                        }
                        NSLog(@"total => %@", json[@"total"]);
                    }
                    [self->vcSearch isShowMoreHidden: isHidden];
                } andFailure:^(NSError * _Nonnull error) {
                    NSLog(@"Error %@", error);
                }];
            }];
    }

    searchController = [[UISearchController alloc] initWithSearchResultsController:vcSearch];
    searchController.searchResultsUpdater = self;
    searchController.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController = searchController;
        self.navigationItem.hidesSearchBarWhenScrolling = NO;
    } else {
        // Fallback on earlier versions
        tblRecentChat.tableHeaderView = searchController.searchBar;
    }
    searchController.delegate = self;
    searchController.dimsBackgroundDuringPresentation = NO;
    searchController.searchBar.delegate = self;
    self.definesPresentationContext = YES;
}
-(void)prepareAndSetUsersMap {
    
    [[eRTCCoreDataManager sharedInstance] fetchChatUserListWithCompletionHandler:^(id ary, NSError *err) {
        NSMutableDictionary *_userMap = @{}.mutableCopy;
        for (NSDictionary *uDetails in ary) {
            NSString *uID = uDetails[@"appUserId"];
            if (uID != NULL){
                _userMap[uID] = uDetails;
            }
        }
        NSDictionary *details = [[UserModel sharedInstance] getUserDetails];
        if (details[@"appUserId"] != NULL){
            _userMap[details[@"appUserId"]] = details;
        }
        self->usersMap = _userMap.copy;
    }];
}


-(void)prepareAndSetThreadMap {
    [[eRTCChatManager sharedChatInstance] getActiveThreads:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        NSLog(@"SearchHistoryViewController -> [getActiveThreads] -> %@",json);
        
        [self prepareAndSetThreadMapFrom:json];
    } andFailure:^(NSError * _Nonnull error) {
        NSLog(@"RecentChatViewController -> getRecentChat --> getActiveThreads -> %@",error);
    }];
}


-(void)prepareAndSetThreadMapFrom:(NSArray*)threads {
    NSMutableDictionary *_threadMap = @{}.mutableCopy;
    for (NSDictionary *thread in threads) {
        NSString *tID = thread[@"threadId"];
        if (tID != NULL){
            _threadMap[tID] = thread;
        }
    }
    self->threadMap = _threadMap.copy;
}


-(void)prepareAndSetGroupMap {
    [eRTCCoreDataManager fetchGroupRecordWithCompletionHandler:^(id ary, NSError *err) {
        if ([ary isKindOfClass:NSArray.class] && [ary count] > 0){
            NSLog(@"SearchHistoryViewController -> [prepareAndSetGroupMap] -> %@", ary);
            NSMutableDictionary *_groupMap = @{}.mutableCopy;
            for (NSDictionary *thread in ary) {
                NSString *tID = thread[@"threadId"];
                if (tID != NULL){
                    _groupMap[tID] = thread;
                }
            }
            self->groupMap = _groupMap.copy;
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_isSearchStarredMessage == true) {
    self.navigationItem.title = @"Starred Message";
    }else{
    self.navigationItem.title = @"Messages";
    }

    if (!searchController.searchResultsUpdater){
        searchController.searchResultsUpdater = self;
        searchController.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }
   
    if (@available(iOS 11.0, *)) {
        if (!self.navigationItem.searchController){
            self.navigationItem.searchController = searchController;
           // self.navigationItem.hidesSearchBarWhenScrolling = YES;
        }
        
//
    } else {
        // Fallback on earlier versions
        if (!tblRecentChat.tableHeaderView){
            tblRecentChat.tableHeaderView = searchController.searchBar;
        }
        
    }
    if (!searchController.delegate){
        searchController.delegate = self;
        searchController.dimsBackgroundDuringPresentation = NO;
        searchController.searchBar.delegate = self;
        self.definesPresentationContext = YES;
    }
    [self getRecentMessageData];
   // [self setupNotResultFoundView];
}

-(void)getRecentMessageData {
    NSString *appUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
    [[eRTCChatManager sharedChatInstance] getRecentChatData:appUserId withData:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        self->arrRecentSearch = [NSMutableArray new];
        NSMutableArray *arr;
        arr = [NSMutableArray arrayWithArray:[self reverseArray:json]];
        self->arrRecentSearch = [arr subarrayWithRange:NSMakeRange(0, MIN(5, arr.count))];
        [tblRecentChat reloadData];
    } andFailure:^(NSError * _Nonnull error) {
        
    }];
}

-(NSArray *) reverseArray : (NSArray *) myArray {
    return [[myArray reverseObjectEnumerator] allObjects];
}


-(void) setupNotResultFoundView{
    UITableView *tableView = tblRecentChat;
    if (arrRecentSearch.count > 0 || arrTableData.count > 0) {
    tableView.backgroundView = nil;
    }else {
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height)];
        noDataLabel.text = @"No recent searches";
        noDataLabel.font = [UIFont fontWithName:@"SFProDisplay-Semibold" size:18];
        noDataLabel.textAlignment = NSTextAlignmentCenter;
        noDataLabel.textColor = [UIColor darkGrayColor];
        noDataLabel.backgroundColor = [UIColor whiteColor];
        tableView.backgroundView = noDataLabel;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return TRUE;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString *newSearchText = searchController.searchBar.text;
    
    if (_isSearchStarredMessage == true) {
        
        
    }else{
        NSString *searchString = searchController.searchBar.text;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString *searchString = searchBar.text;
}


- (void)searchText:(NSString * _Nonnull)searchText completion:(void (^)(void)) completion {

    if (_isSearchStarredMessage == true) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@",searchText];
        NSArray * _arrFiltered = [self.aryStarredMessage filteredArrayUsingPredicate:predicate];
      
        arrTableData = [NSMutableArray arrayWithArray:_arrFiltered];
        [self->tblRecentChat reloadData];
    }else{
        BOOL isLocalSearchMessage = false;
        BOOL isGlobalSearchEnable = false;
        NSDictionary *dictConfig = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
        
        if ([dictConfig[@"globalSearchEnable"] boolValue] == 0 && [dictConfig[@"localSearch"] boolValue] == 0) {
            isGlobalSearchEnable = true;
        }else if ([dictConfig[@"globalSearchEnable"] boolValue] == 1 && [dictConfig[@"localSearch"] boolValue] == 0) {
            BOOL isappGlobalSearch = [[NSUserDefaults standardUserDefaults] boolForKey:@"isGlobalSearchEnable"];
            if (isappGlobalSearch == true) {
                isGlobalSearchEnable = true;
            }else{
                isLocalSearchMessage = true;
            }
        }else if ([dictConfig[@"globalSearchEnable"] boolValue] == 0 && [dictConfig[@"localSearch"] boolValue] == 1) {
            BOOL isappGlobalSearch = [[NSUserDefaults standardUserDefaults] boolForKey:@"isGlobalSearchEnable"];
            if (isappGlobalSearch == true) {
                isGlobalSearchEnable = true;
            }else{
                isGlobalSearchEnable = false;
            }
        }else if ([dictConfig[@"globalSearchEnable"] boolValue] == 1 && [dictConfig[@"localSearch"] boolValue] == 1) {
            BOOL isappGlobalSearch = [[NSUserDefaults standardUserDefaults] boolForKey:@"isGlobalSearchEnable"];
            if (isappGlobalSearch == true) {
                isGlobalSearchEnable = true;
            }else{
                isGlobalSearchEnable = false;
            }
        }
        
        if (isLocalSearchMessage == false) {
        self->searchText = searchText;
        skip = 0;
        
        [[eRTCChatManager sharedChatInstance] getHistory: self->searchText   limit:limit skip:skip isGblobalSearchEnable:isGlobalSearchEnable threadID:NULL completion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            NSLog(@"isGblobalSearchEnable>>>>>22>>> %@", json);
            if ([errMsg isEqualToString:GlobalSearch_msg]) {
                vcSearch.tableView.hidden = true;
                [self.view endEditing:true];
                [self.view makeToast:GlobalSearch_msg duration:3.0 position:CSToastPositionCenter];
            }else{
            self->skip = self.self->arrTableData.count;
            NSArray *items = @[];
            if (json[@"chats"]){
                items = json[@"chats"];
            }
            NSMutableDictionary *_threadMap = @{}.mutableCopy;
            if (json[@"threads"]) {
                [self prepareAndSetThreadMapFrom:json[@"threads"]];
            }else {
                [self prepareAndSetThreadMap];
            }
            [self->vcSearch searchText:searchText];
            [self prepareAndSetGroupMap];
            [self refreshTableDataWith: (isGlobalSearchEnable ? [self prepareData:items] : [self prepareLocalData:items])];
            if (json[@"total"]){
                NSLog(@"total => ", json[@"total"]);
            }
            BOOL isHidden = FALSE;
            if (json[@"total"] && [json[@"total"] isKindOfClass:NSNumber.class]){
                if (self->arrTableData.count >= [json[@"total"] intValue]){
                    isHidden = TRUE;
                }
                NSLog(@"total => %@", json[@"total"]);
            }else {
                isHidden = TRUE;
            }
            [self->vcSearch isShowMoreHidden: isHidden];
            completion();
         }
        } andFailure:^(NSError * _Nonnull error) {
            NSLog(@"Error %@", error);
        
            completion();
        }];
        }else{
            vcSearch.tableView.hidden = true;
            [self.view makeToast:GlobalSearch_msg duration:3.0 position:CSToastPositionCenter];
        }
   }
  }

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (_isSearchStarredMessage == true) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"message contains[c] %@",searchText];
        NSArray * _arrFiltered = [self.aryStarredMessage filteredArrayUsingPredicate:predicate];
        arrTableData = [NSMutableArray arrayWithArray:_arrFiltered];
        [self->tblRecentChat reloadData];
    }else{
        NSString *searchString = searchBar.text;
    [self->vcSearch isShowMoreHidden: TRUE];
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        if ([searchText isEqual:@""]){
            [self refreshTableDataWith: @[]];
            return;
        }
        if (timer){
            [self->timer invalidate];
            self->timer = NULL;
        }
        if (!searchActivityIndicatorView){
            if (@available(iOS 13.0, *)) {
               // searchActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
            } else {
                // Fallback on earlier versions
            }
           // searchActivityIndicatorView.hidesWhenStopped = true;
        }
        UITextField *textField = NULL;
        for (UIView *view in searchBar.subviews[0].subviews) {
            for (UIView *_view in view.subviews) {
                if ([_view isKindOfClass:UITextField.class]){
                    textField = (UITextField*)_view;
                    if (!defaultSearchTextfieldLeftView){
                        defaultSearchTextfieldLeftView = textField.leftView;
                    }
                }
            }
        }
        if (textField){
           // textField.leftView = searchActivityIndicatorView;
        }
        
        
       // [searchActivityIndicatorView startAnimating];
        timer = [NSTimer scheduledTimerWithTimeInterval:1.2 repeats:false block:^(NSTimer * _Nonnull timer) {
            [self searchText:searchText completion:^{
               // [self->searchActivityIndicatorView stopAnimating];
                if (textField){
                    textField.leftView = self->defaultSearchTextfieldLeftView;
                }
                [self->timer invalidate];
                self->timer = NULL;
            }];
        }];
        
        
    }else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
  }
    
}


- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}




-(void)searchMessageforRecentChat:(NSString*)searchTextMsg {
    
}




- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:YES];
}

- (NSMutableArray *)prepareLocalData:(NSArray *)ary {
    
    NSMutableArray * chats = [NSMutableArray new];
    for (NSDictionary *chat in ary) {
        NSString *tID = chat[@"threadId"];
        NSString *type = chat[@"threadType"];
        
        NSMutableDictionary *chatData = chat.mutableCopy;
        NSDictionary *threadDetails = NULL;
        if (tID && threadMap[tID] != NULL){
            threadDetails = threadMap[tID];
        }
        
        if (threadDetails && threadDetails[@"recipientAppUserId"] != NULL){
            type = threadDetails[@"threadType"];
            [chatData setObject:[NSString stringWithFormat:@"%@", type] forKey:@"threadType"];
            if ([type isEqual:@"single"]){
                NSString *recipientAppUserId = threadDetails[@"recipientAppUserId"];
                
                if (recipientAppUserId != NULL && usersMap[recipientAppUserId] != NULL){
                    NSDictionary *userDetails = usersMap[recipientAppUserId];
                    if(userDetails[User_Name] != nil) {
                        [chatData setObject:[NSString stringWithFormat:@"%@", userDetails[User_Name]] forKey:User_Name];
                    }
                    if(userDetails[TenantID] != nil) {
                        [chatData setObject:[NSString stringWithFormat:@"%@", userDetails[TenantID]] forKey:TenantID];
                    }
                    if(userDetails[User_ID] != nil) {
                        [chatData setObject:[NSString stringWithFormat:@"%@", userDetails[User_ID]] forKey:User_ID];
                    }
                    if(userDetails[User_ProfileStatus] != nil) {
                        [chatData setObject:[NSString stringWithFormat:@"%@", userDetails[User_ProfileStatus]] forKey:User_ProfileStatus];
                    }
                    if(userDetails[User_ProfilePic] != nil) {
                        [chatData setObject:[NSString stringWithFormat:@"%@", userDetails[User_ProfilePic]] forKey:User_ProfilePic];
                        
                    }
                    if(userDetails[User_ProfilePic_Thumb] != nil) {
                        [chatData setObject:[NSString stringWithFormat:@"%@", userDetails[User_ProfilePic_Thumb]] forKey:User_ProfilePic_Thumb];
                        
                    }
                    if(userDetails[App_User_ID] != nil) {
                        [chatData setObject:[NSString stringWithFormat:@"%@", userDetails[App_User_ID]] forKey:App_User_ID];
                    }
                    if(userDetails[ThreadID] != nil) {
                        [chatData setObject:[NSString stringWithFormat:@"%@", userDetails[ThreadID]] forKey:ThreadID];
                    }
                }
            }else if ([type isEqual:@"group"]){
                NSDictionary *groupDetails = groupMap[tID];
                if(groupDetails[Group_GroupId] != nil) {
                    [chatData setObject:[NSString stringWithFormat:@"%@", groupDetails[Group_GroupId]] forKey:Group_GroupId];
                }
                if(groupDetails[Group_Type] != nil) {
                    [chatData setObject:[NSString stringWithFormat:@"%@", groupDetails[Group_Type]] forKey:Group_Type];
                }
                if(groupDetails[User_ProfileStatus] != nil) {
                    [chatData setObject:[NSString stringWithFormat:@"%@", groupDetails[User_ProfileStatus]] forKey:User_ProfileStatus];
                }
                if(groupDetails[User_ProfilePic] != nil) {
                    [chatData setObject:[NSString stringWithFormat:@"%@", groupDetails[User_ProfilePic]] forKey:User_ProfilePic];
                    
                }
                if(groupDetails[User_Name] != nil) {
                    [chatData setObject:[NSString stringWithFormat:@"%@", groupDetails[User_Name]] forKey:User_Name];
                }
            }
            [chats addObject:chatData.copy];
        }
    }
    
    return chats;
}

- (NSMutableArray *)prepareData:(NSArray *)ary {
    
    NSMutableArray * chats = [NSMutableArray new];
    for (NSDictionary *chat in ary) {
        NSString *tID = chat[@"threadId"];
        NSString *type = chat[@"threadType"];
        
        NSMutableDictionary *chatData = chat.mutableCopy;
        NSDictionary *threadDetails = NULL;
        if (tID && threadMap[tID] != NULL){
            threadDetails = threadMap[tID];
        }
        
        NSString *recipientAppUserId = NULL;
        if (threadDetails[@"participants"] != NULL && [threadDetails[@"participants"] isKindOfClass:NSArray.class]){
            
            NSArray *participants = threadDetails[@"participants"];
            NSDictionary *userDetails = [[UserModel sharedInstance] getUserDetails];
            NSString *ertcUID = userDetails[User_eRTCUserId];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"appUserId != %@",ertcUID];
            NSArray *filteredArr = [participants filteredArrayUsingPredicate:predicate];
            NSDictionary *recipient = filteredArr.firstObject;
            if (recipient){
                recipientAppUserId = recipient[@"appUserId"];
            }
        }
        
        if (recipientAppUserId == NULL) continue;
        if (threadDetails && recipientAppUserId != NULL){
            type = threadDetails[@"threadType"];
            [chatData setObject:[NSString stringWithFormat:@"%@", type] forKey:@"threadType"];
            if ([type isEqual:@"single"]){
                if (recipientAppUserId != NULL && usersMap[recipientAppUserId] != NULL){
                    NSDictionary *userDetails = usersMap[recipientAppUserId];
                    if(userDetails[User_Name] != nil) {
                        [chatData setObject:[NSString stringWithFormat:@"%@", userDetails[User_Name]] forKey:User_Name];
                    }
                    if(userDetails[TenantID] != nil) {
                        [chatData setObject:[NSString stringWithFormat:@"%@", userDetails[TenantID]] forKey:TenantID];
                    }
                    if(userDetails[User_ID] != nil) {
                        [chatData setObject:[NSString stringWithFormat:@"%@", userDetails[User_ID]] forKey:User_ID];
                    }
                    if(userDetails[User_ProfileStatus] != nil) {
                        [chatData setObject:[NSString stringWithFormat:@"%@", userDetails[User_ProfileStatus]] forKey:User_ProfileStatus];
                    }
                    if(userDetails[User_ProfilePic] != nil) {
                        [chatData setObject:[NSString stringWithFormat:@"%@", userDetails[User_ProfilePic]] forKey:User_ProfilePic];
                        
                    }
                    if(userDetails[User_ProfilePic_Thumb] != nil) {
                        [chatData setObject:[NSString stringWithFormat:@"%@", userDetails[User_ProfilePic_Thumb]] forKey:User_ProfilePic_Thumb];
                        
                    }
                    if(userDetails[App_User_ID] != nil) {
                        [chatData setObject:[NSString stringWithFormat:@"%@", userDetails[App_User_ID]] forKey:App_User_ID];
                    }
                    if(userDetails[ThreadID] != nil) {
                        [chatData setObject:[NSString stringWithFormat:@"%@", userDetails[ThreadID]] forKey:ThreadID];
                    }
                }
            }else if ([type isEqual:@"group"]){
                
                NSDictionary *groupDetails = groupMap[tID];
                NSLog(@"groupMap>>>>>>>>>>%@",groupMap);
                NSLog(@"ary>>>>>>>>>>%@",ary);
                
                if(groupDetails[Group_GroupId] != nil) {
                    [chatData setObject:[NSString stringWithFormat:@"%@", groupDetails[Group_GroupId]] forKey:Group_GroupId];
                }
                if(groupDetails[Group_Type] != nil) {
                    [chatData setObject:[NSString stringWithFormat:@"%@", groupDetails[Group_Type]] forKey:Group_Type];
                }
                if(groupDetails[User_ProfileStatus] != nil) {
                    [chatData setObject:[NSString stringWithFormat:@"%@", groupDetails[User_ProfileStatus]] forKey:User_ProfileStatus];
                }
                if(groupDetails[User_ProfilePic] != nil) {
                    [chatData setObject:[NSString stringWithFormat:@"%@", groupDetails[User_ProfilePic]] forKey:User_ProfilePic];
                    
                }
                if(groupDetails[User_Name] != nil) {
                    [chatData setObject:[NSString stringWithFormat:@"%@", groupDetails[User_Name]] forKey:User_Name];
                }
            }
            [chats addObject:chatData.copy];
        }
    }
    
    return chats;
}

- (void)addMoreDataWith:(NSArray *) ary {
    NSMutableArray * chats = [self prepareData:ary];
    NSString *strAppUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"s != %@",strAppUserId];
    NSArray *filteredArr = [NSArray arrayWithArray:chats];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:FALSE];
    filteredArr=[filteredArr sortedArrayUsingDescriptors:@[sort]];
    [self->arrTableData addObjectsFromArray:filteredArr];
    self->arrChatUsers = self->arrTableData.copy;
    self->vcSearch.searchResults = [NSMutableArray arrayWithArray:self->arrTableData.copy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->vcSearch.tableView reloadData];
        [self->tblRecentChat reloadData];
        [self->vcSearch.tableView
         scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self->arrTableData.count-1  inSection:0]
         atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    });
    [self setupNotResultFoundView];
}

- (void)refreshTableDataWith:(NSArray *) ary {
    NSString *strAppUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"s != %@",strAppUserId];
    NSArray *filteredArr = [NSArray arrayWithArray:ary];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:FALSE];
    filteredArr=[filteredArr sortedArrayUsingDescriptors:@[sort]];
    
    NSMutableArray *arrFilteredData = [NSMutableArray new];
    for (NSDictionary *dict in filteredArr) {
        NSString *name = dict[@"name"];
        if ( ( ![name isEqual:[NSNull null]] ) && ( [name length] != 0 ) ) {
            [arrFilteredData addObject:dict];
        }
    }
    
    
    self->arrTableData = [[NSArray arrayWithArray:arrFilteredData] mutableCopy];
    self->arrChatUsers = [NSArray arrayWithArray:arrFilteredData];
    self->vcSearch.searchResults = [NSMutableArray arrayWithArray:arrFilteredData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->vcSearch.tableView reloadData];
        [self->tblRecentChat reloadData];
    });
    [self setupNotResultFoundView];
}

#pragma mark - UITableView Delegates and DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (arrTableData.count > 0) {
        return arrTableData.count;
    }else{
        if (arrRecentSearch.count > 0) {
        return arrRecentSearch.count;
        }else{
            [self setupNotResultFoundView];
        }
        [self setupNotResultFoundView];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (arrTableData.count > 0) {
        RecentChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RecentChatCellIdentifier];
        cell.imgPrivateChannel.hidden = true;
        if (cell == nil) {
            NSArray *arrNib = [[NSBundle mainBundle] loadNibNamed:RecentChatCellIdentifier owner:self options:nil];
            cell = [arrNib objectAtIndex:0];
        }
        
        if (arrTableData.count > indexPath.row) {
            NSDictionary * dict = [arrTableData objectAtIndex:indexPath.row];
           // cell.lblMessage.text = dict[Message];
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
            } else {
                cell.unReadMessage.hidden = YES;
            }
            
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
    }else{
        RecentSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:RecentSearchWithCell];
        if (arrRecentSearch.count > indexPath.row) {
        NSDictionary * dict = [arrRecentSearch objectAtIndex:indexPath.row];
        if (dict[MsgTitle] != nil && dict[MsgTitle] != [NSNull null]) {
            cell.lblMessages.text = dict[MsgTitle];
        }
            if (dict[@"createdAt"] != nil && dict[@"createdAt"] != [NSNull null]) {
                double timeStamp = [[dict valueForKey:@"createdAt"] doubleValue];
                NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
                JSQMessage*  newMessage = [[JSQMessage alloc] initWithSenderId:@"" senderDisplayName:@"" date:msgdate text:@""];
                cell.lblCurrentDate.attributedText =  [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:newMessage.date];
                [cell.lblCurrentDate setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:13.0]];
                [cell.lblCurrentDate setHidden:NO];
            }else{
                cell.lblCurrentDate.text = @"";
                [cell.lblCurrentDate setHidden:YES];
            }
            
            if (indexPath.row == 4) {
                cell.constantBtnSearchHistory.constant = 35;
            }else{
                cell.constantBtnSearchHistory.constant = 0;
            }
            
        }
        cell.delegate = self;
        return cell;
    
    }
    return [UITableViewCell new];
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
    if (arrTableData.count > 0) {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (arrTableData.count > indexPath.row) {
        NSDictionary * dict = [arrTableData objectAtIndex:indexPath.row];
        if (![Helper stringIsNilOrEmpty:dict[@"threadType"]]) {
            if ([dict[@"threadType"] isEqualToString:@"single"]){
                SingleChatViewController * _vcMessage = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"SingleChatViewController"];
                _vcMessage.dictUserDetails = dict;
                _vcMessage.searchMessage = dict;
                _vcMessage.isUserSearchText = true;
                [self.navigationController pushViewController:_vcMessage animated:YES];
            }
            else{
                UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle bundleForClass:InfoGroupViewController.class]];
                GroupChatViewController *vcInfo = [story instantiateViewControllerWithIdentifier:NSStringFromClass(GroupChatViewController.class)];
                vcInfo.dictGroupinfo = dict;
                vcInfo.searchMessage = dict;
                vcInfo.isUserSearchText = true;
                [self.navigationController pushViewController:vcInfo animated:YES];
            }
        }
    }
    }else{
        NSDictionary *dictData = [arrRecentSearch objectAtIndex:indexPath.row];
        if (dictData[Message] != nil && dictData[Message] != [NSNull null]) {
            searchController.searchBar.text = dictData[MsgTitle];
            [self searchText:dictData[MsgTitle] completion:^{
            }];
            
        }
    }
}

-(void)selectedIndex:(RecentSearchCell *)cell
{
    NSIndexPath *indexPath = [tblRecentChat indexPathForCell:cell];
    NSDictionary *dictData = [arrRecentSearch objectAtIndex:indexPath.row];
    
    if (dictData[MsgUniqueId] != nil && dictData[MsgUniqueId] != [NSNull null]) {
    [[eRTCChatManager sharedChatInstance] deleterecentChatRecord:dictData[MsgUniqueId]];
    }
    NSString *appUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
    [[eRTCChatManager sharedChatInstance] getRecentChatData:appUserId withData:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        self->arrRecentSearch = [NSMutableArray new];
        NSMutableArray *arr;
        arr = [NSMutableArray arrayWithArray:[self reverseArray:json]];
        self->arrRecentSearch = [arr subarrayWithRange:NSMakeRange(0, MIN(5, arr.count))];
        [self->tblRecentChat reloadData];
    } andFailure:^(NSError * _Nonnull error) {
        
    }];
}

-(void)selectedClearRecentChat:(RecentSearchCell *)cell {
       [self clearSearchHistory];
}

-(void)clearSearchHistory {
    NSString *appUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
    [[eRTCChatManager sharedChatInstance] getRecentChatData:appUserId withData:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        self->arrRecentSearch = [NSMutableArray new];
        self->arrRecentSearch = json;
        for (NSDictionary *dictRecentmessage in self->arrRecentSearch) {
            if (dictRecentmessage[MsgUniqueId] != nil && dictRecentmessage[MsgUniqueId] != [NSNull null]) {
            [[eRTCChatManager sharedChatInstance] deleterecentChatRecord:dictRecentmessage[MsgUniqueId]];
            }
        }
    } andFailure:^(NSError * _Nonnull error) {
    }];
    self->arrRecentSearch = [NSMutableArray new];
    [tblRecentChat reloadData];
}

@end
