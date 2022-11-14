//
//  SingleChatViewController.m
//  eRTCApp
//
//  Created by rakesh  palotra on 28/03/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import "StarredMessageViewController.h"
#import "ProfileViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "BFRImageViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "JSQAudioRecorderView.h"
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import "JSQGIFMediaItem.h"
#import "JSQFileMediaItem.h"
#import "JSQLinkPreviewMediaItem.h"
#import "chatReplyCount.h"
#import "UIApplication+X.h"
#import <Toast/Toast.h>
#import "StarredMessageVC.h"
#import "SingleChatViewController.h"
#import "GroupChatViewController.h"
#import "JSQAudioMediaItem+JSQAudioMediaItemX.h"

@import GiphyUISDK;
@import GiphyCoreSDK;

@interface NSData (Download)

+ (void) ertc_dataWithContentsOfStringURL:(nullable NSString *)strURL onCompletionHandler:(void (^)(NSData * _Nullable data)) onCompletionHandler ;

@end

@implementation NSData (Download)

+ (void) ertc_dataWithContentsOfStringURL:(nullable NSString *)strURL onCompletionHandler:(void (^)(NSData  * _Nullable data)) onCompletionHandler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        __block NSData *dataDownloaded = [NSData new];
        NSLog(@"ertc_dataWithContentsOfStringURL--%@",strURL);
        if ([[NSFileManager defaultManager] fileExistsAtPath:strURL]) {
            dataDownloaded = [NSData dataWithContentsOfFile:strURL];
            dispatch_async(dispatch_get_main_queue(), ^{
                onCompletionHandler(dataDownloaded);
            });
            
        }else {
            NSURL *dataURL = [NSURL URLWithString:strURL];
            if (dataURL != nil) {
                NSError *error = nil;
                NSData *dataDownloading = [NSData dataWithContentsOfURL:dataURL options:NSDataReadingUncached error:&error];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error == nil) {
                        dataDownloaded = dataDownloading;
                        onCompletionHandler(dataDownloaded);
                    }else {
                    }
                });
            }
        }
    });
}

@end

@interface StarredMessageViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIViewControllerPreviewingDelegate,MPMediaPickerControllerDelegate, JSQAudioRecorderViewDelegate,CLLocationManagerDelegate,CNContactViewControllerDelegate,CNContactPickerDelegate, UIGestureRecognizerDelegate,UISearchBarDelegate> {
    
    // Typing Indicator
    NSTimer * typingTimer;
    BOOL  isTypingActive;
    JSQMessage *currentMessage;
    CLLocationManager *locationManager;
    CLGeocoder *geoCoder;
    CLPlacemark *placeMark;
    NSString*address;
    NSNumber *userLat,*userLong;
    NSMutableDictionary*dictlocation;
    NSMutableDictionary*dictContact;
    NSMutableArray *_chatHistory;
    NSMutableArray *_arrChatHistory;
    JSQAudioMediaItem *currentAudioMediaItem;
    UIBarButtonItem *searchButton;
    UIBarButtonItem *cancelButton;
    UISearchController *searchController;
    UISearchBar *searchBar;
   
}
@property(nonatomic, strong) JSQAudioRecorderView *audioRecorderView;
@property(nonatomic, strong) NSMutableArray *message;
@property(nonatomic, strong) NSMutableArray *arrFilter;
@property (strong, nonatomic) NSArray *imgURL;
@property (strong, nonatomic) NSSet *userNames;
@property (strong, nonatomic) NSMutableArray *arrAllUsers;
@property (strong, nonatomic) NSMutableArray *aryWhole;
//@property(nonatomic, strong) NSString *strThreadId;

@end

@implementation StarredMessageViewController
@synthesize playerViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"dictUserDetails--%@",self.dictUserDetails);
    
    [self showUserIconAndNameOnNavigationTitle];
    [self configureChatWindow];
    _message = [[NSMutableArray alloc] init];
    _arrFilter = [[NSMutableArray alloc] init];
    
    NSString *strAppUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
    NSString *strUserName = [[UserModel sharedInstance] getUserDetailsUsingKey:User_Name];
    self.senderId = strAppUserId;
    self.senderDisplayName = strUserName;
    [self callAPIForGetContactsUserList];
   
    [self geoLocation];
    [self hideInputToolbar];
    
    if (self.strThreadId != nil) {
        [self performSelector:@selector(getChatHistory) withObject:nil afterDelay:0.5];
    }
    else {
        //self.strThreadId = [NSString stringWithFormat:@"%@",self.dictUserDetails[ThreadID]];
       // [self performSelector:@selector(getChatHistory) withObject:nil afterDelay:0.5];
        [self generateThreadId];
    }
    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didchatStarFavourite:)
                                                 name:DidReceveEventStarFavouriteMessage
                                               object:nil];
    
    UIImage *image = [[UIImage imageNamed:@"search"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    searchButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(searchFavourite:)];
    self.navigationItem.rightBarButtonItem=searchButton;
    cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelSearchBar:)];

    searchBar = [[UISearchBar alloc]init];
    searchBar.tintColor = [UIColor blackColor];
    searchBar.backgroundColor = [Helper colorWithHexString:@"e1e2e4"];
    searchBar.placeholder = @"Search";
    searchBar.delegate = self;
}


-(IBAction)cancelSearchBar:(id)sender{
    searchBar.hidden = true;
    [self.navigationItem setHidesBackButton:false animated:false];
    [self showUserIconAndNameOnNavigationTitle];
    self.navigationItem.leftBarButtonItem=nil;
    _chatHistory = _arrChatHistory.mutableCopy;
    _message = _arrFilter.mutableCopy;
    [self.collectionView reloadData];
}

-(IBAction)searchFavourite:(id)sender{
    self.navigationItem.titleView = searchBar;
    [self.navigationItem setHidesBackButton:YES animated:YES];
    searchBar.hidden = false;
    self.navigationItem.leftBarButtonItem=cancelButton;
   // cancelButton.hidden = false;
}

- (void)jsq_updateCollectionViewInsets {
    CGFloat topInset = self.topLayoutGuide.length + self.topContentAdditionalInset;
    CGFloat bottomInset = 0.0;
    [self jsq_setCollectionViewInsetsTopValue:topInset bottomValue:bottomInset];
}

- (void)hideInputToolbar {
    self.inputToolbar.hidden = YES;
    [self jsq_updateCollectionViewInsets];
}

-(void)geoLocation
{
    geoCoder = [[CLGeocoder alloc] init];
    if (locationManager == nil)
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.delegate = self;
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (currentAudioMediaItem != nil) {
        [currentAudioMediaItem pause];
    }
}

-(void)viewDidAppear:(BOOL)animated{
   [super viewDidAppear:animated];
}
- (void)refreshTableDataWith:(NSArray *) ary {
    self.arrAllUsers = [ary mutableCopy];
    NSString *strAppUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"appUserId != %@",strAppUserId];
    NSArray *filteredArr = [ary filteredArrayUsingPredicate:predicate];
    
    if (filteredArr.count >0) {
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        NSArray *sortedArray=[filteredArr sortedArrayUsingDescriptors:@[sort]];
        if (sortedArray.count > 0) {
            self.aryWhole = [[NSArray arrayWithArray:sortedArray] mutableCopy];
        }
    }
}


- (void)callAPIForGetContactsUserList {
    
    /*
     these are the 3 parameter for get chat user list.
     1. lastId  (To be used for Pagination)
     2. lastCallTime (epoch time value for time based sunc. Do not pass this param itself for retrieving all data.)
     3. updateType  (type of sync i.e. addUpdated or deleted. Default value is addUpdated)
     */
    
    [[eRTCCoreDataManager sharedInstance] fetchChatUserListWithCompletionHandler:^(id ary, NSError *err) {
        [self refreshTableDataWith:ary];
        NSMutableSet *mSet = [NSMutableSet new];
        [(NSArray*)ary enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]] && obj[@"name"] != NULL){
             
                [mSet addObject:obj[@"name"]];
            }
        }];
        self.userNames = mSet.copy;
    }];
}


-(void)generateThreadId {
    NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
    NSMutableDictionary * dictParam = [NSMutableDictionary new];
    if (self.dictUserDetails[App_User_ID] != nil && self.dictUserDetails[App_User_ID] != [NSNull null]) {
        [dictParam setObject:self.dictUserDetails[App_User_ID] forKey:RecipientAppUserId];
    }
    [dictParam setObject:userId forKey:SendereRTCUserId];
    [[eRTCChatManager sharedChatInstance] getChatThreadIDWithParam:[NSDictionary dictionaryWithDictionary:dictParam] andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        if (![Helper stringIsNilOrEmpty:json[Key_Result]]) {
            NSDictionary * dictResult = json[Key_Result];
            if (![Helper stringIsNilOrEmpty:dictResult[ThreadID]]) {
                self.strThreadId = [NSString stringWithFormat:@"%@",dictResult[ThreadID]];
                [self performSelector:@selector(getChatHistory) withObject:nil afterDelay:0.5];
            }
        } else {
            if (![Helper stringIsNilOrEmpty:json[Key_Message]]) {
                [Helper showAlertOnController:@"eRTC" withMessage:json[Key_Message] onController:self];
            }
        }
    } andFailure:^(NSError * _Nonnull error) {
        [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self completion:^{
            [self.navigationController popViewControllerAnimated:true];
        }];
        
    }];
}



/*
-(void)generateThreadId {
    NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
    NSMutableDictionary * dictParam = [NSMutableDictionary new];
    if (self.dictUserDetails[App_User_ID] != nil && self.dictUserDetails[App_User_ID] != [NSNull null]) {
        [dictParam setObject:self.dictUserDetails[App_User_ID] forKey:RecipientAppUserId];
    }
    
    [dictParam setObject:userId forKey:SendereRTCUserId];
    [[eRTCChatManager sharedChatInstance] getChatThreadIDWithParam:[NSDictionary dictionaryWithDictionary:dictParam] andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        if (![Helper stringIsNilOrEmpty:json[Key_Result]]) {
            NSDictionary * dictResult = json[Key_Result];
            if (![Helper stringIsNilOrEmpty:dictResult[ThreadID]]) {
                self.strThreadId = [NSString stringWithFormat:@"%@",dictResult[ThreadID]];
                [self performSelector:@selector(getChatHistory) withObject:nil afterDelay:0.5];
            }
        } else {
            if (![Helper stringIsNilOrEmpty:json[Key_Message]]) {
                [Helper showAlertOnController:@"eRTC" withMessage:json[Key_Message] onController:self];
            }
        }
    } andFailure:^(NSError * _Nonnull error) {
    }];
}*/


