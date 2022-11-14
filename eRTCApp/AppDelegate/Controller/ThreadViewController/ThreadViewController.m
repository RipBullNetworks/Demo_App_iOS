//
//  ThreadViewController.m
//  eRTCApp
//
//  Created by apple on 22/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "ThreadViewController.h"
#import "ProfileViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "BFRImageViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "JSQAudioRecorderView.h"
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import "UIImage+animatedGIF.h"
#import "JSQFileMediaItem.h"
#import "chatReplyCount.h"
#import "ChatReactions.h"
#import <HWPanModal/HWPanModal.h>
#import "FavViewCell.h"
#import "LocationManager.h"
//#import "eRTCApp-Swift.h"

#import "JSQGIFMediaItem.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import <GiphyUISDK/GiphyUISDK.h>
#import <GiphyCoreSDK/GiphyCoreSDK.h>
#import <Toast/Toast.h>
#import "AudioClickable.h"
//@import GiphyUISDK;
//@import GiphyCoreSDK;
#import "ForwardToViewController.h"
#import "JSQLinkPreviewMediaItem.h"
#import "ShowGIFViewController.h"
#import "JSQAudioMediaItem+JSQAudioMediaItemX.h"
#import "UIApplication+X.h"
#import "ReportsMessageViewController.h"
#import "JSQReportCell.h"
#import "ReplayThreadMessageCell.h"
#import "ReplyThreadFooterCell.h"

@interface ThreadViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIViewControllerPreviewingDelegate,MPMediaPickerControllerDelegate, JSQAudioRecorderViewDelegate,CLLocationManagerDelegate,CNContactViewControllerDelegate,CNContactPickerDelegate, UIGestureRecognizerDelegate,UISearchBarDelegate,UICollectionViewDelegateFlowLayout,footerReplyDelegate,replyThreadHeaderDelegate> {
    
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
    NSMutableArray *_arrMessageHistory;
    UILabel *noDataLabel ;
    
    JSQAudioMediaItem *currentAudioMediaItem;
    UIBarButtonItem *searchButton;
    UIBarButtonItem *cancelButton;
    UISearchController *searchController;
    UISearchBar *searchBar;
    NSMutableArray *arrChatThread;
    
    NSOperationQueue *queue;
    NSInteger numberofPage;
    NSInteger currentPage;
    NSMutableArray *arrGlobalData;
}
@property(nonatomic, strong) JSQAudioRecorderView *audioRecorderView;
@property(nonatomic, strong) NSMutableArray *message;
@property(nonatomic, strong) NSMutableArray *arrReplyHistory;
@property(nonatomic, strong) NSMutableArray *arrFilter;
@property (strong, nonatomic) NSArray *imgURL;
@property (strong, nonatomic) NSSet *userNames;
@property (strong, nonatomic) NSMutableArray *arrAllUsers;
@property (strong, nonatomic) NSMutableArray *aryWhole;

@end

@implementation ThreadViewController
//@synthesize playerViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"dictUserDetails--%@",self.dictUserDetails);
    
    [self showUserIconAndNameOnNavigationTitle];
    [self configureChatWindow];
    _message = [[NSMutableArray alloc] init];
    _arrFilter = [[NSMutableArray alloc] init];
    self->arrGlobalData = [[NSMutableArray alloc] init];
    NSString *strAppUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
    NSString *strUserName = [[UserModel sharedInstance] getUserDetailsUsingKey:User_Name];
    self.senderId = strAppUserId;
    self.senderDisplayName = strUserName;
    
    [self geoLocation];
    [self hideInputToolbar];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ReplayThreadMessageCell" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReplayThreadMessageCell"];
   // [self.collectionView registerNib:[UINib nibWithNibName:@"ReplyThreadFooterCell" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ReplyThreadFooterCell"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didchatStarFavourite:)
                                                 name:DidReceveEventStarFavouriteMessage
                                               object:nil];
    UIImage *image = [[UIImage imageNamed:@"search"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self->numberofPage = 1;
    self->currentPage = 0;
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
    noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height)];
    noDataLabel.textColor        = [UIColor blueColor];
    noDataLabel.textAlignment    = NSTextAlignmentCenter;
    NSDictionary *config = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
        if ([config[@"e2eChat"] boolValue]){
        noDataLabel.text             = @"Threads is not available for e2e project";
        }else{
        noDataLabel.text             = @"";
        [self getChatHistoryThread:@"" isDirection:@"future"];
       }
    self.collectionView.backgroundView = noDataLabel;
   
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (currentAudioMediaItem != nil) {
        [currentAudioMediaItem pause];
    }
    noDataLabel.text             = @"";
    self.collectionView.backgroundView = noDataLabel;
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

