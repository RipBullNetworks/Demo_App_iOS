//
//  PhotoDownload.m
//  NSOperationQueueObjC
//
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "MediaDownloadOperation.h"

@interface MediaDownloadOperation (){
    NSURL *_url;
}

@end

@implementation MediaDownloadOperation
 
-(NSURL *)url {
    return _url;
}
-(instancetype)initWith:(NSURL *)url
{
    self = [super init];
    if (self) {
        _url = url;
    }
    return self;
}

- (void)main {
    if ([self isCancelled]) {
      
    }
    self.data = [NSData dataWithContentsOfURL: _url];
}

@end
