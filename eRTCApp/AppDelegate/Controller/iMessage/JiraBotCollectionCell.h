//
//  JiraBotCollectionCell.h
//  eRTCApp
//
//  Created by apple on 05/08/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>

NS_ASSUME_NONNULL_BEGIN


@interface JiraBotCollectionCell : JSQMessagesCollectionViewCell
@property (weak, nonatomic) IBOutlet UICollectionView *cvJirabotCollectionView;
@property (strong, nonatomic) NSMutableArray *arrayDataSource;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;


@end

NS_ASSUME_NONNULL_END