-(NSUInteger)getIndexOfMessageId:(NSString *)msgId threadId:(NSString*)threadId{
    if (msgId != NULL && threadId != NULL && [@"" isEqualToString:threadId]) {
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
    NSMutableArray *arrNewData = aryChat.mutableCopy;
    _message = [[NSMutableArray alloc] init];
    if (aryChat.count > 0) {
    for (int i=0; i<[arrNewData count]; i++) {
        NSDictionary * dict = [arrNewData objectAtIndex:i];
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
                        NSMutableDictionary *update =  [arrNewData[i] mutableCopy];
                        
                        if ([details[MsgUniqueId] isEqual:update[MsgUniqueId]]){
                            update[@"mediaFileName"] = details[@"mediaFileName"];
                            update[LocalFilePath] = details[LocalFilePath];
                           // aryChat[i] = update.copy;
                            [arrNewData replaceObjectAtIndex:i withObject:update];
                            
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
                double timeStamp = [[dict valueForKey:@"senderTimeStampMs"]doubleValue];
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
                        NSMutableDictionary *update =  [arrNewData[i] mutableCopy];
                        if ([details[MsgUniqueId] isEqual:update[MsgUniqueId]]){
                            update[@"mediaFileName"] = details[@"mediaFileName"];
                            update[LocalFilePath] = details[LocalFilePath];
                            [arrNewData replaceObjectAtIndex:i withObject:update];
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
                double timeStamp = [[dict valueForKey:@"senderTimeStampMs"]doubleValue];
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
                double timeStamp = [[dict valueForKey:@"senderTimeStampMs"]doubleValue];
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
                        NSMutableDictionary *update =  [arrNewData[i] mutableCopy];
                        if ([details[MsgUniqueId] isEqual:update[MsgUniqueId]]){
                            update[@"mediaFileName"] = details[@"mediaFileName"];
                            update[LocalFilePath] = details[LocalFilePath];
                            [arrNewData replaceObjectAtIndex:i withObject:update];
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
                        NSMutableDictionary *update =  [arrNewData[i] mutableCopy];
                        if ([details[MsgUniqueId] isEqual:update[MsgUniqueId]]){
                            update[@"mediaFileName"] = details[@"mediaFileName"];
                            update[LocalFilePath] = details[LocalFilePath];
                            [arrNewData replaceObjectAtIndex:i withObject:update];
                        }
                        [self finishSendingMessage];
                    }
                }];
                
                double timeStamp = [[dict valueForKey:@"senderTimeStampMs"]doubleValue];
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
                        }else{
                            double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
                            NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
                            
                            NSString *strContactPersonName = [Helper getContactNameString:dictContact];
                            newMessage = [[JSQMessage alloc] initWithSenderId:_strSenderID
                                                            senderDisplayName:_strDisplayName
                                                                         date:msgdate
                                                                         text:[NSString stringWithFormat:@"%@",strContactPersonName]];
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
                        double timeStamp = [[dict valueForKey:@"senderTimeStampMs"]doubleValue];
                        NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
                        newMessage = [[JSQMessage alloc] initWithSenderId:_strSenderID senderDisplayName:_strDisplayName date:msgdate media:locationItem];
                        [locationItem setLocation:clLocation withCompletionHandler:^{
                            [self.collectionView reloadData];
                        }];
                    }
                }
            } else if ([dict[MsgType] isEqualToString:@"text"]) {
                double timeStamp = [[dict valueForKey:@"senderTimeStampMs"]doubleValue];
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
                        if (index != -1 && index <= arrNewData.count){
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
        NSMutableDictionary *dictMessage = [NSMutableDictionary new];
            [dictMessage setObject:self.message forKey:@"chatHistory"];
        
            NSLog(@"dictMessage<<<123>>>>> %@", dictMessage);
            [_arrMessageHistory addObject:dictMessage];
    }
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
    lbl.text = @"Threads";
    lbl.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:16];
    lbl.textAlignment = NSTextAlignmentCenter;
    [titleView addSubview:lbl];
    self.navigationItem.titleView = titleView;
}

