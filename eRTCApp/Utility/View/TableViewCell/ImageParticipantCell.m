//
//  ImageParticipantCell.m
//  eRTCApp
//
//  Created by apple on 15/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "ImageParticipantCell.h"
#import "ImageVideoCell.h"
#import <AVFoundation/AVFoundation.h>
#import "GalleryDetailsShareVC.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import "FileManager.h"
#import "MediaDownloadOperation.h"
#import "ThumbnailDownloader.h"



@interface ImageParticipantCell () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout> {
    NSOperationQueue *queue;
}
@end

@implementation ImageParticipantCell


- (void)awakeFromNib {
    [self setupCollectionView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setupCollectionView {
    [_cvVideoImageList registerNib:[UINib nibWithNibName:@"ImageVideoCell" bundle:nil] forCellWithReuseIdentifier:@"ImageVideoCell"];
    [_cvVideoImageList setDelegate:self];
    [_cvVideoImageList setDataSource:self];
   //
   // [_cvVideoImageList isScrollEnabled];
}

-(void)getGalleryData:(NSMutableArray *)arrData {
    if (arrData.count > 0){
    self.arrGallerycollectionData = arrData;
    }else{
        self.arrGallerycollectionData = arrData;
    }
    [_cvVideoImageList reloadData];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _cvVideoImageList.bounds.size.width, _cvVideoImageList.bounds.size.height)];
    noDataLabel.textColor        = [UIColor blueColor];
    noDataLabel.textAlignment    = NSTextAlignmentCenter;
    if (self.arrGallerycollectionData.count > 0) {
        noDataLabel.text             = @"";
        _cvVideoImageList.backgroundView = noDataLabel;
        return self.arrGallerycollectionData.count;
    }else{
        noDataLabel.text             = @"No Media Exist";
        _cvVideoImageList.backgroundView = noDataLabel;
    }
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageVideoCell" forIndexPath:indexPath];
    NSDictionary *dict = self.arrGallerycollectionData[indexPath.row];
    
    NSString *msgType = dict[MsgType];
    NSDictionary *dictMedia = dict[@"media"];
    NSString *url = NULL;
    NSString *filename;
    NSData *imgProfile;
    BOOL isVideo = [msgType isEqualToString:Key_video];
    if ([msgType isEqualToString:AudioFileName]) {
        url = [NSString stringWithFormat:@"%@",dict[AudioFileName]];
        filename = [NSString stringWithFormat:@"%@.gif", dict[@"msgUniqueId"]];
        [cell.activityIndicator stopAnimating];
    }else if ([msgType isEqualToString:Key_video]){
        url = dictMedia[FilePath];
        filename = [NSString stringWithFormat:@"%@.jpg", dict[@"msgUniqueId"]];
    }else {
        url = [NSString stringWithFormat:@"%@",dictMedia[Thumbnail]];
        filename = [NSString stringWithFormat:@"%@",dictMedia[@"name"]];
    }
    
    NSDictionary *dictConfig = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
    NSString *imgBaseurl;
    if ([dictConfig isKindOfClass:[NSDictionary class]]){
        if  (![Helper stringIsNilOrEmpty:dictConfig[ChatServerBaseurl]]) {
            imgBaseurl = [dictConfig[ChatServerBaseurl] stringByAppendingString:@"v1/"];
        }
    }
    NSString *fullurl = [NSString stringWithFormat:@"%@%@", imgBaseurl, url];
    
    NSURL *_url = [NSURL URLWithString:fullurl];
    if (![FileManager isFileAlreadySaved:filename]) {
        MediaDownloadOperation *op = [[MediaDownloadOperation alloc] initWith:_url];
        if (isVideo){
            op = [[ThumbnailDownloader alloc] initWith:_url];
        }
        [cell.activityIndicator startAnimating];
        op.completionBlock = ^{
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [FileManager saveFile:filename withData:op.data];
                if ([dict[MsgType] isEqualToString:@"audio"]) {
                [cell.activityIndicator stopAnimating];
                [cell.imgUser setImage:[UIImage imageNamed:@"audioIcon"]];
                [cell.imgMediaType setImage:[UIImage imageNamed:@"audioRecord"]];
                }else if ([dict[MsgType] isEqualToString:Key_video]){
                [cell.imgUser setImage: [UIImage imageWithData:op.data]];
                [cell.imgMediaType setImage:[UIImage imageNamed:@"videoDefault"]];
                }else if ([dict[MsgType] isEqualToString:Image]) {
                [cell.imgUser setImage: [UIImage imageWithData:op.data]];
                [cell.imgMediaType setImage:[UIImage imageNamed:@"imageDefoult"]];
                }
                [cell.activityIndicator stopAnimating];
            });
        };
        [queue addOperation:op];
    }else {
        [cell.activityIndicator stopAnimating];
        NSString *localFile = [FileManager getFileURL:filename];
        NSData *_data = [NSData dataWithContentsOfFile:[NSURL URLWithString:localFile].path];
        if ([dict[MsgType] isEqualToString:@"audio"]) {
        [cell.activityIndicator stopAnimating];
        [cell.imgUser setImage:[UIImage imageNamed:@"audioIcon"]];
        [cell.imgMediaType setImage:[UIImage imageNamed:@"audioRecord"]];
        }else if ([dict[MsgType] isEqualToString:Key_video]){
        [cell.imgUser setImage: [UIImage imageWithData: _data]];
        [cell.imgMediaType setImage:[UIImage imageNamed:@"videoDefault"]];
        }else if ([dict[MsgType] isEqualToString:Image]) {
        [cell.imgUser setImage: [UIImage imageWithData: _data]];
        [cell.imgMediaType setImage:[UIImage imageNamed:@"imageDefoult"]];
        }
        
    }
    if ([dict[MsgType] isEqualToString:@"audio"]) {
        [cell.imgUser setImage:[UIImage imageNamed:@"audioIcon"]];
        [cell.imgMediaType setImage:[UIImage imageNamed:@"audioRecord"]];
        [cell.activityIndicator stopAnimating];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((_cvVideoImageList.bounds.size.width)/4, 80);
}

//- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath  {
//    //NSMutableDictionary *dict = self.arrGallerycollectionData[indexPath.row];
//    //[self.delegate selectedImageIndex:self selectDict:dict];
//   // if (self.completion != nil) { self.completion(dict);}
//}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
        NSMutableDictionary *dict = self.arrGallerycollectionData[indexPath.row];
        [self.delegate selectedImageIndex:self selectDict:dict];
        //if (self.completion != nil) { self.completion(dict);}
}

-(UIImage *)loadThumbNail:(NSURL *)urlVideo
{
    UIImage *imageReduced;
    AVAsset *avAsset = [AVURLAsset URLAssetWithURL:urlVideo options:nil];
            if ([[avAsset tracksWithMediaType:AVMediaTypeVideo] count] > 0)
            {
                AVAssetImageGenerator *imageGenerator =[AVAssetImageGenerator assetImageGeneratorWithAsset:avAsset];
                Float64 durationSeconds = CMTimeGetSeconds([avAsset duration]);
                CMTime midpoint = CMTimeMakeWithSeconds(durationSeconds/2.0, 600);
                NSError *error;
                CMTime actualTime;
                CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:&actualTime error:&error];
                if (halfWayImage != NULL)
                {
                    NSString *actualTimeString = (NSString *)CFBridgingRelease(CMTimeCopyDescription(NULL, actualTime));
                    NSString *requestedTimeString = (NSString *)CFBridgingRelease(CMTimeCopyDescription(NULL, midpoint));
                    NSLog(@"Got halfWayImage: Asked for %@, got %@", requestedTimeString, actualTimeString);

                }
                imageReduced = [UIImage imageWithCGImage:halfWayImage];
             }
    return imageReduced;
 }




@end
