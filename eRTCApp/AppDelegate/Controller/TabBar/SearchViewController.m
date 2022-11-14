//
//  SearchViewController.m
//  eRTCApp
//
//  Created by Rakesh Palotra on 08/01/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import "SearchViewController.h"
#import "UserContactsCell.h"
#import "RecentChatTableViewCell.h"
#import "SingleChatViewController.h"
#import "eRTCTabBarViewController.h"
#import "InfoGroupViewController.h"
#import <Toast/Toast.h>
#import "GroupChatViewController.h"

@interface SearchViewController (){
        LoadMore loadMoreCallback;
    UIView *footerView;
    BOOL isShowMoreHidden;
    NSString *searchText;
}

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 56;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:RecentChatCellIdentifier bundle:[NSBundle mainBundle]] forCellReuseIdentifier:RecentChatCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:UserContactsCellIdentifier bundle:[NSBundle mainBundle]] forCellReuseIdentifier:UserContactsCellIdentifier];
   
    if (!self->loadMoreCallback){
        self.tableView.tableFooterView = [UIView new];
        self.tableView.sectionFooterHeight = 0.0;
    }
}
-(void)setRefereshCallBack:(LoadMore) loadMore {
    self->loadMoreCallback = loadMore;
}
-(void)searchText:(NSString*)searchText{
    self->searchText = searchText;
    
}

-(void)isShowMoreHidden:(BOOL)isShowMoreHidden {
    self->isShowMoreHidden = isShowMoreHidden;
    if (isShowMoreHidden){
        self.tableView.tableFooterView = [UIView new];
        self.tableView.sectionFooterHeight = 0.0;
    }else {
        self.tableView.tableFooterView = [self getFooterView];
        self.tableView.sectionFooterHeight = 50;
    }
}

-(void)showDeactivatedMessage:(NSString *)msg {
    self.tableView.hidden = true;
    [self.view makeToast:GlobalSearch_msg];
}