-(void)configureChatWindow {
    self.inputToolbar.contentView.textView.delegate =self;
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

    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:[NSDate date]
                                                          text:text ];
    
     message.msgStatus =@"sending...";
    [_message addObject:message];
    [self finishSendingMessageAnimated:YES];
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
        return _arrChatHistory.count;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
//    return CGSizeMake(collectionView.frame.size.width, 45.0);
//}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.frame.size.width, 115.0);
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
    
    NSLog(@"threadindexPath.section >>>>>%d",indexPath.section);
    if (_arrMessageHistory.count > 0) {
        NSDictionary *dictHistory = _arrMessageHistory[indexPath.section];
        NSArray *arrHistory = dictHistory[@"chatHistory"];
        JSQMessage *jsqM = [arrHistory objectAtIndex:indexPath.item];
        if([jsqM.media isKindOfClass:[JSQGIFMediaItem class]]){
            JSQGIFMediaItem *item = (JSQGIFMediaItem *)jsqM.media;
            [item.cachedImageView setNeedsLayout];
            
        }
    return [arrHistory objectAtIndex:indexPath.item];
    }
    return 0;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    if (_arrChatHistory.count > 0 && _arrChatHistory.count > section ){
        NSDictionary *dictHistory = _arrChatHistory[section];
        NSArray *arrHistory = dictHistory[@"chatHistory"];
        return [arrHistory count];
    }else{
        return 0;
    }
    return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *msgObject;
    if (_arrChatHistory.count > 0 && _arrChatHistory.count > indexPath.section ){
        NSDictionary *dictHistory = _arrChatHistory[indexPath.section];
        NSArray *arrHistory = dictHistory[@"chatHistory"];
        msgObject = [arrHistory objectAtIndex:indexPath.row];
    }
    
    JSQMessagesCollectionViewCell *cell  = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    if (msgObject && [msgObject valueForKey:@"isReported"] != nil && [msgObject valueForKey:@"isReported"] != [NSNull null] ){
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"JSQReportCell" forIndexPath:indexPath];
        cell.delegate = self;
        cell.cellTopLabel.hidden = true;
        cell.cellBottomLabel.hidden = true;
    }
    
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
                NSMutableAttributedString *attrEdit = [Helper mentionHighlightedAttributedStringByNames:_userNames message:msgObject[Message]].mutableCopy;
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
            NSMutableAttributedString *attrString = [Helper mentionHighlightedAttributedStringByNames:_userNames message:msgObject[Message]].mutableCopy;
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
        }else if (msgObject != NULL && ![msgObject[IsDeletedMSG] boolValue] && [msgObject[IsForwarded] isEqual:@1] && msgObject[Message] == NULL){
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
            //cell.textView.attributedText =  [Helper mentionHighlightedAttributedStringByNames:_userNames message:cell.textView.text];
            //cell.textView.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:17];
            
            cell.textView.attributedText = [Helper getuserMentionName:_userNames message:cell.textView.text];
            cell.textView.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:17];
            
        }
    }

    chatReplyCount *replyCountView = [cell.cellBottomLabel viewWithTag:1000];
    CGFloat trailingSpace = 0;
    if (_arrChatHistory.count > 0 && _arrChatHistory.count > indexPath.section ){
        NSDictionary *dictHistory = _arrChatHistory[indexPath.section];
        NSArray *arrHistory = dictHistory[@"chatHistory"];
    if (arrHistory.count - 1 == indexPath.row){
        trailingSpace = -40;
    }
  }
    if (!replyCountView){
        if (replyCountView == nil) {
            replyCountView = [[[NSBundle mainBundle] loadNibNamed:@"chatReplyCount" owner:self options:nil] objectAtIndex:0];
            replyCountView.tag = 1000;
        }
        [replyCountView showHideThreadReplyView:FALSE];
        [replyCountView showHideChatReactionViews:FALSE];
        [cell.cellBottomLabel addSubview:replyCountView];
    }
    else{
        
        [replyCountView showHideThreadReplyView:FALSE];
        [replyCountView showHideChatReactionViews:FALSE];
    }
    if (_arrChatHistory.count > 0 && _arrChatHistory.count > indexPath.section ){
        NSDictionary *dictHistory = _arrChatHistory[indexPath.section];
        NSArray *arrHistory = dictHistory[@"chatHistory"];
        cell.contentView.userInteractionEnabled = YES;
        cell.cellBottomLabel.userInteractionEnabled = YES;
        NSDictionary *dicMessage = [arrHistory objectAtIndex:indexPath.row];
        
        if ([dicMessage valueForKey:@"replyMsgCount"] != nil && [dicMessage valueForKey:@"replyMsgCount"] != [NSNull null] )
        {
            NSInteger isReplyAvailble = [[dicMessage valueForKey:@"replyMsgCount"] integerValue];
            [replyCountView showHideThreadReplyView:NO];
            if (isReplyAvailble > 0) {
                [replyCountView.btnReplyThread addTarget:self action:@selector(pushToReplyThreadVC:) forControlEvents:UIControlEventTouchUpInside];
                [cell bringSubviewToFront:replyCountView.btnReplyThread];
                replyCountView.btnReplyThread.tag = indexPath.row;
                replyCountView.lblCount.text = [NSString stringWithFormat:@"View more %@ replies",[dicMessage valueForKey:@"replyMsgCount"]];
                [replyCountView showHideThreadReplyView:YES];
            }
            [cell.cellBottomLabel bringSubviewToFront:replyCountView.collectionView];
        }
        
        if ([dicMessage valueForKey:@"reaction"] != nil && [dicMessage valueForKey:@"reaction"] != [NSNull null] ) {
            if (replyCountView == nil) {
                replyCountView = [[[NSBundle mainBundle] loadNibNamed:@"chatReplyCount" owner:self options:nil] objectAtIndex:0];
                replyCountView.tag = 1000;
            }
            [cell.cellBottomLabel addSubview:replyCountView];
            [replyCountView showHideChatReactionViews:YES];
            replyCountView.delegate = self;
            [replyCountView convertDataToEmoji:[dicMessage valueForKey:@"reaction"]];
            replyCountView.selectedIndexPath = indexPath;
            [cell.cellBottomLabel bringSubviewToFront:replyCountView.collectionView];
            if ([currentMessage.senderId isEqualToString:self.senderId]) {
                [replyCountView messageSent:YES];
            } else {
                [replyCountView messageSent:NO];
            }
        }
       
        UIView *parent = (cell.mediaView == NULL) ? cell.messageBubbleContainerView : cell.mediaView;
        FavViewCell *fav = [parent viewWithTag:999];
        if (dicMessage[@"isFavourite"] != NULL && [dicMessage[@"isFavourite"]  isEqual: @1] && [dicMessage[@"isDeletedMsg"]  isEqual: @0]){
            if (fav == NULL){
                fav = [[[NSBundle mainBundle] loadNibNamed:@"FavViewCell" owner:self options:nil] objectAtIndex:0];
                fav.translatesAutoresizingMaskIntoConstraints = NO;
                [parent addSubview:fav];
                CGFloat consSize;
                if ([msgObject valueForKey:@"name"] != nil && [msgObject valueForKey:@"name"] != [NSNull null] ) {
                    consSize = 15.f;
                }else {
                    consSize = 22.f;
                }
                NSLayoutConstraint *trailing =[NSLayoutConstraint
                                                constraintWithItem:fav
                                                attribute:NSLayoutAttributeTrailing
                                                relatedBy:NSLayoutRelationEqual
                                                toItem:parent
                                                attribute:NSLayoutAttributeTrailing
                                                multiplier:1.0f
                                                constant:-consSize];
                
                NSLayoutConstraint *top =[NSLayoutConstraint
                                             constraintWithItem:fav
                                             attribute:NSLayoutAttributeTop
                                             relatedBy:NSLayoutRelationEqual
                                             toItem:parent
                                             attribute:NSLayoutAttributeTop
                                             multiplier:1.0f
                                             constant:4.f];
                fav.tag = 999;
                [parent addConstraint:trailing];
                [parent addConstraint:top];
            }
            
        }else {
            if (fav != NULL){
                [fav removeFromSuperview];
            }
        }
        if (arrHistory.count - 1 == indexPath.row){
            [replyCountView setPaddingForLastMessage];
        }
    }
    return cell;
}

