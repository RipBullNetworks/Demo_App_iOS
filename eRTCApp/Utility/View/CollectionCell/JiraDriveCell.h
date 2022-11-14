//
//  JiraDriveCell.h
//  eRTCApp
//
//  Created by apple on 03/08/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JiraDriveCell;
@protocol JiraReportedDelegate <NSObject>
@required
- (void)selectedItcTickets:(JiraDriveCell *)cell;
@end

@interface JiraDriveCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *btnOpen;
@property (weak, nonatomic) IBOutlet UIView *vwContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblType;
@property (weak, nonatomic) IBOutlet UILabel *lblSprint;
@property (weak, nonatomic) IBOutlet UILabel *lblEback;
@property (nonatomic, weak) id<JiraReportedDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *lblCreadedBy;
@property (weak, nonatomic) IBOutlet UILabel *lblLastUpdate;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblAssigned;

@end

NS_ASSUME_NONNULL_END