-(NSUInteger)getIndexOfMessageId:(NSString *)msgId threadId:(NSString*)threadId{
    if (msgId != NULL && threadId != NULL && [self.strThreadId isEqualToString:threadId]) {
        __block NSUInteger indexPath = -1;
        __block NSDictionary *message = NULL;
        [_chatHistory enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]] && [msgId isEqual:obj[@"msgUniqueId"]]){
                indexPath = idx;
                message = obj;
                return;
            }
        }];
        return indexPath;
    }
    return -1;
}


- (void)showChatFromLocalDB:(NSMutableArray *) aryChat {
    for (int i=0; i<[aryChat count]; i++) {
        NSDictionary * dict = [aryChat objectAtIndex:i];
        NSString * _strSenderID = @"";
        NSString * _strDisplayName = @"";
        BOOL isOutgoingMsg = NO;
        id<JSQMessageMediaData> newMediaData = nil;
        id newMediaAttachmentCopy = nil;
        JSQMessage *newMessage = nil;
        
        if ([dict[SendereRTCUserId] isEqualToString:self.senderId]) {
            _strSenderID = self.senderId;
            _strDisplayName = self.senderDisplayName;
            isOutgoingMsg =YES;
        }
        
        if (![Helper stringIsNilOrEmpty:dict[MsgType]]) {
            if ([dict[MsgType] isEqualToString:@"gify"] || [dict[MsgType] isEqualToString:@"gif"]) {
                JSQGIFMediaItem *photoItemCopy = [[JSQGIFMediaItem alloc] init];
                [eRTCChatManager downloadMediaMessage:dict andCompletionHandler:^(NSDictionary * _Nonnull details, NSError * _Nonnull error, NSData * _Nonnull data) {
                    if (!error && data){
                        [photoItemCopy setImageData:data];
                        NSMutableDictionary *update =  [self->_chatHistory[i] mutableCopy];
                        if ([details[MsgUniqueId] isEqual:update[MsgUniqueId]]){
                            update[@"mediaFileName"] = details[@"mediaFileName"];
                            update[LocalFilePath] = details[LocalFilePath];
                            self->_chatHistory[i] = update.copy;
                        }
                        [self finishReceivingMessage];
                    }
                }];
                if (isOutgoingMsg) {
                    photoItemCopy.appliesMediaViewMaskAsOutgoing = YES;
                } else {
                    photoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                }
                newMediaAttachmentCopy = [UIImage imageWithData:photoItemCopy.imageData];
                newMediaData = photoItemCopy;
                double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
                NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
                newMessage = [[JSQMessage alloc] initWithSenderId:_strSenderID senderDisplayName:_strDisplayName date:msgdate media:photoItemCopy];
                // newMessage = [JSQMessage messageWithSenderId:_strSenderID displayName:_strDisplayName media:photoItemCopy];
            }
            else  if ([dict[MsgType] isEqualToString:@"file"]) {
                
                NSString *strURL = @"";
                JSQFileMediaItem *photoItemCopy = [[JSQFileMediaItem alloc] init];
                if (![Helper stringIsNilOrEmpty:dict[LocalFilePath]] && [dict[LocalFilePath] length] > 0) {
                    
                    strURL = dict[LocalFilePath];
                    photoItemCopy.fileURL = [NSURL fileURLWithPath:strURL];
                } else {
                    strURL = dict[FilePath];
                }
                //  [NSData ertc_dataWithContentsOfStringURL:strURL onCompletionHandler:^(NSData * _Nullable data) {
                
                //   }];
                [photoItemCopy setFileExtension:strURL.pathExtension];
                if (isOutgoingMsg) {
                    photoItemCopy.appliesMediaViewMaskAsOutgoing = YES;
                    
                } else {
                    photoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                }
                
                // newMediaAttachmentCopy = [UIImage imageWithData:photoItemCopy.imageData];
                newMediaData = photoItemCopy;
                
                double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
                NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
                newMessage = [[JSQMessage alloc] initWithSenderId:_strSenderID senderDisplayName:_strDisplayName date:msgdate media:photoItemCopy];
                // newMessage = [JSQMessage messageWithSenderId:_strSenderID displayName:_strDisplayName media:photoItemCopy];
            }
            else if ([dict[MsgType] isEqualToString:@"image"]) {
                NSString *strURL = @"";
                JSQPhotoMediaItem *photoItemCopy = nil;
                photoItemCopy = [[JSQPhotoMediaItem alloc] init];
                if (![Helper stringIsNilOrEmpty:dict[LocalFilePath]] && [dict[LocalFilePath] length] > 0) {
                    strURL = dict[LocalFilePath];
                } else {
                    strURL = dict[FilePath];
                }
                [eRTCChatManager downloadMediaMessage:dict andCompletionHandler:^(NSDictionary * _Nonnull details, NSError * _Nonnull error, NSData * _Nonnull data) {
                    if (!error && data){
                        [photoItemCopy setImage:[UIImage imageWithData:data]];
                        NSMutableDictionary *update =  [self->_chatHistory[i] mutableCopy];
                        if ([details[MsgUniqueId] isEqual:update[MsgUniqueId]]){
                            update[@"mediaFileName"] = details[@"mediaFileName"];
                            update[LocalFilePath] = details[LocalFilePath];
                            self->_chatHistory[i] = update.copy;
                        }
                        [self finishReceivingMessage];
                    }
                }];

                if (isOutgoingMsg) {
                    photoItemCopy.appliesMediaViewMaskAsOutgoing = YES;
                    
                } else {
                    photoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                }
                newMediaAttachmentCopy = [UIImage imageWithCGImage:photoItemCopy.image.CGImage];
                newMediaData = photoItemCopy;
                double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
                NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
                newMessage = [[JSQMessage alloc] initWithSenderId:_strSenderID senderDisplayName:_strDisplayName date:msgdate media:photoItemCopy];
                
                // newMessage = [JSQMessage messageWithSenderId:_strSenderID displayName:_strDisplayName media:photoItemCopy];
            } else if ([dict[MsgType] isEqualToString:@"video"]) {
                NSURL * videoURL = nil;
                if (![Helper stringIsNilOrEmpty:dict[LocalFilePath]] && [dict[LocalFilePath] length] > 0) {
                    videoURL = [NSURL URLWithString:[@"file://" stringByAppendingString:dict[LocalFilePath]]];
                } else {
                    videoURL = [NSURL URLWithString:dict[FilePath]];
                }
                
                JSQVideoMediaItem *videoItem = [[JSQVideoMediaItem alloc] init];
                
                double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
                NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
                // newMessage = [JSQMessage messageWithSenderId:_strSenderID displayName:_strDisplayName media:videoItem];
                newMessage = [[JSQMessage alloc] initWithSenderId:_strSenderID senderDisplayName:_strDisplayName date:msgdate media:videoItem];
                [eRTCChatManager downloadMediaMessage:dict andCompletionHandler:^(NSDictionary * _Nonnull details, NSError * _Nonnull error, NSData * _Nonnull data) {
                    if (!error && data && details[LocalFilePath] != NULL){
                        NSString *msgId = details[MsgUniqueId];
                        NSString *threadId = details[ThreadID];
                        NSURL * videoURL = [NSURL URLWithString:[@"file://" stringByAppendingString:details[LocalFilePath]]];
                        NSUInteger index = [self getIndexOfMessageId:msgId threadId:threadId];
                        JSQVideoMediaItem *_videoItem = [[JSQVideoMediaItem alloc] initWithFileURL:videoURL isReadyToPlay:TRUE];
                        self.message[i] = [[JSQMessage alloc] initWithSenderId:_strSenderID senderDisplayName:_strDisplayName date:msgdate media:_videoItem];
                        NSMutableDictionary *update =  [self->_chatHistory[i] mutableCopy];
                        if ([details[MsgUniqueId] isEqual:update[MsgUniqueId]]){
                            update[@"mediaFileName"] = details[@"mediaFileName"];
                            update[LocalFilePath] = details[LocalFilePath];
                            self->_chatHistory[i] = update.copy;
                        }
                        if ([self.collectionView numberOfItemsInSection:0] > i){
                            [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
                        }
                    }
                }];
                if (isOutgoingMsg) {
                    videoItem.appliesMediaViewMaskAsOutgoing = YES;
                    
                } else {
                    videoItem.appliesMediaViewMaskAsOutgoing = NO;
                }
                
                
            } else if ([dict[MsgType] isEqualToString:@"audio"]) {
                NSURL * audioURL = nil;
                if (![Helper stringIsNilOrEmpty:dict[LocalFilePath]] && [dict[LocalFilePath] length] > 0) {
                    audioURL = [NSURL URLWithString:[@"file://" stringByAppendingString:dict[LocalFilePath]]];
                } else {
                    audioURL = [NSURL URLWithString:dict[FilePath]];
                }
                JSQAudioMediaItem *audioItem = [[JSQAudioMediaItem alloc] init];
                audioItem.delegate = self;
                audioItem.audioViewAttributes.audioCategory = AVAudioSessionCategoryPlayback;
                if (isOutgoingMsg ) {
                    audioItem.appliesMediaViewMaskAsOutgoing = YES;
                    
                } else {
                    audioItem.appliesMediaViewMaskAsOutgoing = NO;
                }
                [eRTCChatManager downloadMediaMessage:dict andCompletionHandler:^(NSDictionary * _Nonnull details, NSError * _Nonnull error, NSData * _Nonnull data) {
                    if (!error && data && details[LocalFilePath] != NULL){
                        [audioItem setAudioData:data];
                        NSMutableDictionary *update =  [self->_chatHistory[i] mutableCopy];
                        if ([details[MsgUniqueId] isEqual:update[MsgUniqueId]]){
                            update[@"mediaFileName"] = details[@"mediaFileName"];
                            update[LocalFilePath] = details[LocalFilePath];
                            self->_chatHistory[i] = update.copy;
                        }
                        [self finishSendingMessage];
                    }
                }];
                
                double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
                NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
                newMessage = [[JSQMessage alloc] initWithSenderId:_strSenderID senderDisplayName:_strDisplayName date:msgdate media:audioItem];
                //  newMessage = [JSQMessage messageWithSenderId:_strSenderID displayName:_strDisplayName media:audioItem];
                
                
            } else if ([dict[MsgType] isEqualToString:@"contact"]) {
                if (![Helper objectIsNilOrEmpty:dict andKey:ContactType]) {
                    NSDictionary *dictContact = dict[ContactType];
                    if ([dictContact count] > 0 && ![Helper objectIsNilOrEmpty:dictContact andKey:Numbers]) {
                        NSArray *aryNumbers = dictContact[Numbers];
                        if ([aryNumbers count] > 0) {
                            NSDictionary *dictNumber = [aryNumbers objectAtIndex:0];
                            if (![Helper stringIsNilOrEmpty:dictNumber[Number]] && [dictNumber[Number] length] > 0) {
                                double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
                                NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
                                
                                NSString *strContactPersonName = [Helper getContactNameString:dictContact];
                                newMessage = [[JSQMessage alloc] initWithSenderId:_strSenderID
                                                                senderDisplayName:_strDisplayName
                                                                             date:msgdate
                                                                             text:[NSString stringWithFormat:@"%@",strContactPersonName]]; //  \n%@ dictNumber[Number]
                            }
                        }
                    }
                }
            } else if ([dict[MsgType] isEqualToString:@"location"]) {
                if (![Helper objectIsNilOrEmpty:dict andKey:LocationType]) {
                    NSDictionary *dictLocation = dict[LocationType];
                    if (![Helper stringIsNilOrEmpty:dictLocation[Latitude]] && ![Helper stringIsNilOrEmpty:dictLocation[Longitude]]) {
                        CLLocation *clLocation = [[CLLocation alloc] initWithLatitude:[dictLocation[Latitude] doubleValue] longitude:[dictLocation[Longitude] doubleValue] ];
                        JSQLocationMediaItem *locationItem = [[JSQLocationMediaItem alloc] init];
                        if (isOutgoingMsg) {
                            locationItem.appliesMediaViewMaskAsOutgoing = YES;
                            
                        } else {
                            locationItem.appliesMediaViewMaskAsOutgoing = NO;
                        }
                        double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
                        NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
                        newMessage = [[JSQMessage alloc] initWithSenderId:_strSenderID senderDisplayName:_strDisplayName date:msgdate media:locationItem];
                        // newMessage = [JSQMessage messageWithSenderId:_strSenderID
                        //      displayName:_strDisplayName
                        //    media:locationItem];
                        [locationItem setLocation:clLocation withCompletionHandler:^{
                            [self.collectionView reloadData];
                        }];
                    }
                }
            } else if ([dict[MsgType] isEqualToString:@"text"]) {
                double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
                NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
                NSString *strMessage = @"";
                if ([dict[@"replyMsgConfig"] boolValue]){
                    strMessage = [NSString stringWithFormat:@"Replied to a thread:%@\n%@",dict[Parent_Msg],dict[Message]];
                }else if (![dict[IsDeletedMSG] boolValue] && [dict[IsEdited] boolValue]){
                    strMessage = [NSString stringWithFormat:@"%@%@",dict[Message], EditedString];
                }else if (![dict[IsDeletedMSG] boolValue] && [dict[IsForwarded] boolValue]){
                    strMessage = [NSString stringWithFormat:@"%@\n%@",ForwardedString, dict[Message]];
                }else {
                    strMessage = dict[Message];
                }
                
                NSURL *first = [Helper getFirstUrlIfExistInMessage:strMessage];
                if (first){
                    JSQLinkPreviewMediaItem *item = [[JSQLinkPreviewMediaItem alloc] initWithURL:first details:dict completionHandler:^(NSDictionary * _Nonnull details, NSError * _Nullable error) {
                        NSString *msgId = dict[MsgUniqueId];
                        NSString *threadId = dict[ThreadID];
                        NSUInteger index = [self getIndexOfMessageId:msgId threadId:threadId];
                        if (index != -1 && index <= self->_chatHistory.count){
                            [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
                        }
                    }];
                    newMessage = [[JSQMessage alloc] initWithSenderId:_strSenderID
                                                    senderDisplayName:_strDisplayName
                                                                 date:msgdate
                                                                media:item];
                }else {
                    newMessage = [[JSQMessage alloc] initWithSenderId:_strSenderID
                                                    senderDisplayName:_strDisplayName
                                                                 date:msgdate
                                                                 text:NSLocalizedString(strMessage, nil)];
                }
                
            }
            
            newMessage.msgStatus = dict[MsgStatusEvent];
            if (newMessage != nil) {
                [self.message addObject:newMessage];
                [self.arrFilter addObject:newMessage];
            }
            //TODO
            if([dict[MsgStatusEvent] isEqualToString:MsgDeliveredStatus]) {
                [[eRTCChatManager sharedChatInstance] updateMessageWithReadStatus:dict];
            }
        }else {
            NSLog(@"NOT FOUND MSG TYPS %@", dict);
        }
    }
    if ([self.message count] > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            [self scrollToBottomAnimated:YES];
            /*if (self.isScrollToBottom == YES){
                [self scrollToBottomAnimated:YES];
            }else{
                self.isScrollToBottom = YES;
            }*/
        });
    }
}


