//
//  MyProfileViewController.m
//  eRTCApp
//
//  Created by Apple on 26/07/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import "MyProfileViewController.h"
#import "myProfileCell.h"
#import <AVKit/AVKit.h>
#import <Toast/Toast.h>
#import "IndicatorPopUpVC.h"
#import "EditProfileVC.h"

@interface MyProfileViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate>{
    BOOL isEditEnable ;
    UIBarButtonItem *EditBarButtonItem;
    UIImage *imageReduced;
    NSString* userStatus;
    NSString* userAvailabilityStatus;
    BOOL                                       _isImageSet;
}



@property (strong, nonatomic) NSMutableArray *arrUser;
@end

@implementation MyProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Profile
    
    self.navigationController.navigationBarHidden = NO;
    [self.navigationItem.backBarButtonItem setTitle:@""];
    self.navigationItem.title = @"Profile";
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
        
    } else {
        // Fallback on earlier versions
    }
    [self addObservers];
}

-(void) removeProfilePic {
     [_imgUser sd_setImageWithURL:[UIImage imageNamed:@"DefaultUserIcon"] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
}


-(void) showUserDefoultData {
    isEditEnable = NO;
   [[eRTCCoreDataManager sharedInstance] getLoggedInUserInfo:^(id  _Nonnull userInfo) {
       [[UserModel sharedInstance] saveUserDetailsWith:userInfo];
   }];
   userAvailabilityStatus= [[UserModel sharedInstance] getUserDetailsUsingKey:AvailabilityStatus];
   if (userAvailabilityStatus ==nil) {
       userAvailabilityStatus = @"Availability Status";
   }
    NSString* Name = [[UserModel sharedInstance] getUserDetailsUsingKey:User_Name];
   _lblUserName.text = Name;
    
    NSString*imageURL = [[UserModel sharedInstance] getUserDetailsUsingKey:User_ProfilePic_Thumb];
    if([[UserModel sharedInstance] getUserDetailsUsingKey:User_ProfilePic_Thumb] != nil && [[UserModel sharedInstance] getUserDetailsUsingKey:User_ProfilePic_Thumb] != [NSNull null]) {
        [self.imgUser sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
        _isImageSet = YES;
    }else{
        _isImageSet = NO;
        [self.imgUser sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
    }
    
    //https://socket-qa.ripbullertc.com/v1/file/profilePic/618ba617a955cf60dbc25b9861aefdb286266d000911d599_1638968907942.png
    userStatus = [[UserModel sharedInstance] getUserDetailsUsingKey:User_ProfileStatus];
    EditBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(clickdButton:)];
        self.navigationItem.rightBarButtonItem=EditBarButtonItem;
        [self.buttonImage setUserInteractionEnabled:NO];

    self.imgUser.layer.cornerRadius = self.imgUser.frame.size.width / 2;
    self.imgUser.clipsToBounds = YES;
    self.buttonImage.layer.cornerRadius = self.imgUser.frame.size.width / 2;
    self.buttonImage.clipsToBounds = YES;
    
    self.tblProfile.estimatedRowHeight = 44;
    self.tblProfile.rowHeight = UITableViewAutomaticDimension;
    [self.tblProfile reloadData];
}


#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -100;
        self.view.frame = f;
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
}

//DidUpdateOtherUserProfile

-(void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveAvailabilityStatusNotification:)
                                                 name:DidRecievedAvailabilityStatusNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateOtheruserPro:)
                                                 name:DidUpdateOtherUserProfile
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeIndicatorStatus:)
                                                 name:UpdateIndicators
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateProfileStatus:)
                                                 name:UpdateUserProfileSuccessfully
                                               object:nil];
}

