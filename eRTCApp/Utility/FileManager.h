//
//  FileManager.h
//  eRTCApp
//
//  Created by apple on 30/06/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileManager : NSObject
//CHECK IF FILE ALREADY SAVED
+(BOOL)isFileAlreadySaved:(NSString *)mediaName;
//SAVE FILE IN DOC DIRECTORY
+(void)saveFile:(NSString *)mediaName withData:(NSData *)data;
+(NSString*)getFileURL:(NSString *)mediaName;
@end

NS_ASSUME_NONNULL_END
