//
//  EditProfileVC.m
//  eRTCApp
//
//  Created by apple on 13/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "EditProfileVC.h"
#import "EditTblCell.h"
#import <AVKit/AVKit.h>
#import <Toast/Toast.h>
#import "EditStatusVC.h"

@interface EditProfileVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate>{
          UIBarButtonItem *EditBarButtonItem;
    UIImage *imageReduced;
    NSString* userStatus;
    NSString* userAvailabilityStatus;
    BOOL                                       _isImageSet;;
}
@end

@implementation EditProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
      self.imgProfile.layer.cornerRadius = 55;
      self.imgProfile.layer.masksToBounds = TRUE;
    self.txtViewStatus.delegate = self;
    self.navigationController.navigationBarHidden = NO;
    //[self.navigationItem.backBarButtonItem setTitle:@""];
    self.navigationItem.title = @"Edit Profile";
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
        
    } else {
        // Fallback on earlier versions
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateOtheruserPro:)
                                                 name:DidUpdateOtherUserProfile
                                               object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Edit Profile";
    //self.navigationController.navigationBar.topItem.title = @"";
    [self showUserDefoultData];
   // [_tblProfileData reloadData];
}

-(void) showUserDefoultData {
    
   [[eRTCCoreDataManager sharedInstance] getLoggedInUserInfo:^(id  _Nonnull userInfo) {
       [[UserModel sharedInstance] saveUserDetailsWith:userInfo];
   }];
   userAvailabilityStatus= [[UserModel sharedInstance] getUserDetailsUsingKey:AvailabilityStatus];
   if (userAvailabilityStatus ==nil) {
       userAvailabilityStatus = @"Availability Status";
   }
    NSString* Name = [[UserModel sharedInstance] getUserDetailsUsingKey:User_Name];
   //_lblUserName.text = Name;
    
    NSString*imageURL = [[UserModel sharedInstance] getUserDetailsUsingKey:User_ProfilePic_Thumb];
    if([[UserModel sharedInstance] getUserDetailsUsingKey:User_ProfilePic_Thumb] != nil && [[UserModel sharedInstance] getUserDetailsUsingKey:User_ProfilePic_Thumb] != [NSNull null]) {
        [self.imgProfile sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
        _isImageSet = YES;
    }else{
        _isImageSet = NO;
        [self.imgProfile sd_setImageWithURL:[UIImage imageNamed:@"DefaultUserIcon"] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
    }
    _txtViewStatus.text = [[UserModel sharedInstance] getUserDetailsUsingKey:User_ProfileStatus];
}


- (void)didUpdateOtheruserPro:(NSNotification *) notification {
    [self showUserDefoultData];
}




- (IBAction)btnUpdate:(UIButton *)sender {
    if (_txtViewStatus.text != nil && [_txtViewStatus.text length] > 0){
        [self userUpdateProfile];
    }else{
        [self.view makeToast:@"Status is mandatory."];
    }
}


#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


/*
#pragma mark - UITableView Delegates and DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EditTblCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditTblCell" forIndexPath:indexPath];
    NSString* name = [[UserModel sharedInstance] getUserDetailsUsingKey:User_Name];
    NSString* UserID = [[UserModel sharedInstance] getUserDetailsUsingKey:User_ID];
    NSString* status = [[UserModel sharedInstance] getUserDetailsUsingKey:User_ProfileStatus];
    NSString* email = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
//    NSString* userTime = [[UserModel sharedInstance] getUserDetailsUsingKey:User_LoginTimeStamp];
//    double timeStamp = [userTime doubleValue];
//    NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"EEE MMM dd yyyy HH:mm:ss"];
//    NSString  *userTimeStamp = [dateFormatter stringFromDate:msgdate];
    cell.imgRight.hidden = true;
    if (indexPath.row == 0) {
        cell.lblTitle.text = @"Full Name";
        cell.lblSubTitle.text = name;
    }else if (indexPath.row == 1) {
        cell.lblTitle.text = @"Display Name";
        cell.lblSubTitle.text = @"";
    }else if (indexPath.row == 2) {
        cell.lblTitle.text = @"Email";
        cell.lblSubTitle.text = email;
    }else if (indexPath.row == 3) {
        cell.lblTitle.text = @"Status";
        cell.lblSubTitle.text = status;
        cell.imgRight.hidden = false;
    }else if (indexPath.row == 4) {
        //Get TimeStamp
        if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_LoginTimeStamp] != nil && [[UserModel sharedInstance] getUserDetailsUsingKey:User_LoginTimeStamp] != [NSNull null]) {
            NSString* userTime = [[UserModel sharedInstance] getUserDetailsUsingKey:User_LoginTimeStamp];
            double timeStamp = [userTime doubleValue];
            NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEE MMM dd yyyy HH:mm:ss"];
            NSString  *finalate = [dateFormatter stringFromDate:msgdate];
            cell.lblTitle.text = @"Time Zone";
            cell.lblSubTitle.text = finalate;
        }
        
    }
    
    
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
    [self pushToStatusControllr];
    }
}*/

- (void)pushToStatusControllr {
    EditStatusVC *_vcProfile = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"EditStatusVC"];
    [self.navigationController pushViewController:_vcProfile animated:YES];
}

- (IBAction)btnUploadProfile:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // OK button tapped.
        [self pickImage:nil];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self pickImageFromGallary:nil];
        // Distructive button tapped.
    }]];
    if (_isImageSet) {
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Remove Profile" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self removeProfile];
    }]];
    }
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (IBAction) pickImage:(id)sender{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:@"Device has no camera."
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* OkButton = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       
                                   }];
        [alert addAction:OkButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else{
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == AVAuthorizationStatusAuthorized) {
          // do your logic
            UIImagePickerController *pickerController = [[UIImagePickerController alloc]
                                                         init];
            pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            pickerController.delegate = self;
            pickerController.allowsEditing = YES;
            [self presentViewController:pickerController animated:YES completion:nil];
            
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

-(void) removeProfilePic {
    // [ sd_setImageWithURL:[UIImage imageNamed:@"DefaultUserIcon"] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
}


- (IBAction) pickImageFromGallary:(id)sender{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc]
                                                 init];
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.allowsEditing = YES;
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [self dismissViewControllerAnimated:YES completion:^{
        NSString*mediaType = info[UIImagePickerControllerMediaType];
        if ( [mediaType isEqualToString:@"public.image"]){
            UIImage *selectedImage = info[UIImagePickerControllerEditedImage];
           // [self.btnEditProfile setImage:selectedImage forState:normal];
            [self.imgProfile setImage:selectedImage];
             self->imageReduced = [self reduceImageSize:selectedImage];
            
            // [self addPhotoMediaMessage:imageReduced];
        }
        //[self finishSendingMessageAnimated:YES];
        
    }];
 }

