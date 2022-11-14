//
//  ContactsViewController.m
//  eRTCApp
//
//  Created by rakesh  palotra on 01/01/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import "ContactsViewController.h"
#import "UserContactsCell.h"
#import "SearchViewController.h"
#import "SingleChatViewController.h"
#import "GroupListViewController.h"

@interface ContactsViewController () <ContactsSearchDelegate> {
    NSArray * arrUsers;
    NSArray * arrTableData;
    SearchViewController * vcSearch;
    UIRefreshControl *refreshControl;
    NSArray *_arySectionIndexTitle;
    NSMutableDictionary *_dictParticipants;
    NSArray *_arySearchedParticipants;
    NSArray *_aryParticipants;
    UISearchController *searchController;
    BOOL isContactList;
}

@end

@implementation ContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                selector:@selector(syncContactDB:)
                                                    name:ContactDBUpdatedNotification
                                                  object:nil];
    
    self.tblContacts.estimatedRowHeight = 56;
    self.tblContacts.rowHeight = UITableViewAutomaticDimension;
    
     [self.tblContacts registerNib:[UINib nibWithNibName:UserContactsCellIdentifier bundle:[NSBundle mainBundle]] forCellReuseIdentifier:UserContactsCellIdentifier];
    
    [self configureNavigationBar];
    [self performSelector:@selector(callAPIForGetChatUserList) withObject:nil afterDelay:0.5];
//    [self callAPIForGetChatUserList];
//    refreshControl = [[UIRefreshControl alloc]init];
//    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    if (@available(iOS 10.0, *)) {
        self.tblContacts.refreshControl = refreshControl;
    } else {
        [self.tblContacts addSubview:refreshControl];
    }
    [self setupTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeIndicatorStatus:)
                                                 name:DidReceveEventStarFavouriteMessage
                                               object:nil];
}

-(void)didChangeIndicatorStatus:(NSNotification *) notification{
    NSString *userInfo = notification.object;
    
    NSLog(@"Get USer List ");
    [self callAPIForGetContactsUserList];
    [self performSelector:@selector(callAPIForGetChatUserList) withObject:nil afterDelay:0.5];
   
    
    /*
     {
         appUserId = "dev12@mailinator.com";
         availabilityStatus = dnd;
         blockedStatus = unblocked;
         name = dev121;
         profileStatus = "I am using eRTC";
         userId = 618e4598286629000a3f6a2f;
     }
     )
     */
}



- (void)setupTableView {
    _aryParticipants = [NSArray new];
    _arySectionIndexTitle = @[@"1", @"2", @"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",@"#", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    [_tblContacts registerNib:[UINib nibWithNibName:@"ParticipantTableViewCell" bundle:nil] forCellReuseIdentifier:@"ParticipantTableViewCell"];
    [_tblContacts reloadData];
}

-(NSArray *)tableRowsWithSection:(NSInteger )section andParticipants:(NSDictionary *)dictParticipants {
    if (_arySectionIndexTitle.count>section) {
        if (_dictParticipants[_arySectionIndexTitle[section]]!= nil) {
            return (NSArray *)_dictParticipants[_arySectionIndexTitle[section]];
        }
    }
    return [NSArray new];
}

-(void) reloadTableWithParticipants:(NSArray *)participants {
    
    NSString *strAppUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"appUserId != %@",strAppUserId];
    NSArray *filteredArr = [participants filteredArrayUsingPredicate:predicate];
    
    UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _tblContacts.bounds.size.width, _tblContacts.bounds.size.height)];
    noDataLabel.textColor        = [UIColor blueColor];
    noDataLabel.textAlignment    = NSTextAlignmentCenter;
    

    _arySearchedParticipants = filteredArr;
    _dictParticipants = [NSMutableDictionary new];
    for (NSString *strSection in _arySectionIndexTitle) {
        NSMutableArray *sections = [NSMutableArray new];
        if (_dictParticipants[strSection] != nil) {
            sections = (NSMutableArray *)_dictParticipants[strSection];
        }
        
        for (NSDictionary *participant in filteredArr) {
            if(participant[Key_Name] != nil) {
                NSString *name = participant[Key_Name];
                if (name.length>0) {
                    NSString *firstCharecter = [[name substringToIndex:1] uppercaseString];
                    if ([[strSection uppercaseString] isEqualToString:firstCharecter]) {
                        [sections addObject:participant];
                    }
                }
            }
        }
        
        if ([sections count]>0) {
            isContactList = true;
            _dictParticipants[strSection] = sections;
        }
        
        if (isContactList) {
            noDataLabel.text             = @"";
            self.tblContacts.backgroundView = noDataLabel;
        }else{
            noDataLabel.text             = @"Contacts not found";
            self.tblContacts.backgroundView = noDataLabel;
            self.tblContacts.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
    }
    [_tblContacts reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
    } else {
        // Fallback on earlier versions
    }
    self.title = @"Contacts";
    if (searchController != NULL && searchController.isActive){
        searchController.searchBar.text = @"";
        [searchController setActive:FALSE];
    }
    [self performSelector:@selector(callAPIForGetChatUserList) withObject:nil afterDelay:0.5];
    [self callAPIForGetContactsUserList];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
    } else {
        // Fallback on earlier versions
    }
    self.title = nil;
    if (self.navigationController.tabBarController != NULL && self.navigationController.tabBarController.viewControllers.count > 2){
        self.navigationController.tabBarController.tabBar.items[2].title = @"Threads";
        self.navigationController.tabBarController.tabBar.items[1].title = @"Contacts";
    }
}

