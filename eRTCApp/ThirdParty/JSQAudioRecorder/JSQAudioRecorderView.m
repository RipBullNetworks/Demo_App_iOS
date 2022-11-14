//
//  JSQAudioRecorder.m
//  JSQMessagesViewController
//
//  Created by Apple Inc. on 08/06/19.
//

#import "JSQAudioRecorderView.h"

@implementation JSQAudioRecorderView
- (void)jsq_configureAudioRecorderView
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    CGFloat cornerRadius = 6.0f;
    
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.cornerRadius = cornerRadius;
    
    self.userInteractionEnabled = YES;
    
    self.timerLabel.font = [UIFont systemFontOfSize:14.0f];
    self.timerLabel.textColor = [UIColor redColor];
    self.timerLabel.textAlignment = NSTextAlignmentNatural;
    
    
   // [self.slideToCancelLabel setTextAlignment:NSTextAlignmentRight];
  //  [self.slideToCancelLabel setBackgroundColor:[UIColor clearColor]];
    //[self.slideToCancelLabel setText:@"<<< Slide to cancel"];
    //[self.slideToCancelLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [self.slideToCancelLabel setTextColor:[UIColor lightGrayColor]];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"JSQAudioRecorderView" owner:self options:nil] firstObject];
        [view setFrame:self.bounds];
        [self addSubview:view];
        [self jsq_configureAudioRecorderView];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self jsq_configureAudioRecorderView];
}

- (void)setAudioRerorder {
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
     _soundFilePath = [docsDir stringByAppendingPathComponent:@"sound.aac"];
       
       _soundFileURL = [NSURL fileURLWithPath:_soundFilePath];
       NSDictionary *recordSettings = [NSDictionary
                                       dictionaryWithObjectsAndKeys:
                                       @(AVAudioQualityHigh),
                                       AVEncoderAudioQualityKey,
                                       @(1),
                                       AVNumberOfChannelsKey,
                                       @(12000),
                                       AVSampleRateKey,
                                       @(kAudioFormatMPEG4AAC),
                                       AVFormatIDKey,
                                       nil];
    
    NSError *error = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                        error:nil];
    
    _audioRecorder = [[AVAudioRecorder alloc]
                      initWithURL:_soundFileURL
                      settings:recordSettings
                      error:&error];
    _audioRecorder.delegate = self;
    if (error)
    {
    } else {
        [_audioRecorder prepareToRecord];
    }
}

- (void)startAudioRecording {
    [self setAudioRerorder];
    if (!_audioRecorder.recording)
    {
        [_audioRecorder record];
        self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(startDurationTimer) userInfo:nil repeats:YES];
    }
}

- (void)stopAudioRecording {
    if (_audioRecorder.recording)
    {
        [_audioRecorder stop];
        [self stopDurationTimer];
    }
}

- (void)deleteAudioRecording {
    
    if (_audioRecorder)
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:_soundFilePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:_soundFilePath error:nil];
        }
    }
}

-(void) startDurationTimer{
    int timer = _audioRecorder.currentTime;
    NSLog(@"timer >>>>>>>>>>>>>>%d",timer);
    int sec, min = 0;
    int minutes = (_audioRecorder.currentTime/60);
    int seconds = (timer - (minutes * 60));
    NSLog(@"seconds >>>>>>>>>>>>>>%d",seconds);
   // min = timer/60;
   // sec = timer%60;
    
    [self.timerLabel setText:[NSString stringWithFormat:@"%02d:%02d", minutes,seconds]];
}

-(void) stopDurationTimer{
    if (_durationTimer != nil) {
        [_durationTimer invalidate];
        [self.timerLabel setText:@""];
    }
}

-(void) cancelAudioRecording{
    [self stopAudioRecording];
    [self deleteAudioRecording];
    if ([self.jsqARVDelegate respondsToSelector:@selector(jsqAudioRecorderViewDidCancelRecording:)]) {
        [self.jsqARVDelegate jsqAudioRecorderViewDidCancelRecording:self];
    }
}

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder
                          successfully:(BOOL)flag {
    
    if ([self.jsqARVDelegate respondsToSelector:@selector(jsqAudioRecorderView:didFinishRecording:)] && flag) {
        if ([NSData dataWithContentsOfURL:recorder.url] != nil) {
            [self.jsqARVDelegate jsqAudioRecorderView:self didFinishRecording:[NSData dataWithContentsOfURL:recorder.url]];
            NSLog(@"dataWithContentsOfURL >>>>>>>>>>>>>>>%d",recorder.currentTime);
        }
    }
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder
                                  error:(NSError *)error {
    if ([self.jsqARVDelegate respondsToSelector:@selector(jsqAudioRecorderView:audioRecorderErrorDidOccur:)]) {
        [self.jsqARVDelegate jsqAudioRecorderView:self audioRecorderErrorDidOccur:error];
    }
}

@end
