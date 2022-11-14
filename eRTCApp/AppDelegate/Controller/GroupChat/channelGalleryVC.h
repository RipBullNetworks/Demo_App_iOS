//
//  channelGalleryVC.h
//  eRTCApp
//
//  Created by apple on 24/05/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface channelGalleryVC : UIViewController
@property (weak, nonatomic) IBOutlet UICollectionView *cvGalleryList;
@property(nonatomic, strong) NSMutableDictionary *dictGroupInfo;
@property(nonatomic, strong) NSMutableArray *arrGalleyData;



@end

NS_ASSUME_NONNULL_END
