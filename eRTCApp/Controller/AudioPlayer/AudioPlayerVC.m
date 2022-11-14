//
//  AudioPlayerVC.m
//  eRTCApp
//
//  Created by apple on 12/08/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "AudioPlayerVC.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>

@interface AudioPlayerVC () {

AVAudioPlayer *audioPlayer;
}
@end

@implementation AudioPlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.btnPause.hidden = true;
    NSURL *url = [NSURL URLWithString:self.strUrl];
    NSData *data = [NSData dataWithContentsOfURL:url];
    audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
}


- (IBAction)btnDismiss:(id)sender {
   [self dismissViewControllerAnimated:true completion:nil];
 }

- (IBAction)btnPlay:(id)sender {
    self.btnPlay.hidden = true;
    self.btnPause.hidden = false;
    [audioPlayer play];
}

- (IBAction)btnPause:(id)sender {
    self.btnPause.hidden = true;
    self.btnPlay.hidden = false;
    [audioPlayer pause];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