- (CGFloat)convertDataToEmoji:(NSDate *)data {
    
    NSArray *arrData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if ([arrData count] == 0) {
        return 30.0f;
    } else if ([arrData count] <= 6) {
        return 40.0f;
    } else if ([arrData count] <= 12) {
        return 80.0f;
    } else {
        return 120.0f;
    }
}

-(void)messageDidReceived:(NSString *)message andSenderId:(NSString *)senderId
{
    [self.message addObject:[JSQMessage messageWithSenderId:senderId displayName:senderId text:message]];
    [[super collectionView] reloadData];
}

#pragma mark - Custom menu items
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath{
//    UICollectionView *cell = [collectionView cellForItemAtIndexPath:indexPath];
   // [self hadleLongPressAction:indexPath];
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
    

}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"indexPath>>>>>>>>>>>>%@",_arrChatHistory);
    if (currentPage < numberofPage && indexPath.section == (_arrChatHistory.count-1)) {
        currentPage = numberofPage + 1;
        numberofPage = numberofPage + 1;
        NSDictionary *dict = _arrChatHistory[indexPath.section];
        NSLog(@"NSDictionary *dict>>>>>>>>>>>>%@",dict);
        if (dict[MsgUniqueId] != nil && dict[MsgUniqueId] != [NSNull null]) {
            NSString *msgUniqId = dict[MsgUniqueId];
            [self getChatHistoryThread:@"" isDirection:@"past"];
            NSLog(@"NSDictionary *dict>>>>>>>>>>>>%@",msgUniqId);
        }
    }
}


- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 30.0f;
}

-(NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath{
    JSQMessage *message;
    
    if (_arrMessageHistory.count > 0 && _arrMessageHistory.count > indexPath.section ){
        NSDictionary *dictHistory = _arrMessageHistory[indexPath.section];
        NSArray *arrHistory = dictHistory[@"chatHistory"];
        currentMessage = [arrHistory objectAtIndex:indexPath.row];
    }
    return nil;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    
    if (_arrMessageHistory.count > 0 && _arrMessageHistory.count > indexPath.section ){
        
    NSDictionary *dictHistory = _arrChatHistory[indexPath.section];
    if (kind == UICollectionElementKindSectionHeader) {
        ReplayThreadMessageCell *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReplayThreadMessageCell" forIndexPath:indexPath];
        NSString*strNumberofReplies = [NSString stringWithFormat:@"Replies %@",dictHistory[Thread_NumberOfReplies]];
        if (dictHistory[Thread_message] != nil && dictHistory[Thread_message] != [NSNull null]) {
        headerView.lblMessage.text = [NSString stringWithFormat:@"%@",dictHistory[Thread_message]];
        }
        headerView.lblUserType.text = [NSString stringWithFormat:@"%@",dictHistory[@"participantsUser"]];//participantsUser
        [headerView.btnReplies setTitle:strNumberofReplies forState:UIControlStateNormal];
        headerView.delegate = self;
        
        if ([dictHistory[ThreadType] isEqualToString:@"single"]) {
            [headerView.imgUserProfile setImage:[UIImage imageNamed:@"forwardMsgToUser"]];
            if (dictHistory[Key_Name] != nil && dictHistory[Key_Name] != [NSNull null]) {
            headerView.lbluserName.text = [NSString stringWithFormat:@"%@",dictHistory[Key_Name]];
            }
        }else{
            [headerView.imgUserProfile setImage:[UIImage imageNamed:@"groupIcon"]];
            if (dictHistory[Key_Name] != nil && dictHistory[Key_Name] != [NSNull null]) {
            headerView.lbluserName.text = [NSString stringWithFormat:@"%@",dictHistory[Key_Name]];
            }
        }
        reusableview = headerView;
    }
  }
//      if (kind == UICollectionElementKindSectionFooter) {
//        ReplyThreadFooterCell *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ReplyThreadFooterCell" forIndexPath:indexPath];
//        footerview.delegate = self;
//        reusableview = footerview;
//         }
    return reusableview;
}


#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
      
   
}

