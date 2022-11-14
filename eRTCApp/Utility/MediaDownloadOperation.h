//
//  PhotoDownload.h
//  NSOperationQueueObjC
//
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MediaDownloadOperation : NSOperation

@property NSData *data;
@property (readonly) NSURL *url;


- (instancetype)initWith:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
