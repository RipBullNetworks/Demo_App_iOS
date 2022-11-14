//
//  ChatReactions.h
//  eRTCApp
//
//  Created by rakesh  palotra on 30/06/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatReactionsCollectionCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatReactions : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *arrEmojis;

- (void)convertDataToEmoji:(NSDate *)data;
@end

NS_ASSUME_NONNULL_END
