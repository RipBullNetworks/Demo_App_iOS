//
//  DocumentManager.h
//  eRTCApp
//
//  Created by rakesh  palotra on 21/04/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DocumentManager : NSObject

+ (id)sharedInstance;

-(BOOL)writeFileWithMediaFolderName:(NSString *)folderName andFileName:(NSString *)fileName andFileData:(NSData *) data;

-(NSString *)getFilePathWithMediaFolderName:(NSString *)folderName andFileName:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
