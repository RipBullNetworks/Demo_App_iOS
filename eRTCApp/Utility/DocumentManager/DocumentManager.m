//
//  DocumentManager.m
//  eRTCApp
//
//  Created by rakesh  palotra on 21/04/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import "DocumentManager.h"

@implementation DocumentManager

+ (id)sharedInstance {
    static dispatch_once_t once;
    static DocumentManager *instance;
    dispatch_once(&once, ^{
        instance = [[DocumentManager alloc] init];
    });
    return instance;
}

-(NSString *)documentsDirectory {
    NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

-(BOOL)writeFileWithMediaFolderName:(NSString *)folderName  andFileName:(NSString *)fileName andFileData:(NSData *) data {
   // NSString *path = [self pathOfFile:@"media"];
    NSString *path = [NSString stringWithFormat:@"%@/%@",[self groupPath],@"media"];
    NSString *chatPath= [NSString stringWithFormat:@"%@/%@",path,folderName];
    if (![self isFolderExist:chatPath]){
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:chatPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    NSString *filePath= [NSString stringWithFormat:@"%@/%@",chatPath,fileName];
    
    NSError * err = nil;
    
    if ([data writeToFile:filePath options:NSDataWritingAtomic error:&err]){
        [self addSkipBackupAttributeToItemAtPath:filePath];
        NSLog(@"write success at path %@",filePath);
        return YES;
    }
    
    return NO;
}

-(NSString *)getFilePathWithMediaFolderName:(NSString *)folderName  andFileName:(NSString *)fileName {
   // NSString *path = [self pathOfFile:@"media"];
    NSString *path = [NSString stringWithFormat:@"%@/%@",[self groupPath],@"media"];
    NSString *chatPath= [NSString stringWithFormat:@"%@/%@",path,folderName];
    if (![self isFolderExist:chatPath]){
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:chatPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    NSString *filePath= [NSString stringWithFormat:@"%@/%@",chatPath,fileName];
    
    NSLog(@"get file at path %@",filePath);
    
    return filePath;
}

-(BOOL)isFolderExist:(NSString *)filePath {
    BOOL isDir;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
    
    if (fileExists && isDir)
        return YES;
    
    return NO;
}

-(NSString *)pathOfFile:(NSString *)fileName {
    NSString *filePath= [[NSString alloc] initWithFormat:@"%@/%@", [self documentsDirectory],fileName];
    return filePath;
}

-(NSString *)groupPath{
    NSString *strMainAppId = [[NSUserDefaults standardUserDefaults] valueForKey:@"appBundleIdentifire"];
    NSString *groupUserID = [NSString stringWithFormat:@"group.%@",strMainAppId];
     NSString *appGroupDirectoryPath = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupUserID].path;

    return appGroupDirectoryPath;
}

-(BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePathString {
    NSURL *fileURL = [NSURL fileURLWithPath:filePathString];
    
    assert([[NSFileManager defaultManager] fileExistsAtPath: [fileURL path]]);
    
    NSError *error = nil;
    
    BOOL success = [fileURL setResourceValue:[NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey
                                       error: &error];
    return success;
}

@end
