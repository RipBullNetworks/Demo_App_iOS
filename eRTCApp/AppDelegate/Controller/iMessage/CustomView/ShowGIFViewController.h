//
//  ShowGIFViewController.h
//  eRTCApp
//
//  Created by jayant patidar on 23/11/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^Callback)(void);

@interface ShowGIFViewController : UIViewController
- (instancetype)initWithURL: (NSURL*)url didSelect: (void (^)(void)) didSelect  didCancel: (void (^)(void)) didCancel;
@end

NS_ASSUME_NONNULL_END
