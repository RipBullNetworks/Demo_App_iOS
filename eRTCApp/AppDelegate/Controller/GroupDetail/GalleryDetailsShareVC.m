//
//  GroupDetailsVC.m
//  eRTCApp
//
//  Created by apple on 16/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "GalleryDetailsShareVC.h"
#import "GroupInfoDetailsVC.h"
#import <AVFoundation/AVFoundation.h>
#import "ForwardToViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import "FileManager.h"
#import "MediaDownloadOperation.h"
#import "ThumbnailDownloader.h"
#import "AudioVC.h"

@interface GalleryDetailsShareVC () {
    UIBarButtonItem *ThreeDotBarButtonItem;
    NSString* imgStrUrl;
    NSString* strTitle;
    NSOperationQueue *queue;
    NSString* sharingUrl;
    AVAudioPlayer *audioPlayer;
    NSString *imgBaseurl;
}

@end

@implementation GalleryDetailsShareVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_subViewSocialMediaPopUP setHidden:YES];
    ThreeDotBarButtonItem = [[UIBarButtonItem alloc]
                                   initWithTitle:@"..."
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(DotBtnAction:)];
    queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    self.navigationItem.rightBarButtonItem = ThreeDotBarButtonItem;
   
    [self setRightBarButton];
    if (_dictGalleryInfo[SendereRTCUserId] != nil && _dictGalleryInfo[SendereRTCUserId] != [NSNull null]) {
    [[eRTCChatManager sharedChatInstance] getuserInfoWithERTCId:_dictGalleryInfo[SendereRTCUserId] andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        NSMutableArray *arrUser = [NSMutableArray new];
        arrUser = json;
        if (arrUser.count > 0) {
            self.dictUserDetails = [arrUser objectAtIndex:0];
        }
    } andFailure:^(NSError * _Nonnull error) {
       
    }];
       // [self audioPlayPouse];
}
    self.navigationController.navigationBarHidden = NO;
    [self.navigationItem.backBarButtonItem setTitle:@""];
    self.navigationItem.title = @"Image Details";
    if (@available(iOS 11.0, *)) {
    self.navigationController.navigationBar.prefersLargeTitles = NO;
    } else {
     
    }
    NSDictionary *dictConfig = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
    imgBaseurl = [[NSString alloc] init];
    if ([dictConfig isKindOfClass:[NSDictionary class]]){
        if  (![Helper stringIsNilOrEmpty:dictConfig[ChatServerBaseurl]]) {
            imgBaseurl = [dictConfig[ChatServerBaseurl] stringByAppendingString:BaseUrlVersion];
        }
    }
    [self setGalleryImage];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Image Details";
}

-(void)setGalleryImage {
    [KVNProgress show];
    _dictforward = [[NSMutableDictionary alloc] init];
    NSString *msgType = _dictGalleryInfo[MsgType];
    if ([msgType isEqualToString:Image]){
        _btnPlay.hidden = true;
    }else{
        _btnPlay.hidden = false;
    }
    NSDictionary *dictMedia = _dictGalleryInfo[@"media"];
    NSString *url = NULL;
    NSString *filename;
    BOOL isVideo = [msgType isEqualToString:Key_video];
    url = [NSString stringWithFormat:@"%@",dictMedia[FilePath]];
    filename = [NSString stringWithFormat:@"%@",dictMedia[@"name"]];
    NSString *base = [NSString stringWithFormat:@"%@",imgBaseurl];;
    NSString *fullurl = [NSString stringWithFormat:@"%@%@", base, url];
    NSURL *_url = [NSURL URLWithString:fullurl];
    
    if (![FileManager isFileAlreadySaved:filename]) {
        MediaDownloadOperation *op = [[MediaDownloadOperation alloc] initWith:_url];
        if (isVideo){
            op = [[ThumbnailDownloader alloc] initWith:_url];
        }else if ([msgType isEqualToString:AudioFileName]) {
            op = [[ThumbnailDownloader alloc] initWith:_url];
        }
        op.completionBlock = ^{
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [KVNProgress dismiss];
                [FileManager saveFile:filename withData:op.data];
                if ([msgType isEqualToString:AudioFileName]){
                    [_imgGroupProfile setImage:[UIImage imageNamed:@"audioIcon"]];
                }else{
                    [self->_imgGroupProfile setImage: [UIImage imageWithData:op.data]];
                }
            });

        };
        [queue addOperation:op];
        NSString *localFile = [FileManager getFileURL:filename];
        [_dictforward setValue:localFile forKey:LocalFilePath];
    }else {
        [KVNProgress dismiss];
        NSString *localFile = [FileManager getFileURL:filename];
        NSData *_data = [NSData dataWithContentsOfFile:[NSURL URLWithString:localFile].path];
        [_dictforward setValue:localFile forKey:LocalFilePath];
        if ([msgType isEqualToString:AudioFileName]){
            [_imgGroupProfile setImage:[UIImage imageNamed:@"audioIcon"]];
        }else{
            [_imgGroupProfile setImage: [UIImage imageWithData: _data]];
        }
    }
    
    if ([msgType isEqualToString:AudioFileName]){
        [_dictforward setValue:dictMedia[@"name"] forKey:MediaFileName];
    }else{
        [_dictforward setValue:dictMedia[@"name"] forKey:MediaFileName];
    }
    [_dictforward setValue:_dictGalleryInfo[MsgUniqueId] forKey:MsgUniqueId];
    [_dictforward setValue:_dictGalleryInfo[SendereRTCUserId] forKey:SendereRTCUserId];
    [_dictforward setValue:_dictGalleryInfo[MsgType] forKey:MsgType];
    [_dictforward setValue:_dictGalleryInfo[ThreadID] forKey:ThreadID];
    [_dictforward setValue:_dictGalleryInfo[TenantID] forKey:TenantID];
    
}

