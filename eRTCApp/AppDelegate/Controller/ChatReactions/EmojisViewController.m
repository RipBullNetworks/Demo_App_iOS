//
//  EmojisViewController.m
//  eRTCApp
//
//  Created by rakesh  palotra on 22/06/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import "EmojisViewController.h"
#import "EmojiHelper.h"
#import "MyEmojiCategory.h"

@interface EmojisViewController () <HWPanModalPresentable, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) NSArray<MyEmojiCategory *> *emojiCategories;
@property (strong, nonatomic) NSMutableArray *emojisArrayFromAPI;
@end

@implementation EmojisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.emojiCategories = [EmojiHelper getAllEmojisInCategories];
    [self.emojisCollectionView reloadData];
}

-(PanModalHeight)shortFormHeight {
    return PanModalHeightMake(PanModalHeightTypeContent, 300);
}

- (BOOL)isPanScrollEnabled {
    return YES;
}

- (UIScrollView *)panScrollable {
    return self.emojisCollectionView;
}

- (UIViewAnimationOptions)transitionAnimationOptions {
    return UIViewAnimationOptionCurveLinear;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.emojiCategories count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    MyEmojiCategory *category = [self.emojiCategories objectAtIndex:section];
    return [category.emoji count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
       if (kind == UICollectionElementKindSectionHeader) {
           EmojisSectionHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"EmojisSectionHeader" forIndexPath:indexPath];
           MyEmojiCategory *category = [self.emojiCategories objectAtIndex:indexPath.section];
           headerView.labelTitle.text = category.name;
           reusableview = headerView;
       }
       return reusableview;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EmojisCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EmojisCollectionViewCell" forIndexPath:indexPath];
    cell.title.text = [self getEmojiStringAtIndexPath:indexPath];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(30, 30);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeZero;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate sendMesage:[self getEmojiStringAtIndexPath:indexPath] selectedindexPath:self.selectedIndexPath];
    }];
}

- (NSString *)getEmojiStringAtIndexPath:(NSIndexPath *)indexPath {
  MyEmojiCategory *emojiCategory = [self.emojiCategories objectAtIndex:indexPath.section];
  MyEmoji *emoji = [emojiCategory.emoji objectAtIndex:indexPath.row];
  return [emoji.variations componentsJoinedByString:@" "];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  MyEmojiCategory *emojiCategory = [self.emojiCategories objectAtIndex:section];
  return emojiCategory.name;
}
@end
