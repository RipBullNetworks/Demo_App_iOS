//
//  AudioPlayerVC.h
//  eRTCApp
//
//  Created by apple on 12/08/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioPlayerVC : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *btnPause;
@property (nonatomic, strong) NSString *strUrl;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;

@end

NS_ASSUME_NONNULL_END