- (void)getChatHistory {
    _message = [[NSMutableArray alloc] init];
    _arrFilter = [[NSMutableArray alloc] init];
    if (self.strThreadId != nil ) {
        NSMutableArray *chats = @[].mutableCopy;
        NSPredicate * pred = [NSPredicate predicateWithFormat:@"isFavourite ==1 AND replyMsgConfig != 1"];
        [[eRTCCoreDataManager sharedInstance] getUserChatHistoryWithThreadID:self.strThreadId andCompletionHandler:^(id ary, NSError *err) {
            NSArray * filteredArray = [ary filteredArrayUsingPredicate:pred];
            if (filteredArray.count == 0) { return ;}
            [chats addObjectsFromArray:filteredArray];
        }];
        
//        [[eRTCCoreDataManager sharedInstance] getUserChatHistoryWithThreadID:self.strGroupThread andCompletionHandler:^(id ary, NSError *err) {
//            NSArray * filteredArray = [ary filteredArrayUsingPredicate:pred];
//            if (filteredArray.count == 0) { return ;}
//            [chats addObjectsFromArray:filteredArray];
//        }];
        
        [[eRTCCoreDataManager sharedInstance] getUserReplyThreadChatHistoryWithThreadID:self.strThreadId andCompletionHandler:^(id ary, NSError *err) {
        NSLog(@"ThreadChatViewController ->  getChatHistory -> getUserReplyThreadChatHistoryWithThreadID -> %@",ary);
            NSArray * filteredArray = [ary filteredArrayUsingPredicate:pred];
            if (filteredArray.count == 0) { return ;}
            [chats addObjectsFromArray:filteredArray];
        }];
        
        if (chats.count == 0) { return ;}
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
        NSArray *_sortedArray=[chats sortedArrayUsingDescriptors:@[sort]];
        self->_arrChatHistory = [NSMutableArray new];
        self->_arrChatHistory = _sortedArray.mutableCopy;
        self->_chatHistory = [NSMutableArray new];
        self->_chatHistory = _sortedArray.mutableCopy;
        [self showChatFromLocalDB: _sortedArray.copy];
    }
}





-(NSString *)documentsDirectory{
    NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

-(NSString *)pathOfFile:(NSString *)fileName{
    NSString *filePath= [[NSString alloc] initWithFormat:@"%@/%@", [self documentsDirectory],fileName];
    return filePath;
}
-(BOOL)isFolderExist:(NSString *)filePath{
    BOOL isDir;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
    
    if (fileExists && isDir)
        return YES;
    
    return NO;
}
-(NSString *)mediaPathWithName:(NSString *)folderName UserId:(NSString *)chatID andFileName:(NSString *)fileName{
    
    NSString *path = [self pathOfFile:@"media"];
    
    NSString *chatPath= [NSString stringWithFormat:@"%@/%@/%@",path,folderName,chatID];
    if (![self isFolderExist:chatPath]){
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:chatPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    NSString *dataPath= [NSString stringWithFormat:@"%@/%@",chatPath,fileName];
    
    return dataPath;
}
- (void) showUserIconAndNameOnNavigationTitle {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, -15, 150, 60)];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(5, 13, 140, 20)];
    lbl.text = @"Favorite Messages";
    
    lbl.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:16];
    lbl.textAlignment = NSTextAlignmentCenter;
    [titleView addSubview:lbl];

    self.navigationItem.titleView = titleView;
}

