//
//  channelGalleryVC.m
//  eRTCApp
//
//  Created by apple on 24/05/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "channelGalleryVC.h"
#import "ChannelGalleryCell.h"
#import "ImageVideoCell.h"
#import <AVFoundation/AVFoundation.h>
#import "GalleryDetailsShareVC.h"
#import <MediaPlayer/MediaPlayer.h>
#import "FileManager.h"
#import "MediaDownloadOperation.h"
#import "ThumbnailDownloader.h"


@interface channelGalleryVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    NSOperationQueue *queue;
    NSInteger numberofPage;
    NSInteger currentPage;
    UIRefreshControl *refreshControl;
}

@end


@implementation channelGalleryVC

#pragma mark :- ViewLifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrGalleyData = [[NSMutableArray alloc] init];
    queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    [_cvGalleryList registerNib:[UINib nibWithNibName:@"ImageVideoCell" bundle:nil] forCellWithReuseIdentifier:@"ImageVideoCell"];
    [_cvGalleryList setDelegate:self];
    [_cvGalleryList setDataSource:self];
    if (_dictGroupInfo.count > 0) {
    [self callApiforGetGalleryData:@"" isDirection:@""];
    }
    self.title = @"Gallery";
    self->numberofPage = 1;
    self->currentPage = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Chat Gallery";
}

#pragma mark :- CollectionViewDelegate&Datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _cvGalleryList.bounds.size.width, _cvGalleryList.bounds.size.height)];
    noDataLabel.textColor        = [UIColor blueColor];
    noDataLabel.textAlignment    = NSTextAlignmentCenter;
    if (self.arrGalleyData.count > 0) {
        noDataLabel.text             = @"";
        _cvGalleryList.backgroundView = noDataLabel;
        return self.arrGalleyData.count;
    }else{
        noDataLabel.text             = @"No Media Exist";
        _cvGalleryList.backgroundView = noDataLabel;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageVideoCell" forIndexPath:indexPath];
    NSDictionary *dict = self.arrGalleyData[indexPath.row];
    
    NSString *msgType = dict[MsgType];
    NSDictionary *dictMedia = dict[@"media"];
    
    NSString *url = NULL;
    NSString *filename;
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
            imgBaseurl = [dictConfig[ChatServerBaseurl] stringByAppendingString:BaseUrlVersion];
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
                if ([msgType isEqualToString:AudioFileName]) {
                [cell.activityIndicator stopAnimating];
                [cell.imgUser setImage:[UIImage imageNamed:@"audioIcon"]];
                [cell.imgMediaType setImage:[UIImage imageNamed:@"audioRecord"]];
                }else if ([msgType isEqualToString:Key_video]){
                [cell.imgUser setImage: [UIImage imageWithData:op.data]];
                [cell.imgMediaType setImage:[UIImage imageNamed:@"videoDefault"]];
                }else if ([msgType isEqualToString:Image]) {
                [cell.imgUser setImage: [UIImage imageWithData:op.data]];
                [cell.imgMediaType setImage:[UIImage imageNamed:@"imageDefoult"]];
                }
                [cell.activityIndicator stopAnimating];
            });
        };
        [queue addOperation:op];
    }else {
        NSString *localFile = [FileManager getFileURL:filename];
        NSData *_data = [NSData dataWithContentsOfFile:[NSURL URLWithString:localFile].path];
        if ([msgType isEqualToString:AudioFileName]) {
        [cell.imgUser setImage:[UIImage imageNamed:@"audioIcon"]];
        [cell.imgMediaType setImage:[UIImage imageNamed:@"audioRecord"]];
        }else if ([msgType isEqualToString:Key_video]){
        [cell.imgUser setImage: [UIImage imageWithData: _data]];
        [cell.imgMediaType setImage:[UIImage imageNamed:@"videoDefault"]];
        }else if ([msgType isEqualToString:Image]) {
        [cell.imgUser setImage: [UIImage imageWithData: _data]];
        [cell.imgMediaType setImage:[UIImage imageNamed:@"imageDefoult"]];
        }
        [cell.activityIndicator stopAnimating];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"indexPath>>>>>>>>>>>>%d",indexPath.row);
    if (currentPage < numberofPage && indexPath.row == _arrGalleyData.count-1) {
        currentPage = numberofPage + 1;
        numberofPage = numberofPage + 1;
        NSDictionary *dict = self.arrGalleyData[indexPath.row];
        NSLog(@"NSDictionary *dict>>>>>>>>>>>>%@",dict);
        if (dict[MsgUniqueId] != nil && dict[MsgUniqueId] != [NSNull null]) {
            NSString *msgUniqId = dict[MsgUniqueId];
            [self callApiforGetGalleryData:msgUniqId isDirection:@"past"];
            NSLog(@"NSDictionary *dict>>>>>>>>>>>>%@",msgUniqId);
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((_cvGalleryList.frame.size.width - 5)/2, 120);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    GalleryDetailsShareVC *galleryVC = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"GroupDetailsVC"];
    galleryVC.dictGalleryInfo = self.arrGalleyData[indexPath.row];
   [self.navigationController pushViewController:galleryVC animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath  {
  
}


-(void)callApiforGetGalleryData:(NSString*)msgUniqId isDirection:(NSString*)direction {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
        NSMutableDictionary *details = @{}.mutableCopy;
        [details setValue:@20 forKey:@"pageSize"];
        [details setValue:@"true" forKey:@"deep"];
        NSLog(@"msgUniqId>>>>>>>>>>%@",msgUniqId);
        
        if ([msgUniqId isEqualToString:@""]) {
        } else {
            [details setValue:msgUniqId forKey:@"currentMsgId"];
            [details setValue:direction forKey:@"direction"];
        }
    
        [[eRTCChatManager sharedChatInstance] chatHistoryGet:_dictGroupInfo[ThreadID] parameters:details.copy
                                                                    andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            [KVNProgress dismiss];
            NSDictionary *dictResponse = (NSDictionary *)json;
            if (dictResponse[Key_Success] != nil) {
                BOOL success = (BOOL)dictResponse[Key_Success];
                if (success) {
                    if ([dictResponse[Key_Result] isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *result = (NSDictionary *)dictResponse[Key_Result];
                        if ([result count]>0){
                            NSArray *arr = result[Key_chats];
                           // numberofPage = currentPage + 1;
                            [self.arrGalleyData addObjectsFromArray:arr];
                            if ([self.arrGalleyData count]>0){
                                self.cvGalleryList.reloadData;
                             }
                        }
                    }
                }
            }
        }andFailure:^(NSError * _Nonnull error) {
            [KVNProgress dismiss];
        }];
        
    }else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
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
