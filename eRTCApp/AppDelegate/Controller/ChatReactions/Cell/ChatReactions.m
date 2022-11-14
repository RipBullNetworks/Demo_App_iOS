//
//  ChatReactions.m
//  eRTCApp
//
//  Created by rakesh  palotra on 30/06/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import "ChatReactions.h"

@implementation ChatReactions

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ChatReactionsCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"ChatReactionsCollectionCell"];
    self.collectionView.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
}

- (void)convertDataToEmoji:(NSDate *)data {
    self.arrEmojis = [NSMutableArray new];
    NSArray *arrData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (arrData != nil && [arrData count] > 0) {
        for (NSDictionary *dictData in arrData) {
            [self.arrEmojis addObject: [NSString stringWithFormat:@"%@", [dictData valueForKey:@"emojiCode"]]];
        }
    }
    [self.collectionView reloadData];
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
    
    cell.labelEmoji.text = [NSString stringWithFormat:@"%@", [self.arrEmojis objectAtIndex:indexPath.row]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(20, 20);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//   NSLog(@"%@", [self getEmojiStringAtIndexPath:indexPath]);
}
@end