-(void)configureChatWindow {
    /**
     *  Register custom menu actions for cells.
     */
    [JSQMessagesCollectionViewCell registerMenuAction:@selector(customAction:)];
    
    
    /**
     *  OPT-IN: allow cells to be deleted
     */
    [JSQMessagesCollectionViewCell registerMenuAction:@selector(delete:)];
    
    /**
     *  Customize your toolbar buttons
     *
     *  self.inputToolbar.contentView.leftBarButtonItem = custom button or nil to remove
     *  self.inputToolbar.contentView.rightBarButtonItem = custom button or nil to remove
     */
    
    /**
     *  Set a maximum height for the input toolbar
     *
     *  self.inputToolbar.maximumHeight = 150;
     
     */
    
    self.inputToolbar.contentView.textView.delegate =self;

    self.collectionView.collectionViewLayout.springinessEnabled = NO;
    
    self.inputToolbar.maximumHeight = 100;
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32, 25)];
    [leftButton setImage:[UIImage imageNamed:@"cameraNew"] forState:UIControlStateNormal];
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32, 25)];
    
    [rightButton setImage:[UIImage imageNamed:@"sendNew"] forState:UIControlStateSelected];
    [rightButton setImage:[UIImage imageNamed:@"MicrophoneNew"] forState:UIControlStateNormal];
    
    UILongPressGestureRecognizer *lpg = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(rightButtonAudioLongPress:)];
    lpg.cancelsTouchesInView = false;
    lpg.allowableMovement = 10;
    lpg.minimumPressDuration = 0.5;
    [rightButton addGestureRecognizer:lpg];
    self.inputToolbar.contentView.leftBarButtonItem =leftButton;
    self.inputToolbar.contentView.rightBarButtonItem =rightButton;
    
    [self.inputToolbar.contentView.textView setHidden:NO];
    [self.inputToolbar.contentView.recorderView setHidden:YES];
    
    UIView *recorderView = self.inputToolbar.contentView.recorderView;
    CGRect audioRercorder = recorderView.bounds;
    
    self.audioRecorderView = [[JSQAudioRecorderView alloc] initWithFrame:audioRercorder];
    [self.audioRecorderView setJsqARVDelegate:self];
    NSLayoutConstraint *centreHorizontallyConstraint = [NSLayoutConstraint constraintWithItem:self.audioRecorderView
                                                                                    attribute:NSLayoutAttributeCenterX
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:recorderView
                                                                                    attribute:NSLayoutAttributeCenterX
                                                                                   multiplier:1.0
                                                                                     constant:0];
    
    NSLayoutConstraint *centreVerticelConstraint = [NSLayoutConstraint constraintWithItem:self.audioRecorderView
                                                                                attribute:NSLayoutAttributeCenterY
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:recorderView
                                                                                attribute:NSLayoutAttributeCenterY
                                                                               multiplier:1.0
                                                                                 constant:0];
    
    NSLayoutConstraint *equalHeightConstraint = [NSLayoutConstraint constraintWithItem:self.audioRecorderView
                                                                             attribute:NSLayoutAttributeHeight
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:recorderView
                                                                             attribute:NSLayoutAttributeHeight
                                                                            multiplier:1.0
                                                                              constant:0];
    
    NSLayoutConstraint *equalWidthConstraint = [NSLayoutConstraint constraintWithItem:self.audioRecorderView
                                                                            attribute:NSLayoutAttributeWidth
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:recorderView
                                                                            attribute:NSLayoutAttributeWidth
                                                                           multiplier:1.0
                                                                             constant:0];
    [recorderView addConstraints:@[centreHorizontallyConstraint, centreVerticelConstraint, equalWidthConstraint, equalHeightConstraint]];
    
    [recorderView addSubview:self.audioRecorderView];
}


- (void)rightButtonAudioLongPress:(UILongPressGestureRecognizer*)gesture {

    if (self.inputToolbar.contentView.rightBarButtonItem.isSelected == NO) {
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan:
                [self.inputToolbar.contentView.textView setHidden:YES];
                [self.inputToolbar.contentView.recorderView setHidden:NO];
                [self.audioRecorderView startAudioRecording];
                break;
            case UIGestureRecognizerStateChanged:
                break;
            case UIGestureRecognizerStateEnded:
                [self.inputToolbar.contentView.textView setHidden:NO];
                [self.inputToolbar.contentView.recorderView setHidden:YES];
                //[self.inputToolbar.contentView.textView setText:@""];
                [self.audioRecorderView stopAudioRecording];
                break;
            default:
                break;
        }
    }
}






#pragma mark - Custom menu actions for cells

- (void)didReceiveMenuWillShowNotification:(NSNotification *)notification
{
    /**
     *  Display custom menu actions for cells.
     */
//    UIMenuController *menu = [notification object];
//    menu.menuItems = @[ [[UIMenuItem alloc] initWithTitle:@"Custom Action" action:@selector(customAction:)] ];
    
    [super didReceiveMenuWillShowNotification:notification];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return NO;
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    [self.inputToolbar.contentView.textView resignFirstResponder];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Media messages", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                         destructiveButtonTitle:nil
                                        otherButtonTitles:NSLocalizedString(@"Camera", nil), NSLocalizedString(@"Photo & Video Library", nil),NSLocalizedString(@"Share Current Location", nil),NSLocalizedString(@"Share Contact", nil),
                            NSLocalizedString(@"Share GIF", nil),nil];
    
    [sheet showFromToolbar:self.inputToolbar];
}


-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:[NSDate date]
                                                          text:text ];
    
     message.msgStatus =@"sending...";
    // [JSQSystemSoundPlayer jsq_playMessageSentSound];
    //    NSString *response  = [NSString stringWithFormat:@"{\"type\": \"usermsg\",\"name\": \"%@\", \"message\": \"%@\", \"color\": \"red\"}",self.senderDisplayName,text];
    //    NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSUTF8StringEncoding]];
    //    [socket.outputStream write:[data bytes] maxLength:[data length]];
    [_message addObject:message];
    //[_message addObject:[JSQMessage messageWithSenderId:senderId displayName:senderDisplayName text:text]];
    
    //[[super collectionView] reloadData];
    [self finishSendingMessageAnimated:YES];
    
}

-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesBubbleImageFactory *bubble = [[JSQMessagesBubbleImageFactory alloc] init];
 /*   if([[_message objectAtIndex:indexPath.item] senderId] != self.senderId)
    {
        return [bubble incomingMessagesBubbleImageWithColor:[UIColor lightGrayColor]];
    }
    else
        return [bubble outgoingMessagesBubbleImageWithColor:[UIColor colorWithHue:130.0f / 360.0f saturation:0.68f brightness:0.84f alpha:1.0f]];*/
    return [bubble outgoingMessagesBubbleImageWithColor:[UIColor colorWithRed:0.9 green:0.93 blue:1.0 alpha:1.0]];

}

-(id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
    
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [_message objectAtIndex:indexPath.item];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height)];
    noDataLabel.textColor        = [UIColor blueColor];
    noDataLabel.textAlignment    = NSTextAlignmentCenter;
    if (_message.count > 0) {
        noDataLabel.text             = @"";
        self.collectionView.backgroundView = noDataLabel;
        return [_message count];
    }else{
        noDataLabel.text             = @"No starred message found!";
        self.collectionView.backgroundView = noDataLabel;
        return 0;
    }
    
    return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = _message[indexPath.row];
    NSDictionary *msgObject;
    if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row ){
        msgObject = [_chatHistory objectAtIndex:indexPath.row];
    }
 
    JSQMessagesCollectionViewCell *cell  = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    if (msgObject && [msgObject valueForKey:@"isReported"] != nil && [msgObject valueForKey:@"isReported"] != [NSNull null] ){
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"JSQReportCell" forIndexPath:indexPath];
        cell.delegate = self;
        cell.cellTopLabel.hidden = true;
        cell.cellBottomLabel.hidden = true;
    }
    
