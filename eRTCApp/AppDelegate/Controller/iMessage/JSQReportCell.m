//
//  JSQReportCell.m
//  eRTCApp
//
//  Created by rakesh  palotra on 21/05/20.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//
#import "JSQReportCell.h"
#import "GoogleDriveCell.h"
#import "ImageVideoCell.h"
#import "JiraDriveCell.h"
#import "EmptyCollectionCell.h"


//@interface JSQReportCell ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{ //
//
//}
//@end

@implementation JSQReportCell
#pragma mark - Overrides//JiraDriveCell

- (void)awakeFromNib
{
    self.messageBubbleTopLabel.textAlignment = NSTextAlignmentLeft;
    self.cellBottomLabel.textAlignment = NSTextAlignmentLeft;
    [super awakeFromNib];

}


- (IBAction)btnUndo:(id)sender {
    [self.delegate selectedUndoButton:self];
}

/*
#pragma mark :- CollectionViewDelegate&Datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 ) {
    GoogleDriveCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GoogleDriveCell" forIndexPath:indexPath];
    return cell;
    }else if (indexPath.row == 3) {
    EmptyCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EmptyCollectionCell" forIndexPath:indexPath];
    return cell;
    }else {
    JiraDriveCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JiraDriveCell" forIndexPath:indexPath];
    return cell;
    }
    return [UICollectionViewCell new];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((_cvCollectionView.frame.size.width -32), 280);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath  {
  
}*/






@end
