//
//  JSQReportCell.h
//  eRTCApp
//
//  Created by rakesh  palotra on 21/05/20.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "JSQReportCell.h"
#import <JSQMessagesViewController/JSQMessagesViewController.h>
/**
 *  A `JSQMessagesCollectionViewCellIncoming` object is a concrete instance 
 *  of `JSQMessagesCollectionViewCell` that represents an incoming message data item.
 */
@class JSQReportCell;
@protocol ChatUndoMsgDelegate <NSObject>
@required
- (void)selectedUndoButton:(JSQReportCell *)cell;
@end

@interface JSQReportCell : JSQMessagesCollectionViewCell
@property (weak, nonatomic) IBOutlet UICollectionView *cvCollectionView;
@property (weak, nonatomic) IBOutlet UITableView *tblDriveCell;
@property (nonatomic, weak) id<ChatUndoMsgDelegate> delegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hgtReportedView;
@property(nonatomic, strong) NSString *strType;

@end
