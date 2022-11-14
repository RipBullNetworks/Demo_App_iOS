//
//  Appshared.h
//  eRTCApp
//
//  Created by apple on 08/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Appshared : NSObject

@property (nonatomic, retain) NSString *someProperty;

+ (id)sharedManager;

@end

NS_ASSUME_NONNULL_END