- (void)refreshTable{
    //TODO: refresh your data
    [refreshControl endRefreshing];
    [self callAPIForGetChatUserList];
    //[self.tblContacts reloadData];
}

- (void)configureNavigationBar {
    vcSearch = vcSearch = [[SearchViewController alloc] init];
    vcSearch.searchType = 2;
    vcSearch.gsDelegate = self;
    searchController = [[UISearchController alloc] initWithSearchResultsController:vcSearch];
    searchController.searchResultsUpdater = self;
    searchController.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController = searchController;
        self.navigationItem.hidesSearchBarWhenScrolling = YES;
    } else {
        // Fallback on earlier versions
        self.tblContacts.tableHeaderView = searchController.searchBar;
    }
    searchController.searchBar.layer.borderColor = [UIColor clearColor].CGColor;
    //searchController.searchBar.searchTextField.backgroundColor = [UIColor colorWithRed:.93 green:.96 blue:1.0 alpha:1.0];
    searchController.searchBar.layer.borderWidth = 1;
  
    searchController.delegate = self;
    searchController.dimsBackgroundDuringPresentation = NO;
    searchController.searchBar.delegate = self;
    self.definesPresentationContext = YES;
}

#pragma mark - @API Call
- (void)callAPIForGetChatUserList {
    /*
     these are the 3 parameter for get chat user list.
     1. lastId  (To be used for Pagination)
     2. lastCallTime (epoch time value for time based sunc. Do not pass this param itself for retrieving all data.)
     3. updateType  (type of sync i.e. addUpdated or deleted. Default value is addUpdated)
     */
    
    [[eRTCCoreDataManager sharedInstance] fetchChatUserListWithCompletionHandler:^(id ary, NSError *err) {         [self refreshTableDataWith:ary];
        [self reloadTableWithParticipants:ary];
    }];

    /*
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [[eRTCAppUsers sharedInstance] getUserListWithLastUserID:@"" andLastCallTime:@"" andUpdateType:@"" andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            if (![Helper stringIsNilOrEmpty:json[Key_Success]] && [json[Key_Success] integerValue] == 1) {
                if (![Helper stringIsNilOrEmpty:json[Key_Result]]) {
                    NSArray * ary = json[Key_Result][Key_ChatUsers];
                    if (ary.count > 0) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self refreshTableDataWith:ary];
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
    */
}
- (void)callAPIForGetContactsUserList {
   
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [[eRTCAppUsers sharedInstance] getUserListWithLastUserID:@"" andLastCallTime:@"" andUpdateType:@"" andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            if (![Helper stringIsNilOrEmpty:json[Key_Success]] && [json[Key_Success] integerValue] == 1) {
                if (![Helper stringIsNilOrEmpty:json[Key_Result]]) {
                    NSArray * ary = json[Key_Result][Key_ChatUsers];
                    
                    [self refreshTableDataWith:ary];
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

- (void)refreshTableDataWith:(NSArray *) ary {
    
    NSString *strAppUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"appUserId != %@",strAppUserId];
    NSArray *filteredArr = [ary filteredArrayUsingPredicate:predicate];
    
    if (filteredArr.count >0) {
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSArray *sortedArray=[filteredArr sortedArrayUsingDescriptors:@[sort]];
    if (sortedArray.count > 0) {
        self->arrUsers = [NSArray arrayWithArray:sortedArray];
        self->arrTableData = [NSArray arrayWithArray:sortedArray];
        self->vcSearch.searchResults = [NSMutableArray arrayWithArray:sortedArray];
       // dispatch_async(dispatch_get_main_queue(), ^{
            [self.tblContacts reloadData];
      //  });
    }
    }
}

#pragma mark - UITableView Delegates and DataSource
#pragma mark Table Delegate and DataSource
//- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    return _arySectionIndexTitle;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return _arySectionIndexTitle.count;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (_dictParticipants[_arySectionIndexTitle[section]]!= nil) {
        NSArray *ary = _dictParticipants[_arySectionIndexTitle[section]];
        
        if (ary.count>0) {
            return (NSString *)_arySectionIndexTitle[section];
        }
    }
    return @"";
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSArray *ary = [self tableRowsWithSection:section andParticipants:_dictParticipants];
    if (ary.count>0) {
        return 40;
    }
    return 0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *ary = [self tableRowsWithSection:section andParticipants:_dictParticipants];
    
    if (ary.count>0) {
        UIView *view = [UIView new];
        [view setFrame:CGRectMake(0, 0, tableView.bounds.size.width, 28)];
        [view setBackgroundColor:[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0]];
        UILabel *lbl = [UILabel new];
        [lbl setBackgroundColor:[UIColor clearColor]];
        [lbl setTextColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
        [lbl setFont:[UIFont fontWithName:@"SFProDisplay-Medium" size:17]];
        [lbl setText:(NSString *)_arySectionIndexTitle[section]];
        [lbl setFrame:CGRectMake(16, 0, view.bounds.size.width-32, 28)];
        [view addSubview:lbl];
        return view;
    }
    return [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *ary = [self tableRowsWithSection:section andParticipants:_dictParticipants];
    
    if (ary.count > 0) {
        return ary.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:UserContactsCellIdentifier forIndexPath:indexPath];
    cell.imgUser.layer.cornerRadius= cell.imgUser.frame.size.height/2;
    cell.imgUser.layer.masksToBounds = YES;
    NSArray *ary = [self tableRowsWithSection:indexPath.section andParticipants:_dictParticipants];
    
    if (ary.count > indexPath.row) {
        NSDictionary * dict = [ary objectAtIndex:indexPath.row];
        if (dict[BlockedStatus] != nil && dict[BlockedStatus] != [NSNull null]) {
            if ([dict[BlockedStatus] isEqualToString:Block_Status]) {
                cell.imageBlock.hidden = true;
            }else if ([dict[BlockedStatus] isEqualToString:Blocked]) {
                cell.imageBlock.hidden = false;
            }
            else
            {
                cell.imageBlock.hidden = true;
            }
        }
        if (dict[User_Name] != nil && dict[User_Name] != [NSNull null]) {
            cell.lblUserName.text = dict[User_Name];
        }
        
        if (dict[@"availabilityStatus"] != nil && dict[@"availabilityStatus"] != [NSNull null]) {
            if ([dict[AvailabilityStatus] isEqualToString:@"online"]) {
                cell.imgUserAwailability.image =  [UIImage imageNamed:@"greenIndicator"];
            }else if ([dict[AvailabilityStatus] isEqualToString:@"away"]) {
                cell.imgUserAwailability.image =  [UIImage imageNamed:@"yelloIndicator"];
            }else if ([dict[AvailabilityStatus] isEqualToString:@"invisible"]) {
                cell.imgUserAwailability.image =  [UIImage imageNamed:@"invisible"];
            }else if ([dict[AvailabilityStatus] isEqualToString:@"offline"] || [dict[AvailabilityStatus] isEqualToString:@"dnd"]) {
                cell.imgUserAwailability.image =  [UIImage imageNamed:@"redIndicator"];
            }
        }//blockedStatus
        
        if (dict[App_User_ID] != nil && dict[App_User_ID] != [NSNull null]) {
            cell.lblUserEmailId.text = dict[App_User_ID];
        }
        
        if (dict[User_ProfilePic_Thumb] != nil && dict[User_ProfilePic_Thumb] != [NSNull null]) {
            NSString *imageURL = [NSString stringWithFormat:@"%@",dict[User_ProfilePic_Thumb]];
            [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:imageURL]
            placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
        }else{
             cell.imgUser.image =  [UIImage imageNamed:@"DefaultUserIcon"];
        }
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *ary = [self tableRowsWithSection:indexPath.section andParticipants:_dictParticipants];
    
    if (ary.count>indexPath.row) {
        NSMutableDictionary * dict = [[ary objectAtIndex:indexPath.row] mutableCopy];
       
        if (dict[App_User_ID] != NULL){
            for (NSDictionary *user in self->arrUsers) {
                if (user[App_User_ID] != NULL && [user[App_User_ID] isEqual:dict[App_User_ID]] && (([dict[BlockedStatus] isEqualToString:Block_Status]) || ([dict[BlockedStatus] isEqualToString:Blocked]))){
                    dict[BlockedStatus] = user[BlockedStatus];
                    break;
                }
            }
        }
        
        SingleChatViewController * _vcMessage = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"SingleChatViewController"];
        _vcMessage.dictUserDetails = dict.copy;
        [self.navigationController pushViewController:_vcMessage animated:YES];
    }

    
    
}

- (void)didSelectedItem:(NSDictionary *)item {
    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController.searchBar.text = @"";
    }
    SingleChatViewController * _vcMessage = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"SingleChatViewController"];
    _vcMessage.dictUserDetails = item;
    [self.navigationController pushViewController:_vcMessage animated:YES];

}

#pragma mark - Actions

-(void)navRightButtonClicked {
    GroupListViewController * _vcGroup = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"GroupListViewController"];
    [self.navigationController pushViewController:_vcGroup animated:YES];
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
    if (arrUsers.count > 0 && [searchString length] > 0) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@",searchString];
        NSArray * _arrFiltered = [arrUsers filteredArrayUsingPredicate:predicate];
        vcSearch.searchResults = [NSMutableArray arrayWithArray:_arrFiltered];
    } else {
        vcSearch.searchResults = [NSMutableArray arrayWithArray:arrUsers];
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

- (void)syncContactDB:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    //    if ([notification userInfo])
    [self callAPIForGetContactsUserList];
}

@end
