//
//  FileManager.m
//  eRTCApp
//
//  Created by apple on 30/06/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "FileManager.h"

@implementation FileManager

+(NSString*)documentDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}
//CHECK IF FILE ALREADY SAVED
+(BOOL)isFileAlreadySaved:(NSString *)mediaName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [self documentDirectory];
    NSString *writablePath = [documentsDirectory stringByAppendingPathComponent:mediaName];
    
    if([fileManager fileExistsAtPath:writablePath]){
        // file exist
        return YES;
    }
    else {
        // file doesn't exist
        return NO;
    }
}
//SAVE FILE IN DOC DIRECTORY
+(void)saveFile:(NSString *)mediaName withData:(NSData *)data {
    NSString *documentsDirectory = [self documentDirectory];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,mediaName];
    [data writeToFile:filePath atomically:YES];
}

//SAVE FILE URL
+(NSString*)getFileURL:(NSString *)mediaName{
    NSString *documentsDirectory = [self documentDirectory];
    return [NSString stringWithFormat:@"%@/%@", documentsDirectory,mediaName];
  
}
@end
