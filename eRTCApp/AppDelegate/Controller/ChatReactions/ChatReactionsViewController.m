//
//  ChatReactionsViewController.m
//  eRTCApp
//
//  Created by rakesh  palotra on 21/06/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import "ChatReactionsViewController.h"
#import "EmojiHelper.h"

@interface ChatReactionsViewController () <HWPanModalPresentable, UITableViewDataSource, UITableViewDelegate>{
    NSString *_messageType;
}
@property (strong, nonatomic) NSArray<MyEmojiCategory *> *emojiCategories;
@end

@implementation ChatReactionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpInitialData];
    
    self.emojiCategories = [EmojiHelper getAllEmojisInRecentCategories];
//    NSLog(@"EMOJIS = %@", self.emojiCategories);
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.userMessage != nil) {
    self.vWContainerMessage.hidden = false;
    self.lblShowMessage.text = self.userMessage;
    }else{
        self.vWContainerMessage.hidden = true;
    }
}

-(void) setMessageType:(NSString*)type{
    _messageType = type;
}
- (void)setUpInitialData {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView reloadData];
}

- (BOOL)showDragIndicator {
    return NO;
}

-(CGFloat) getHeight {
    CGFloat height;
    NSDictionary *config = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
    
    if ([self.arrayDataSource count] > 0) {
        height = (100 + ([self.arrayDataSource count]*50));
    }
   
    if (self.isThread) {
        height = 190 + 120;
    }
    if (_messageType != NULL){
        NSSet *types = [[NSSet alloc] initWithObjects: GifyFileName, LocationType, ContactType,  @"image", nil];
        if ([types containsObject:_messageType]){
            height -= (50 + (self.isThread ? 10 : 0));
        }
    }
    if ([_messageType isEqualToString:@"text"]){
        height += 60;
    }
    return height;
}


- (PanModalHeight)longFormHeight {
    return PanModalHeightMake(PanModalHeightTypeContent, (100 + ([self.arrayDataSource count]*50)));
}

-(PanModalHeight)shortFormHeight {
    return PanModalHeightMake(PanModalHeightTypeContent,  (100 + ([self.arrayDataSource count]*50)));
}

- (UIViewAnimationOptions)transitionAnimationOptions {
    return UIViewAnimationOptionCurveLinear;
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
    if (indexPath.row == 0) {
        static NSString *identifier = @"ReactionsTableViewCellActions";
        ReactionsTableViewCell * cell = (ReactionsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ReactionsTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:1];
            cell.emojiCategories = self.emojiCategories;
            [cell updateRecentEmojis];
        }
        [cell.btnLike addTarget:self action:@selector(chatReactionClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnDisLike addTarget:self action:@selector(chatReactionClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnLaughLike addTarget:self action:@selector(chatReactionClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnRofl addTarget:self action:@selector(chatReactionClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnHeart addTarget:self action:@selector(chatReactionClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnClap addTarget:self action:@selector(chatReactionClicked:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    } else {
        static NSString *identifier = @"ReactionsTableViewCell";
        ReactionsTableViewCell * cell = (ReactionsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ReactionsTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        if ([[self.arrayDataSource objectAtIndex:indexPath.row] isKindOfClass:[NSMutableDictionary class]]) {
            cell.title.text = [self.arrayDataSource objectAtIndex:indexPath.row][@"name"];
            cell.imgView.image = [UIImage imageNamed:[self.arrayDataSource objectAtIndex:indexPath.row][@"image"]];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissViewControllerAnimated:YES completion:^{
        ReactionsTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cell != nil) {
            if ([cell.title.text isEqualToString:@"Copy"]) {
                [self.delegate chatReactDelegate:Copy];
            } else if ([cell.title.text isEqualToString:@"Add to favorites"]) {
                [self.delegate chatReactDelegate:FavUnFav];
            } else if ([cell.title.text isEqualToString:@"Remove From Favourites"]) {
                [self.delegate chatReactDelegate:FavUnFav];
            } else if ([cell.title.text isEqualToString:@"View thread"]) {
                [self.delegate chatReactDelegate:StartThread];
            } else if ([cell.title.text isEqualToString:@"Start a thread"]) {
                [self.delegate chatReactDelegate:StartThread];
            }else if ([cell.title.text isEqualToString:@"Forward"]) {
                [self.delegate chatReactDelegate:Forward];
            }else if ([cell.title.text isEqualToString:@"Delete"]) {
                [self.delegate chatReactDelegate:Delete];
            }else if ([cell.title.text isEqualToString:@"Edit"]) {
                [self.delegate chatReactDelegate:Edit];
            }else if ([cell.title.text isEqualToString:@"Report Message"]) {
                [self.delegate chatReactDelegate:Report];
            }else if ([cell.title.text isEqualToString:@"Follow thread"])  {
                [self.delegate chatReactDelegate:Follow];
            }else if ([cell.title.text isEqualToString:@"Unfollow thread"]) {
                [self.delegate chatReactDelegate:Follow];
            }
        }
//        if (indexPath.row == 1) {
//            [self.delegate chatReactDelegate:Copy];
//        } else if (indexPath.row == 2) {
//            [self.delegate chatReactDelegate:FavUnFav];
//        } else if (indexPath.row == 3) {
//            [self.delegate chatReactDelegate:StartThread];
//        } else if (indexPath.row == 4) {
//            [self.delegate chatReactDelegate:More];
//        }
    }];
}

- (void)chatReactionClicked:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate recentChatReactionDelegate:(int) sender.tag selectedIndexPath:self.selectedIndexPath emojiCode:[sender titleForState:UIControlStateNormal]];
    }];
}
@end