//

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    
    JSQMessage *message;
    if (_arrMessageHistory.count > 0 && _arrMessageHistory.count > indexPath.section ){
        NSDictionary *dictHistory = _arrMessageHistory[indexPath.section];
        NSArray *arrHistory = dictHistory[@"chatHistory"];
        message = [arrHistory objectAtIndex:indexPath.row];
    }
    
    
    
//    if (indexPath.item == 0) {
//       // return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
//    }
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


#pragma mark API
-(void) sendContactNumber:(NSDictionary*)contact {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        NSMutableDictionary*dictParam = [[NSMutableDictionary alloc]init];
        if (self.dictUserDetails[App_User_ID] != nil && self.dictUserDetails[App_User_ID] != [NSNull null]) {
            // Turn off the location manager to save power.
            NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
            //[dictParam setValue:self.strThreadId forKey:ThreadID];
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
    }
}

-(void)sendFavouriteAndUnfavourateMessage:(NSDictionary*)editstarFavourite {
        NSMutableDictionary * dictFavouriteMessage = [NSMutableDictionary new];
        if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil) {
            if (self.dictUserDetails[App_User_ID] != nil && self.dictUserDetails[App_User_ID] != [NSNull null]) {
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
                //[self updateMessageCellAtIndexPath:indexPath message:object];
                } andFailure:^(NSError * _Nonnull error) {
                    NSLog(@"error--> %@",error);
                   [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
                }];
            }
        }
    }

