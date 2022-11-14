//
//  Appshared.m
//  eRTCApp
//
//  Created by apple on 08/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "Appshared.h"

@implementation Appshared

@synthesize someProperty;

+ (id)sharedManager {
    static Appshared *keyPublic = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keyPublic = [[self alloc] init];
    });
    return keyPublic;
}

@end
