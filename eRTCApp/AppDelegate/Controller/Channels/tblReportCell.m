//
//  tblReportCell.m
//  eRTCApp
//
//  Created by apple on 09/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "tblReportCell.h"
#import "UIColor+JSQMessages.h"

@implementation tblReportCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _vwContainer.layer.borderColor = [self colorWithHexString:@"71869C"].CGColor;
    _vwContainer.layer.borderWidth = 1;
    _btnDelete.layer.borderWidth = 1;
    _btnResolve.layer.borderWidth  = 1;
    _btnDelete.layer.borderColor = [self colorWithHexString:@"71869C"].CGColor;
    _btnResolve.layer.borderColor = [self colorWithHexString:@"71869C"].CGColor;
    
    self.imgMedia.layer.cornerRadius = 8;
    self.imgMedia.layer.masksToBounds = true;
    
    self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.width/2;
    self.imgProfile.layer.masksToBounds = true;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];

    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];

    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];

    if ([cString length] != 6) return  [UIColor grayColor];

    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];

    range.location = 2;
    NSString *gString = [cString substringWithRange:range];

    range.location = 4;
    NSString *bString = [cString substringWithRange:range];

    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];

    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

@end

