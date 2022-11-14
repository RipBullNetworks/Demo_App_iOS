//
//  driveDemoCell.m
//  eRTCApp
//
//  Created by apple on 03/08/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "driveDemoCell.h"
#import "GoogleDriveCell.h"
#import "ImageVideoCell.h"

@interface driveDemoCell ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    
}
@end

@implementation driveDemoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    //[_cvDriveCollectionList registerNib:[UINib nibWithNibName:@"GoogleDriveCell" bundle:nil] forCellWithReuseIdentifier:@"GoogleDriveCell"];
    [_cvDriveCollectionList registerNib:[UINib nibWithNibName:@"ImageVideoCell" bundle:nil] forCellWithReuseIdentifier:@"ImageVideoCell"];

    self.cvDriveCollectionList.delegate = self;
    self.cvDriveCollectionList.dataSource = self;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark :- CollectionViewDelegate&Datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  //  GoogleDriveCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GoogleDriveCell" forIndexPath:indexPath];
    ImageVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageVideoCell" forIndexPath:indexPath];

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((100), 100);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath  {
  
}

@end
