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

#import "JSQLinkPreviewMediaItem.h"
#import <LinkPresentation/LinkPresentation.h>
#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"
#import <MediaPlayer/MediaPlayer.h>
#import "FileManager.h"
#import "MediaDownloadOperation.h"
#import "ThumbnailDownloader.h"

@interface JSQLinkPreviewMediaItem (){
    NSDictionary *_details;
    LinkPreviewCompletion _completion;
    NSString *desc;
    NSString *_text;
    UIImageView *imageView;
    NSOperationQueue *queue;
}


@end


@implementation JSQLinkPreviewMediaItem

#pragma mark - Initialization

- (instancetype)initWithURL:(NSURL *)url details:(NSDictionary*) details completionHandler:(LinkPreviewCompletion)completionHandler
{
    
    NSArray *emojis = [[eRTCCoreDataManager sharedInstance] convertDataIntoObjectWith:details[@"reaction"]];
   
    self = [super init];
    if (self) {
        _url = url;
        _details = details;
        _isDataLoaded = FALSE;
//        _cachedImageView = nil;
        _imageData = nil;
        _completion = completionHandler;

        [self downloadData];
       
    }
    return self;
    
}

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
//    _cachedImageView = nil;
}

#pragma mark - Setters

-(void)downloadData {
    if (@available(iOS 13.0, *)) {
        LPMetadataProvider *metadataProvider = [LPMetadataProvider new];
        [metadataProvider startFetchingMetadataForURL:_url completionHandler:^(LPLinkMetadata * _Nullable metadata, NSError * _Nullable error) {
            if (!error){
                self->desc = [metadata title];
                if ([metadata imageProvider] != NULL){
                    [[metadata imageProvider] loadItemForTypeIdentifier:@"public.png" options:nil completionHandler:^(__kindof id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                        NSLog(@"URL PREVIEW: %@",item);
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
                                       ^{
                            //This is your completion handler
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                self.imageData = item;
                                self->_isDataLoaded = TRUE;
                                self->_completion(self->_details, NULL);
                            });
                        });
                    }];
                }
            }
        }];
    } else {
        // Fallback on earlier versions
    };
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
//    _cachedImageView = nil;
}

- (CGSize)mediaViewDisplaySize
{
    if (_isDataLoaded) {
        return CGSizeMake(280.0f, (180.0f + [Helper requiredHeight: _details[Message]]));
    }
    return CGSizeMake(280.0f, (25.0f + [Helper requiredHeight: _details[Message]]));;
}

-(NSAttributedString*)getAttributedText {
    NSMutableAttributedString *nsAS =  [[NSMutableAttributedString alloc] initWithString:_url.absoluteString];
    if (_details != NULL && _details[Message] != NULL && [_details[Message] length] > 0){
        nsAS =  [[NSMutableAttributedString alloc] initWithString:_details[Message]];
//        NSRange range = [_details[Message] rangeOfString:_url.absoluteString];
//        [nsAS addAttributes:@{ NSForegroundColorAttributeName:[UIColor grayColor]} range:range];
        NSError *error = NULL;
        NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
        NSArray *matches = [detector matchesInString:nsAS.string
                                             options:0
                                               range:NSMakeRange(0, [nsAS.string length])];
        
        for (NSTextCheckingResult *match in matches) {
            if ([match resultType] == NSTextCheckingTypeLink) {
                NSURL *url = [match URL];
                NSRange strRange = [nsAS.string rangeOfString:url.absoluteString];
                NSRange wordRange = [match rangeAtIndex:0];
                if (wordRange.location != NSNotFound){
                    [nsAS addAttributes:@{NSForegroundColorAttributeName: [UIColor systemBlueColor]} range:wordRange];
                }else {
                    NSString *urlWithoutHttp = url.absoluteString;
                    urlWithoutHttp = [urlWithoutHttp stringByReplacingOccurrencesOfString:@"https://" withString:@""];
                    urlWithoutHttp = [urlWithoutHttp stringByReplacingOccurrencesOfString:@"http://" withString:@""];
                     strRange = [nsAS.string rangeOfString:urlWithoutHttp.copy];
                    if (strRange.location != NSNotFound){
                        [nsAS addAttributes:@{NSForegroundColorAttributeName: [UIColor systemBlueColor],
                                             NSFontAttributeName: [UIFont fontWithName:@"SFProDisplay-bold" size:14]
                        } range:strRange];
                    }
                }
            }
        }

        return nsAS.copy;
    }

    return nsAS.copy;
}

