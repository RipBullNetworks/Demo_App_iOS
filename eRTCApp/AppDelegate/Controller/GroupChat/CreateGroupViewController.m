//
//  CreateGroupViewController.m
//  eRTCApp
//
//  Created by Ashish Vani on 29/06/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.//chatRecentTabVc
//
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CreateGroupViewController.h"
#import "InfoGroupViewController.h"
#import "GroupParticipantsCollectionViewCell.h"
#import "GroupChatViewController.h"
#import "GroupListViewController.h"
#import <Toast/Toast.h>
#import "chatRecentTabVc.h"

@interface CreateGroupViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate> {
    __weak IBOutlet UIView                    *_viewNavTitle;
    __weak IBOutlet UILabel                   *_lblNavTitle;
    __weak IBOutlet UIButton                  *_bntCreate;
    __weak IBOutlet UIButton                  *_btnCamera;
    __weak IBOutlet UIImageView               *_imgProfile;
    __weak IBOutlet UITextField               *_tfGroupSubject;
    __weak IBOutlet UITextField               *_tfGroupDecription;
    __weak IBOutlet UILabel                   *_lblPublicGroupTitle;
    __weak IBOutlet UILabel                   *_lblPublicGroupSubTitle;
    __weak IBOutlet UILabel                   *_lblParticipants;
    __weak IBOutlet UIView                    *_viewParticipants;
    __weak IBOutlet UISwitch                  *_switchPublicGroup;
    __weak IBOutlet UICollectionView          *_cvParticipants;

    BOOL                                       _isImageSet;
     UIImage *imageReduced;
}

@end

@implementation CreateGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:tap];
    [self setupNavigationBar];
    [self setupCameraView];
    [self setupOtherViews];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupCollectionView];
}

#pragma mark - Setup
- (void)setupInfoWithView {
    _isImageSet = NO;
    [_btnCamera setSelected:_isImageSet];
}

- (void)setupCollectionView {
    [_cvParticipants registerNib:[UINib nibWithNibName:@"GroupParticipantsCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"GroupParticipantsCollectionViewCell"];
    [_cvParticipants setDelegate:self];
    [_cvParticipants setDataSource:self];
    [_cvParticipants reloadData];
}

- (void)setupCameraView {
    _imgProfile.layer.masksToBounds = YES;
    _imgProfile.layer.cornerRadius = _imgProfile.bounds.size.width/2;
    _btnCamera.layer.cornerRadius = _btnCamera.bounds.size.width/2;
    _imgProfile.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.0];
    [_btnCamera setSelected:YES];
}

- (void)setupOtherViews {
    [_tfGroupSubject setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Channel Name", nil) attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0.72 green:0.72 blue:0.72 alpha:1.0], NSFontAttributeName : [UIFont fontWithName:@"SFProDisplay-Regular" size:15.0]}]];
    [_tfGroupDecription setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Channel Description (Optional)", nil) attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0.72 green:0.72 blue:0.72 alpha:1.0], NSFontAttributeName : [UIFont fontWithName:@"SFProDisplay-Regular" size:15.0]}]];
    [_tfGroupSubject setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:15.0]];
    [_tfGroupSubject setTextColor:[UIColor blackColor]];
    [_tfGroupSubject setDelegate:self];
    [_tfGroupDecription setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:15.0]];
    [_tfGroupDecription setTextColor:[UIColor blackColor]];
    [_tfGroupDecription setDelegate:self];
    
    [_lblPublicGroupTitle setTextColor:[UIColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.0]];
    [_lblPublicGroupTitle setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:16.0]];
    
    [_lblPublicGroupSubTitle setTextColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.38]];
    [_lblPublicGroupSubTitle setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:14.0]];
    
  //  [_lblParticipants setTextColor:[UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.0]];
  //  [_lblParticipants setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:14.0]];
    
    [_lblPublicGroupTitle setText:NSLocalizedString(@"Public Group", nil)];
    [_lblPublicGroupSubTitle setText:NSLocalizedString(@"Anyohe workspace can join.", nil)];
    NSString *participants = [NSString stringWithFormat:@"%@ : %lu of 250", NSLocalizedString(@"PARTICIPANTS", nil), (unsigned long)self.arySelectedParticipants.count];
   // [_lblParticipants setText:participants];
    [_viewParticipants setBackgroundColor:[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0]];
}

- (void)setupNavigationBar {
    [_bntCreate.titleLabel setFont:[UIFont fontWithName:@"SFProDisplay-Medium" size:16]];
    [_lblNavTitle setFont:[UIFont fontWithName:@"SFProDisplay-Medium" size:18]];
    [self.navigationItem setTitleView:_viewNavTitle];
    [_lblNavTitle setText:NSLocalizedString(@"New Channel", nil)];
    [_bntCreate setTitle:NSLocalizedString(@"Create", nil) forState:UIControlStateNormal];
    [_bntCreate setEnabled:(self.arySelectedParticipants.count>0 && _tfGroupSubject.text.length>0)];
}

#pragma mark - IBAction
-(void)dismissKeyboard {
    [_tfGroupSubject resignFirstResponder];
    [_tfGroupDecription resignFirstResponder];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [_tfGroupSubject resignFirstResponder];
        [_tfGroupDecription resignFirstResponder];
    }
}
-(IBAction)btnCameraTapped:(id)sender {
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
            self->_isImageSet = NO;
            [self->_btnCamera setSelected:self->_isImageSet];
            [self->_imgProfile setImage:nil];
        }];
        [activitySheet addAction:delete];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [activitySheet addAction:cancel];
    
    [self presentViewController:activitySheet animated:YES completion:nil];
}