-(void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:DidRecievedAvailabilityStatusNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:UpdateIndicators];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Profile";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    self.navigationController.navigationBar.topItem.title = @"";
    
    userAvailabilityStatus= [[UserModel sharedInstance] getUserDetailsUsingKey:AvailabilityStatus];
    if ([userAvailabilityStatus isEqualToString:@"auto"]) {
        [_imgIndicator setImage:[UIImage imageNamed:@"greenIndicator"]];
    }else if ([userAvailabilityStatus isEqualToString:@"away"]) {
        [_imgIndicator setImage:[UIImage imageNamed:@"yelloIndicator"]];
    }else if ([userAvailabilityStatus isEqualToString:@"invisible"]) {
        [_imgIndicator setImage:[UIImage imageNamed:@"invisible"]];
        _imgIndicator.tintColor = UIColor.grayColor;
    }else if ([userAvailabilityStatus isEqualToString:@"dnd"]) {
        [_imgIndicator setImage:[UIImage imageNamed:@"redIndicator"]];
    }
    
    if (userAvailabilityStatus ==nil) {
        userAvailabilityStatus = @"Availability Status";
    }
    [self.tblProfile reloadData];
    
    [self showUserDefoultData];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeObservers];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


-(IBAction)clickdButton:(id)sender{
    [self pushToEditProfile];
    
    /*
    NSString *strTitle ;
    if (isEditEnable == NO){
        isEditEnable = YES;
        strTitle = @"Save";
        [self.buttonImage setUserInteractionEnabled:YES];
    }
    else{
          isEditEnable = NO;
        strTitle = @"Edit";
        [self.buttonImage setUserInteractionEnabled:NO];
        
        [self savedButton:nil];
    }
    [EditBarButtonItem setTitle: strTitle];
    */
    
    //[self.tblProfile reloadData];
}

