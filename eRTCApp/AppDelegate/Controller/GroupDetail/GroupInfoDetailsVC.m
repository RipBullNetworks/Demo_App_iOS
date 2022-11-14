//
//  GroupInfoDetailsVC.m
//  eRTCApp
//
//  Created by apple on 16/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "GroupInfoDetailsVC.h"
#import "InfoTableViewCell.h"
#import "FileManager.h"
#import "MediaDownloadOperation.h"
#import "ThumbnailDownloader.h"


@interface GroupInfoDetailsVC ()<UITableViewDelegate,UITableViewDataSource> {
    NSString* imgStrUrl;
    NSString* strTitle;
    NSOperationQueue *queue;
    NSString* sharingUrl;
}

@end

@implementation GroupInfoDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Info";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"";
    [self setInfoData];
    self.imgDetails.layer.cornerRadius = self.imgDetails.frame.size.height/2;
    self.imgDetails.clipsToBounds = true;
    self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.height/2;
    self.imgProfile.clipsToBounds = true;
}

-(void)setInfoData {
    self.lblName.text = [NSString stringWithFormat:@"%@", [_dictUserDetails valueForKey:User_Name]];
     NSString *imgURl = [NSString stringWithFormat:@"%@", [_dictUserDetails valueForKey:User_ProfilePic_Thumb]];
     [_imgProfile sd_setImageWithURL:[NSURL URLWithString:imgURl] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
   
    //Get TimeStamp
    if (_dictGalleryInfo[@"senderTimeStampMs"] != nil && _dictGalleryInfo[@"senderTimeStampMs"] != [NSNull null]) {
        double timeStamp = [[_dictGalleryInfo valueForKey:@"senderTimeStampMs"]doubleValue];
        NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [dateFormatter setDateFormat:@"dd/MM/yyyy-HH:mm a"];
        NSString  *finalate = [dateFormatter stringFromDate:msgdate];
        self.lblDate.text = finalate;
    }
    
        NSDictionary *dictMedia = _dictGalleryInfo[@"media"];
        // Get mediaProfile name
        if (dictMedia[@"name"] != nil && dictMedia[@"name"] != [NSNull null]) {
            self.lblImageName.text = dictMedia[@"name"];
        }
        
    NSString *msgType = _dictGalleryInfo[MsgType];
    NSString *url = NULL;
    NSString *filename;
    BOOL isGif = [msgType isEqualToString:GifyFileName];
    BOOL isVideo = [msgType isEqualToString:Key_video];
    if (isGif) {
        url = [NSString stringWithFormat:@"%@",_dictGalleryInfo[GifyFileName]];
        filename = [NSString stringWithFormat:@"%@.gif", _dictGalleryInfo[@"msgUniqueId"] ];
        self.lblImageName.text = _dictGalleryInfo[MsgType];
    }else if ([msgType isEqualToString:Key_video]){
        url = dictMedia[FilePath];
        filename = [NSString stringWithFormat:@"%@.jpg", _dictGalleryInfo[@"msgUniqueId"]];
        
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
    NSString *base = (isGif) ? @"" : [NSString stringWithFormat:@"%@",imgBaseurl];
    NSString *fullurl = [NSString stringWithFormat:@"%@%@", base, url];
    NSURL *_url = [NSURL URLWithString:fullurl];
    //Get Image Url Size
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Download IMAGE using URL
        NSData *data = [[NSData alloc]initWithContentsOfURL:_url];
        // COMPOSE IMAGE FROM NSData
        UIImage *image = [[UIImage alloc]initWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            // UI UPDATION ON MAIN THREAD
            // Calcualte height & width of image
            CGFloat height = image.size.height;
            CGFloat width = image.size.width;
            NSString *imageSize = [NSString stringWithFormat:@"%.f%@%.f", width,@" x ", height];
            if ([msgType isEqualToString:Key_video]){
                self.lblImageSize.text = @"800 X 800";
            }else{
                self.lblImageSize.text = imageSize;
            }
        });
    });

    
    
    if (![FileManager isFileAlreadySaved:filename]) {
        MediaDownloadOperation *op = [[MediaDownloadOperation alloc] initWith:_url];
        if (isVideo){
            op = [[ThumbnailDownloader alloc] initWith:_url];
        }
       // [cell.activityIndicator startAnimating];
        op.completionBlock = ^{
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [FileManager saveFile:filename withData:op.data];
                if (isGif){
                    [_imgDetails sd_setImageWithURL:_dictGalleryInfo[GifyFileName] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
                   // [_imgGroupProfile setImage: [UIImage imageWithData:op.data]];
                }else {
                    [_imgDetails setImage: [UIImage imageWithData:op.data]];
                }
            });

        };
        [queue addOperation:op];
    }else {
        NSString *localFile = [FileManager getFileURL:filename];
        NSData *_data = [NSData dataWithContentsOfFile:[NSURL URLWithString:localFile].path];
        if (isGif){
        [_imgDetails sd_setImageWithURL:_dictGalleryInfo[GifyFileName] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
        }else {
            [_imgDetails setImage: [UIImage imageWithData: _data]];
        }
    }
    

    
   // NSString *imageURL = [NSString stringWithFormat:@"%@",dictMedia[FilePath]];
   // NSString *strUrl = [imageBaseUrl stringByAppendingString:imageURL];
    //[_imgDetails sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
}


/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InfoTableViewCell"];
    return cell;
}*/



@end