-(void)getChatHistoryThread:(NSString*)msgUniqId isDirection:(NSString*)direction {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];

        NSMutableDictionary *dictParam = @{}.mutableCopy;
        [dictParam setValue:@20 forKey:@"pageSize"];
        //[dictParam setValue:@"true" forKey:@"deep"];
        
        
        if ([msgUniqId isEqualToString:@""]) {
        } else {
            [dictParam setValue:msgUniqId forKey:@"currentMsgId"];
            [dictParam setValue:direction forKey:@"direction"];
        }
    
        [[eRTCChatManager sharedChatInstance] getChatThreadHistory:dictParam andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            [KVNProgress dismiss];
            
            
            NSDictionary *dictResponse = (NSDictionary *)json;
            dispatch_async(dispatch_get_main_queue(), ^{
            if (dictResponse[@"success"] != nil) {
                BOOL success = (BOOL)dictResponse[@"success"];
                if (success) {
                    if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                        [KVNProgress dismiss];
                        NSDictionary *dictResult = (NSDictionary *)json;
                        dictResult = (NSDictionary *)dictResponse[@"result"];
                        if (dictResult.count > 0) {
                            _arrChatHistory = [NSMutableArray new];
                            _arrMessageHistory = [NSMutableArray new];
                        if (dictResult[@"chats"] != nil && dictResult[@"chats"] != [NSNull null]) {
                            NSArray *arr = dictResult[@"chats"];
                            [self->arrGlobalData addObjectsFromArray:arr];
                          
                            [self showNoRecordFouundMessage:arrGlobalData.mutableCopy];
                            for (int i = 0; i < [arrGlobalData count]; i++)
                            {
                                NSMutableDictionary * dictParam = [NSMutableDictionary new];
                                NSMutableDictionary * dictGroupInfo = [NSMutableDictionary new];
                                NSMutableDictionary * dictChatHistory = [NSMutableDictionary new];
                                dictParam = [arrGlobalData.mutableCopy objectAtIndex:i];
                                [dictGroupInfo setValue:dictParam[ThreadID] forKey:ThreadID];
                                if (dictParam[Thread_msg] != nil && dictParam[Thread_msg] != [NSNull null]) {
                                NSDictionary*dictThread = dictParam[Thread_msg];
                                NSArray *arrParticipants = dictThread[Group_Participants];
                                NSString *strUser;
                                if ([arrParticipants count] > 0) {
                                strUser = [self getUsernameWithUserId:arrParticipants];
                                }
                                [dictChatHistory setValue:dictThread[ThreadType] forKey:ThreadType];
                                [dictChatHistory setValue:strUser forKey:@"participantsUser"];
                                if ([dictThread[ThreadType] isEqualToString:@"single"]) {
                                [[eRTCChatManager sharedChatInstance] getuserInfoWithERTCId:dictParam[SendereRTCUserId] andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                                    NSMutableArray *arrUser = [NSMutableArray new];
                                    arrUser = json;
                                    if (arrUser.count > 0) {
                                        NSDictionary*dictUser = [arrUser objectAtIndex:0];
                                        [dictChatHistory setValue:dictUser[Key_Name] forKey:Key_Name];
                                    }
                                } andFailure:^(NSError * _Nonnull error) {
                                }];
                                }else{
                                    [[eRTCChatManager sharedChatInstance]  getgroupByThreadId:dictParam andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                                        NSDictionary *dictGroup = json[Key_Result];
                                        [dictChatHistory setValue:dictGroup[Key_Name] forKey:Key_Name];
                                    }andFailure:^(NSError * _Nonnull error) {
                                    }];
                                }
                                    
                                NSMutableArray *sortedArray = dictParam[Thread_replies];
                                NSDictionary *dictReplies = dictParam[ReplyThreadFeatureData];
                                [dictChatHistory setValue:dictParam[ThreadID] forKey:ThreadID];
                                [dictChatHistory setValue:dictParam[MsgUniqueId] forKey:MsgUniqueId];
                                if ([dictParam[MsgType] isEqualToString:LocationType]){
                                [dictChatHistory setValue:LocationType forKey:Thread_message];
                                }else if ([dictParam[MsgType] isEqualToString:TextType]) {
                                [dictChatHistory setValue:dictParam[Thread_message] forKey:Thread_message];
                                }else if ([dictParam[MsgType] isEqualToString:ContactType]) {
                                    [dictChatHistory setValue:ContactType forKey:Thread_message];
                                }else if ([dictParam[MsgType] isEqualToString:Image]) {
                                    [dictChatHistory setValue:Image forKey:Thread_message];
                                }else if ([dictParam[MsgType] isEqualToString:AudioFileName]) {
                                    [dictChatHistory setValue:AudioFileName forKey:Thread_message];
                                }else if ([dictParam[MsgType] isEqualToString:Key_video]) {
                                    [dictChatHistory setValue:Key_video forKey:Thread_message];
                                }
                                [dictChatHistory setValue:dictParam[MsgType] forKey:MsgType];
                                NSString*numberOfReplies = [NSString stringWithFormat:@"%@",dictReplies[Thread_NumberOfReplies]];
                                [dictChatHistory setValue:numberOfReplies forKey:Thread_NumberOfReplies];
                                [dictChatHistory setObject:sortedArray forKey:@"chatHistory"];
                                [_arrChatHistory addObject:dictChatHistory];
                                [self showChatFromLocalDB:sortedArray];
                                    
                              }
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.collectionView reloadData];
                                [self scrollToBottomAnimated:YES];
                               });
                            
                        }
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                        _arrChatHistory = [NSMutableArray new];
                        [self.collectionView reloadData];
                        NSArray *arr;
                        [self showNoRecordFouundMessage:arr];
                        });
                    }}
                }
            }
            });
        }andFailure:^(NSError * _Nonnull error) {
            [KVNProgress dismiss];
            [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
        }];
    } else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}