-(IBAction)savedButton:(id)sender{
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        if (imageReduced != nil || (userStatus != nil && [userStatus length] > 0)) {
            [KVNProgress show];
            NSMutableDictionary *updateUserProfile = [[NSMutableDictionary alloc]init];
            NSString* UserID = [[UserModel sharedInstance] getUserDetailsUsingKey:User_ID];
            [updateUserProfile setObject:userStatus forKey:User_ProfileStatus];
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
                            [Helper showAlertOnController:@"eRTC" withMessage:@"Profile updated successfully." onController:self];
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
        if (imageReduced != nil || (userStatus != nil && [userStatus length] > 0)) {
            [KVNProgress show];
            NSMutableDictionary *updateUserProfile = [[NSMutableDictionary alloc]init];
            NSString* UserID = [[UserModel sharedInstance] getUserDetailsUsingKey:User_ID];
            [updateUserProfile setObject:userStatus forKey:User_ProfileStatus];
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
                            [_imgUser sd_setImageWithURL:[UIImage imageNamed:@"DefaultUserIcon"] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
                            [Helper showAlertOnController:@"eRTC" withMessage:@"Profile removed successfully." onController:self];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    userStatus = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return YES;
}

#pragma mark - UITableView Delegates and DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    myProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:MyProfileCellIdentifier forIndexPath:indexPath];
   
    NSString* UserID = [[UserModel sharedInstance] getUserDetailsUsingKey:User_ID];
    NSString* email = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
    NSString* userTime = [[UserModel sharedInstance] getUserDetailsUsingKey:User_LoginTimeStamp];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (isEditEnable == YES){
        if ([indexPath row] == 0) {
            cell.lblPlaceholder.text = @"";
            [cell.txtStatus setHidden:YES];
            if ([userAvailabilityStatus.uppercaseString isEqualToString:@"DND"]) {
                cell.lblTitle.text = [userAvailabilityStatus uppercaseString];
            }
           else if ([userAvailabilityStatus.lowercaseString isEqualToString:@"Auto".lowercaseString]) {
                cell.lblTitle.text = @"Online";
            }
            else {
                cell.lblTitle.text = userAvailabilityStatus;
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if ([indexPath row] == 1) {
            cell.lblPlaceholder.text = @"Status";
            cell.lblPlaceholder.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:13];
            cell.lblPlaceholder.textColor = [UIColor colorWithRed:113.0f/255.0f green:134.0f/255.0f blue:156.0f/255.0f alpha:1.0];
            cell.lblTitle.text = @"";
            userStatus = cell.txtStatus.text;
            cell.txtStatus.text = userStatus;
            cell.txtStatus.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:15];
            [cell.txtStatus setHidden:NO];
            cell.txtStatus.delegate = self;
            [cell.txtStatus setUserInteractionEnabled:YES];
        }else  if ([indexPath row] == 2){
            [cell.txtStatus setHidden:YES];
            cell.lblPlaceholder.text = @"Email Address";
            cell.lblPlaceholder.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:13];
            cell.lblPlaceholder.textColor = [UIColor colorWithRed:113.0f/255.0f green:134.0f/255.0f blue:156.0f/255.0f alpha:1.0];
            cell.lblTitle.text = email;
        }else if ([indexPath row] == 3) {
            [cell.txtStatus setHidden:YES];
            cell.lblPlaceholder.text = @"Time";
            cell.lblPlaceholder.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:13];
            cell.lblPlaceholder.textColor = [UIColor colorWithRed:113.0f/255.0f green:134.0f/255.0f blue:156.0f/255.0f alpha:1.0];
            double timeStamp = [userTime doubleValue];
            NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEE MMM dd yyyy HH:mm:ss"];
            NSString  *userTimeStamp = [dateFormatter stringFromDate:msgdate];
            cell.lblTitle.text = userTimeStamp;
        }
    }
    else{
       if ([indexPath row] == 0) {
           cell.lblPlaceholder.text = @"";
           [cell.txtStatus setHidden:YES];
           if ([userAvailabilityStatus.uppercaseString isEqualToString:@"DND"]) {
                cell.lblTitle.text = [userAvailabilityStatus uppercaseString];

            }
           else if ([userAvailabilityStatus.lowercaseString isEqualToString:@"Auto".lowercaseString]) {
               cell.lblTitle.text = @"Online";
           }
           else {
                cell.lblTitle.text = [userAvailabilityStatus capitalizedString];
                }
           cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
       } else if ([indexPath row] == 1) {
            cell.lblPlaceholder.text = @"Status";
           cell.lblPlaceholder.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:13];
           cell.lblPlaceholder.textColor = [UIColor colorWithRed:113.0f/255.0f green:134.0f/255.0f blue:156.0f/255.0f alpha:1.0];
            cell.lblTitle.text = @"";
            cell.txtStatus.text =  userStatus;
            //status = cell.txtStatus.text;
            [cell.txtStatus setHidden:NO];
            cell.txtStatus.delegate = self;
            [cell.txtStatus setUserInteractionEnabled:NO];
        }else  if ([indexPath row] == 2){
            [cell.txtStatus setHidden:YES];
            cell.lblPlaceholder.text = @"Email Address";
            cell.lblPlaceholder.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:13];
            cell.lblPlaceholder.textColor = [UIColor colorWithRed:113.0f/255.0f green:134.0f/255.0f blue:156.0f/255.0f alpha:1.0];
            cell.lblTitle.text = email;
        }else if ([indexPath row] == 3) {
            [cell.txtStatus setHidden:YES];
            cell.lblPlaceholder.text = @"Time";
            cell.lblPlaceholder.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:13];
            cell.lblPlaceholder.textColor = [UIColor colorWithRed:113.0f/255.0f green:134.0f/255.0f blue:156.0f/255.0f alpha:1.0];
            if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_LoginTimeStamp] != nil && [[UserModel sharedInstance] getUserDetailsUsingKey:User_LoginTimeStamp] != [NSNull null]) {
                NSString* userTime = [[UserModel sharedInstance] getUserDetailsUsingKey:User_LoginTimeStamp];
                double timeStamp = [userTime doubleValue];
                NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"EEE MMM dd yyyy HH:mm:ss"];
                NSString  *finalate = [dateFormatter stringFromDate:msgdate];
                cell.lblTitle.text = finalate;
        }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        IndicatorPopUpVC * nvcIndicator =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"IndicatorPopUpVC"];
        [nvcIndicator setModalPresentationStyle:UIModalPresentationOverFullScreen];
        [self presentViewController:nvcIndicator animated:YES completion:nil];
    }
}