-(void)setRightBarButton {
    UIImage* imgDot = [UIImage imageNamed:@"Horiz"];
    CGRect frameimg = CGRectMake(15,5, 25,25);
    UIButton *btnDoted = [[UIButton alloc] initWithFrame:frameimg];
    [btnDoted setBackgroundImage:imgDot forState:UIControlStateNormal];
    [btnDoted addTarget:self action:@selector(btnMoreOptions:)
         forControlEvents:UIControlEventTouchUpInside];
    [btnDoted setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem *btnDotMore =[[UIBarButtonItem alloc] initWithCustomView:btnDoted];
    self.navigationItem.rightBarButtonItem = btnDotMore;
}

-(IBAction)btnMoreOptions:(id)sender{
    UIAlertController *activitySheet = [UIAlertController alertControllerWithTitle:nil
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *first = [UIAlertAction actionWithTitle: @"Forword" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ForwardToViewController *forwardToVc = [[Helper newFeaturesStoryBoard] instantiateViewControllerWithIdentifier:@"ForwardToViewController"];
        forwardToVc.dictMessageDetails = self->_dictforward;
        forwardToVc.threadId = self->_dictGalleryInfo[ThreadID];
        forwardToVc.isGallery = YES;
        forwardToVc.dictUserDetails = [self.dictUserDetails mutableCopy];
        [self.navigationController pushViewController:forwardToVc animated:YES];
         
    }];
    UIAlertAction *library = [UIAlertAction actionWithTitle:NSLocalizedString(@"Share", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *msgType = self->_dictGalleryInfo[MsgType];
        NSString *strUrl;
        if ([msgType isEqualToString:AudioFileName]){
            NSDictionary *dictMedia = self->_dictGalleryInfo[@"media"];
            NSString *imageURL = [NSString stringWithFormat:@"%@",dictMedia[FilePath]];
            strUrl = [imgBaseurl stringByAppendingString:imageURL];
        }else{
            NSDictionary *dictMedia = self->_dictGalleryInfo[@"media"];
            NSString *imageURL = [NSString stringWithFormat:@"%@",dictMedia[FilePath]];
            strUrl = [imgBaseurl stringByAppendingString:imageURL];
        }
        NSArray* dataToShare = @[strUrl];
        UIActivityViewController* activityViewController =[[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
        activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop];
        if (activityViewController == nil){
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:activityViewController animated:YES completion:^{}];
        });

    }];

    UIAlertAction *info = [UIAlertAction actionWithTitle:NSLocalizedString(@"Info", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self pushToInfoVc];
    }];
    [activitySheet addAction:first];
    [activitySheet addAction:library];
    [activitySheet addAction:info];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [activitySheet addAction:cancel];
    [self presentViewController:activitySheet animated:YES completion:nil];
}

- (void)pushToInfoVc {
    GroupInfoDetailsVC *infoVc = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"GroupInfoDetailsVC"];
    infoVc.dictGalleryInfo = self.dictGalleryInfo;
    infoVc.dictUserDetails = self.dictUserDetails;
   [self.navigationController pushViewController:infoVc animated:YES];
}

- (IBAction)btnBackGroundCancelPopUp:(id)sender {
    [_subViewSocialMediaPopUP setHidden:YES];
}