-(void)loadMore:(UIButton*) button{
    if (self->loadMoreCallback){
        self->loadMoreCallback();
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height)];
    noDataLabel.font = [UIFont fontWithName:@"SFProDisplay-Semibold" size:18];
    noDataLabel.textAlignment = NSTextAlignmentCenter;
    noDataLabel.textColor = [UIColor darkGrayColor];
    noDataLabel.backgroundColor = [UIColor whiteColor];
    if ([self.searchResults count] == 0) {
        noDataLabel.text = @"No result Found";
        self.tableView.backgroundView = noDataLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }else{
        noDataLabel.text = @"";
        self.tableView.backgroundView = noDataLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
 
    
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.searchType == RecentSearch) {
        RecentChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RecentChatCellIdentifier];
        cell.imgBlock.hidden = true;
       
        cell.imgPrivateChannel.hidden = true;
        if (self.searchResults.count > indexPath.row) {
            cell.lblMessage.hidden = NO;
            cell.muteIMG.hidden = YES;
            cell.imgBlock.hidden = true;
            NSDictionary * dict = [self.searchResults objectAtIndex:indexPath.row];
            if (dict[User_Name] != nil && dict[User_Name] != [NSNull null]) {
                cell.lblName.text = dict[User_Name];
            }else{
                cell.lblName.text = @"";

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
            
            
            
             if (dict[Message] != nil && dict[Message] != [NSNull null]) {
                NSString *message = [Helper getRemoveMentionTags:dict[Message]];
                 if (self->searchText){
                     cell.lblMessage.attributedText = [self getAttributeText:message forSubstring:self->searchText];
                 }else {
                     cell.lblMessage.text = message;
                 }
                      
             }else{
                 cell.lblMessage.text = @"";
             }
            if (dict[User_ProfilePic_Thumb] != nil && dict[User_ProfilePic_Thumb] != [NSNull null]) {
                NSString *imageURL = [NSString stringWithFormat:@"%@",dict[User_ProfilePic_Thumb]];
                [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:imageURL]
                    placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
                cell.profileImageView.layer.cornerRadius= cell.profileImageView.frame.size.height/2;
                cell.profileImageView.layer.masksToBounds = YES;
            }else{
                cell.profileImageView.image =  [UIImage imageNamed:@"DefaultUserIcon"];
            }
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
                    //cell.imgBlock.hidden = NO;
                }

                    if (dict[BlockedStatus] != nil && dict[BlockedStatus] != [NSNull null]) {
                       if ([dict[BlockedStatus] isEqualToString:@"blocked"]) {
                           [cell.muteIMG setImage:[UIImage imageNamed:@"profileBlock"]];
                            cell.muteIMG.hidden = NO;
                            cell.imgBlock.hidden = NO;
                            cell.unReadMessage.hidden = YES;
                       }
                    }
                   if (dict[NotificationSettings] != nil && dict[NotificationSettings] != [NSNull null]) {

                          if ([dict[NotificationSettings] isEqualToString:@"none"]) {
                              [cell.muteIMG setImage:[UIImage imageNamed:@"muteImg"]];
                               cell.muteIMG.hidden = NO;
                              cell.imgBlock.hidden = true;
                          }
                       }
                       
                if (dict[AvailabilityStatus] != nil && dict[AvailabilityStatus] != [NSNull null]) {
                    cell.lblAvailabilityStatus.hidden = NO;

                    if ([dict[AvailabilityStatus] isEqualToString:Online]) {
                        cell.lblAvailabilityStatus.textColor = [UIColor colorWithRed:20/255.0f green:78/255.0f blue:35/255.0f alpha:1.0];
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
            }
            cell.lblAvailabilityStatus.layer.cornerRadius= cell.lblAvailabilityStatus.frame.size.height/2;
            cell.lblAvailabilityStatus.layer.masksToBounds = YES;
        cell.imgBlock.hidden = true;
        cell.imgPrivateChannel.hidden = true;
        return cell;
        
    } else if (self.searchType == ContactsSearch) {
        UserContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:UserContactsCellIdentifier forIndexPath:indexPath];
        
        if (self.searchResults.count > indexPath.row) {
            NSDictionary * dict = [self.searchResults objectAtIndex:indexPath.row];
            if (dict[User_Name] != nil && dict[User_Name] != [NSNull null]) {
                cell.lblUserName.text = dict[User_Name];
            }
            if (dict[@"availabilityStatus"] != nil && dict[@"availabilityStatus"] != [NSNull null]) {
                if ([dict[AvailabilityStatus] isEqualToString:@"online"]) {
                    cell.imgUserAwailability.image =  [UIImage imageNamed:@"greenIndicator"];
                }else if ([dict[AvailabilityStatus] isEqualToString:@"away"]) {
                    cell.imgUserAwailability.image =  [UIImage imageNamed:@"yelloIndicator"];
                }else if ([dict[AvailabilityStatus] isEqualToString:@"offline"]) {
                    cell.imgUserAwailability.image =  [UIImage imageNamed:@"redIndicator"];
                }
            }
            
            if (dict[App_User_ID] != nil && dict[App_User_ID] != [NSNull null]) {
                cell.lblUserEmailId.text = dict[App_User_ID];
            }
            
            if (dict[BlockedStatus] != nil && dict[BlockedStatus] != [NSNull null]) {
                if ([dict[BlockedStatus] isEqualToString:Block_Status]) {
                    cell.imageBlock.hidden = true;
                }else{
                    cell.imageBlock.hidden = false;
                }
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
    
    return [[UITableViewCell alloc] init];
}

- (NSMutableAttributedString*)getAttributeText:(NSString*)string forSubstring:(NSString*)searchstring {
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string];
    NSError *error;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:searchstring options:NSRegularExpressionIgnoreMetacharacters error:&error];
    [regex enumerateMatchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        NSLog(@"match %lu", (unsigned long)[result range].location);
        if (result != NULL){
            [text addAttribute: NSBackgroundColorAttributeName value: [[UIColor redColor] colorWithAlphaComponent:0.2] range:[result range]];
        }
    }];
    return text;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.searchResults.count > indexPath.row) {
            eRTCTabBarViewController *_ertc = (eRTCTabBarViewController *)[[[AppDelegate sharedAppDelegate] window] rootViewController];
            UINavigationController *_nav = (UINavigationController *)_ertc.viewControllers[_ertc.selectedIndex];
            NSMutableDictionary *dictRecentChat = [[NSMutableDictionary alloc] init];
            NSDictionary *dict = [self.searchResults objectAtIndex:indexPath.row];
            [dictRecentChat addEntriesFromDictionary: dict];
            [dictRecentChat setValue:self->searchText forKey:@"msgTitle"];
            NSLog(@"dictRecentChat>>>>>>>%@",dictRecentChat);
        NSString *appUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
        [[eRTCChatManager sharedChatInstance] inserRecentSearchData:appUserId withDictData:dictRecentChat];

            if (![Helper stringIsNilOrEmpty:dict[@"threadType"]]) {
                if ([dict[@"threadType"] isEqualToString:@"single"]){
                    SingleChatViewController * _vcMessage = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"SingleChatViewController"];
                    _vcMessage.dictUserDetails = dict;
                    _vcMessage.searchMessage = dict;
                    _vcMessage.isUserSearchText = true;
                    [_nav pushViewController:_vcMessage animated:YES];
                }
                else{
                    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle bundleForClass:InfoGroupViewController.class]];
                    GroupChatViewController *vcInfo = [story instantiateViewControllerWithIdentifier:NSStringFromClass(GroupChatViewController.class)];
                    vcInfo.dictGroupinfo = dict;
                    vcInfo.searchMessage = dict;
                    [_nav pushViewController:vcInfo animated:YES];
                }
            } else if ([_nav.viewControllers count] > 0 && [[[_nav viewControllers] firstObject] isKindOfClass:[ContactsViewController class]]) {
                if (self.gsDelegate != nil) {
                    [self.gsDelegate didSelectedItem:dict];
                }
            }
        }
    }];
}

-(UIView*)getFooterView {
    if (!self->footerView){
        UIView *footerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)];
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        footerView.backgroundColor = [UIColor whiteColor];
        [button setTitle:@"Show More" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont fontWithName:@"SFProDisplay-Semibold" size:14]];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        CGFloat x = (self.tableView.frame.size.width - 130)/2;
        button.frame=CGRectMake(x, 0, 130, 50);
        CALayer *TopBorder = [CALayer layer];
        TopBorder.frame = CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 1.0f);
        TopBorder.backgroundColor = [UIColor groupTableViewBackgroundColor].CGColor;
        [footerView.layer addSublayer:TopBorder];
        [button addTarget:self action:@selector(loadMore:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:button];
        self->footerView = footerView;
    }
    return  footerView;
}

@end
