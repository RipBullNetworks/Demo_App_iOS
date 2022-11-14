//
//  StarredMessageVC.m
//  eRTCApp
//
//  Created by Apple on 30/11/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "StarredMessageVC.h"
#import "StarredMessageCell.h"

@interface StarredMessageVC  ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate, UISearchControllerDelegate, UISearchResultsUpdating> {
    NSString                                  *strTitle;
    NSString                                  *_strAppLoggedInUserID;
    UISearchController *searchController;
    NSMutableArray *arySearch;
}


@end

@implementation StarredMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tblFavouriteLIst registerNib:[UINib nibWithNibName:@"StarredMessageCell" bundle:nil] forCellReuseIdentifier:@"StarredMessageCell"];
    self.tblFavouriteLIst.delegate = self;
    self.tblFavouriteLIst.dataSource = self;
    [self setupTableView];
    self.searchBarView.delegate = self;
   
}


#pragma mark - SearchBar Delegates
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
   // NSString *searchString = searchController.searchBar.text;
    strTitle = searchController.searchBar.text;
    [self searchForText:strTitle];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    strTitle = searchBar.text;
    
    [self searchForText:strTitle];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    strTitle = searchText;
    [self searchForText:strTitle];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:true];
    strTitle = @"";
    [self searchForText:@""];
    arySearch = [NSMutableArray new];
    [self.tblFavouriteLIst reloadData];
}

#pragma mark Private
- (void)searchForText:(NSString*)searchString {
    if (self.aryStarredMessage.count > 0 && [searchString length] > 0) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"message contains[c] %@",searchString];
        NSArray * _arrFiltered = [self.aryStarredMessage filteredArrayUsingPredicate:predicate];
        arySearch = [NSMutableArray arrayWithArray:_arrFiltered];
    } else {
        arySearch = [NSMutableArray new];
    }
    [self.tblFavouriteLIst reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tblFavouriteLIst.bounds.size.width, self.tblFavouriteLIst.bounds.size.height)];
    noDataLabel.textColor        = [UIColor blueColor];
    noDataLabel.textAlignment    = NSTextAlignmentCenter;
    self.tblFavouriteLIst.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (arySearch.count > 0) {
        noDataLabel.text             = @"";
        self.tblFavouriteLIst.backgroundView = noDataLabel;
        return arySearch.count;
    }else{
        noDataLabel.text             = @"No starred message found!";
        self.tblFavouriteLIst.backgroundView = noDataLabel;
        return 0;
    }
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StarredMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StarredMessageCell"];
    NSDictionary*dictData = self.aryStarredMessage[indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (dictData[CreatedAt] != nil && dictData[CreatedAt] != [NSNull null]) {
        double timeStamp = [[dictData valueForKey:CreatedAt]doubleValue];
        NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
        [dateFormatter setDateFormat:@"EEE MMM dd yyyy HH:mm:ss"];
        NSString  *finalate = [dateFormatter stringFromDate:msgdate];
        cell.lblDate.text = finalate;
    }
    //cell.lblMessage.text = dictData[@"message"];
    
    cell.lblMessage.attributedText =  [Helper mentionHighlightedAttributedStringByNames:@"" message:dictData[@"message"]];
    cell.lblMessage.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:17];
    
    return  cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark setupView
-(void) setupTableView {
   // [self.tblFavouriteLIst setEstimatedRowHeight:56];
    //[self.tblFavouriteList setRowHeight:UITableViewAutomaticDimension];
   // self.tblFavouriteList.separatorStyle = UITableViewCellSeparatorStyleNone;
    //[self.tblFavouriteList registerNib:[UINib nibWithNibName:StarredfavMessageCell bundle:nil] forCellReuseIdentifier:StarredfavMessageCell];
}




- (IBAction)btnCancel:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}


@end
