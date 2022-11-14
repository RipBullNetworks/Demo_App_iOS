//
//  JSQMessagesViewController+JSQMessagesViewControllerX.m
//  eRTCApp
//
//  Created by jayant patidar on 16/10/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import "JSQMessagesViewController+JSQMessagesViewControllerX.h"
#import "chatReplyCount.h"

@implementation JSQMessagesViewController (JSQMessagesViewControllerX)
-(UIContextMenuConfiguration *)collectionView:(UICollectionView *)collectionView contextMenuConfigurationForItemAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point API_AVAILABLE(ios(13.0)){

    JSQMessagesCollectionViewCell *cell = ( JSQMessagesCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell){
       
        UICollectionViewLayoutAttributes *attributes = [collectionView layoutAttributesForItemAtIndexPath:indexPath];
        CGRect cellRect = attributes.frame;
        CGRect cellFrameInSuperview = [collectionView convertRect:cellRect toView:self.collectionView];
        cellFrameInSuperview.size.height -= cell.cellBottomLabel.frame.size.height;
        BOOL _isContains = CGRectContainsPoint(cellFrameInSuperview, point);
        if (_isContains){
            [self collectionView:collectionView shouldShowMenuForItemAtIndexPath:indexPath];
            return [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil actionProvider:^UIMenu * _Nullable(NSArray<UIMenuElement *> * _Nonnull suggestedActions) {
                return nil;
            }];
        }
    }
    return nil;

}
@end
