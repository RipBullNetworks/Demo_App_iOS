//
//  ForwardToTableViewCell.m
//  eRTCApp
//
//  Created by Rakesh Palotra on 28/08/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import "ForwardToTableViewCell.h"

@implementation ForwardToTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.checkStatus = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUIWithData:(NSDictionary *)dictData isContacts:(BOOL)isContacts status:(BOOL)status {
    if (dictData != nil && dictData != [NSNull null]) {
        self.imgUser.layer.cornerRadius= self.imgUser.frame.size.height/2;
        self.imgUser.layer.masksToBounds = YES;
        if (dictData[User_Name] != nil && dictData[User_Name] != [NSNull null]) {
            self.lblName.text = dictData[User_Name];
        }
        if (dictData[User_ProfilePic_Thumb] != nil && dictData[User_ProfilePic_Thumb] != [NSNull null]) {
            NSString *imageURL = [NSString stringWithFormat:@"%@",dictData[User_ProfilePic_Thumb]];
            [self.imgUser sd_setImageWithURL:[NSURL URLWithString:imageURL]
                            placeholderImage:[UIImage imageNamed:@"forwordIcon"]];
        } else {
            self.imgUser.image =  [UIImage imageNamed:@"forwordIcon"];
        }
        if (status) {
            [self.btnCheck setSelected:YES];
            [self.btnCheck setImage:[UIImage imageNamed:@"CheckCircle"] forState:UIControlStateNormal];
        } else {
            [self.btnCheck setSelected:NO];
            [self.btnCheck setImage:[UIImage imageNamed:@"radioUncheck"] forState:UIControlStateNormal];
        }
    }
}

- (void)updateButtonStatus:(BOOL)btnStatus isContacts:(BOOL)isContacts {
    if (btnStatus) {
        [self.btnCheck setSelected:YES];
        [self.btnCheck setImage:[UIImage imageNamed:@"CheckCircle"] forState:UIControlStateNormal];
    } else {
        [self.btnCheck setSelected:NO];
        [self.btnCheck setImage:[UIImage imageNamed:@"radioUncheck"] forState:UIControlStateNormal];
    }
}
@end