- (IBAction)btnPlay:(id)sender {
   
    NSString *msgType = _dictGalleryInfo[MsgType];
    if (_dictGalleryInfo[typeMedia] != nil && _dictGalleryInfo[typeMedia] != [NSNull null]) {
    NSDictionary *dictMedia = _dictGalleryInfo[typeMedia];
    NSString *imageURL = [NSString stringWithFormat:@"%@",dictMedia[FilePath]];
    NSString *strUrl = [imgBaseurl stringByAppendingString:imageURL];
    NSURL *url = [[NSURL alloc] initWithString:strUrl];
    if ([msgType isEqualToString:AudioFileName]){
        [_imgGroupProfile setImage:[UIImage imageNamed:@"audioIcon"]];
        AudioVC * viewController =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AudioVC"];
        [viewController setModalPresentationStyle:UIModalPresentationFullScreen];
        viewController.strUrl = strUrl;
        [self presentViewController:viewController animated:NO completion:nil];
    }else{
        AVPlayer *player = [AVPlayer playerWithURL:url];
        AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
        [self presentViewController:controller animated:YES completion:nil];
        controller.player = player;
        [player play];
    }
  }
}

- (IBAction)btnInstagram:(UIButton *)sender {
    self->strTitle = @"Instagram";
    [self shareImage:@""];
}

- (IBAction)btnLinkdIn:(UIButton *)sender {
    self->strTitle = @"LinkedIn";
    [self shareImage:@""];
}


- (IBAction)btnTwitter:(UIButton *)sender {
    self->strTitle = @"Twitter";
    [self shareImage:@""];
}


- (IBAction)btnFacebook:(UIButton *)sender {
    self->strTitle = @"Facebook";
    [self shareImage:@""];
}

- (IBAction)btnCancel:(UIButton *)sender {
    [_subViewSocialMediaPopUP setHidden:YES];
}

- (void)shareImage:(NSString *)strType
{
    [_subViewSocialMediaPopUP setHidden:YES];
    NSString *strtitleMsg = [@"Are you sure you want to share this image via " stringByAppendingString:self->strTitle];
     UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Share Image"
                                 message:strtitleMsg
                                 preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* cancel = [UIAlertAction
                                actionWithTitle:@"Cancel"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                    
                                }];
    UIAlertAction* yes = [UIAlertAction
                               actionWithTitle:@"Yes, I’m Sure"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
        [self UrlPostImage];
                               }];

    //Add your buttons to alert controller
    [alert addAction:cancel];
    [alert addAction:yes];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)UrlPostImage
    {
        NSURL *myURL = [NSURL URLWithString:self->imgStrUrl];
        NSData * imageData = [[NSData alloc] initWithContentsOfURL:myURL];
        UIImage *imgShare = [[UIImage alloc] initWithData:imageData];
        NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
        if([[UIApplication sharedApplication] canOpenURL:instagramURL]) //check for App is install or not
        {
            UIImage *imageToUse = imgShare;
            NSString *documentDirectory=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *saveImagePath=[documentDirectory stringByAppendingPathComponent:@"Image.png"];
            NSData *imageData=UIImagePNGRepresentation(imageToUse);
            [imageData writeToFile:saveImagePath atomically:YES];
            NSURL *imageURL=[NSURL fileURLWithPath:saveImagePath];
            self.documentController=[[UIDocumentInteractionController alloc]init];
            self.documentController = [UIDocumentInteractionController interactionControllerWithURL:imageURL];
            self.documentController.delegate = self;
            self.documentController.annotation = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Testing"], @"InstagramCaption", nil];
            self.documentController.UTI = @"com.instagram.exclusivegram";
            UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
            [self.documentController presentOpenInMenuFromRect:CGRectMake(1, 1, 1, 1) inView:vc.view animated:YES];
    }
    else {
        //DisplayAlertWithTitle(@"Instagram not found", @"");
    }
}

-(void)saveImagesInLocalDirectory:(NSString*)imgUrl {
            NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *imgName = @"image.png";
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *writablePath = [documentsDirectoryPath stringByAppendingPathComponent:imgName];
            if(![fileManager fileExistsAtPath:writablePath]){
                // file doesn't exist
                NSLog(@"file doesn't exist");
                    //save Image From URL
                    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString: imgUrl]];
                    NSError *error = nil;
                    [data writeToFile:[documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", imgName]] options:NSAtomicWrite error:&error];

                   if (error) {
                          NSLog(@"Error Writing File : %@",error);
                   }else{
                          NSLog(@"Image %@ Saved SuccessFully",imgName);
                   }
            }
            else{
                // file exist
                NSLog(@"file exist");
            }
}





@end
