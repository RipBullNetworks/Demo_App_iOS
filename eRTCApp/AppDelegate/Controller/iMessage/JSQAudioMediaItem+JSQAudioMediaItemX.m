
//  JSQAudioMediaItem+JSQAudioMediaItemX.m
//  eRTCApp

@import ObjectiveC;
#import "JSQAudioMediaItem+JSQAudioMediaItemX.h"

@implementation JSQAudioMediaItem (JSQAudioMediaItemX)
-(AVAudioPlayer*) gAudioPlayer{
    id player =  [self valueForKey:@"audioPlayer"];
    if ([player isKindOfClass:AVAudioPlayer.class]){
        return player;
    }
    return NULL;
}
-(void) playPause {
    id button =  [self valueForKey:@"playButton"];
    if ([button isKindOfClass:UIButton.class]){
        [button sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}
-(void) play {
    id button =  [self valueForKey:@"playButton"];
    if ([button isKindOfClass:UIButton.class]){
        [button setSelected:TRUE];
//        [button sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}
-(void) pause {
    id button =  [self valueForKey:@"playButton"];
    if ([button isKindOfClass:UIButton.class]){
        AVAudioPlayer *player = [self gAudioPlayer];
        if (player){
            [button setSelected:FALSE];
            [player pause];
        }
       
        
//        [button sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}
@end