//    if ([msgObject[ReplyMsgConfig] boolValue] == true){
//        if ([msgObject[MsgType] isEqualToString:Key_video] || [msgObject[MsgType] isEqualToString:Image] || [msgObject[MsgType] isEqualToString:LocationType] || [msgObject[MsgType] isEqualToString:GifyFileName] || [msgObject[MsgType] isEqualToString:ContactType] || [msgObject[MsgType] isEqualToString:AudioFileName] ) {
//            NSString *strParentMsg = msgObject[Parent_Msg];
//            // NSDictionary *msg = [[eRTCCoreDataManager sharedInstance] getMessageByUniqueID:mQid];
//            cell.messageBubbleTopLabel.text = [NSString stringWithFormat:@"Replied to a thread:%@",strParentMsg];
//            cell.messageBubbleTopLabel.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:18];
//        }
//    }
    
    cell.textView.selectable = false;
    cell.textView.textColor = [UIColor blackColor];
    if (cell.textView.text != nil && [cell.textView.text length] > 0) {
        if (msgObject != NULL && [msgObject[MsgType] isEqual:ContactType]){
            cell.textView.attributedText = [[NSAttributedString alloc]
                                            initWithString:cell.textView.text
                                            attributes:@{
                                                NSForegroundColorAttributeName:[UIColor systemBlueColor],
                                                NSFontAttributeName: [UIFont fontWithName:@"SFProDisplay-Semibold" size:16]
                                            }];
        }else if ([msgObject[IsEdited] isEqual:@1] && [msgObject[IsForwarded] isEqual:@1]){
            if ([msgObject[MsgType] isEqualToString:@"text"]){
                NSMutableAttributedString *attrString =  [Helper mentionHighlightedAttributedStringByNames:_userNames message:@" Forwarded \n  "].mutableCopy;
                NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                [style setLineSpacing:5];
                [attrString addAttributes:@{
                    NSForegroundColorAttributeName:[UIColor grayColor],
                    NSFontAttributeName: [UIFont fontWithName:@"SFProDisplay-Regular" size:15],
                    NSParagraphStyleAttributeName: style
                } range:NSMakeRange(0, ForwardedString.length)];
                NSMutableAttributedString *attrEdit = [Helper mentionHighlightedAttributedStringByNames:_userNames message:message.text].mutableCopy;
                NSString *orignalMessage = [attrEdit.string stringByReplacingOccurrencesOfString:EditedString withString:@""];
                NSRange textRange = NSMakeRange(0, attrEdit.length);
                NSRange range = NSMakeRange(orignalMessage.length, EditedString.length);
                if (NSEqualRanges(NSIntersectionRange(textRange, range), range)) {
                    [attrEdit addAttributes:@{
                        NSForegroundColorAttributeName:[UIColor lightGrayColor],
                        NSFontAttributeName: [UIFont fontWithName:@"SFProDisplay-Regular" size:15]
                    } range:NSMakeRange(orignalMessage.length, EditedString.length)];
                }
                
                NSMutableAttributedString *mutableAttString = [[NSMutableAttributedString alloc] init];
                [mutableAttString appendAttributedString:attrString];
                [mutableAttString appendAttributedString:attrEdit];
                cell.textView.attributedText = mutableAttString;
            }
        }else if ([msgObject[IsEdited] isEqual:@1] && [msgObject[ReplyMsgConfig] boolValue] == true) {
            if ([msgObject[MsgType] isEqualToString:@"text"]){
            NSString *strMessage = @"";
                    NSString *strParentMsg = msgObject[Parent_Msg];
                    strParentMsg = (strParentMsg != NULL) ? strParentMsg : @"";
                    if ([strParentMsg length] > 35) {
                        NSRange range = [strParentMsg rangeOfComposedCharacterSequencesForRange:(NSRange){0, 35}];
                        strParentMsg = [strParentMsg substringWithRange:range];
                        strParentMsg = [strParentMsg stringByAppendingString:@"…"];
                    }
            strMessage = [NSString stringWithFormat:@"Replied to a thread:%@",strParentMsg];
                NSMutableAttributedString *attrString =  [Helper mentionHighlightedAttributedStringByNames:_userNames message:cell.textView.text].mutableCopy;
                NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                [style setLineSpacing:5];
                [attrString addAttributes:@{
                    NSForegroundColorAttributeName:[UIColor grayColor],
                    NSFontAttributeName: [UIFont fontWithName:@"SFProDisplay-Regular" size:14],
                    NSParagraphStyleAttributeName: style
                } range:NSMakeRange(0, strMessage.length)];
               NSString* strMsgEdit = [NSString stringWithFormat:@"%@",EditedString];
                NSMutableAttributedString *attrEdit = [Helper mentionHighlightedAttributedStringByNames:_userNames message:strMsgEdit].mutableCopy;
               // NSString *orignalMessage = [attrEdit.string stringByReplacingOccurrencesOfString:EditedString withString:@""];
                NSRange textRange = NSMakeRange(0, attrEdit.length);
                NSRange range = NSMakeRange(0, EditedString.length);
                if (NSEqualRanges(NSIntersectionRange(textRange, range), range)) {
                    [attrEdit addAttributes:@{
                        NSForegroundColorAttributeName:[UIColor lightGrayColor],
                        NSFontAttributeName: [UIFont fontWithName:@"SFProDisplay-Regular" size:14]
                    } range:NSMakeRange(0, EditedString.length)];
                }
                
                NSMutableAttributedString *mutableAttString = [[NSMutableAttributedString alloc] init];
                [mutableAttString appendAttributedString:attrString];
                [mutableAttString appendAttributedString:attrEdit];
                
                cell.textView.attributedText = mutableAttString.copy;
          }
        }else if (msgObject != NULL && ![msgObject[IsDeletedMSG] boolValue] && [msgObject[IsEdited] isEqual:@1]){
            NSMutableAttributedString *attrString = [Helper mentionHighlightedAttributedStringByNames:_userNames message:message.text].mutableCopy;
            NSString *orignalMessage = [attrString.string stringByReplacingOccurrencesOfString:EditedString withString:@""];
            NSRange textRange = NSMakeRange(0, attrString.length);
            NSRange range = NSMakeRange(orignalMessage.length, EditedString.length);
            if (NSEqualRanges(NSIntersectionRange(textRange, range), range)) {
                [attrString addAttributes:@{
                    NSForegroundColorAttributeName:[UIColor lightGrayColor],
                    NSFontAttributeName: [UIFont fontWithName:@"SFProDisplay-Regular" size:15]
                } range:NSMakeRange(orignalMessage.length, EditedString.length)];
            }
        cell.textView.attributedText = attrString.copy;
        }else if (msgObject != NULL && ![msgObject[IsDeletedMSG] boolValue] && [msgObject[IsForwarded] isEqual:@1] && message.media == NULL){
            if ([msgObject[MsgType] isEqualToString:@"text"]){
                NSMutableAttributedString *attrString =  [Helper mentionHighlightedAttributedStringByNames:_userNames message:cell.textView.text].mutableCopy;
                NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                [style setLineSpacing:5];
                [attrString addAttributes:@{
                    NSForegroundColorAttributeName:[UIColor grayColor],
                    NSFontAttributeName: [UIFont fontWithName:@"SFProDisplay-Regular" size:15],
                    NSParagraphStyleAttributeName: style
                } range:NSMakeRange(0, ForwardedString.length)];
                cell.textView.attributedText = attrString.copy;
            }
        }else if ([msgObject[ReplyMsgConfig] boolValue] == true){
            if ([msgObject[MsgType] isEqualToString:@"text"]){
            NSString *strMessage = @"";
                    NSString *strParentMsg = msgObject[Parent_Msg];
                    strParentMsg = (strParentMsg != NULL) ? strParentMsg : @"";
                    if ([strParentMsg length] > 35) {
                        NSRange range = [strParentMsg rangeOfComposedCharacterSequencesForRange:(NSRange){0, 35}];
                        strParentMsg = [strParentMsg substringWithRange:range];
                        strParentMsg = [strParentMsg stringByAppendingString:@"…"];
                    }
            strMessage = [NSString stringWithFormat:@"Replied to a thread:%@",strParentMsg];
                NSMutableAttributedString *attrString =  [Helper mentionHighlightedAttributedStringByNames:_userNames message:cell.textView.text].mutableCopy;
                NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                [style setLineSpacing:5];
                [attrString addAttributes:@{
                    NSForegroundColorAttributeName:[UIColor grayColor],
                    NSFontAttributeName: [UIFont fontWithName:@"SFProDisplay-Regular" size:15],
                    NSParagraphStyleAttributeName: style
                } range:NSMakeRange(0, strMessage.length)];
            cell.textView.attributedText = attrString.copy;
        }
        }else {
            
            cell.textView.attributedText =  [Helper mentionHighlightedAttributedStringByNames:_userNames message:cell.textView.text];
            cell.textView.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:17];
        }
    }/*
    chatReplyCount *replyCountView = [cell.cellBottomLabel viewWithTag:1000];
    if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row )
    {
        cell.contentView.userInteractionEnabled = YES;
        cell.cellBottomLabel.userInteractionEnabled = YES;
        NSDictionary *dicMessage = [_chatHistory objectAtIndex:indexPath.row];
        
        if ([dicMessage valueForKey:@"reaction"] != nil && [dicMessage valueForKey:@"reaction"] != [NSNull null] ) {
            
            if (replyCountView == nil) {
                replyCountView = [[[NSBundle mainBundle] loadNibNamed:@"chatReplyCount" owner:self options:nil] objectAtIndex:0];
                replyCountView.tag = 1000;
            }
            [cell.cellBottomLabel addSubview:replyCountView];
            [replyCountView showHideChatReactionViews:YES];
            [replyCountView convertDataToEmoji:[dicMessage valueForKey:@"reaction"]];
            replyCountView.selectedIndexPath = indexPath;
            [cell.cellBottomLabel bringSubviewToFront:replyCountView.collectionView];
            if ([currentMessage.senderId isEqualToString:self.senderId]) {
                // Out Going
                [replyCountView messageSent:YES];
            } else {
                // In Coming
                [replyCountView messageSent:NO];
            }
//            [replyCountView.collectionView scrollsToTop];
        }
       
        if (_chatHistory.count - 1 == indexPath.row){
            [replyCountView setPaddingForLastMessage];
        }
    }
      */
    return cell;
}

-(void)messageDidReceived:(NSString *)message andSenderId:(NSString *)senderId
{
    [self.message addObject:[JSQMessage messageWithSenderId:senderId displayName:senderId text:message]];
    [[super collectionView] reloadData];
}

#pragma mark - Custom menu items
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath{
//    UICollectionView *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [self hadleLongPressAction:indexPath];
    return NO;
}

-(void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
}

- (void)customAction:(id)sender
{
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Custom Action", nil)
                                message:nil
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles:nil]
     show];
}

#pragma mark - Responding to collection view tap events
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath {
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *meesageData = _message[indexPath.row];
    
    if ([meesageData.media isKindOfClass:[JSQVideoMediaItem class]]){
        JSQVideoMediaItem *videoItemNew = (JSQVideoMediaItem *)meesageData.media;
        [self actionPlayVideo:videoItemNew.fileURL];


    }else  if ([meesageData.media isKindOfClass:[JSQLinkPreviewMediaItem class]]){
        JSQLinkPreviewMediaItem *linkPreviewMediaItem = (JSQLinkPreviewMediaItem *)meesageData.media;
        [UIApplication openLinkInBrowser:linkPreviewMediaItem.url];
    }
   else if ([meesageData.media isKindOfClass:[JSQPhotoMediaItem class]]){
        JSQPhotoMediaItem *photoItemNew = (JSQPhotoMediaItem *)meesageData.media;
       
        BFRImageViewController *imageVC = [[BFRImageViewController alloc] initWithImageSource:[NSArray arrayWithObjects:photoItemNew.image, nil]];
       [self presentViewController:imageVC animated:YES completion:nil];
       
    }
   else if ([meesageData.media isKindOfClass:[JSQLocationMediaItem class]]){
       NSString* directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%@,%@&daddr=%@,%@",userLat,userLong,userLat,userLong];
       if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
           [[UIApplication sharedApplication] openURL:[NSURL URLWithString: directionsURL] options:@{} completionHandler:^(BOOL success) {}];
       } else {
           UIApplication *application = [UIApplication sharedApplication];
           NSURL *URL = [NSURL URLWithString:directionsURL];
           [application openURL:URL options:@{} completionHandler:^(BOOL success) {
               if (success) {
               }
           }];
       }
   }
    
    NSDictionary *msgObject;
    if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row ){
        msgObject = [_chatHistory objectAtIndex:indexPath.row];
    }
    

}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
}


- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 20.0f;
}

-(NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath{

    //return nothing for incoming messages
    return nil;
}

#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
      
   
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    
    JSQMessage *message = [self.message objectAtIndex:indexPath.item];
    
    if (indexPath.item == 0) {
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
       return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
     
}

#pragma mark - JSQMessagesComposerTextViewPasteDelegate methods

- (BOOL)composerTextView:(JSQMessagesComposerTextView *)textView shouldPasteWithSender:(id)sender
{
    if ([UIPasteboard generalPasteboard].image) {
        // If there's an image in the pasteboard, construct a media item with that image and `send` it.
        JSQPhotoMediaItem *item = [[JSQPhotoMediaItem alloc] initWithImage:[UIPasteboard generalPasteboard].image];
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.senderId
                                                 senderDisplayName:self.senderDisplayName
                                                              date:[NSDate date]
                                                             media:item];
        [self.message addObject:message];
        [self finishSendingMessage];
        return NO;
    }
    return YES;
}

