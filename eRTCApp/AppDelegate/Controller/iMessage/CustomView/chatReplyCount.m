//
//  chatReplyCount.m
//  eRTCApp
//
//  Created by rakesh  palotra on 02/05/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import "chatReplyCount.h"
#import "ChatReactionsCollectionCell.h"

@implementation chatReplyCount

- (void)awakeFromNib {
    [super awakeFromNib];
    self.replyViewHeight.constant = 0;
    self.reactionViewHeight.constant = 0;
    [self.collectionView registerNib:[UINib nibWithNibName:@"ChatReactionsCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"ChatReactionsCollectionCell"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [UIView setAnimationsEnabled:NO];
}

- (void)messageSent:(BOOL)status {
    if (status) {
        self.collectionView.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
        self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 10);
    } else {
        self.collectionView.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
        self.collectionView.contentInset = UIEdgeInsetsMake(0, 10, 0, 0);
    }
}

-(void)setPaddingForLastMessage{
      self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 60);
}
- (void)showHideThreadReplyView:(BOOL)threadView {
    
    if (threadView) {
        // Show
        self.replyViewHeight.constant = 60;
    } else {
        // Hide
        self.replyViewHeight.constant = 0;
    }
    [self layoutSubviews];
}

- (void)showHideChatReactionViews:(BOOL)reactionView {
    if (reactionView) {
        // Show
        self.reactionViewHeight.constant = 30;
    } else {
        // Hide
        self.reactionViewHeight.constant = 0;
        self.arrEmojis = [NSMutableArray new];
        [self.collectionView reloadData];
    }
    [self layoutSubviews];
}



- (void)convertDataToEmoji:(NSDate *)data {
    
    self.selectedUndoMessage = @"";
    self.arrEmojis = [NSMutableArray new];
    self.arrUsers = [NSMutableArray new];
    
    NSArray *arrData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (arrData != nil && [arrData count] > 0) {
        for (NSDictionary *dictData in arrData) {
            NSString *count = @"";
            if ([dictData valueForKey:@"emojiCount"] != nil && [dictData valueForKey:@"emojiCount"] != [NSNull null]) {
                count = [NSString stringWithFormat:@"%@", [dictData valueForKey:@"emojiCount"]];
            }
            [self.arrEmojis addObject: [NSString stringWithFormat:@"%@ %@", [dictData valueForKey:@"emojiCode"], count]];
            if ([dictData valueForKey:@"reactionUsers"] != nil && [dictData valueForKey:@"reactionUsers"] != [NSNull null]) {
                if ([[dictData valueForKey:@"reactionUsers"] isKindOfClass:[NSArray class]]) {
                    NSArray *arrUserData = [dictData valueForKey:@"reactionUsers"];
                    NSMutableDictionary *dictEmojisUserData = [NSMutableDictionary new];
                    if ([arrUserData count] > 0) {
                        [dictEmojisUserData setValue:[dictData valueForKey:@"emojiCode"] forKey:@"emoji"];
                        [dictEmojisUserData setValue:arrUserData forKey:@"users"];
                        [self.arrUsers addObject:dictEmojisUserData];
                    }
                }
            }
        }
    }
    
    
    if ([_arrEmojis count] > 0) {
        self.reactionViewHeight.constant = 30;
    }else if ([_arrEmojis count] <= 6) {
        self.reactionViewHeight.constant = 70;
    }else if ([_arrEmojis count] <= 12) {
        self.reactionViewHeight.constant = 60;
    }
    [self.collectionView reloadData];
}

-(void)btnEmojiTapped:(UIButton *)btn {
    NSLog(@"Tag = %ld", (long)btn.tag);
    if (self.delegate != nil) {
        NSString *emojiString = [self.arrEmojis objectAtIndex:btn.tag];
        NSMutableArray *arrString = [NSMutableArray new];
        arrString = [emojiString componentsSeparatedByString:@" "];
        if ([arrString count] > 0) {
            [self.delegate sendEmoji:[NSString stringWithFormat:@"%@", [arrString objectAtIndex:0]] selectedIndexPath:self.selectedIndexPath];
        }
//        [self.delegate sendEmoji:[NSString stringWithFormat:@"%@", [self.arrEmojis objectAtIndex:btn.tag]] selectedIndexPath:self.selectedIndexPath];
    }
}

-(void)btnUndoMessage:(UIButton *)btn {
    //[self.delegate btnUndoChatMessage:self.selectedIndexPath];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.arrEmojis != nil && [self.arrEmojis count] > 0) {
        return [self.arrEmojis count];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
        ChatReactionsCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ChatReactionsCollectionCell" forIndexPath:indexPath];
    
        cell.selectedIndexPath = indexPath;
        cell.delegate = self;
        cell.labelEmoji.text = [NSString stringWithFormat:@"%@", [self.arrEmojis objectAtIndex:indexPath.row]];
        cell.btnEmoji.tag = indexPath.row;
        [cell.btnEmoji addTarget:self action:@selector(btnEmojiTapped:) forControlEvents:(UIControlEventTouchUpInside)];
        cell.backgroundColor = [UIColor colorWithRed:0.925 green:0.965 blue:1.0 alpha:0.3];
        cell.layer.borderColor = [[UIColor colorWithRed:0.663 green:0.84 blue:1.0 alpha:0.8] CGColor];
        cell.layer.borderWidth = 0.5;
        cell.layer.cornerRadius = 10;
        return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectZero];
        lbl.text = [NSString stringWithFormat:@" %@ ", [self.arrEmojis objectAtIndex:indexPath.row]];
        [lbl sizeToFit];
        return CGSizeMake(lbl.frame.size.width, 20);
   
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate != nil) {
        NSString *emojiString = [self.arrEmojis objectAtIndex:indexPath.row];
        NSArray<NSString*> *arrString = [NSArray new];
        arrString = [emojiString componentsSeparatedByString:@" "];
        if ([arrString count] > 0) {
            [self.delegate sendEmoji:[NSString stringWithFormat:@"%@", [arrString objectAtIndex:0]] selectedIndexPath:self.selectedIndexPath];
        }
//        [self.delegate sendEmoji:[NSString stringWithFormat:@"%@", [self.arrEmojis objectAtIndex:indexPath.row]] selectedIndexPath:self.selectedIndexPath];
    }
}

-(void)showUserWhoReacted:(NSString *)emojiString selectedIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate != nil) {
        NSArray<NSString*> *arrString = [NSArray new];
        arrString = [emojiString componentsSeparatedByString:@" "];
        if ([arrString count] > 0) {
            [self.delegate showUserWhoReacted:[NSString stringWithFormat:@"%@", [arrString objectAtIndex:0]] selectedIndexPath:self.selectedIndexPath];
        } else {
            [self.delegate showUserWhoReacted:emojiString selectedIndexPath:self.selectedIndexPath];
        }
    }
}
@end
