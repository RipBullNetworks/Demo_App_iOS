//
//  CreateNewAdminViewController.m
//  eRTCApp
//
//  Created by apple on 13/05/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "CreateNewAdminViewController.h"
#import "SearchViewController.h"
#import "GroupParticipantsCollectionViewCell.h"
#import "ParticipantTableViewCell.h"
#import "GroupSearchViewController.h"
#import "CreateGroupViewController.h"
#import <Toast/Toast.h>

@interface CreateNewAdminViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate, UISearchControllerDelegate, UISearchResultsUpdating, GroupSearchDelegate> {
    __weak IBOutlet UITableView               *_tblParticipants;
    __weak IBOutlet UICollectionView          *_cvParticipants;
    __weak IBOutlet UIButton                  *_bntNext;
    __weak IBOutlet UIButton                  *_bntCancel;
    __weak IBOutlet NSLayoutConstraint        *_lcCollectionHeight;
                    GroupSearchViewController *_vcSearchContact;
                    NSArray                   *_arySectionIndexTitle;
                    NSArray                   *_aryParticipants;
                    NSArray                   *_arySearchedParticipants;
                    NSMutableDictionary       *_dictParticipants;
    NSString                                  *_strAppLoggedInUserID;
    NSDictionary *alreadyAddedMap;
}

@end

@implementation CreateNewAdminViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:false];
    NSMutableDictionary *map = @{}.mutableCopy;
    
//    [_arySelectedParticipants enumerateObjectsUsingBlock:^(NSDictionary  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSMutableDictionary *copy = obj.mutableCopy;
//        copy[@"isAddedAlready"] = @true;
//        map[obj[App_User_ID]] = copy.copy;
//    }];
    //alreadyAddedMap = map.copy;
    [self setupNavigationBar];
    [self setupCollectionView];
    [self setupTableView];
    [self setupCollectionHeight];
    self.title = @"Select Admin";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [_cvParticipants reloadData];
    [self callReloadingParticipants];
}

#pragma mark - setup View
- (void)setupCollectionHeight {
    __block NSArray *arySP = self.arySelectedParticipants;
    __block NSLayoutConstraint *lcCH = _lcCollectionHeight;
   // [_lblNavSubTitle setText:[NSString stringWithFormat:@"%lu/%lu", (unsigned long)self.arySelectedParticipants.count,(unsigned long)_aryParticipants.count]];
    [UIView animateWithDuration:0.1 animations:^{
        if (arySP.count>0) {
            if (lcCH.constant == 0) {
                lcCH.constant = 113;
            }
        }else {
            lcCH.constant = 0;
        }
    }];
    
}

