//
//  JSQAudioRecorderView.h
//  JSQMessagesViewController
//
//  Created by Apple Inc. on 08/06/19.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class JSQAudioRecorderView;
@protocol JSQAudioRecorderViewDelegate <NSObject>
-(void) jsqAudioRecorderViewDidCancelRecording:(JSQAudioRecorderView *)sender;
-(void) jsqAudioRecorderView:(JSQAudioRecorderView *)sender didFinishRecording:(NSData *)audioData;
-(void) jsqAudioRecorderView:(JSQAudioRecorderView *)sender audioRecorderErrorDidOccur:(NSError *)audioError;

    
@end

@interface JSQAudioRecorderView : UIView<AVAudioRecorderDelegate> {
    NSString *_soundFilePath;
    NSURL *_soundFileURL;
}

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UILabel *slideToCancelLabel;

@property (weak, nonatomic) id<JSQAudioRecorderViewDelegate> jsqARVDelegate;
@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic)  NSTimer *durationTimer;

- (void)startAudioRecording;
- (void)stopAudioRecording ;
-(void) cancelAudioRecording;
@end

