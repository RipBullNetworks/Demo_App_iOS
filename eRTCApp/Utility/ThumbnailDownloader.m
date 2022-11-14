//
//  VideoFileDownloader.m
//  eRTCApp
//
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "ThumbnailDownloader.h"
#import <AVKit/AVKit.h>
@implementation ThumbnailDownloader

- (void)main {
    if ([self isCancelled]) {
      
    }
    AVAsset *asset = [AVAsset assetWithURL: self.url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = [asset duration];
    time.value = 0;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC

    self.data = UIImageJPEGRepresentation(thumbnail,1.0);

}

@end
