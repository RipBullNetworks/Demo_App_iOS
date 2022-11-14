//
//  JSQMessagesInputToolbar+JSQMessagesInputToolbarX.m
//  eRTCApp
//
//  Created by rakesh  palotra on 20/10/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import "JSQMessagesInputToolbar+JSQMessagesInputToolbarX.h"
#import "AudioClickable.h"

@implementation JSQMessagesInputToolbar (JSQMessagesInputToolbarX)

- (void)jsq_rightBarButtonPressed:(UIButton *)sender
{
    if (sender.isSelected) {
        [self.delegate messagesInputToolbar:self didPressRightBarButton:sender];
        
    } else {
        if ([self.delegate conformsToProtocol:@protocol(AudioClickable)]){
            for (UIGestureRecognizer *gr in sender.gestureRecognizers) {
                if ([gr isKindOfClass:UILongPressGestureRecognizer.class]){
                   if ( gr.view.tag != -1) {
                       id<AudioClickable> audioClicable = (id<AudioClickable>)self.delegate;
                       [audioClicable didPressAudioButton];
                       return;
                   }
                }
            }
        }
        sender.tag = 1;
        NSLog(@"audio selected ");
    }
}

@end