#pragma mark -Change profile Image

- (IBAction)btnUpdateProfileImage:(id)sender {
    
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
           // self.imgUser.image = selectedImage;
             [self.buttonImage setImage:selectedImage forState:normal];
             self->imageReduced = [self reduceImageSize:selectedImage];
            
            
            // [self addPhotoMediaMessage:imageReduced];
        }
        //[self finishSendingMessageAnimated:YES];
        
    }];
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



#pragma mark - Availability status
- (void)userAvailabilityStatus {
    UIAlertController * view =  [UIAlertController
                                    alertControllerWithTitle:@""
                                    message:@"Select Availability status"
                                    preferredStyle:UIAlertControllerStyleActionSheet];

    if ([userAvailabilityStatus isEqualToString:@"Auto"]) {
           UIAlertAction* online = [UIAlertAction
                                  actionWithTitle:@"Online"
                                  style:UIAlertActionStyleDestructive
                                  handler:^(UIAlertAction * action)
                                  {
               [self sendAvailabilityStatusToRecepient:@"auto"];
           }];
        [view addAction:online];

    }else{
           UIAlertAction* online = [UIAlertAction
                                  actionWithTitle:@"Online"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action)
                                  {
               [self sendAvailabilityStatusToRecepient:@"auto"];
           }];
        [view addAction:online];

    }
   
    if ([userAvailabilityStatus isEqualToString:@"Away"]) {
        UIAlertAction* away = [UIAlertAction
                                       actionWithTitle:@"Away"
                                       style:UIAlertActionStyleDestructive
                                       handler:^(UIAlertAction * action)
                                       {
               [self sendAvailabilityStatusToRecepient:@"away"];
           }];
        [view addAction:away];

    }else{
        
        UIAlertAction* away = [UIAlertAction
                                       actionWithTitle:@"Away"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action)
                                       {
               [self sendAvailabilityStatusToRecepient:@"away"];
           }];
        [view addAction:away];

    }
   
    if ([userAvailabilityStatus isEqualToString:@"Invisible"]) {
        UIAlertAction* invisible = [UIAlertAction
                                         actionWithTitle:@"Invisible"
                                         style:UIAlertActionStyleDestructive
                                         handler:^(UIAlertAction * action)
                                         {
               [self sendAvailabilityStatusToRecepient:@"invisible"];
           }];
        [view addAction:invisible];

    }else{
        UIAlertAction* invisible = [UIAlertAction
                                         actionWithTitle:@"Invisible"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
               [self sendAvailabilityStatusToRecepient:@"invisible"];
           }];
        [view addAction:invisible];
    }
   
    if ([userAvailabilityStatus isEqualToString:@"Dnd"]) {
        UIAlertAction* dnd = [UIAlertAction
                                  actionWithTitle:@"DND"
                                  style:UIAlertActionStyleDestructive
                                  handler:^(UIAlertAction * action)
                                  {
               [self sendAvailabilityStatusToRecepient:@"dnd"];
           }];
        [view addAction:dnd];

    }else{
        UIAlertAction* dnd = [UIAlertAction
                                  actionWithTitle:@"DND"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action)
                                  {
               [self sendAvailabilityStatusToRecepient:@"dnd"];
           }];
        [view addAction:dnd];
    }
   
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
    }];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
}

-(void)sendAvailabilityStatusToRecepient:(NSString *)availabilityStatus {
    NSMutableDictionary * dictParam = [NSMutableDictionary new];
    [dictParam setValue:availabilityStatus forKey:AvailabilityStatus];
    [[eRTCChatManager sharedChatInstance] checkUserAvailabilityStatus:dictParam andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        [self updateAvilability];
    } andFailure:^(NSError * _Nonnull error) {
        NSLog(@"json error--%@",error.description);
    }];
}