-(NSString*)getText {
    if (_text == NULL){
        _text =  _url.absoluteString;
        if (_details != NULL && _details[Message] != NULL && [_details[Message] length] > 0){
        _text = _details[Message];
        }
    }
    
    
    return _text;
}
#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView
{
    
    [UIView setAnimationsEnabled:NO];
    CGSize size = [self mediaViewDisplaySize];
    [UIImageView setAnimationsEnabled:false];
    UIFont *font = [UIFont fontWithName:@"SFProDisplay-Regular" size:14];
    CGRect frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIEdgeInsets labelInset =  UIEdgeInsetsMake(0, 12, 0, 12);
    NSAttributedString *text = [self getAttributedText];
    if (!_isDataLoaded) {
        UITextView *label = [UITextView new];
        label.frame = frame;
        label.attributedText = text;
        label.font = font;
        label.editable = FALSE;
//        label.backgroundColor = [UIColor grayColor];
        label.contentInset = labelInset;
        UIActivityIndicatorView *av = [UIActivityIndicatorView new];
       
        //[av startAnimating];
        
        CGPoint center = label.center;
        center.y -= 10;
        
        av.center = center;
        [label addSubview:av];
        
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:label isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        return label;
    }
    
    
    UIView *containerView = [UIView new];
    containerView.clipsToBounds = YES;
    containerView.frame = frame;
    CGFloat lableHeight = [Helper requiredHeight: _details[Message]];
    CGFloat imageHeight = frame.size.height - (lableHeight + 20);
    CGRect imageFrame = frame;
    imageFrame.size.height = imageHeight;
    
//    NSString *filename = _details[MsgUniqueId];
//    if (![FileManager isFileAlreadySaved:filename]) {
//            dispatch_async(dispatch_get_main_queue(), ^(void){
//                imageView = [[UIImageView alloc] init];
//                [FileManager saveFile:filename withData:self.imageData];
//                [imageView setImage:[UIImage imageWithData:self.imageData]];
//            });
//    }else {
//        NSString *localFile = [FileManager getFileURL:filename];
//        NSData *_data = [NSData dataWithContentsOfFile:[NSURL URLWithString:localFile].path];
//        [imageView setImage:[UIImage imageWithData:_data]];
//    }

    imageView = [[UIImageView alloc] init];
    
    [imageView setImage:[UIImage imageWithData:self.imageData]];
    imageView.frame = imageFrame;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    
    imageFrame.size.height = lableHeight;
    imageFrame.origin.y = imageHeight;
    UITextView *label = [UITextView new];
    label.frame = imageFrame;
    if (desc){
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ -", desc]];
        [str appendAttributedString:text.copy];
        NSError *error = NULL;
        NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
        NSArray *matches = [detector matchesInString:str.string
                                             options:0
                                               range:NSMakeRange(0, [str.string length])];
        for (NSTextCheckingResult *match in matches) {
            if ([match resultType] == NSTextCheckingTypeLink) {
                NSURL *url = [match URL];
                NSRange strRange = [str.string rangeOfString:url.absoluteString];
                if (strRange.location != NSNotFound){
                    [str addAttributes:@{NSForegroundColorAttributeName: [UIColor systemBlueColor]} range:strRange];
                }else {
                    NSString *urlWithoutHttp = url.absoluteString;
                    urlWithoutHttp = [urlWithoutHttp stringByReplacingOccurrencesOfString:@"https://" withString:@""];
                    urlWithoutHttp = [urlWithoutHttp stringByReplacingOccurrencesOfString:@"http://" withString:@""];
                     strRange = [str.string rangeOfString:urlWithoutHttp.copy];
                    if (strRange.location != NSNotFound){
                        [str addAttributes:@{NSForegroundColorAttributeName: [UIColor systemBlueColor],
                                             NSFontAttributeName: [UIFont fontWithName:@"SFProDisplay-bold" size:14]
                        } range:strRange];
                    }
                }
            }
        }
        text = str;
    }
    label.textContainer.maximumNumberOfLines = 10;
    label.attributedText = text;
//    label.textColor = [UIColor systemBlueColor];
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    label.editable = FALSE;
    label.contentInset = labelInset;
    [containerView addSubview:imageView];
    [containerView addSubview:label];
//    containerView.backgroundColor = [UIColor redColor];

        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:containerView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
//        self.cachedImageView = imageView;
//    }
    
    return containerView;
}
- (NSUInteger)mediaHash
{
    return self.hash;
}

#pragma mark - NSObject

- (NSUInteger)hash
{
    return super.hash ^ _url.hash;
}

#pragma mark - NSCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _url = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(imageData))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.url forKey:NSStringFromSelector(@selector(url))];
}

#pragma mark - NSCopying
- (instancetype)copyWithZone:(NSZone *)zone
{
    JSQLinkPreviewMediaItem *copy = [[JSQLinkPreviewMediaItem allocWithZone:zone] initWithURL:_url details:_details completionHandler:_completion];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}




@end
