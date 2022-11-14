//
//  EditChannelInfo.m
//  eRTCApp
//
//  Created by apple on 20/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "EditChannelInfo.h"
#import "tbleditInfoChannelCell.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Toast/Toast.h>
#import <AVFoundation/AVFoundation.h>
#import "EditGroupSubjectViewController.h"
#import "EditGroupDescriptionViewController.h"

@interface EditChannelInfo ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    UIBarButtonItem *SaveBarButtonItem;
    __weak IBOutlet UILabel                   *_lblNavTitle;
    __weak IBOutlet UIView                    *_viewNavTitle;
    BOOL                                       _isImageSet;
}

@end

@implementation EditChannelInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Edit Channel Info";
//    if (@available(iOS 11.0, *)) {
//        self.navigationController.navigationBar.prefersLargeTitles = NO;
//
//    } else {
//        // Fallback on earlier versions
//    }
    SaveBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(SavebtnAction:)];
    self.navigationItem.rightBarButtonItem=SaveBarButtonItem;
    
}

-(void)viewWillDisappear:(BOOL)animated{
[super viewWillDisappear:animated];
[self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Edit Channel Info";
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.width/2;
    self.imgProfile.clipsToBounds = true;
    [self setChannelData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
}

-(void)setChannelData{
    if (self.dictEditInfo[@"name"]) {
      self.lblGroupName.text = [NSString stringWithFormat:@"%@",self.dictEditInfo[@"name"]];
    }
    if (self.dictEditInfo[@"description"]) {
      self.lblDescription.text = [NSString stringWithFormat:@"%@",self.dictEditInfo[@"description"]];
    }
    if (self.dictEditInfo[User_ProfilePic_Thumb] != nil && self.dictEditInfo[User_ProfilePic_Thumb] != [NSNull null]) {
        NSString *imageURL = [NSString stringWithFormat:@"%@",self.dictEditInfo[User_ProfilePic_Thumb]];
        [_imgProfile sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
        _isImageSet = YES;
    } else {
        [_imgProfile setImage:[UIImage imageNamed:@"DefaultUserIcon"]];
        _isImageSet = NO;
        //[self->_imgProfile setImage:nil];
    }
    self.navigationItem.title = @"Edit Channel Info";
    
}

- (void)setupNavigationBar {
    [_lblNavTitle setFont:[UIFont fontWithName:@"SFProDisplay-Medium" size:18]];
    [self.navigationItem setTitleView:_viewNavTitle];
    [_lblNavTitle setText:NSLocalizedString(@"Channel Details", nil)];
}


- (IBAction)btnEditProfile:(UIButton *)sender {
    UIAlertController *activitySheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Media messages", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *camera = [UIAlertAction actionWithTitle:NSLocalizedString(@"Camera", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self takeImageFromCamera];
    }];
    UIAlertAction *library = [UIAlertAction actionWithTitle:NSLocalizedString(@"Photo Library", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self takeImageFromLibrary];
    }];
    [activitySheet addAction:camera];
    [activitySheet addAction:library];
    
    if (_isImageSet) {
        UIAlertAction *delete = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            //[self->_btnCamera setSelected:self->_isImageSet];
            [self removeGroupProfile];
        }];
        [activitySheet addAction:delete];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [activitySheet addAction:cancel];
    [self presentViewController:activitySheet animated:YES completion:nil];
    
}

-(IBAction)SavebtnAction:(id)sender{
  //  [self callAPIForUpdateGroupInfo];
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)btnGroupName:(id)sender {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle bundleForClass:EditGroupSubjectViewController.class]];
    UIViewController * vc = [UIViewController new];
    EditGroupSubjectViewController *vcEGS = [story instantiateViewControllerWithIdentifier:NSStringFromClass(EditGroupSubjectViewController.class)];
    [vcEGS setDictGroupInfo:self.dictEditInfo];
    [vcEGS setCompletion:^(BOOL isEdit, NSMutableDictionary * _Nullable dictInfo) {
        if (isEdit) {
            self.dictEditInfo = dictInfo;
            [self reloadInputViews];
            [self upDateChannelInfo];
        }
    }];
    vc = vcEGS;
    UINavigationController *ncEG = [[UINavigationController alloc] initWithRootViewController:vc];
    ncEG.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:ncEG animated:YES completion:nil];
}

- (IBAction)btnDescription:(id)sender {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle bundleForClass:EditGroupSubjectViewController.class]];
    UIViewController * vc = [UIViewController new];
    EditGroupDescriptionViewController *vcEGD = [story instantiateViewControllerWithIdentifier:NSStringFromClass(EditGroupDescriptionViewController.class)];
    [vcEGD setDictGroupInfo:self.dictEditInfo];
    [vcEGD setCompletion:^(BOOL isEdit, NSMutableDictionary * _Nullable dictInfo) {
        if (isEdit) {
            _dictEditInfo = dictInfo;
            [self reloadInputViews];
            [self upDateChannelInfo];
        }
    }];
    vc = vcEGD;
    UINavigationController *ncEG = [[UINavigationController alloc] initWithRootViewController:vc];
    ncEG.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:ncEG animated:YES completion:nil];
}





#pragma mark ImagePicker Delegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [self dismissViewControllerAnimated:YES completion:^{
        UIImage *original = info[UIImagePickerControllerEditedImage];
        [self->_imgProfile setImage:original];
        [self callAPIForUpdateGroupInfo];
        self->_isImageSet = YES;
    }];
}

