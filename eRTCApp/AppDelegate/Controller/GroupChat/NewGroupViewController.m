//
//  NewGroupViewController.m
//  eRTCApp
//
//  Created by Ashish Vani on 27/06/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import "NewGroupViewController.h"
#import "SearchViewController.h"
#import "GroupParticipantsCollectionViewCell.h"
#import "ParticipantTableViewCell.h"
#import "GroupSearchViewController.h"
#import "CreateGroupViewController.h"
#import <Toast/Toast.h>
#import "GroupChatViewController.h"
#import "InfoGroupViewController.h"

@interface NewGroupViewController()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate, UISearchControllerDelegate, UISearchResultsUpdating, GroupSearchDelegate> {
    __weak IBOutlet UITableView               *_tblParticipants;
    __weak IBOutlet UICollectionView          *_cvParticipants;
    __weak IBOutlet UIButton                  *_bntNext;
    __weak IBOutlet UIButton                  *_bntCancel;
    __weak IBOutlet UIView                    *_viewNavTitle;
    __weak IBOutlet UILabel                   *_lblNavTitle;
    __weak IBOutlet UILabel                   *_lblNavSubTitle;
    __weak IBOutlet NSLayoutConstraint        *_lcCollectionHeight;
                    GroupSearchViewController *_vcSearchContact;
                    NSArray                   *_arySectionIndexTitle;
                    NSArray                   *_aryParticipants;
                    NSArray                   *_arySearchedParticipants;
                    NSMutableDictionary       *_dictParticipants;
    NSDictionary *alreadyAddedMap;
}

@end

@implementation NewGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:false];
    NSMutableDictionary *map = @{}.mutableCopy;
    
    [_arySelectedParticipants enumerateObjectsUsingBlock:^(NSDictionary  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *copy = obj.mutableCopy;
        copy[@"isAddedAlready"] = @true;
        map[obj[App_User_ID]] = copy.copy;
    }];
    alreadyAddedMap = map.copy;
    
    [self setupNavigationBar];
    [self setupCollectionView];
    [self setupTableView];
    [self setupCollectionHeight];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [_cvParticipants reloadData];
   // [_cvParticipants ]
    [self callAPIForParticipants];
}

#pragma mark - setup View
- (void)setupCollectionHeight {
    __block NSArray *arySP = self.arySelectedParticipants;
    __block NSLayoutConstraint *lcCH = _lcCollectionHeight;
    [_lblNavSubTitle setText:[NSString stringWithFormat:@"%lu/100", (unsigned long)self.arySelectedParticipants.count]];//,(unsigned long)_aryParticipants.count
    [UIView animateWithDuration:0.1 animations:^{
        if (arySP.count>0) {
            if (lcCH.constant == 0) {
                lcCH.constant = 113;
            }
        }else {
            lcCH.constant = 0;
        }
    }];
    if (self.arySelectedParticipants.count > 3)
    {
    [_cvParticipants scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.arySelectedParticipants.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

- (void)setupCollectionView {
    _lcCollectionHeight.constant = 0;
    if (![self arySelectedParticipants]) { [self setArySelectedParticipants:[NSMutableArray new]];}
    [_cvParticipants updateConstraints];
    [_cvParticipants registerNib:[UINib nibWithNibName:@"GroupParticipantsCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"GroupParticipantsCollectionViewCell"];
    [_cvParticipants reloadData];
}

- (void)setupTableView {
    _aryParticipants = [NSArray new];
    _arySectionIndexTitle = @[@"1", @"2", @"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",@"#", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    [_tblParticipants registerNib:[UINib nibWithNibName:@"ParticipantTableViewCell" bundle:nil] forCellReuseIdentifier:@"ParticipantTableViewCell"];
    [_tblParticipants reloadData];
}

- (void)setupNavigationBar {
    [_bntNext.titleLabel setFont:[UIFont fontWithName:@"SFProDisplay-Medium" size:16]];
    [_bntCancel.titleLabel setFont:[UIFont fontWithName:@"SFProDisplay-Medium" size:16]];
    [_lblNavTitle setFont:[UIFont fontWithName:@"SFProDisplay-Medium" size:18]];
    [_lblNavSubTitle setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:14]];
    
    [self.navigationItem setTitleView:_viewNavTitle];
    [_lblNavSubTitle setHidden:YES];
   // [_lblNavSubTitle setText:@"0/0"];
    [_bntNext setTitle:NSLocalizedString(@"Next", nil) forState:UIControlStateNormal];
    
    if (self.isAddParticipants) {
        [_bntNext setTitle:NSLocalizedString(@"Add", nil) forState:UIControlStateNormal];
    }
    [_bntCancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [_lblNavTitle setText:NSLocalizedString(@"Add Participants", nil)];
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
    if (_aryParticipants.count > 0 && [searchString length] > 0) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@",searchString];
        NSArray * _arrFiltered = [_aryParticipants filteredArrayUsingPredicate:predicate];
        _vcSearchContact.arySearchResults = [NSMutableArray arrayWithArray:_arrFiltered];
    } else {
        _vcSearchContact.arySearchResults = [NSMutableArray arrayWithArray:_aryParticipants];
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
    //_cvParticipants.scrollToItem(at:IndexPath(item: 4, section: 0), at: .right, animated: false)
    
//    NSIndexPath *indexPath = // compute some index path
//
//    [_cvParticipants scrollToItemAtIndexPath:indexPath
//                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
//                                        animated:YES];
    


}

-(void) reloadTableWithParticipants:(NSArray *)participants {
    NSString *strAppUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"appUserId != %@",strAppUserId];
    NSArray *filteredArr = [participants filteredArrayUsingPredicate:predicate];
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
    if (self.isAddParticipants) {
        [self callAPIForAddPraticipantsInGroup];
    }else {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle bundleForClass:CreateGroupViewController.class]];
        CreateGroupViewController *vcCG = [story instantiateViewControllerWithIdentifier:NSStringFromClass(CreateGroupViewController.class)];
        [vcCG setArySelectedParticipants:self.arySelectedParticipants];
        [self.navigationController pushViewController:vcCG animated:YES];
    }
}

-(IBAction)btnCancelTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark API Call
-(void) callAPIForAddPraticipantsInGroup {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
        NSMutableDictionary*dictParam = [[NSMutableDictionary alloc]init];
        [dictParam setValue:self.dictGroupInfo[@"groupId"] forKey:Group_GroupId];
        if (self.arySelectedParticipants.count > 0 && [self.arySelectedParticipants valueForKey:App_User_ID] != nil) {
            [dictParam setValue:[self.arySelectedParticipants valueForKey:App_User_ID] forKey:Group_Participants];
        }
        [[eRTCChatManager sharedChatInstance] groupAddParticipants:dictParam andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            [KVNProgress dismiss];
            NSDictionary *dictResponse = (NSDictionary *)json;
            if (dictResponse[@"success"] != nil) {
                BOOL success = (BOOL)dictResponse[@"success"];
                if (success) {
                    if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *result = (NSDictionary *)dictResponse[@"result"];
                        
                        if ([result count]>0){
                            self.dictGroupInfo = [[NSMutableDictionary alloc] initWithDictionary:result];
                            if (self.completion != nil) { self.completion(YES, self.dictGroupInfo);}
                           // [self.navigationController popViewControllerAnimated:false];
                            for (UIViewController *vc in self.navigationController.viewControllers) {
                                if ([vc isKindOfClass:[InfoGroupViewController class]]) {
                                    [self.navigationController popToViewController:vc animated:false];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:DidSendInvitationMessage object:result];
                                }
                            }
                        }
                    }
                }
            }
            if (dictResponse[@"msg"] != nil) {
                NSString *message = (NSString *)dictResponse[@"msg"];
                if ([message length]>0) {
                    [Helper showAlertOnController:@"eRTC" withMessage:message onController:self];
                }
            }
        } andFailure:^(NSError * _Nonnull error) {
            [KVNProgress dismiss];
            [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
        }];
    } else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}