- (NSString *)convertObjectInToJsonString:(id)aDict {
    
    NSString *jsonString = @"";
    
    @try {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:aDict
                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        if (! jsonData) {
        } else {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            return jsonString;
        }
    } @catch (NSException *exception) {
    }
    
    return jsonString;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length>0) {
        if (isTypingActive !=true) {
            [self sendTypingStatusToRecepient:YES];
        } else {
            [self stopTypingIndicator];
        }
        
        return textView.text;
    }
    
    return YES;
}

-(void)sendTypingStatusToRecepient:(BOOL)isON {
    
    NSMutableDictionary * dictParam = [NSMutableDictionary new];
    [dictParam setObject:self.dictUserDetails[App_User_ID] forKey:App_User_ID]; // current selected user
    [dictParam setObject:[[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] forKey:User_eRTCUserId]; // logged in user
    if (isON) {
        isTypingActive = true;
        [dictParam setObject:[NSString stringWithFormat:@"on"] forKey:TypingStatusEvent];
       [self stopTypingIndicator];

    } else {
        isTypingActive = false;
        [dictParam setObject:[NSString stringWithFormat:@"off"] forKey:TypingStatusEvent];
      }
    
    [[eRTCChatManager sharedChatInstance] sendTypingStatus:dictParam];

}
-(void)stopTypingIndicator{
    
     [typingTimer invalidate];
     typingTimer = [NSTimer scheduledTimerWithTimeInterval:TypingTimeout
                                                    target:self
                                                  selector:@selector(userTypingFinished)
                                                  userInfo:nil
                                                   repeats:NO];
}
-(void)userTypingFinished {
    [self sendTypingStatusToRecepient:NO];
}
#pragma mark - JSQMessagesViewAccessoryDelegate methods

- (void)messageView:(JSQMessagesCollectionView *)view didTapAccessoryButtonAtIndexPath:(NSIndexPath *)path
{
}

#pragma mark - Actions
-(UIImage*)getImage:(NSString*)strImageURL
{
    __block UIImage *image =nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSURL *imageURL = [NSURL URLWithString:strImageURL];
                       NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                       //This is your completion handler
                       dispatch_sync(dispatch_get_main_queue(), ^{
                           //If self.image is atomic (not declared with nonatomic)
                           // you could have set it directly above
                           image = [UIImage imageWithData:imageData];
                           // return image;
                           //This needs to be set here now that the image is downloaded
                           // and you are back on the main thread
                           
                       });
                   });
    return image;
    //Any code placed outside of the block will likely
    // be executed before the block finishes.
}



#pragma mark - 3D Touch
- (void)check3DTouch {
    [self registerForPreviewingWithDelegate:self sourceView:self.view];
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    return [[BFRImageViewController alloc] initWithImageSource:self.imgURL];
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self presentViewController:viewControllerToCommit animated:YES completion:nil];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)] && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self check3DTouch];
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


- (void)actionPlayVideo:(NSURL*)videoUrl{
    //NSURL *videoURL=[NSURL fileURLWithPath:[[reverseArray objectAtIndex:indexPath.row]valueForKey:@"videoPath"]];
    AVPlayerViewController * _moviePlayer1 = [[AVPlayerViewController alloc] init];
    _moviePlayer1.player = [AVPlayer playerWithURL:videoUrl];
    [self presentViewController:_moviePlayer1 animated:YES completion:^{
        [_moviePlayer1.player play];
    }];
}

#pragma mark JSQAudioRecorderViewDelegate

-(void)jsqAudioRecorderViewDidCancelRecording {
    [self.inputToolbar.contentView.textView setHidden:NO];
    [self.inputToolbar.contentView.recorderView setHidden:YES];
}

-(void)jsqAudioRecorderView:(JSQAudioRecorderView *)sender audioRecorderErrorDidOccur:(NSError *)audioError {
    
}

-(void)jsqAudioRecorderView:(JSQAudioRecorderView *)sender didFinishRecording:(NSData *)audioData {
    [self.inputToolbar.contentView.textView setHidden:NO];
    [self.inputToolbar.contentView.recorderView setHidden:YES];
    
    if (audioData != nil) {
    }
}

-(void)contactsDetailsFromPhoneContactBook{
    
    CNContactPickerViewController *picker = [[CNContactPickerViewController alloc] init];
    
    picker.delegate = self;
    
    picker.displayedPropertyKeys = @[CNContactPhoneNumbersKey];
    
    [self presentViewController:picker animated:YES completion:nil];
    
    
}
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContacts:(NSArray<CNContact *> *)contacts {
    
    for (CNContact *contact in contacts) {
        NSString*ContactEmail;
        NSString *emailtype;
        NSArray <CNLabeledValue<CNPhoneNumber *> *> *phoneNumbers = contact.phoneNumbers;
        NSString *Name = contact.givenName;
        CNLabeledValue<CNPhoneNumber *> *firstPhone = [phoneNumbers firstObject];
        CNPhoneNumber *number = firstPhone.value;
        NSString *phoneMobile = number.stringValue;
        NSString *phoneNumbertype = firstPhone.label;
        
//        for (CNLabeledValue<NSString*>* email in contact.emailAddresses) {
//            if ([email.identifier isEqualToString:contact.identifier]) {
//                ContactEmail = (NSString *)email.value;
//                 emailtype = email.label;
//            }
//            else{
                ContactEmail = @"test@gmail.com";
                emailtype = @"work";
            //}
       // }

        dictContact = [[NSMutableDictionary alloc]init];
        [dictContact setValue:Name forKey:Key_Name];
        NSMutableDictionary*dictphone = [[NSMutableDictionary alloc]init];
        [dictphone setValue:phoneNumbertype forKey:@"type"];
        [dictphone setValue:phoneMobile forKey:@"number"];
        NSArray*contactnumber = [NSArray arrayWithObjects:dictphone,nil];
        NSMutableDictionary*dictEmail = [[NSMutableDictionary alloc]init];
        
        [dictEmail setValue:emailtype forKey:@"type"];
        [dictEmail setValue:ContactEmail forKey:@"email"];
        [dictContact setValue:contactnumber forKey:Key_Number];
        NSArray*email = [NSArray arrayWithObjects: dictEmail,nil];
        [dictContact setValue:email forKey:Key_Email];
        JSQMessage *contactmessage = [[JSQMessage alloc] initWithSenderId:self.senderId
                                                        senderDisplayName:self.senderDisplayName
                                                                     date:[NSDate date]
                                                                     text:phoneMobile];
        
        
     
       [self sendContactNumber:dictContact];
        [_message addObject:contactmessage];
        [self finishSendingMessageAnimated:YES];
        
        
    }
}
-(void)contactPickerDidCancel:(CNContactPickerViewController *)picker {
}