-( void)removeGroupProfile{
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        //if (imageReduced != nil || (userStatus != nil && [userStatus length] > 0)) {
           [KVNProgress show];
        NSString *groupId = [NSString stringWithFormat:@"%@",self.dictEditInfo[@"groupId"]];
        [[eRTCAppUsers sharedInstance] removeGroupProfile:groupId andCompletion:^(id  json, NSString * errMsg) {
            [KVNProgress dismiss];
            NSDictionary *dictResponse = (NSDictionary *)json;
            if (dictResponse[@"success"] != nil) {
                self->_isImageSet = NO;
                [Helper showAlertOnController:@"eRTC" withMessage:@"Group Profile removed successfully." onController:self];
                BOOL success = (BOOL)dictResponse[@"success"];
                if (success) {
                    if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *result = (NSDictionary *)dictResponse[@"result"];
                        if ([result count]>0){
                            self.imgProfile.image = nil;
                            [self removeProfilePic];
                            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateGroupProfileSuccessfully object:result];
                            return;
                        }
                        
                    }
                }
                
            }
        } andFailure:^(NSError * _Nonnull error) {
            //[KVNProgress dismiss];
            [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
        }];
       // }
    } else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}

-(void) removeProfilePic {
     [_imgProfile sd_setImageWithURL:[UIImage imageNamed:@"DefaultUserIcon"] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
}

- (UIImage *)reduceImageSize:(UIImage *)image{
    CGSize size= CGSizeMake(640, 640);
    if (image.size.height < image.size.width)
    {
        float ratio = size.height / image.size.height;
        CGSize newSize = CGSizeMake(image.size.width * ratio, size.height);
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 1);
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    }
    else
    {
        float ratio = size.width / image.size.width;
        CGSize newSize = CGSizeMake(size.width, image.size.height * ratio);
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 1);
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    }
    UIImage *aspectScaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return aspectScaledImage;
}


- (void) takeImageFromCamera{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"Device has no camera.", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == AVAuthorizationStatusAuthorized) {
          // do your logic
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:nil];
            
        } else if(authStatus == AVAuthorizationStatusDenied ||  authStatus == AVAuthorizationStatusRestricted){
          // denied
            [self.view makeToast:@"Please enable the camera permissions."];
        } else if(authStatus == AVAuthorizationStatusNotDetermined){
          // not determined?!
          [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            if(granted){
              NSLog(@"Granted access to %@", mediaType);
            } else {
              NSLog(@"Not granted access to %@", mediaType);
            }
          }];
        }
    }
}

- (void) takeImageFromLibrary {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark API
-(void)callAPIForUpdateGroupInfo {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        NSMutableDictionary*dictParam = [[NSMutableDictionary alloc]init];
        [KVNProgress show];
        NSData *groupProfileData = UIImageJPEGRepresentation(_imgProfile.image, 1.0);
        [dictParam setValue:self.dictEditInfo[@"groupId"] forKey:Group_GroupId];
        [[eRTCChatManager sharedChatInstance] CreatePrivateGroup:dictParam withGroupImage:groupProfileData  andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            [KVNProgress dismiss];
            NSDictionary *dictResponse = (NSDictionary *)json;
            if (dictResponse[@"success"] != nil) {
                BOOL success = (BOOL)dictResponse[@"success"];
                if (success) {
                    if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *result = (NSDictionary *)dictResponse[@"result"];
                        if ([result count]>0){
                            //[Helper showAlertOnController:@"eRTC" withMessage:@"Group Profile Update successfully." onController:self];
                            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateGroupProfileSuccessfully object:result];
                            _dictEditInfo = [[NSMutableDictionary alloc]init];
                            self.dictEditInfo = result;
                            return;
                        }
                    }
                }
            }
            if (dictResponse[@"msg"] != nil) {
                NSString *message = (NSString *)dictResponse[@"msg"];
                if ([message length]>0) {
                    [Helper showAlertOnController:@"eRTC" withMessage:message onController:self];
                }
            }
        } andFailure:^(NSError * _Nonnull error) {
             [KVNProgress dismiss];
            [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
        }];
    }else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}

-(void)upDateChannelInfo {
    if (self.dictEditInfo[@"name"]) {
      self.lblGroupName.text = [NSString stringWithFormat:@"%@",self.dictEditInfo[@"name"]];
    }
    
    if (self.dictEditInfo[@"description"]) {
      self.lblDescription.text = [NSString stringWithFormat:@"%@",self.dictEditInfo[@"description"]];
    }
    if (self.dictEditInfo[User_ProfilePic_Thumb] != nil && self.dictEditInfo[User_ProfilePic_Thumb] != [NSNull null]) {
        NSString *imageURL = [NSString stringWithFormat:@"%@",self.dictEditInfo[User_ProfilePic_Thumb]];
        NSString *strUrl = [imageBaseUrl stringByAppendingString:imageURL];
        _imgProfile = [[UIImage alloc] init];
        [_imgProfile sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
        _isImageSet = YES;
    } else {
        [_imgProfile setImage:[UIImage imageNamed:@"DefaultUserIcon"]];
        _isImageSet = NO;
        //[self->_imgProfile setImage:nil];
    }
    self.navigationItem.title = @"Edit Channel Info";
}





@end
