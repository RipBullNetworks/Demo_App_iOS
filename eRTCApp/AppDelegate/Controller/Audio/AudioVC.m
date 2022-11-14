//
//  ViewController.m
//  AudioVisualizer
//
//  Created by Diana on 6/28/16.
//  Copyright © 2016 Diana. All rights reserved.
//

#import "AudioVC.h"

#define visualizerAnimationDuration 0.01

@implementation AudioVC
{
    double lowPassReslts;
    double lowPassReslts1;
    NSTimer *visualizerTimer;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initObservers];
    [self initAudioPlayer];
    [self initAudioVisualizer];
}

- (void) didEnterBackground
{
    [self stopAudioVisualizer];
}

- (void) didEnterForeground
{
    if (_playPauseButton.isSelected)
    {
        [self startAudioVisualizer];
    }
}

#pragma mark - Initializations
- (void) initObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void) initAudioPlayer
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self->_strUrl isEqualToString:@""]) {
        }else{
        NSURL *url = [NSURL URLWithString:self->_strUrl];
       // NSURL *soundFileURL = [NSURL fileURLWithPath:self->_strUrl];
        
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:url];
        self->_audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
        [self->_audioPlayer setMeteringEnabled:YES];
    if (error)
    {
        NSLog(@"Error in audioPlayer: %@", [error localizedDescription]);
    }
    else
    {
        self->_audioPlayer.delegate = self;
        [self->_audioPlayer prepareToPlay];
    }}
    });
}

- (void) initAudioVisualizer
{
    CGRect frame = CGRectMake(0, 44, self.view.frame.size.width-20, 200);
    frame.origin.x = 0;
    frame.origin.y = 0;
    UIColor*visualizerColor = [UIColor whiteColor];
    _audioVisualizer = [[AudioVisualizer alloc] initWithBarsNumber:62 frame:frame andColor:visualizerColor];
    [_visualizerView addSubview:_audioVisualizer];
}

#pragma mark -
- (IBAction)playPauseButtonPressed:(id)sender
{
    if (_playPauseButton.isSelected)
    {
        [_audioPlayer pause];
        [_playPauseButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [_playPauseButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateHighlighted];
        [_playPauseButton setSelected:NO];
        [self stopAudioVisualizer];
    }
    else
    {
        [_audioPlayer play];
        [_playPauseButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [_playPauseButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateHighlighted];
        [_playPauseButton setSelected:YES];
        [self startAudioVisualizer];
    }
}

- (void) updateLabels
{
    _currentTimeLabel.text = [self convertSeconds:_audioPlayer.currentTime];
    _remainingTimeLabel.text = [self convertSeconds:_audioPlayer.duration - _audioPlayer.currentTime];
}

- (NSString *)convertSeconds:(float)secs
{
    if (secs != secs || secs < 0.1)
    {
        secs = 0;
    }
    int totalSeconds = (int)secs;
    if (secs - totalSeconds > 0.45)
        totalSeconds++;
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    if(hours > 0)
        return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

- (IBAction)btnDismiss:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
    [_audioVisualizer stopAudioVisualizer];
    [_audioPlayer pause];
}

#pragma mark - Visualizer Methods
- (void) visualizerTimer:(CADisplayLink *)timer
{
    [_audioPlayer updateMeters];
    const double ALPHA = 1.05;
    double averagePowerForChannel = pow(10, (0.05 * [_audioPlayer averagePowerForChannel:0]));
    lowPassReslts = ALPHA * averagePowerForChannel + (1.0 - ALPHA) * lowPassReslts;
    double averagePowerForChannel1 = pow(10, (0.05 * [_audioPlayer averagePowerForChannel:1]));
    lowPassReslts1 = ALPHA * averagePowerForChannel1 + (1.0 - ALPHA) * lowPassReslts1;
    [_audioVisualizer animateAudioVisualizerWithChannel0Level:lowPassReslts andChannel1Level:lowPassReslts1];
    [self updateLabels];
}

- (void) stopAudioVisualizer
{
    [visualizerTimer invalidate];
    visualizerTimer = nil;
    [_audioVisualizer stopAudioVisualizer];
}

- (void) startAudioVisualizer
{
    [visualizerTimer invalidate];
    visualizerTimer = nil;
    visualizerTimer = [NSTimer scheduledTimerWithTimeInterval:visualizerAnimationDuration target:self selector:@selector(visualizerTimer:) userInfo:nil repeats:YES];
}

#pragma mark - Audio Player Delegate Methods
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"audioPlayerDidFinishPlaying");
    [_playPauseButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [_playPauseButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateHighlighted];
    [_playPauseButton setSelected:NO];
    _currentTimeLabel.text = @"00:00";
    _remainingTimeLabel.text = [self convertSeconds:_audioPlayer.duration];
    [self stopAudioVisualizer];
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"audioPlayerDecodeErrorDidOccur");
    [_playPauseButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [_playPauseButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateHighlighted];
    [_playPauseButton setSelected:NO];
    _currentTimeLabel.text = @"00:00";
    _remainingTimeLabel.text = @"00:00";
    [self stopAudioVisualizer];
}

-(void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    NSLog(@"audioPlayerBeginInterruption");
}

-(void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
    NSLog(@"audioPlayerEndInterruption");
}

@end