//Selected ReplyThread button Actionn Protocol Delegate
-(void)selectedReplyThreadIndex:(ReplyThreadFooterCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
}

-(void)selectedThreadMoreIndex:(ReplyThreadFooterCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSDictionary *dict = _arrChatHistory[indexPath.section];
    [self openMoreFollowAndDeletethread:dict];
}


-(void)openMoreFollowAndDeletethread:(NSDictionary *)dictData {
    UIAlertController *activitySheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *followThread = [UIAlertAction actionWithTitle:NSLocalizedString(@"Unfollow Thread", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self followUnFollowMsg:dictData];
    }];
    UIAlertAction *deleteThread = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete Message", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [activitySheet addAction:followThread];
   // [activitySheet addAction:deleteThread];
   
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [activitySheet addAction:cancel];
    [self presentViewController:activitySheet animated:YES completion:nil];
}

// Implement Follow And Unfollow Thread Function
- (void)followUnFollowMsg:(NSDictionary *)dict {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
    NSMutableDictionary * dictMsgFollowUnfollow = [NSMutableDictionary new];
    [dictMsgFollowUnfollow setValue:@false forKey:@"follow"];
    [dictMsgFollowUnfollow setValue:dict[ThreadID] forKey:ThreadID];
    [dictMsgFollowUnfollow setValue:dict[MsgUniqueId] forKey:MsgUniqueId];
    [dictMsgFollowUnfollow setValue:@"true" forKey:@"isStarred"];

    [[eRTCChatManager sharedChatInstance] followUnFollowChatMessage:dictMsgFollowUnfollow andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        NSDictionary *dictResponse = (NSDictionary *)json;
        if (dictResponse[@"success"] != nil) {
            BOOL success = (BOOL)dictResponse[@"success"];
            if (success) {
                [self.view makeToast:ThreadUnFollowMessage];
                [self getChatHistoryThread:@"" isDirection:@""];
            }
        }
    } andFailure:^(NSError * _Nonnull error) {
        [KVNProgress dismiss];
        [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
    }];

    }else{
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}

-(NSString *)getUsernameWithUserId:(NSArray *)arrUsers {
    NSMutableArray *arrUserName = [NSMutableArray new];
    for (int i = 0; i < [arrUsers count]; i++)
    {
    NSDictionary *dictData = [arrUsers objectAtIndex:i];
        
    [[eRTCChatManager sharedChatInstance] getuserInfoWithERTCId:dictData[@"user"] andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        NSMutableArray *arrUser = [NSMutableArray new];
        NSLog(@"json>>>>>>>>>>>>%@",json);
        arrUser = json;
        if ([arrUser count] > 0) {
            NSDictionary*dictUser = [arrUser objectAtIndex:0];
            if (dictUser[App_User_ID] != nil && dictUser[App_User_ID] != [NSNull null]) {
            NSString*strUserID = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
            [arrUserName addObject:dictUser[Key_Name]];
            }
        }
    } andFailure:^(NSError * _Nonnull error) {
    }];
}
    return [self convertToCommaSeparatedFromArray:arrUserName];
}

-(NSString *)convertToCommaSeparatedFromArray:(NSArray*)array{
    return [array componentsJoinedByString:@","];
}


-(void)showNoRecordFouundMessage:(NSArray*)arrNoRecord {
    if (arrNoRecord.count > 0){
        noDataLabel.text             = @"";
        self.collectionView.backgroundView = noDataLabel;
    }else{
        noDataLabel.text             = @"No thread found";
        self.collectionView.backgroundView = noDataLabel;
    }
}


@end