#pragma mark API
-(void) sendContactNumber:(NSDictionary*)contact {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        NSMutableDictionary*dictParam = [[NSMutableDictionary alloc]init];
        if (self.dictUserDetails[App_User_ID] != nil && self.dictUserDetails[App_User_ID] != [NSNull null]) {
            
            // Turn off the location manager to save power.
            
            NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
            
            [dictParam setValue:self.strThreadId forKey:ThreadID];
            [dictParam setValue:userId forKey:SendereRTCUserId];
            [dictParam setValue:@"contact" forKey:MsgType];
            [dictParam setValue:contact forKey:@"contact"];
            
            [[eRTCChatManager sharedChatInstance] sendContactMessageWithParam:dictParam andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                NSDictionary *dictResponse = (NSDictionary *)json;
                if (dictResponse[@"success"] != nil) {
                    BOOL success = (BOOL)dictResponse[@"success"];
                    if (success) {
                        if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
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
                [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
            }];
        }else {
            [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
        }
    }
}

#pragma mark - custom actions

- (void)hadleLongPressAction:(NSIndexPath *) indexPath {
    UIAlertController * view =  [UIAlertController
                                 alertControllerWithTitle:nil
                                 message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* copy = [UIAlertAction
                           actionWithTitle:@"Copy"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
        NSDictionary *dictConfig = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
        if ([dictConfig[@"copyChatEnable"] boolValue]) {
            [self copyMessageWithIndexPath:indexPath];
        }else{
            [self.view makeToast:@"Copy message is not available now. Please contact your administrator."];
        }
        
    }];
    
    UIAlertAction* favourite = [UIAlertAction
                                actionWithTitle:@"Remove From Favourites"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
        NSLog(@"Fav Un Fav");
        NSDictionary * dictMessage = [NSDictionary new];
        if (self->_chatHistory.count > indexPath.row) {
            dictMessage = [self->_chatHistory objectAtIndex:indexPath.row];
        }
        
        [self isMarkFavouriteWithIndexPath:dictMessage favouriteUser:false];
    }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action) {
                                                         //Do some thing here
                                                     }];
    [copy setValue:[[UIImage imageNamed:@"copy"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [copy setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    [favourite setValue:[[UIImage imageNamed:@"Vector"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [favourite setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    NSUInteger index = indexPath.row ;
    if (_chatHistory.count >= index) {
        NSDictionary * dictMessage = [_chatHistory objectAtIndex:index];
        if (dictMessage != NULL && [dictMessage[MsgType] isEqual:@"text"]){
            [view addAction:copy];
        }
    }
   
    [view addAction:favourite];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
}


-(void)isMarkFavouriteWithIndexPath:(NSDictionary *) dictMessage favouriteUser:(BOOL)isFavouriteEvent {
        if (![Helper objectIsNilOrEmpty:dictMessage andKey:MsgUniqueId]) {
            BOOL isFavouite = NO;
            if (isFavouriteEvent) {
                
            }else{
            [self sendFavouriteAndUnfavourateMessage:dictMessage];
            }
                [[eRTCCoreDataManager sharedInstance] isMarkFavouriteWithMessageUniqueId:dictMessage[MsgUniqueId] andMarkFavourite:isFavouite andCompletionHandler:^(BOOL isMarkFavourite) {
                NSMutableDictionary * dictTemp = [NSMutableDictionary dictionaryWithDictionary:dictMessage];
                [dictTemp setObject:[NSNumber numberWithBool:(isMarkFavourite) ? isFavouite : !isFavouite] forKey:IsFavourite];
                    [AppDelegate sharedAppDelegate].isUpdateChatHistory = YES;
                for (int i = 0; i < [self->_chatHistory count]; i++)
                {
                    NSMutableDictionary * dictParam = [NSMutableDictionary new];
                    dictParam = [self->_chatHistory objectAtIndex:i];
                    if ([dictParam[MsgUniqueId] isEqualToString:dictMessage[MsgUniqueId]]) {
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                        [self->_chatHistory removeObjectAtIndex:indexPath.row];
                        [self.message removeObjectAtIndex:indexPath.row];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.collectionView reloadData];
                            [self scrollToBottomAnimated:YES];
                        });
                    }
                }
            } faliure:^(NSError * _Nonnull error) {
                [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
            }];
        }
    
}



/*
-(void)isMarkFavouriteWithIndexPath:(NSIndexPath *) indexPath {
    if (_chatHistory.count > indexPath.row) {
        NSDictionary * dictMessage = [_chatHistory objectAtIndex:indexPath.row];
        if (![Helper objectIsNilOrEmpty:dictMessage andKey:MsgUniqueId]) {
            BOOL isFavouite = NO;
           /* if (![Helper objectIsNilOrEmpty:dictMessage andKey:IsFavourite]) {
                if ([dictMessage[IsFavourite] intValue]) {
                    isFavouite = NO;
                } else {
                    isFavouite = YES;
                }
            }
            [[eRTCCoreDataManager sharedInstance] isMarkFavouriteWithMessageUniqueId:dictMessage[MsgUniqueId] andMarkFavourite:isFavouite andCompletionHandler:^(BOOL isMarkFavourite) {
//                NSMutableDictionary * dictTemp = [NSMutableDictionary dictionaryWithDictionary:dictMessage];
//                [dictTemp setObject:[NSNumber numberWithBool:isMarkFavourite] forKey:IsFavourite];
                if(isMarkFavourite){
                    [AppDelegate sharedAppDelegate].isUpdateChatHistory = YES;
                    [self->_chatHistory removeObjectAtIndex:indexPath.row];
                    if (self.message.count > 0 && indexPath.row < self.message.count){
                        [self.message removeObjectAtIndex:indexPath.row];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                                       [self.collectionView reloadData];
                                       [self scrollToBottomAnimated:YES];
                                   });
                }

            } faliure:^(NSError * _Nonnull error) {
                [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
            }];
        }
    }
}*/

- (void)copyMessageWithIndexPath:(NSIndexPath *) indexPath{
    NSString *text = @"";
    if (_chatHistory.count > indexPath.row) {
        NSDictionary * dictMessage = [_chatHistory objectAtIndex:indexPath.row];
        if (dictMessage != NULL && [dictMessage[MsgType] isEqual:@"text"]){
            text = [Helper getRemoveMentionTags:dictMessage[Message]];
        }
    }
    [[UIPasteboard generalPasteboard] setString:text];
}

- (void)audioMediaItem:(JSQAudioMediaItem *)audioMediaItem didChangeAudioCategory:(NSString *)category options:(AVAudioSessionCategoryOptions)options error:(NSError *)error {
    if (currentAudioMediaItem != NULL && audioMediaItem != currentAudioMediaItem && currentAudioMediaItem.gAudioPlayer != NULL && currentAudioMediaItem.gAudioPlayer.isPlaying){
        [currentAudioMediaItem pause];
    }
    currentAudioMediaItem = audioMediaItem;
}

-(void)didchatStarFavourite:(NSNotification *) notification{
    NSDictionary *userobj = notification.object;
    NSString *strAppUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
   // if (self.dictUserDetails[App_User_ID] != nil && self.dictUserDetails[App_User_ID] != [NSNull null]) {
    if ([userobj[@"eRTCUserId"] isEqualToString:strAppUserId]){
    NSArray*aryChats = userobj[@"chats"];
    NSDictionary*dictChats = aryChats[0];
    NSMutableDictionary * dictParam = [NSMutableDictionary new];
    if ([dictChats[@"isStarred"] boolValue]){
    [dictParam setValue:[NSNumber numberWithInt:0] forKey:IsFavourite];
    }else{
    [dictParam setValue:[NSNumber numberWithInt:1] forKey:IsFavourite];
    }
    [dictParam setValue:dictChats[MsgUniqueId] forKey:MsgUniqueId];
    if (dictChats[@"isStarred"] != NULL) {
    [self isMarkFavouriteWithIndexPath:dictParam favouriteUser:true];
    }
    }
}

-(void)sendFavouriteAndUnfavourateMessage:(NSDictionary*)editstarFavourite {
        NSMutableDictionary * dictFavouriteMessage = [NSMutableDictionary new];
       // if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil) {
            if (self.strThreadId != nil && self.strThreadId != [NSNull null]) {
                [dictFavouriteMessage setValue:editstarFavourite[ThreadID] forKey:ThreadID];
                [dictFavouriteMessage setValue:editstarFavourite[MsgUniqueId] forKey:MsgUniqueId];
                if ([editstarFavourite[IsFavourite] intValue])
                {
                [dictFavouriteMessage setValue:IsFalse forKey:IsStarred];
                }else {
                [dictFavouriteMessage setValue:Istrue forKey:IsStarred];
                }
                NSLog(@"dictFavouriteMessage--> %@",dictFavouriteMessage);
                [[eRTCChatManager sharedChatInstance] addandRemoveFavouriteMessage:dictFavouriteMessage andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
               // [self updateMessageCellAtIndexPath:indexPath message:object];
                    [self performSelector:@selector(getChatHistory) withObject:nil afterDelay:0.1];
                } andFailure:^(NSError * _Nonnull error) {
                    NSLog(@"error--> %@",error);
                   [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
                }];
            }
       // }
    }



#pragma mark - SearchBar Delegates
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
   [self searchForText:searchController.searchBar.text];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self searchForText:searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self searchForText:searchText];
}
    
    - (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
        return  true;
    }

//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
//    [self.view endEditing:true];
//    [self searchForText:@""];
//    _arrAllUsers = [NSMutableArray new];
//    [self.collectionView reloadData];
//
//}

#pragma mark Private
- (void)searchForText:(NSString*)searchString {
    _chatHistory = [NSMutableArray new];
    _message = [NSMutableArray new];
    if (_arrChatHistory.count > 0 && [searchString length] > 0) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"message contains[c] %@",searchString];
        NSPredicate * predicatetext = [NSPredicate predicateWithFormat:@"text contains[c] %@",searchString];
        NSArray * _arrFiltered = [_arrChatHistory filteredArrayUsingPredicate:predicate];
        NSArray * _arrMessageData = [_arrFilter filteredArrayUsingPredicate:predicatetext];
        _message = [NSMutableArray arrayWithArray:_arrMessageData];
        _chatHistory = [NSMutableArray arrayWithArray:_arrFiltered];
    } else {
        _chatHistory = _arrChatHistory.mutableCopy;
        _message = _arrFilter.mutableCopy;
    }
    [self.collectionView reloadData];
}
    
    
    - (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
        [searchBar resignFirstResponder];
        [searchBar setShowsCancelButton:NO animated:YES];
    }

-(void)updateMessageCellAtIndexPath:(NSIndexPath*)path message:(NSDictionary*)details{
    [[eRTCCoreDataManager sharedInstance] getUserReplyThreadChatHistoryWithThreadID:self.strThreadId withParentID:[self.dictUserDetails valueForKey:MsgUniqueId] andCompletionHandler:^(id ary, NSError *err) {
       // self->_chatHistory = [NSMutableArray arrayWithArray:ary];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
        NSArray *sortedArray=[ary sortedArrayUsingDescriptors:@[sort]];
        [sortedArray enumerateObjectsUsingBlock:^(id  _Nonnull data, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([data isKindOfClass:[NSDictionary class]] && data[@"msgUniqueId"] != NULL && [data[@"msgUniqueId"] isEqual:details[@"msgUniqueId"]]){
                JSQMessage *message = [self getMediaItemFrom:data indexPath:path];
                if (message != NULL && self->_chatHistory.count > 0 && self->_chatHistory.count > path.row ){
                    [self.message replaceObjectAtIndex:path.row  withObject:message];
                    [self->_chatHistory  replaceObjectAtIndex:path.row withObject:[data copy]];
                    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:path.row inSection:0]]];
                }
                return;
            }
        }];
    }];
}

