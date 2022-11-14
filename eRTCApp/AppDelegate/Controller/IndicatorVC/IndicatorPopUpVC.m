//
//  IndicatorPopUpVC.m
//  eRTCApp
//
//  Created by apple on 12/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "IndicatorPopUpVC.h"

@interface IndicatorPopUpVC ()
@property (weak, nonatomic) IBOutlet UIView *vwContainer;

@end

@implementation IndicatorPopUpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: _vwContainer.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){10.0, 10.}].CGPath;
    self.vwContainer.layer.mask = maskLayer;
}

- (IBAction)btnCommonIndicator:(UIButton *)sender {
    NSString *indicatorStatus;
    NSMutableDictionary * dictIndicator = [NSMutableDictionary new];
    if (sender.tag == 101) {
        indicatorStatus = Online;
    }else if (sender.tag == 102) {
        indicatorStatus = Away;
    }else if (sender.tag == 103) {
        indicatorStatus = Invisible;
    }else if (sender.tag == 104) {
        indicatorStatus = Offline;
    }
  [[NSNotificationCenter defaultCenter] postNotificationName:UpdateIndicators object:indicatorStatus];
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

- (IBAction)btnRemoveController:(UIButton *)sender {
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

@end
