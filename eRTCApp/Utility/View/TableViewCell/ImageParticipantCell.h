//
//  ImageParticipantCell.h
//  eRTCApp
//
//  Created by apple on 15/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>
//typedef void(^CompletionBlocke)(NSMutableDictionary * _Nullable dictInfo);
NS_ASSUME_NONNULL_BEGIN

@class ImageParticipantCell;
@protocol myGalleryVideoDelegate <NSObject>
@required
- (void)selectedImageIndex:(ImageParticipantCell *)cell selectDict:(NSMutableDictionary *)dict;
@end

@interface ImageParticipantCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UICollectionView *cvVideoImageList;
@property(nonatomic, strong) NSMutableArray *arrGallerycollectionData;
@property (nonatomic, weak) id<myGalleryVideoDelegate> delegate;
@property(nonatomic, strong) NSString *strThreadId;
//@property (nonatomic) CompletionBlocke completion;

-(void)getGalleryData:(NSMutableArray *)arrData;

@end

NS_ASSUME_NONNULL_END