-(void)updateAvilability{
    [[eRTCCoreDataManager sharedInstance] getLoggedInUserInfo:^(id  _Nonnull userInfo) {
        [[UserModel sharedInstance] saveUserDetailsWith:userInfo];
    }];
    userAvailabilityStatus= [[[UserModel sharedInstance] getUserDetailsUsingKey:AvailabilityStatus] capitalizedString];
    if (userAvailabilityStatus ==nil) {
        userAvailabilityStatus = @"Availability Status";
    }
    [self.tblProfile reloadData];
}

- (void)didUpdateOtheruserPro:(NSNotification *) notification {
    [self showUserDefoultData];
}


/*
 eRTCUserId = 61aefdb87b2ce2e9213ab655;
 eventList =     (
             {
         eventData =             {
             availabilityStatus = auto;
         };
         eventType = availabilityStatusChanged;
     }
 );
}
 */


- (void)didReceiveAvailabilityStatusNotification:(NSNotification *) notification {
    
    NSDictionary *dictAvailabilityData = notification.userInfo;
    NSString* appId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
    
    if (dictAvailabilityData[Key_EventList] != nil && dictAvailabilityData[Key_EventList] != [NSNull null]) {
    NSArray *aryAvailability = [dictAvailabilityData objectForKey:Key_EventList];
        
        NSDictionary *dictEventData = aryAvailability.firstObject;
        NSDictionary*availabilityEventData = dictEventData[Key_EventData];
    NSString* availabilityuserId = [dictAvailabilityData objectForKey:AvailabilityuserId];
    if ([appId isEqualToString:availabilityuserId]) {
        userAvailabilityStatus= [availabilityEventData objectForKey:AvailabilityStatus];
        [self didchangeStatus:[availabilityEventData objectForKey:AvailabilityStatus]];
    }
}
    [self.tblProfile reloadData];
    NSLog(@"json error--%@",dictAvailabilityData);
}

- (void)logOutUser{
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:IsLoggedIn];
    [[NSUserDefaults standardUserDefaults]setValue:@"NO" forKey:IsLoggedIn];
  [[NSUserDefaults standardUserDefaults] synchronize];
  [[UserModel sharedInstance]logOutUser];
  [[AppDelegate sharedAppDelegate] willChangeLoginAsRootOfApplication];
}

-(void)didChangeIndicatorStatus:(NSNotification *) notification{
    NSString *userInfo = notification.object;
    [self didchangeStatus:userInfo];
}

-(void)didUpdateProfileStatus:(NSNotification *) notification{
   
}

-(void)didchangeStatus:(NSString *)isAvailability {
    
    if ([isAvailability isEqualToString:Online] || [isAvailability isEqualToString:@"auto"]) {
        [_imgIndicator setImage:[UIImage imageNamed:@"greenIndicator"]];
        [self sendAvailabilityStatusToRecepient:@"auto"];
    }else if ([isAvailability isEqualToString:Away]) {
        [_imgIndicator setImage:[UIImage imageNamed:@"yelloIndicator"]];
        [self sendAvailabilityStatusToRecepient:@"away"];
    }else if ([isAvailability isEqualToString:Invisible]) {
        [_imgIndicator setImage:[UIImage imageNamed:@"invisible"]];
        [self sendAvailabilityStatusToRecepient:@"invisible"];
    }else if ([isAvailability isEqualToString:Offline] || [isAvailability isEqualToString:@"dnd"]) {
        [_imgIndicator setImage:[UIImage imageNamed:@"redIndicator"]];
        [self sendAvailabilityStatusToRecepient:@"dnd"];
    }
}

- (void)pushToEditProfile {
    EditProfileVC *_vcProfile = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"EditProfileVC"];
    [self.navigationController pushViewController:_vcProfile animated:YES];
}

@end
