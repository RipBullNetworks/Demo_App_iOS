//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQFileMediaItem.h"

#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"

@interface JSQFileMediaItem ()


@end


@implementation JSQFileMediaItem

#pragma mark - Initialization

- (instancetype)initWithFileExtension:(NSString *)fileExt
{
    self = [super init];
    if (self) {
        _fileExtension = fileExt;
        _cachedImageView = nil;
    }
    return self;
}

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
    _cachedImageView = nil;
}

#pragma mark - Setters

- (void)setFileExtension:(NSString *)fileExt
{
    _fileExtension = fileExt;
    [self setFileIcon];

}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedImageView = nil;
}

#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView
{
   
    if (self.cachedImageView == nil) {
      //  CGSize size = [self mediaViewDisplaySize];
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(30.0f, 0.0f, 250, 150);
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        
        self.cachedImageView = imageView;
        [self setFileIcon];
    }
    
    return self.cachedImageView;
}

-(void)setFileIcon{
  
    if([[self.fileExtension lowercaseString] isEqualToString:@"pdf"]){
        [self.cachedImageView setImage:[UIImage imageNamed:@"pdf"]];
    }else if([[self.fileExtension lowercaseString] isEqualToString:@"doc"] || [[self.fileExtension lowercaseString] isEqualToString:@"docx"]){
        [self.cachedImageView setImage:[UIImage imageNamed:@"doc"]];

    }else if([[self.fileExtension lowercaseString] isEqualToString:@"xls"] || [[self.fileExtension lowercaseString] isEqualToString:@"xlsx"]){
        [self.cachedImageView setImage:[UIImage imageNamed:@"xls"]];

    }else if([[self.fileExtension lowercaseString] isEqualToString:@"ppt"] || [[self.fileExtension lowercaseString] isEqualToString:@"pptx"]){
        [self.cachedImageView setImage:[UIImage imageNamed:@"ppt"]];
    }else {
        [self.cachedImageView setImage:[UIImage imageNamed:@"txt"]];
    }
}

- (NSUInteger)mediaHash
{
    return self.hash;
}

#pragma mark - NSObject

- (NSUInteger)hash
{
    return super.hash ^ self.fileExtension.hash;
}



#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _fileExtension = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(fileExtension))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.fileExtension forKey:NSStringFromSelector(@selector(fileExtension))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    JSQFileMediaItem *copy = [[JSQFileMediaItem allocWithZone:zone] initWithFileExtension:self.fileExtension];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}

@end
