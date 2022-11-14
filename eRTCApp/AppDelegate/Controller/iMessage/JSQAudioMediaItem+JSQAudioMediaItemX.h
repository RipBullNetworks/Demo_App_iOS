//
//  JSQAudioMediaItem+JSQAudioMediaItemX.h
//  eRTCApp
//
//  Created by jayant patidar on 25/11/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>
#import <JSQMessagesViewController/JSQAudioMediaItem.h>

NS_ASSUME_NONNULL_BEGIN

@interface JSQAudioMediaItem (JSQAudioMediaItemX)
-(AVAudioPlayer*) gAudioPlayer;
-(void) playPause;
-(void) play;
-(void) pause;
@end

NS_ASSUME_NONNULL_END