-(void)callAPIForParticipants {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
        [[eRTCCoreDataManager sharedInstance] fetchChatUserListWithCompletionHandler:^(id ary, NSError *err) {
            [KVNProgress dismiss];
            NSArray *chatUsers = (NSArray *)ary;
            if (chatUsers.count > 0) {
                self->_aryParticipants = chatUsers;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->_lblNavSubTitle setText:[NSString stringWithFormat:@"%lu/100", (unsigned long)self.arySelectedParticipants.count]]; //, (unsigned long)chatUsers.count
                    [self reloadTableWithParticipants:ary];
                });
            }
        }];
    } else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
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
   // if (_aryParticipants.count < 250){
    NSArray *ary = [self tableRowsWithSection:indexPath.section andParticipants:_dictParticipants];
    if (ary.count>indexPath.row) {
        NSDictionary * dict = [ary objectAtIndex:indexPath.row];
        [self addRemoveSelectedItem:dict];
    //}
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

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    _cvParticipants.scrollIndicatorInsets;
}


/*
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // Centering if there are fever pages
    CGSize itemSize = [(UICollectionViewFlowLayout *)collectionViewLayout itemSize];
    CGFloat spacing = [(UICollectionViewFlowLayout *)collectionViewLayout minimumLineSpacing];

    NSInteger count = [self collectionView:self numberOfItemsInSection:section];
    CGFloat totalCellWidth = itemSize.width * count;
    CGFloat totalSpacingWidth = spacing * ((count - 1) < 0 ? 0 : count - 1);
    CGFloat leftInset = (self.view.frame.size.width - (totalCellWidth + totalSpacingWidth)) / 2;
    if (leftInset < 0) {
        UIEdgeInsets inset = [(UICollectionViewFlowLayout *)collectionViewLayout sectionInset];
        return inset;
    }
    CGFloat rightInset = leftInset;
    UIEdgeInsets sectionInset = UIEdgeInsetsMake(0, leftInset, 0, rightInset);
    return sectionInset;
}*/

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

-(void)groupByThreadId {
    NSMutableDictionary*dict = [[NSMutableDictionary alloc]init];
    [dict setValue:@"5d4c41b7497ce60007847969" forKey:ThreadID];
    
    [[eRTCChatManager sharedChatInstance]getgroupByThreadId:dict andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        
    }andFailure:^(NSError * _Nonnull error) {
        NSLog(@"NewGroupViewController ->  getgroupByThreadId %@",error);
    }];
}

@end

