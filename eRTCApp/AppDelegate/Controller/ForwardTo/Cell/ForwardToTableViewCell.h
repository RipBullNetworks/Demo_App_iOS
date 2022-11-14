//
//  ForwardToTableViewCell.h
//  eRTCApp
//
//  Created by Rakesh Palotra on 28/08/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ForwardToTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *btnCheck;
@property (nonatomic, assign) BOOL checkStatus;
- (void)updateUIWithData:(NSDictionary *)dictData isContacts:(BOOL)isContacts status:(BOOL)status;
- (void)updateButtonStatus:(BOOL)btnStatus isContacts:(BOOL)isContacts;

@end

NS_ASSUME_NONNULL_END