-(void)userUpdateProfile {
if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
    if (imageReduced != nil || (_txtViewStatus.text != nil && [_txtViewStatus.text length] > 0)) {
        [KVNProgress show];
        NSMutableDictionary *updateUserProfile = [[NSMutableDictionary alloc]init];
        NSString* UserID = [[UserModel sharedInstance] getUserDetailsUsingKey:User_ID];
        [updateUserProfile setObject:_txtViewStatus.text forKey:User_ProfileStatus];
        [updateUserProfile setObject:@"email" forKey:Login_Type];
        NSData *imageData = UIImageJPEGRepresentation(imageReduced, 1.0);
        [[eRTCAppUsers sharedInstance] updateUserProfileData:updateUserProfile andFileData:imageData andCompletion:^(id  json, NSString * errMsg) {
            [KVNProgress dismiss];
            self->imageReduced = nil;
            NSDictionary *dictResponse = (NSDictionary *)json;
            
            if (dictResponse[@"success"] != nil) {
                BOOL success = (BOOL)dictResponse[@"success"];
                if (success) {
                    if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                        [[eRTCCoreDataManager sharedInstance] getLoggedInUserInfo:^(id  _Nonnull userInfo) {
                            [[UserModel sharedInstance] saveUserDetailsWith:userInfo];
                        }];
                        //[Helper showAlertOnController:@"eRTC" withMessage:@"Profile updated successfully." onController:self];
                        //[[NSNotificationCenter defaultCenter] postNotificationName:updateuser object:userInfo];
                        [self.navigationController popViewControllerAnimated:true];
                        _isImageSet = YES;
                        return;
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
    }
} else {
    [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
}
}

-( void)removeProfile{
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        
        if (imageReduced != nil || (_txtViewStatus.text != nil && [_txtViewStatus.text length] > 0)) {
            [KVNProgress show];
            NSMutableDictionary *updateUserProfile = [[NSMutableDictionary alloc]init];
            NSString* UserID = [[UserModel sharedInstance] getUserDetailsUsingKey:User_ID];
            [updateUserProfile setObject:_txtViewStatus.text forKey:User_ProfileStatus];
            [updateUserProfile setObject:@"email" forKey:Login_Type];

            [[eRTCAppUsers sharedInstance] deleteUserProfile:^(id  json, NSString * errMsg) {
                [KVNProgress dismiss];
                self->imageReduced = nil;
                NSDictionary *dictResponse = (NSDictionary *)json;
                
                if (dictResponse[@"success"] != nil) {
                    BOOL success = (BOOL)dictResponse[@"success"];
                    if (success) {
                        if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                            [[eRTCCoreDataManager sharedInstance] getLoggedInUserInfo:^(id  _Nonnull userInfo) {
                                [[UserModel sharedInstance] saveUserDetailsWith:userInfo];
                            }];
                            [_imgProfile sd_setImageWithURL:[UIImage imageNamed:@"DefaultUserIcon"] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
                           // [Helper showAlertOnController:@"eRTC" withMessage:@"Profile removed successfully." onController:self];
                            [self.navigationController popViewControllerAnimated:true];
                            _isImageSet = NO;
                            [self showUserDefoultData];
                            return;
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
            
        }
    } else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
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

@end
