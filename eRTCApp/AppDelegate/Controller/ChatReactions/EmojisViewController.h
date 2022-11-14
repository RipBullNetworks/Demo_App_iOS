//
//  EmojisViewController.h
//  eRTCApp
//
//  Created by rakesh  palotra on 22/06/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmojisCollectionViewCell.h"
#import "EmojisSectionHeader.h"
#import <HWPanModal/HWPanModal.h>

@class EmojisViewController;
@protocol EmojisViewControllerDelegate <NSObject>
- (void)sendMesage: (NSString *_Nullable)message selectedindexPath:(NSIndexPath *_Nullable)indexpath;
@end //end protocol


NS_ASSUME_NONNULL_BEGIN

@interface EmojisViewController : UIViewController
@property (weak, nonatomic) IBOutlet UICollectionView *emojisCollectionView;
@property (nonatomic, weak) id <EmojisViewControllerDelegate> delegate; //define MyClassDelegate as delegate
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end

NS_ASSUME_NONNULL_END