- (void)setupCollectionView {
    _lcCollectionHeight.constant = 0;
    if (![self arySelectedParticipants]) { [self setArySelectedParticipants:[NSMutableArray new]];}
    [_cvParticipants updateConstraints];
    [_cvParticipants registerNib:[UINib nibWithNibName:@"GroupParticipantsCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"GroupParticipantsCollectionViewCell"];
    [_cvParticipants reloadData];
}

- (void)setupTableView {
    _arySectionIndexTitle = @[@"1", @"2", @"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",@"#", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    [_tblParticipants registerNib:[UINib nibWithNibName:@"ParticipantTableViewCell" bundle:nil] forCellReuseIdentifier:@"ParticipantTableViewCell"];
    [_tblParticipants reloadData];
}

- (void)setupNavigationBar {
    [_bntNext.titleLabel setFont:[UIFont fontWithName:@"SFProDisplay-Medium" size:16]];
    [_bntCancel.titleLabel setFont:[UIFont fontWithName:@"SFProDisplay-Medium" size:16]];
    [_bntNext setTitle:NSLocalizedString(@"Confirm", nil) forState:UIControlStateNormal];
    [_bntCancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [_bntNext setEnabled:NO];
    [self setupNavigationSearchBar];
}

-(void) setupNavigationSearchBar {
    _vcSearchContact = [[GroupSearchViewController alloc] init];
    _vcSearchContact.gsDelegate = self;
    UISearchController *sc = [[UISearchController alloc] initWithSearchResultsController:_vcSearchContact];
    sc.searchResultsUpdater = self;
    sc.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController = sc;
        self.navigationItem.hidesSearchBarWhenScrolling = NO;
    }
    sc.delegate = self;
    sc.dimsBackgroundDuringPresentation = NO;
    sc.searchBar.delegate = self;
    self.definesPresentationContext = YES;
}


#pragma mark Private
- (void)searchForText:(NSString*)searchString {
    if (_arrParticipants.count > 0 && [searchString length] > 0) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@",searchString];
        
        NSArray * _arrFiltered = [_arrParticipants filteredArrayUsingPredicate:predicate];
        _vcSearchContact.arySearchResults = [NSMutableArray arrayWithArray:_arrFiltered];
    } else {
        _vcSearchContact.arySearchResults = [NSMutableArray arrayWithArray:_arrParticipants];
    }
    __block GroupSearchViewController *vcgs = _vcSearchContact;
    dispatch_async(dispatch_get_main_queue(), ^{
        [vcgs.tableView reloadData];
    });
}

-(NSArray *)tableRowsWithSection:(NSInteger )section andParticipants:(NSDictionary *)dictParticipants {
    if (_arySectionIndexTitle.count>section) {
        if (_dictParticipants[_arySectionIndexTitle[section]]!= nil) {
            return (NSArray *)_dictParticipants[_arySectionIndexTitle[section]];
        }
    }
    return [NSArray new];
}

-(void) reloadData {
    [self->_bntNext setEnabled:(self.arySelectedParticipants.count>0)];
    [_cvParticipants reloadData];
    [_tblParticipants reloadData];
}

-(void) reloadTableWithParticipants:(NSMutableArray *)participants {
    
    _arySearchedParticipants = participants;
    _dictParticipants = [NSMutableDictionary new];
    
    for (NSString *strSection in _arySectionIndexTitle) {
        NSMutableArray *sections = [NSMutableArray new];
        if (_dictParticipants[strSection] != nil) {
            sections = (NSMutableArray *)_dictParticipants[strSection];
        }
        
        for (NSDictionary *participant in participants) {
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
            _dictParticipants[strSection] = sections;
        }
    }
    [_tblParticipants reloadData];
}

-(void)addRemoveSelectedItem:(NSDictionary *)item {
    if ([item count]>0) {
        NSString *_id = item[App_User_ID];
        if (alreadyAddedMap[_id] != NULL && [alreadyAddedMap[_id][@"isAddedAlready"]  isEqual: @true]) {
            [self.view makeToast:@"Already added in the group!"];
                return;
        }else {
            if ([[self.arySelectedParticipants valueForKey:App_User_ID] containsObject:item[App_User_ID]]){
                [self.arySelectedParticipants removeObject:item];
            }else {
                [self.arySelectedParticipants addObject:item];
            }
        }
        [self reloadData];
        [self setupCollectionHeight];
    }
}

#pragma mark IBAction
-(IBAction)btnCrossTapped:(id)sender{
    UIButton *btn = (UIButton *) sender;
    NSInteger indexPathRow = [btn tag];
    if (self.arySelectedParticipants.count>indexPathRow) {
        [self addRemoveSelectedItem:[self.arySelectedParticipants objectAtIndex:indexPathRow]];
    }
    
}

-(IBAction)btnNextTapped:(id)sender{
    NSUInteger index;
    for(id someObject in _arySelectedParticipants)
    {
        index = [_arySelectedParticipants indexOfObject:someObject];
            [self callSelectAdminApi:index];
    }
    
    
}

-(IBAction)btnCancelTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

-(void)callReloadingParticipants {
    [self reloadTableWithParticipants:_arrParticipants];
}

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
        return 28;
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
    if (ary.count>0) {
            return ary.count;
        }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ParticipantTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ParticipantTableViewCell"];
    [cell.btnSelected setSelected:NO];
    NSArray *ary = [self tableRowsWithSection:indexPath.section andParticipants:_dictParticipants];
    if (ary.count>indexPath.row) {
        NSDictionary * dict = [ary objectAtIndex:indexPath.row];
        if (dict[User_Name] != nil && dict[Key_Name] != [NSNull null]) {
            cell.lblName.text = dict[Key_Name];
        }
        if (dict[User_ProfilePic_Thumb] != nil && dict[User_ProfilePic_Thumb] != [NSNull null]) {
           NSString *imageURL = [NSString stringWithFormat:@"%@",dict[User_ProfilePic_Thumb]];
            [cell.imgProfile sd_setImageWithURL:[NSURL URLWithString:imageURL]
            placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
            cell.imgProfile.layer.cornerRadius= cell.imgProfile.frame.size.height/2;
            cell.imgProfile.layer.masksToBounds = YES;
            
        }else{
            cell.imgProfile.image =  [UIImage imageNamed:@"DefaultUserIcon"];
        }
       
        if ([[self.arySelectedParticipants valueForKey:App_User_ID] containsObject:dict[App_User_ID]]){
            [cell.btnSelected setSelected:YES];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *ary = [self tableRowsWithSection:indexPath.section andParticipants:_dictParticipants];
    if (ary.count>indexPath.row) {
        NSDictionary * dict = [ary objectAtIndex:indexPath.row];
        [self addRemoveSelectedItem:dict];
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark GroupSearchDelegate
-(void)didSelectedItem:(NSDictionary *)item {
    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController.searchBar.text = @"";
    }
    [self addRemoveSelectedItem:item];
}

#pragma mark Collection Delegate and DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.arySelectedParticipants.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GroupParticipantsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GroupParticipantsCollectionViewCell" forIndexPath:indexPath];
    [cell.btnCross addTarget:self action:@selector(btnCrossTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnCross setTag:indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.imgProfile.backgroundColor = [UIColor clearColor];
    if (self.arySelectedParticipants.count>indexPath.row) {
        NSDictionary * dict = [self.arySelectedParticipants objectAtIndex:indexPath.row];
        if (dict[User_Name] != nil && dict[Key_Name] != [NSNull null]) {
            cell.lblName.text = dict[Key_Name];
        }
        if (dict[User_ProfilePic_Thumb] != nil && dict[User_ProfilePic_Thumb] != [NSNull null]) {
        NSString *imageURL = [NSString stringWithFormat:@"%@",dict[User_ProfilePic_Thumb]];
        [cell.imgProfile sd_setImageWithURL:[NSURL URLWithString:imageURL]
        placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
            cell.imgProfile.layer.cornerRadius= cell.imgProfile.frame.size.height/2;
            cell.imgProfile.layer.masksToBounds = YES;
            cell.imgProfile.layer.cornerRadius= cell.imgProfile.frame.size.height/2;
            cell.imgProfile.layer.masksToBounds = YES;
        }else{
            cell.imgProfile.image =  [UIImage imageNamed:@"DefaultUserIcon"];
        }
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(103, 103);
}

#pragma mark - SearchBar Delegates

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

/*
-(void)calldismissAdminApi {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        NSMutableDictionary*dict = [[NSMutableDictionary alloc]init];
        [KVNProgress show];
        
        NSString*adminSelected = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
        BOOL isParticipantAdmin = false;
        if (adminSelected != nil {
            [dict setValue:adminSelected forKey:@"targetAppUserId"];
            [dict setValue:(isParticipantAdmin?@"make":@"dismiss") forKey:Action];
            [dict setValue:self.groupId forKey:Group_GroupId];
        }
            [[eRTCChatManager sharedChatInstance]groupmakeDismissAdmin:dict andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                [KVNProgress dismiss];
                
                NSDictionary *dictResponse = (NSDictionary *)json;
                if (dictResponse[@"success"] != nil) {
                    BOOL success = (BOOL)dictResponse[@"success"];
                    if (success) {
                        if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *result = (NSDictionary *)dictResponse[@"result"];
                            if (result.count>0) {
                            [self.navigationController popToRootViewControllerAnimated:NO];
                            }
                            if(dictResponse[@"errorCode"] != NULL && [dictResponse[@"errorCode"] isEqualToString:@"GR0004"] && dictResponse[@"msg"] != nil){
                                [self.view makeToast:dictResponse[@"msg"]];
                            }
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
                [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
            }];
        
    }else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}*/

-(void)callSelectAdminApi:(NSInteger)indexInt {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        NSMutableDictionary*dict = [[NSMutableDictionary alloc]init];
        NSDictionary*dictSelectAdmin = _arySelectedParticipants[indexInt];
        NSString*adminSelected = dictSelectAdmin[App_User_ID];
        [KVNProgress show];
            BOOL isParticipantAdmin = true;
            [dict setValue:adminSelected forKey:@"targetAppUserId"];
            [dict setValue:(isParticipantAdmin?@"make":@"dismiss") forKey:Action];
            [dict setValue:self.groupId forKey:Group_GroupId];
            [[eRTCChatManager sharedChatInstance]groupmakeDismissAdmin:dict andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                [KVNProgress dismiss];
                NSDictionary *dictResponse = (NSDictionary *)json;
                if (dictResponse[@"success"] != nil) {
                    BOOL success = (BOOL)dictResponse[@"success"];
                    if (success) {
                        if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *result = (NSDictionary *)dictResponse[@"result"];
                            if (result.count>0) {
                                if (_arySelectedParticipants.count == indexInt+1) {
                                        [self callAPIForRemoveParticipant:nil andExitGroup:YES];
                                    
                                }
                            }
                            if(dictResponse[@"errorCode"] != NULL && [dictResponse[@"errorCode"] isEqualToString:@"GR0004"] && dictResponse[@"msg"] != nil){
                                [self.view makeToast:dictResponse[@"msg"]];
                            }
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
                [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
            }];
        
    }else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}

/*
-(void)callAPIForRemoveParticipant:(NSDictionary *) participant  andExitGroup:(BOOL) isExitGroup {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
        NSMutableDictionary*dict = [[NSMutableDictionary alloc]init];
        if (participant[User_eRTCUserId] != nil && participant[App_User_ID] != nil) {
//            [dict setValue:participant[User_eRTCUserId] forKey:User_eRTCUserId];
            [dict setValue:@[participant[App_User_ID]] forKey:Group_Participants];
        }
        
        if(self.dictGroupInfo[Group_GroupId] != nil) {
            [dict setValue:self.dictGroupInfo[Group_GroupId] forKey:Group_GroupId];
        }
        
        if(isExitGroup == YES) {
            [dict setValue:@[_strAppLoggedInUserID] forKey:Group_Participants];
         //   [dict setValue:[[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] forKey:User_eRTCUserId];
        }
        [[eRTCChatManager sharedChatInstance] groupRemoveParticipants:dict andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            [KVNProgress dismiss];
            NSDictionary *dictResponse = (NSDictionary *)json;
            if (dictResponse[@"success"] != nil) {
                BOOL success = (BOOL)dictResponse[@"success"];
                if (success) {
                    if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *result = (NSDictionary *)dictResponse[@"result"];
                        if (result.count>0) {
                            self.dictGroupInfo = [[NSMutableDictionary alloc] initWithDictionary:result];
                            [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:YES];
                        }
                        if(isExitGroup == YES) {
                           // [self.navigationController dismissViewControllerAnimated:YES completion:^{ }];
                            [self.navigationController popToRootViewControllerAnimated:NO];
                            [[NSNotificationCenter defaultCenter] postNotificationName:RefreshRecentChatList object:nil userInfo:nil];
                            return;
                        }
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
          //  NSLog(@"InfoGroupViewController ->  callAPIForRemoveParticipant -> groupRemoveParticipants -> %@",errMsg);
            [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
        }];
    }else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}*/


-(void)callAPIForRemoveParticipant:(NSDictionary *) participant  andExitGroup:(BOOL) isExitGroup {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
        NSMutableDictionary*dict = [[NSMutableDictionary alloc]init];
        if (participant[User_eRTCUserId] != nil && participant[App_User_ID] != nil) {
//            [dict setValue:participant[User_eRTCUserId] forKey:User_eRTCUserId];
            [dict setValue:@[participant[App_User_ID]] forKey:Group_Participants];
        }
            [dict setValue:_groupId forKey:Group_GroupId];
        
        _strAppLoggedInUserID = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
        if(isExitGroup == YES) {
            
            [dict setValue:@[_strAppLoggedInUserID] forKey:Group_Participants];
         //   [dict setValue:[[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] forKey:User_eRTCUserId];
        }
        
        
        [[eRTCChatManager sharedChatInstance]groupRemoveParticipants:dict andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            
            
            [KVNProgress dismiss];
            NSDictionary *dictResponse = (NSDictionary *)json;
            if (dictResponse[@"success"] != nil) {
                BOOL success = (BOOL)dictResponse[@"success"];
                if (success) {
                    if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *result = (NSDictionary *)dictResponse[@"result"];
                        if (result.count>0) {
                          
                        }
                        if(isExitGroup == YES) {
                            //[self.navigationController dismissViewControllerAnimated:YES completion:^{ }];
                           // [self.navigationController popToRootViewControllerAnimated:NO];
                          //  [[NSNotificationCenter defaultCenter] postNotificationName:RefreshRecentChatList object:nil userInfo:nil];
                            return;
                        }
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
          //  NSLog(@"InfoGroupViewController ->  callAPIForRemoveParticipant -> groupRemoveParticipants -> %@",errMsg);
            [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
        }];
    }else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}


@end