-(IBAction)btnCrossTapped:(UIButton*)sender {
    if (self.arySelectedParticipants.count == 1){
        [self.view makeToast:@"Atleast 1 member is required!"];
        return;
    }
    NSUInteger index =  sender.tag;
    [self.arySelectedParticipants removeObjectAtIndex:index];
    [_cvParticipants reloadData];
    [self updateParticipantCount];
}

-(void)updateParticipantCount {
    NSString *participants = [NSString stringWithFormat:@"%@ : %lu of 250", NSLocalizedString(@"PARTICIPANTS", nil), (unsigned long)self.arySelectedParticipants.count];
    //[_lblParticipants setText:participants];
}

-(IBAction)btnCreateTapped:(id)sender {
    if (_tfGroupSubject.text.length > 1) {
        [self callAPIForCreatePrivateGroup];
    }else{
        [self.view makeToast:@"Atleast 2 characters is required!"];
    }
}

#pragma mark Private
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
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.allowsEditing = YES;
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

#pragma mark Collection Delegate and DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.arySelectedParticipants.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GroupParticipantsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GroupParticipantsCollectionViewCell" forIndexPath:indexPath];
    [cell.btnCross addTarget:self action:@selector(btnCrossTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnCross setTag:indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.imgProfile.backgroundColor = [UIColor clearColor];
    if (self.arySelectedParticipants.count>indexPath.row) {
        NSDictionary * dict = [self.arySelectedParticipants objectAtIndex:indexPath.row];
        if (dict[User_Name] != nil && dict[Key_Name] != [NSNull null]) {
            cell.lblName.text = dict[Key_Name];
        }
        if (dict[User_ProfilePic_Thumb] != nil && dict[User_ProfilePic_Thumb] != [NSNull null]) {
            NSString *imageURL = [NSString stringWithFormat:@"%@",dict[User_ProfilePic_Thumb]];
            [cell.imgProfile sd_setImageWithURL:[NSURL URLWithString:imageURL]
            placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
            cell.imgProfile.layer.cornerRadius= cell.imgProfile.frame.size.height/2;
            cell.imgProfile.layer.masksToBounds = YES;
            
        }else{
            cell.imgProfile.image =  [UIImage imageNamed:@"DefaultUserIcon"];
        }
       
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(103, 103);
}

#pragma mark ImagePicker Delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [self dismissViewControllerAnimated:YES completion:^{
        UIImage *original = info[UIImagePickerControllerEditedImage];
        [self->_imgProfile setImage:original];
        self->_isImageSet = YES;
        [self->_btnCamera setSelected:!(self->_isImageSet)];
        self->imageReduced = [self reduceImageSize:original];
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


#pragma mark Text Field Delegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == _tfGroupSubject) {
        NSString *strName = [textField.text stringByReplacingCharactersInRange:range withString:string];
        [_bntCreate setEnabled:(self.arySelectedParticipants.count>0 && [strName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length>0)];
        return strName.length<30;
    }
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField == _tfGroupSubject) {
        _bntCreate.enabled = NO;
    }
    return YES;
}

#pragma mark API
-(void)callAPIForCreatePrivateGroup {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        NSMutableDictionary*dictParam = [[NSMutableDictionary alloc]init];
        [KVNProgress show];
        if (self.arySelectedParticipants.count > 0 && [self.arySelectedParticipants valueForKey:App_User_ID] != nil) {
            [dictParam setValue:[self.arySelectedParticipants valueForKey:App_User_ID] forKey:Group_Participants];
        }
        [dictParam setValue:_tfGroupSubject.text forKey:Group_Name];
        if (_tfGroupDecription.text.length>0) { [dictParam setValue:_tfGroupDecription.text forKey:Group_description]; }
        NSString *channelkey = [[NSUserDefaults standardUserDefaults]
            stringForKey:ChannelKey];
        [dictParam setValue:channelkey forKey:Group_Type];
        NSData *groupProfileData = UIImageJPEGRepresentation(imageReduced, 1.0);
        [[eRTCChatManager sharedChatInstance] CreatePrivateGroup:dictParam withGroupImage:groupProfileData  andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            NSDictionary *dictResponse = (NSDictionary *)json;
            if (dictResponse[@"success"] != nil) {
                [KVNProgress dismiss];
                BOOL success = (BOOL)dictResponse[@"success"];
                if (success) {
                    if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *result = (NSDictionary *)dictResponse[@"result"];
                        if ([result count]>0){
                            NSArray *childViewControllers = [ [self.navigationController presentingViewController] childViewControllers];
                            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle bundleForClass:InfoGroupViewController.class]];
                            GroupChatViewController *vcInfo = [story instantiateViewControllerWithIdentifier:NSStringFromClass(GroupChatViewController.class)];
                            NSMutableDictionary *mDict = [dictResponse[@"result"] mutableCopy];
                            mDict[@"threadType"] = @"group";
                            vcInfo.dictGroupinfo = mDict.copy;
                            for (UINavigationController *nvc in childViewControllers) {
                                for (UIViewController *vc in nvc.viewControllers) {
                                    if ([vc isKindOfClass:chatRecentTabVc.class]){
                                        [nvc pushViewController:vcInfo animated:FALSE];
                                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                            [KVNProgress dismiss];
                                            [self.navigationController dismissViewControllerAnimated:FALSE completion:^{
                                                [[NSNotificationCenter defaultCenter] postNotificationName:kGroupCreatedNotification object:nil];
                                            }];
                                        });
                                        return;
                                    }
                                }
                            }
                            return;
                        }
                    }
                }
            }
            if (dictResponse[@"msg"] != nil) {
                NSString *message = (NSString *)dictResponse[@"msg"];
                if ([message length]>0) {
                    [KVNProgress dismiss];
                    [self.view makeToast:message];
                   // [Helper showAlertOnController:@"eRTC" withMessage:message onController:self];
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

@end