-(JSQMessage*) getMediaItemFrom:(NSDictionary*) dict indexPath:(NSIndexPath *)path {
    JSQMessage *message = NULL;
    NSString * _strSenderID = @"";
    NSString * _strDisplayName = @"";
    BOOL isOutgoingMsg = NO;
    id<JSQMessageMediaData> newMediaData = nil;
    id newMediaAttachmentCopy = nil;
    
    if ([dict[SendereRTCUserId] isEqualToString:self.senderId]) {
        _strSenderID = self.senderId;
        _strDisplayName = self.senderDisplayName;
        isOutgoingMsg =YES;
    }
    
    if ([dict[MsgType] isEqualToString:@"text"]) {
        
        NSLog(@"creationDateTime--%@",[dict valueForKey:@"createdAt"]);
        
        double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
        NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
        NSLog(@"msgdate--%@",msgdate);
        NSString *strMessage = @"";
        if ([dict[@"replyMsgConfig"] boolValue]){
            strMessage = [NSString stringWithFormat:@"Replied to a thread:%@ \n %@",dict[Parent_Msg],dict[Message]];
        }else if (![dict[IsDeletedMSG] boolValue]  &&  [dict[@"isEdited"] boolValue]){
            strMessage = [NSString stringWithFormat:@"%@%@",dict[Message], EditedString];
        }else{
            strMessage = dict[Message];
        }
        id sendereRTCUserId = dict[@"sendereRTCUserId"];
        __block NSString *userName = _strDisplayName;
        if (sendereRTCUserId != NULL){
//            [_arrAllUsers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                if (obj[@"userId"] != NULL && [sendereRTCUserId isEqual:obj] && obj[@"name"]){
//                    userName = obj[@"name"];
//                }
//            }];
            NSURL *first = [Helper getFirstUrlIfExistInMessage:strMessage];
            double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
            NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
            if (first){
                /*
                JSQLinkPreviewMediaItem *item = [[JSQLinkPreviewMediaItem alloc] initWithURL:first details:dict completionHandler:^(NSDictionary * _Nonnull details, NSError * _Nullable error) {
                    NSString *msgId = details[MsgUniqueId];
                    NSString *threadId = details[ThreadID];
                    NSUInteger index = [self getIndexOfMessageId:msgId threadId:threadId];
                    if (index != -1 && index <= self->_chatHistory.count){
                        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
                    }
                }];
                message = [[JSQMessage alloc] initWithSenderId:sendereRTCUserId
                                                senderDisplayName:userName
                                                             date:msgdate
                                                            media:item];
                 */
                NSString *msgId = dict[MsgUniqueId];
                NSString *threadId = dict[ThreadID];
                NSUInteger index = [self getIndexOfMessageId:msgId threadId:threadId];
                if (index != -1 && index <= self->_chatHistory.count){
                [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
                    message = self->_message[index];
                }
            }else {
                message = [[JSQMessage alloc] initWithSenderId:sendereRTCUserId
                senderDisplayName:userName
                             date:msgdate
                             text:NSLocalizedString(strMessage, nil)];
                
            }
        }
    }else if ([dict[MsgType] isEqualToString:@"gify"]) {
        //  JSQGIFMediaItem *photoItem = [[JSQGIFMediaItem alloc] initWithImage:[FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:strGIF]]];
        
        JSQGIFMediaItem *photoItemCopy = nil;
        if (![Helper stringIsNilOrEmpty:dict[LocalFilePath]] && [dict[LocalFilePath] length] > 0) {
            NSData *data = [NSData dataWithContentsOfFile:dict[LocalFilePath]];
            photoItemCopy = [[JSQGIFMediaItem alloc] initWithImageData:data];
        } else {
            NSString *strGIF = dict[GifyFileName];
            photoItemCopy = [[JSQGIFMediaItem alloc] init];
            [NSData ertc_dataWithContentsOfStringURL:strGIF onCompletionHandler:^(NSData * _Nullable data) {
                [photoItemCopy setImageData:data];
                [self.collectionView reloadItemsAtIndexPaths:@[path]];
            }];
        }
        if (isOutgoingMsg) {
            photoItemCopy.appliesMediaViewMaskAsOutgoing = YES;
            
        } else {
            photoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
        }
        newMediaAttachmentCopy = [UIImage imageWithData:photoItemCopy.imageData];
        newMediaData = photoItemCopy;
        double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
        NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
        message = [[JSQMessage alloc] initWithSenderId:_strSenderID senderDisplayName:_strDisplayName date:msgdate media:photoItemCopy];
        // newMessage = [JSQMessage messageWithSenderId:_strSenderID displayName:_strDisplayName media:photoItemCopy];
    }else if ([dict[MsgType] isEqualToString:@"file"]) {
        
        NSString *strURL = @"";
        JSQFileMediaItem *photoItemCopy = [[JSQFileMediaItem alloc] init];
        if (![Helper stringIsNilOrEmpty:dict[LocalFilePath]] && [dict[LocalFilePath] length] > 0) {
            
            strURL = dict[LocalFilePath];
            photoItemCopy.fileURL = [NSURL fileURLWithPath:strURL];
        } else {
            strURL = dict[FilePath];
        }
        //  [NSData ertc_dataWithContentsOfStringURL:strURL onCompletionHandler:^(NSData * _Nullable data) {
        
        //   }];
        [photoItemCopy setFileExtension:strURL.pathExtension];
        if (isOutgoingMsg) {
            photoItemCopy.appliesMediaViewMaskAsOutgoing = YES;
            
        } else {
            photoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
        }
        
        // newMediaAttachmentCopy = [UIImage imageWithData:photoItemCopy.imageData];
        newMediaData = photoItemCopy;
        
        double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
        NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
        message = [[JSQMessage alloc] initWithSenderId:_strSenderID senderDisplayName:_strDisplayName date:msgdate media:photoItemCopy];
        // newMessage = [JSQMessage messageWithSenderId:_strSenderID displayName:_strDisplayName media:photoItemCopy];
    }else if ([dict[MsgType] isEqualToString:@"image"]) {
        NSString *strURL = @"";
        JSQPhotoMediaItem *photoItemCopy = nil;
        photoItemCopy = [[JSQPhotoMediaItem alloc] init];
        if (![Helper stringIsNilOrEmpty:dict[LocalFilePath]] && [dict[LocalFilePath] length] > 0) {
            strURL = dict[LocalFilePath];
        } else {
            strURL = dict[FilePath];
        }
        [NSData ertc_dataWithContentsOfStringURL:strURL onCompletionHandler:^(NSData * _Nullable data) {
            [photoItemCopy setImage:[UIImage imageWithData:data]];
            [self.collectionView reloadItemsAtIndexPaths:@[path]];
        }];
        if (isOutgoingMsg) {
            photoItemCopy.appliesMediaViewMaskAsOutgoing = YES;
            
        } else {
            photoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
        }
        newMediaAttachmentCopy = [UIImage imageWithCGImage:photoItemCopy.image.CGImage];
        newMediaData = photoItemCopy;
        double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
        NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
        message = [[JSQMessage alloc] initWithSenderId:_strSenderID senderDisplayName:_strDisplayName date:msgdate media:photoItemCopy];
        
        // newMessage = [JSQMessage messageWithSenderId:_strSenderID displayName:_strDisplayName media:photoItemCopy];
    }else if ([dict[MsgType] isEqualToString:@"video"]) {
        NSURL * videoURL = nil;
        if (![Helper stringIsNilOrEmpty:dict[LocalFilePath]] && [dict[LocalFilePath] length] > 0) {
            videoURL = [NSURL URLWithString:[@"file://" stringByAppendingString:dict[LocalFilePath]]];
        } else {
            videoURL = [NSURL URLWithString:dict[FilePath]];
        }
        
        JSQVideoMediaItem *videoItem = [[JSQVideoMediaItem alloc] initWithFileURL:videoURL isReadyToPlay:YES];
        if (isOutgoingMsg) {
            videoItem.appliesMediaViewMaskAsOutgoing = YES;
            
        } else {
            videoItem.appliesMediaViewMaskAsOutgoing = NO;
        }
        double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
        NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
        // newMessage = [JSQMessage messageWithSenderId:_strSenderID displayName:_strDisplayName media:videoItem];
        message = [[JSQMessage alloc] initWithSenderId:_strSenderID senderDisplayName:_strDisplayName date:msgdate media:videoItem];
        
    } else if ([dict[MsgType] isEqualToString:@"audio"]) {
        NSURL * audioURL = nil;
        if (![Helper stringIsNilOrEmpty:dict[LocalFilePath]] && [dict[LocalFilePath] length] > 0) {
            audioURL = [NSURL URLWithString:[@"file://" stringByAppendingString:dict[LocalFilePath]]];
        } else {
            audioURL = [NSURL URLWithString:dict[FilePath]];
        }
        JSQAudioMediaItem *audioItem = [[JSQAudioMediaItem alloc] init];
        audioItem.delegate = self;
        audioItem.audioViewAttributes.audioCategory = AVAudioSessionCategoryPlayback;
        if (isOutgoingMsg ) {
            audioItem.appliesMediaViewMaskAsOutgoing = YES;
            
        } else {
            audioItem.appliesMediaViewMaskAsOutgoing = NO;
        }
        [NSData ertc_dataWithContentsOfStringURL:[audioURL absoluteString] onCompletionHandler:^(NSData * _Nullable data) {
            [audioItem setAudioData:data];
            [self.collectionView reloadItemsAtIndexPaths:@[path]];
            
        }];
        double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
        NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
        message = [[JSQMessage alloc] initWithSenderId:_strSenderID senderDisplayName:_strDisplayName date:msgdate media:audioItem];
        //  newMessage = [JSQMessage messageWithSenderId:_strSenderID displayName:_strDisplayName media:audioItem];
        
        
    } else if ([dict[MsgType] isEqualToString:@"contact"]) {
        if (![Helper objectIsNilOrEmpty:dict andKey:ContactType]) {
            NSDictionary *dictContact = dict[ContactType];
            if ([dictContact count] > 0 && ![Helper objectIsNilOrEmpty:dictContact andKey:Numbers]) {
                NSArray *aryNumbers = dictContact[Numbers];
                if ([aryNumbers count] > 0) {
                    NSDictionary *dictNumber = [aryNumbers objectAtIndex:0];
                    if (![Helper stringIsNilOrEmpty:dictNumber[Number]] && [dictNumber[Number] length] > 0) {
                        double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
                        NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
                        
                        NSString *strContactPersonName = [Helper getContactNameString:dictContact];
                        message = [[JSQMessage alloc] initWithSenderId:_strSenderID
                                                        senderDisplayName:_strDisplayName
                                                                     date:msgdate
                                                                     text:[NSString stringWithFormat:@"%@",strContactPersonName]]; // \n%@ , dictNumber[Number]
                    }
                }
            }
        }
    } else if ([dict[MsgType] isEqualToString:@"location"]) {
        if (![Helper objectIsNilOrEmpty:dict andKey:LocationType]) {
            NSDictionary *dictLocation = dict[LocationType];
            if (![Helper stringIsNilOrEmpty:dictLocation[Latitude]] && ![Helper stringIsNilOrEmpty:dictLocation[Longitude]]) {
                CLLocation *clLocation = [[CLLocation alloc] initWithLatitude:[dictLocation[Latitude] doubleValue] longitude:[dictLocation[Longitude] doubleValue] ];
                JSQLocationMediaItem *locationItem = [[JSQLocationMediaItem alloc] init];
                if (isOutgoingMsg) {
                    locationItem.appliesMediaViewMaskAsOutgoing = YES;
                    
                } else {
                    locationItem.appliesMediaViewMaskAsOutgoing = NO;
                }
                double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
                NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
                message = [[JSQMessage alloc] initWithSenderId:_strSenderID senderDisplayName:_strDisplayName date:msgdate media:locationItem];
                // newMessage = [JSQMessage messageWithSenderId:_strSenderID
                //      displayName:_strDisplayName
                //    media:locationItem];
                [locationItem setLocation:clLocation withCompletionHandler:^{
                   [self.collectionView reloadItemsAtIndexPaths:@[path]];
                }];
            }
        }
    }
    
    if (message && dict[MsgStatusEvent]){
        message.msgStatus = dict[MsgStatusEvent];
    }
    return message;
}




@end
