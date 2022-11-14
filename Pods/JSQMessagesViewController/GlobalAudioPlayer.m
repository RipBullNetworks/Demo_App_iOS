//
//  GlobalAudioPlayer.m
//  abseil
//
//  Created by Apple on 07/10/20.
//

#import "GlobalAudioPlayer.h"


@implementation GlobalAudioPlayer
+ (GlobalAudioPlayer *)sharePlayer {
    static GlobalAudioPlayer *sharedClass = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClass = [[self alloc] init];
    });
    return sharedClass;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}
@end
