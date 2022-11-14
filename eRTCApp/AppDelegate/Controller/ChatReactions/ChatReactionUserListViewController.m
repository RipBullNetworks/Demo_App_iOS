//
//  ChatReactionUserListViewController.m
//  eRTCApp
//
//  Created by Chandra Rao on 26/07/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import "ChatReactionUserListViewController.h"

@interface ChatReactionUserListViewController () <HWPanModalPresentable, UITableViewDataSource, UITableViewDelegate>

@end

@implementation ChatReactionUserListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 44;
}

-(PanModalHeight)shortFormHeight {
    return PanModalHeightMake(PanModalHeightTypeContent, 200);
}

- (UIViewAnimationOptions)transitionAnimationOptions {
    return UIViewAnimationOptionCurveLinear;
}

- (UIScrollView *)panScrollable {
    return self.tableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.arrayDataSource count] > 0) {
        return [self.arrayDataSource count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"ChatRectionsUserTableViewCell";
    ChatRectionsUserTableViewCell * cell = (ChatRectionsUserTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChatRectionsUserTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.imgUser.layer.cornerRadius = cell.imgUser.frame.size.height/2;
    cell.imgUser.layer.masksToBounds = YES;
    NSDictionary *dictData = [self.arrayDataSource objectAtIndex:indexPath.row];
    cell.labelUser.text = [NSString stringWithFormat:@"%@", [dictData valueForKey:@"name"]];
    cell.labelEmoji.text = [NSString stringWithFormat:@"%@", self.emoji];
//    cell.labelEmoji.text = [NSString stringWithFormat:@"%@", [dictData valueForKey:@"emojiCode"]];
    if (dictData[User_ProfilePic_Thumb] != nil && dictData[User_ProfilePic_Thumb] != [NSNull null]) {
        NSString *imageURL = [NSString stringWithFormat:@"%@",dictData[User_ProfilePic_Thumb]];
        [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:imageURL]
        placeholderImage:[UIImage imageNamed:@"recentChatuser"]];
    }else{
         cell.imgUser.image =  [UIImage imageNamed:@"recentChatuser"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
