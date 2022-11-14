//
//  GlobalAudioPlayer.h
//  abseil
//
//  Created by Apple on 07/10/20.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GlobalAudioPlayer : NSObject
+ (GlobalAudioPlayer *)sharePlayer;
@property (strong, nonatomic) AVAudioPlayer *gAudioPlayer;

@end

NS_ASSUME_NONNULL_END
