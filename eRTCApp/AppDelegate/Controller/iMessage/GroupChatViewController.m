//
//  GroupChatViewController.m
//  eRTCApp
//
//  Created by rakesh  palotra on 24/02/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import "GroupChatViewController.h"
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
#import "JSQGIFMediaItem.h"
#import "InfoGroupViewController.h"
#import "ThreadChatGroupViewController.h"
#import "chatReplyCount.h"
#import "ChatReactions.h"
#import <HWPanModal/HWPanModal.h>
#import "FavViewCell.h"
#import "LocationManager.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import <GiphyUISDK/GiphyUISDK.h>
#import <Toast/Toast.h>
#import "AudioClickable.h"
#import "ObserverRemovable.h"
#import "JSQLinkPreviewMediaItem.h"
#import "RecentChatViewController.h"
#import "ShowGIFViewController.h"
#import "JSQAudioMediaItem+JSQAudioMediaItemX.h"
#import "UIApplication+X.h"
#import "ReportsMessageViewController.h"
#import "JSQReportCell.h"
#import "JiraBotCollectionCell.h"
//#import "GroupEventCell.h"



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
typedef void (^LoadPreviouseMessageCompletion)(void);
@interface GroupChatViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIViewControllerPreviewingDelegate,MPMediaPickerControllerDelegate, JSQAudioRecorderViewDelegate,CLLocationManagerDelegate,CNContactViewControllerDelegate,CNContactPickerDelegate, UIGestureRecognizerDelegate,GiphyDelegate,UIDocumentPickerDelegate,UIDocumentInteractionControllerDelegate,UITableViewDataSource, UITableViewDelegate, ChatReactionsDelegateDelegate, EmojisViewControllerDelegate, ChatReplyCountDelegate, JSQAudioMediaItemDelegate, AudioClickable, ObserverRemovable,ChatUndoMsgDelegate>
{
    
    // Typing Indicator
       NSTimer * typingTimer;
       BOOL  isTypingActive;
       BOOL  isFrozenChannel;
       BOOL  isBlockUI;
       BOOL  isDomain;
       BOOL  isFilter;
       BOOL  isProfanity;
       JSQMessage *currentMessage;
       CLLocationManager *locationManager;
       CLGeocoder *geoCoder;
       CLPlacemark *placeMark;
       NSString*address;
       NSNumber *userLat,*userLong;
       NSMutableDictionary*dictlocation;
       NSMutableDictionary*dictContact;
       NSMutableDictionary *dictImage;
       NSMutableArray *_chatHistory;
    NSIndexPath *selectedChatIndexPath;
    JSQAudioMediaItem *currentAudioMediaItem;
    LocationManager *locManager;
    UILabel *lblHeader;
    NSMutableDictionary *editingMessage;
    UIView *editMessageView;
    UIButton *rightButton;
    NSArray<NSArray<NSLayoutConstraint*>*> *editMessageViewconstrainsts;
    NSDictionary *thread;
    UIView *headerView;
    UIView *reportView;
    UIView *bottemView;
    UIView *deactivatedView;
    UIView *profenityView;
    UIView *frozenView;
    UIView *removeView;
    UILabel *statusLabel;
    NSSet *typingNames;
    UIRefreshControl *refreshControl;
    UILabel *blockUnblockLabel;
    CGSize  *cellSize;
    NSIndexPath *selectedPath;
    BOOL  isSearchMessage;
    BOOL  isRemovedChannel;
    BOOL  isSelectedMentionUser;
    NSDictionary *dictDomainProfinityFilter;
    BOOL  isGroupActivated;
    NSString *mentionsUser;
    NSString *mentionUserEmail;
    NSMutableArray *arrMentionUser;
    NSMutableArray *arrMentionEmail;
    NSNumber *isDomainFilt;
    NSMutableArray *arrUser;
}
@property (strong, nonatomic) NSSet *userNames;
@property(nonatomic, strong) JSQAudioRecorderView *audioRecorderView;
@property(nonatomic, strong) NSMutableArray *message;
@property (strong, nonatomic) NSArray *imgURL;

@property (strong, nonatomic) NSMutableArray *numbersArrayList;
@property (strong, nonatomic) NSMutableArray *aryMentioned;
@property (assign) int keyboardheight;
@property (strong, nonatomic) NSMutableArray *aryWhole;
@end
@implementation GroupChatViewController

-(BOOL) isMessageEditing {
    return editingMessage != NULL;
}
-(BOOL)isMessageEdited {
    BOOL isEdited = FALSE;
    
    if (editingMessage != NULL &&
        editingMessage[@"editingMessage"] != NULL &&
        editingMessage[@"editedMessage"] != NULL &&
        editingMessage[@"editingMessage"][Message] != NULL &&
        editingMessage[@"editedMessage"][Message] != NULL &&
        ![editingMessage[@"editingMessage"][Message] isEqualToString: editingMessage[@"editedMessage"][Message]]
        ){
        isEdited = TRUE;
    }
    return isEdited;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.isUserSearchText) {
        [KVNProgress show];
        [self showCollectionView:YES];
    }
    
    isRemovedChannel = false;
    [self.collectionView registerNib:[UINib nibWithNibName:@"JSQReportCell" bundle:nil] forCellWithReuseIdentifier:@"JSQReportCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JiraBotCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"JiraBotCollectionCell"];
   // [self.collectionView registerNib:[UINib nibWithNibName:@"GroupEventCell" bundle:nil] forCellWithReuseIdentifier:@"JiraBotCollectionCell"];
    
    arrMentionUser = [NSMutableArray new];
    arrMentionEmail = [NSMutableArray new];
    self.aryMentioned = [NSMutableArray new];
    self->arrUser = [NSMutableArray new];
    
    self.keyboardheight = 0;
    self.isUserSearchActive = false;
    [self.tblMention setHidden:YES];
    self.tblMention.dataSource = self;
    self->isSelectedMentionUser = NO;
    self.numbersArrayList  = @[@"One", @"Two", @"Three", @"Four", @"Five", @"Six"];
    // Do any additional setup after loading the view.
    [AppDelegate sharedAppDelegate].isUpdateChatHistory = NO;
    [self showUserIconAndNameOnNavigationTitle];
    [self configureChatWindow];
    
    _message = [[NSMutableArray alloc] init];
    
    NSString *strAppUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
    NSString *strUserName = [[UserModel sharedInstance] getUserDetailsUsingKey:User_Name];
    self.senderId = strAppUserId;
    
    if (strUserName !=nil) {
           self.senderDisplayName = strUserName;

       }else{
           self.senderDisplayName = @"";

       }
    self.strThreadId = [NSString stringWithFormat:@"%@",_dictGroupinfo[ThreadID]];
    [eRTCChatManager getThreadByThreadID:_dictGroupinfo[ThreadID] andCallBack:^(id  _Nonnull threads, NSError * _Nonnull err) {
        self->thread = threads;
    }];
    [self performSelector:@selector(getChatHistory) withObject:nil afterDelay:0.5];

    [self geoLocation];
    [Giphy configureWithApiKey:@"6bUrIxVye4HJtD0B9PtYq3tMwiCSvcup" verificationMode:false] ;
    [self addObservers];
    [self callAPIForGetContactsUserList];
    locManager = [LocationManager new];
    
    [locManager setCompletion:^(CLLocation * _Nonnull newLocation, NSError * _Nonnull error) {
        if (newLocation != NULL && error == NULL){
            [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                if (error == nil && [placemarks count] > 0)
                {
                    NSMutableDictionary *details = @{}.mutableCopy;
                    self->placeMark = [placemarks lastObject];
                    self->userLat = [NSNumber numberWithDouble:newLocation.coordinate.latitude];
                    self->userLong= [NSNumber numberWithDouble:newLocation.coordinate.longitude];
                    // For user address
                    
                    NSString *locatedAt = [[self->placeMark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@","];
                    self->address = [[NSString alloc]initWithString:locatedAt];
                    NSString *Area = [[NSString alloc]initWithString:self->placeMark.locality];
                    NSString *Country = [[NSString alloc]initWithString:self->placeMark.country];
                    NSString *CountryArea = [NSString stringWithFormat:@"%@, %@", Area,Country];
                    NSLog(@"%@",CountryArea);
                    
                    self->dictlocation = [[NSMutableDictionary alloc]init];
                    [self->dictlocation setValue: self->userLat forKey:@"latitude"];
                    [self->dictlocation setValue:self->userLong forKey:@"longitude"];
                    [self->dictlocation setValue:self->address forKey:@"address"];
                    [self callAPIForShareCurrentLocation:^{
                        [self finishSendingMessageAnimated:YES];
                    }];
                } else {
                    NSLog(@"%@", error.debugDescription);
                }
            }];
        }else if (error != NULL){
            [Helper showAlertOnController:@"Location Error" withMessage:error.localizedDescription onController:self];
        }
        
    }];
    
    [self addControllerToRecentController];
   
    NSTimeInterval delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    [self headerShowMessage];
    });
   // [self showProfanityFilter:true];
    [self getGroupDetails];
    
    //_aryProfinityFilter = @[@"One", @"Two", @"Three", @"Four", @"Five", @"Six"];
    //_aryDomainFilter = @[@"https://www.google.com"];
    // [self removeChannel:true];
   [self callApiGetChatSetting];
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
    } else {
        // Fallback on earlier versions
    }
    [UIView setAnimationsEnabled:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(didReceivedGroupEvent:)
                                                name:DidReceivedGroupEvent
                                              object:nil];
    
    [self showProfanityFilter]; //add Profanity filter on input Toolbar
    [self addDomanFilterOnInputToolbar]; //add Domain filter on input Toolbar
    [self showDeactivatedMessagePopup];
    
    [self setShowProfanityFilter:false]; // Show profanity filter view inputtoolbar
    [self setDomainFilter:false]; //// Show Domain filter view inputtoolbar
    [self isShowDeactivatedMessage:false];
    [self groupByThreadId:self.strThreadId];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //[self Frozen_Channel:TRUE];
    /*
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [self showOfflineMsg:false];
    }else{
        [self showOfflineMsg:true];
    }*/
    [self getGroupDetails];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                            selector:@selector(didReceivedGroupEvent:)
//                                                name:DidReceivedGroupEvent
//                                              object:nil];
}

    
-(void)showOfflineMsg:(BOOL *)isOfflineMessage {
    if (isOfflineMessage) {
        NSTimeInterval delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        CGFloat topbarHeight = ([UIApplication sharedApplication].statusBarFrame.size.height +
               (self.navigationController.navigationBar.frame.size.height ?: 0.0));
            self->headerView = [[UIView alloc] initWithFrame:CGRectMake(0, topbarHeight, self.collectionView.bounds.size.width, 64)];
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(48, 5, self.collectionView.bounds.size.width-54, 60)];
        UIImageView *imageNowifi = [[UIImageView alloc] initWithFrame:CGRectMake(16, 20, 24, 24)];
        
        [headerView setBackgroundColor:[UIColor colorWithRed:255/255.0 green:237/255.0 blue:237/255.0 alpha:1]];
        lblTitle.textColor = UIColor.redColor;
        lblTitle.text = @"You are offline, please make sure you are connected to the internet.";
        [imageNowifi setImage:[UIImage imageNamed:@"no-wifi"]];
        [lblTitle setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:16.0]];
        lblTitle.numberOfLines = 0;
        lblTitle.textAlignment = NSTextAlignmentLeft;
            [self->headerView addSubview:lblTitle];
            [self->headerView addSubview:imageNowifi];
            [self.navigationController.view addSubview:self->headerView];
        });
    }else{
        [headerView removeFromSuperview];
    }
}
    



-(void)addControllerToRecentController{
    UIViewController *tabController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    UINavigationController *nvc  = ((UITabBarController*)tabController).viewControllers.firstObject;
    if ([tabController isKindOfClass:UITabBarController.class] && [nvc isKindOfClass:UINavigationController.class]){
        UIViewController *recentVC = [[nvc viewControllers] firstObject];
        if ([recentVC isKindOfClass:RecentChatViewController.class]){
            [((RecentChatViewController*)recentVC) addController:self];
        }
    }
}
-(void)geoLocation
{
    geoCoder = [[CLGeocoder alloc] init];
//    if (locationManager == nil)
//    {
//        locationManager = [[CLLocationManager alloc] init];
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//        locationManager.delegate = self;
//        [locationManager requestAlwaysAuthorization];
//    }
//    [locationManager startUpdatingLocation];
}

-(void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMessageNotification:)
                                                 name:DidRecievedMessageNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTypingStatusNotification:)
                                                 name:DidRecievedTypingStatusNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMsgStatus:)
                                                 name:DidRecievedMessageReadStatusNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(refreshChatData)
                                                   name:UpdatChatWindowNotification
                                                 object:nil];
  
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshReactionData:)
                                                name:DidRecievedReactionNotification
                                                object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateChatMsgNotification:)
                                                 name:DidUpdateChatNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDeleteChatMsgNotification:)
                                                 name:DidDeleteChatMessageNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didchatReportSuccess:)
                                                 name:ChatReportSuccessfully
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveEventList:)
                                                 name:DidReceveEventList
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didchatStarFavourite:)
                                                 name:DidReceveEventStarFavouriteMessage
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didgetchatSetting:)
                                                 name:DidGetChatSettingNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getRefreshModerationMessage:)
                                                 name:DeleteModerationMessage
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getIgnoreReportedMessage:)
                                                 name:DidGetChatReportedIdUpdated
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kGroupUpdateSuccessfully
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
        if (note.object != NULL && [note.object isKindOfClass:NSDictionary.class] && note.object[@"name"] != NULL){
//            self.title =
            NSMutableDictionary *dict = self.dictGroupinfo.mutableCopy;
            dict[Group_Name] = note.object[@"name"];
            self.dictGroupinfo = dict.copy;
            if (dict[Group_Name] != nil) {
                self-> lblHeader.text = dict[Group_Name];
            }
        }
    }];
    
 
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didupdateGroupProfile:)
                                                 name:UpdateGroupProfileSuccessfully
                                               object:nil];

}

-(void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:DidRecievedMessageNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:DidRecievedTypingStatusNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:DidRecievedMessageReadStatusNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:UpdatChatWindowNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:DidReceivedGroupEvent];
    [[NSNotificationCenter defaultCenter] removeObserver:DidRecievedReactionNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:DidUpdateChatNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:DidDeleteChatMessageNotification];
   // [[NSNotificationCenter defaultCenter] removeObserver:UIKeyboardDidShowNotification];
    //[[NSNotificationCenter defaultCenter] removeObserver:UIKeyboardDidHideNotification];

   // [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)getRefreshModerationMessage:(NSNotification *) notification{
    [self getChatHistory];
}

- (void)getIgnoreReportedMessage:(NSNotification *) notification{
    NSDictionary *data = [notification object];
    
    if ((![data[Chat_ReportId] isEqual:[NSNull null]]) && ([data[Chat_ReportId] length] != 0)) {
        [self performSelector:@selector(getChatHistory) withObject:nil afterDelay:0.5];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [self callApiGetGroupByGroupId:Freeze];
   if ([[AppDelegate sharedAppDelegate] isUpdateChatHistory]) {
          [AppDelegate sharedAppDelegate].isUpdateChatHistory = NO;
          [self refreshChatData];
      }
    
    if ([_dictGroupinfo[@"isActivated"] boolValue] == true){
        [self isShowDeactivatedMessage:true];
        self->isGroupActivated = true;
    }else{
        [self isShowDeactivatedMessage:false];
        self->isGroupActivated = false;
    }
    
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (currentAudioMediaItem != nil) {
            [currentAudioMediaItem pause];
        }
    [headerView removeFromSuperview];
    [frozenView removeFromSuperview];
    [removeView removeFromSuperview];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:DidRecievedMessageNotification object:nil];
   // [[NSNotificationCenter defaultCenter] removeObserver:self name:DidReceivedGroupEvent object:nil];
   // [self removeObservers];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [headerView removeFromSuperview];
    [frozenView removeFromSuperview];
    [removeView removeFromSuperview];
   // [[NSNotificationCenter defaultCenter] removeObserver:self name:DidReceivedGroupEvent object:nil];
   // [[NSNotificationCenter defaultCenter] removeObserver:DidReceivedGroupEvent];
}

-(void) dealloc {
    [self removeObservers];
}

-(void)showCollectionView:(BOOL)isHidden{
    [self.collectionView setHidden:isHidden];
}

- (void)loadPreviousMessages:(NSMutableDictionary *)details completion:(LoadPreviouseMessageCompletion) completion {
    
    [[eRTCChatManager sharedChatInstance] loadPreviousChatHistoryWithThreadID:thread[ThreadID] parameters:details.copy
                                                                andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
       
        [[eRTCCoreDataManager sharedInstance] getUserChatHistoryWithThreadID:self.strThreadId andCompletionHandler:^(NSArray* ary, NSError *err) {
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
            NSArray *sortedArray=[ary sortedArrayUsingDescriptors:@[sort]];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"msgType.length > 0"];
            self->_chatHistory = [NSMutableArray arrayWithArray:sortedArray];
            self->_message = [[NSMutableArray alloc] init];
            [self showRestoreChatFromLocalDB:self->_chatHistory];
        }];
    }andFailure:^(NSError * _Nonnull error) {
       
    }];
}

- (void)getChatHistory {
    if (self.strThreadId != nil ) {
        [[eRTCCoreDataManager sharedInstance] getUserChatHistoryWithThreadID:self.strThreadId andCompletionHandler:^(NSArray* ary, NSError *err) {
            NSLog(@"ary>>>>>>>>>>>>>>>>>>%@",ary);
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
            NSArray *sortedArray=[ary sortedArrayUsingDescriptors:@[sort]];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"msgType.length > 0"];
            self->_chatHistory = [NSMutableArray arrayWithArray:[sortedArray filteredArrayUsingPredicate: predicate]];
            self->_message = [[NSMutableArray alloc] init];
            [self showChatFromLocalDB:self->_chatHistory];
            if ([[[NSUserDefaults standardUserDefaults]valueForKey:IsRestoration] isEqualToString:@"YES"]) {
            [self setupPullToRefereash];
            [self refershControlAction];
            }
        }];
    }
}

- (void)showRestoreChatFromLocalDB:(NSMutableArray *) aryChat {
    
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
           }else{
                
                _strSenderID = dict[SendereRTCUserId];
                _strDisplayName = dict[User_Name];
            }

        _strDisplayName = (_strDisplayName != NULL) ? _strDisplayName : @"";
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
                newMessage = [[JSQMessage alloc] initWithSenderId:_strSenderID senderDisplayName:(_strDisplayName != NULL) ? _strDisplayName : @"" date:msgdate media:photoItemCopy];
               // newMessage = [JSQMessage messageWithSenderId:_strSenderID displayName:_strDisplayName media:photoItemCopy];
            } else  if ([dict[MsgType] isEqualToString:@"file"]) {
                  NSString *strURL = @"";
                  JSQFileMediaItem *photoItemCopy = [[JSQFileMediaItem alloc] init];
                  if (![Helper stringIsNilOrEmpty:dict[LocalFilePath]] && [dict[LocalFilePath] length] > 0) {
                     
                    strURL = dict[LocalFilePath];
                    photoItemCopy.fileURL = [NSURL fileURLWithPath:strURL];
                  } else {
                    strURL = dict[FilePath];
                  }

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
            } else if ([dict[MsgType] isEqualToString:@"image"]) {
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
                _strDisplayName = (_strDisplayName != NULL ? _strDisplayName : @"");
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
                
                NSLog(@"creationDateTime--%@",[dict valueForKey:@"createdAt"]);

                double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
                NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];

                NSLog(@"msgdate--%@",msgdate);
                NSString *strMessage = @"";
                if ([dict[@"replyMsgConfig"] boolValue]){
                    NSString *parentMsg = dict[Parent_Msg];
                    if ([parentMsg length] > 35) {
                        NSRange range = [parentMsg rangeOfComposedCharacterSequencesForRange:(NSRange){0, 35}];
                        parentMsg = [parentMsg substringWithRange:range];
                        parentMsg = [parentMsg stringByAppendingString:@"…"];
                    }
                   // strMessage = [NSString stringWithFormat:@"Replied to a thread:\n%@",dict[Message]];
                    strMessage = [NSString stringWithFormat:@"Replied to a thread:%@\n%@",parentMsg,dict[Message]];
                }else if (![dict[IsDeletedMSG] boolValue] && [dict[IsEdited] boolValue]){
                    strMessage = [NSString stringWithFormat:@"%@%@",dict[Message], EditedString];
                }else if (![dict[IsDeletedMSG] boolValue] && [dict[IsForwarded] boolValue]){
                    strMessage = [NSString stringWithFormat:@"%@\n%@",ForwardedString, dict[Message]];
                }else{
                    strMessage = dict[Message];
                }
              // JSQatt
                
                
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
                                                    senderDisplayName:(_strDisplayName != NULL) ? _strDisplayName : @""
                                                                 date:msgdate
                                                                media:item];
                }else {
                    newMessage = [[JSQMessage alloc] initWithSenderId:_strSenderID
                                                    senderDisplayName:(_strDisplayName != NULL) ? _strDisplayName : @""
                                                                 date:msgdate
                                                                 text:NSLocalizedString(strMessage, nil)];
                }
            }
            
            else if ([dict[MsgType] isEqualToString:@"groupEvent"]) {
                
                NSLog(@"creationDateTime--%@",[dict valueForKey:@"createdAt"]);

                double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
                NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];

                NSLog(@"msgdate--%@",msgdate);
                NSString *strMessage = @"";
//                if ([dict[@"replyMsgConfig"] boolValue]){
//                    strMessage = [NSString stringWithFormat:@"Replied to a thread:\n%@",dict[Message]];
//                }else{
//                    strMessage = dict[Message];
//                }
                strMessage = dict[Message];
                if (_strDisplayName == nil){
                    _strDisplayName = @"";
                }
                newMessage = [[JSQMessage alloc] initWithSenderId:_strSenderID
                                                senderDisplayName:_strDisplayName
                                                             date:msgdate
                                                             text:NSLocalizedString(strMessage, nil)];
            }
            
            newMessage.msgStatus = dict[MsgStatusEvent];
            if (newMessage != nil) {
                [self.message addObject:newMessage];
            }
            //TODO
            if([dict[MsgStatusEvent] isEqualToString:MsgDeliveredStatus]) {
                [[eRTCChatManager sharedChatInstance] updateMessageWithReadStatus:dict];
            }
        }
    }
    if ([self.message count] > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }
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
           }else{
                
                _strSenderID = dict[SendereRTCUserId];
                _strDisplayName = dict[User_Name];
               //_strDisplayName = dict[App_User_ID];

               
            }

        _strDisplayName = (_strDisplayName != NULL) ? _strDisplayName : @"";
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
                newMessage = [[JSQMessage alloc] initWithSenderId:_strSenderID senderDisplayName:(_strDisplayName != NULL) ? _strDisplayName : @"" date:msgdate media:photoItemCopy];
               // newMessage = [JSQMessage messageWithSenderId:_strSenderID displayName:_strDisplayName media:photoItemCopy];
            } else  if ([dict[MsgType] isEqualToString:@"file"]) {
                
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
            } else if ([dict[MsgType] isEqualToString:@"image"]) {
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
                _strDisplayName = (_strDisplayName != NULL ? _strDisplayName : @"");
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
                
                NSLog(@"creationDateTime--%@",[dict valueForKey:@"createdAt"]);

                double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
                NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];

                NSLog(@"msgdate--%@",msgdate);
                NSString *strMessage = @"";
                if ([dict[@"replyMsgConfig"] boolValue]){
                    NSString *parentMsg = dict[Parent_Msg];
                    if ([parentMsg length] > 35) {
                        NSRange range = [parentMsg rangeOfComposedCharacterSequencesForRange:(NSRange){0, 35}];
                        parentMsg = [parentMsg substringWithRange:range];
                        parentMsg = [parentMsg stringByAppendingString:@"…"];
                    }
                   // strMessage = [NSString stringWithFormat:@"Replied to a thread:\n%@",dict[Message]];
                    strMessage = [NSString stringWithFormat:@"Replied to a thread:%@\n%@",parentMsg,dict[Message]];
                }else if (![dict[IsDeletedMSG] boolValue] && [dict[IsEdited] boolValue]){
                    strMessage = [NSString stringWithFormat:@"%@%@",dict[Message], EditedString];
                }else if (![dict[IsDeletedMSG] boolValue] && [dict[IsForwarded] boolValue]){
                    strMessage = [NSString stringWithFormat:@"%@\n%@",ForwardedString, dict[Message]];
                }else{
                    strMessage = dict[Message];
                }
              // JSQatt
                
                
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
                                                    senderDisplayName:(_strDisplayName != NULL) ? _strDisplayName : @""
                                                                 date:msgdate
                                                                media:item];
                }else {
                    newMessage = [[JSQMessage alloc] initWithSenderId:_strSenderID
                                                    senderDisplayName:(_strDisplayName != NULL) ? _strDisplayName : @""
                                                                 date:msgdate
                                                                 text:NSLocalizedString(strMessage, nil)];
                }
            }
            
            else if ([dict[MsgType] isEqualToString:@"groupEvent"]) {
                
                NSLog(@"creationDateTime--%@",[dict valueForKey:@"createdAt"]);

                double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
                NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];

                NSLog(@"msgdate--%@",msgdate);
                NSString *strMessage = @"";
//                if ([dict[@"replyMsgConfig"] boolValue]){
//                    strMessage = [NSString stringWithFormat:@"Replied to a thread:\n%@",dict[Message]];
//                }else{
//                    strMessage = dict[Message];
//                }
                strMessage = dict[Message];
                if (_strDisplayName == nil){
                    _strDisplayName = @"";
                }
                newMessage = [[JSQMessage alloc] initWithSenderId:_strSenderID
                                                senderDisplayName:_strDisplayName
                                                             date:msgdate
                                                             text:NSLocalizedString(strMessage, nil)];
            }
            
            newMessage.msgStatus = dict[MsgStatusEvent];
            if (newMessage != nil) {
                [self.message addObject:newMessage];
            }
            //TODO
            if([dict[MsgStatusEvent] isEqualToString:MsgDeliveredStatus]) {
                [[eRTCChatManager sharedChatInstance] updateMessageWithReadStatus:dict];
            }
        }
    }
    
    if ([self.message count] > 0) {
        self->isSearchMessage = false;
        if (self.searchMessage[MsgUniqueId] != nil && self.searchMessage[MsgUniqueId] != [NSNull null]) {
            for (int i = 0; i < [self->_chatHistory count]; i++)
            {
                NSMutableDictionary * dictSelectMessage = [NSMutableDictionary new];
                dictSelectMessage = [self->_chatHistory objectAtIndex:i];
                NSString *strMsgUniqId  = [NSString stringWithFormat:@"%@",_searchMessage[MsgUniqueId]];
                NSString *strMatchIdMsg  = [NSString stringWithFormat:@"%@",dictSelectMessage[MsgUniqueId]];
                if ([strMatchIdMsg isEqualToString:strMsgUniqId]) {
                    self->selectedPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [self.collectionView reloadData];
                    NSTimeInterval delayInSeconds = 1.1;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self->selectedPath.row inSection:0]]];
                        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:self->selectedPath.row inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionCenteredVertically];
                        [self showCollectionView:NO];
                        [KVNProgress dismiss];
                    });
                    self->isSearchMessage = true;
                }else{
                    [self showCollectionView:NO];
                    [KVNProgress dismiss];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self->isSearchMessage == true) {
              
            }else{
                [self.collectionView reloadData];
                [self scrollToBottomAnimated:YES];
            }
        });
    }else{
        [self showCollectionView:NO];
        [KVNProgress dismiss];
    }
}

//MARK:- UpdateProfileGroupObserverHandleData
-(void)didupdateGroupProfile:(NSNotification *) notification{
    NSDictionary *userInfo = notification.object; //observationInfo;
    
    NSLog(@"userInfo ------------->   %@",userInfo);
    self.navigationItem.titleView =  nil;
    self.navigationController.navigationBar.topItem.title=@"";
    UIView *titleHeaderView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width-20, 60)];
    UIImage *img = [UIImage imageNamed:@"DefaultUserIcon"];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0 , 4, 35, 35)];
    [imgView setImage:img];
    [imgView setContentMode:UIViewContentModeScaleAspectFill];
    imgView.layer.cornerRadius= imgView.frame.size.height/2;
    imgView.layer.masksToBounds = YES;
    
    if (self.dictGroupinfo.count > 0) {
        if (userInfo[User_ProfilePic_Thumb] != nil && userInfo[User_ProfilePic_Thumb] != [NSNull null]) {
            NSTimeInterval delayInSec = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSec * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                NSString *imageURL = [NSString stringWithFormat:@"%@",userInfo[User_ProfilePic_Thumb]];
                [imgView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
            });
        }
    }
    
    lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x+40, 12, 110, 20)];
    if (userInfo[Group_Name] != nil) {
        lblHeader.text = self.dictGroupinfo[Group_Name];
    }
    lblHeader.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:18];
    lblHeader.textAlignment = NSTextAlignmentLeft;
   // [titleHeaderView addSubview:imgView];
   // [titleHeaderView addSubview:lblHeader];
    statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x+40, lblHeader.frame.origin.x, 110, 20)];
    statusLabel.text = @"typing...";
    statusLabel.textAlignment  = NSTextAlignmentLeft;
    statusLabel.hidden = true;
    statusLabel.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:12];
    UIStackView *sh = [[UIStackView alloc] initWithArrangedSubviews:@[lblHeader, statusLabel]];
    sh.axis = UILayoutConstraintAxisVertical;
    UIStackView *sv = [[UIStackView alloc] initWithArrangedSubviews:@[imgView, sh]];
      [sv addConstraint:[NSLayoutConstraint constraintWithItem:imgView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:35]];
      [sv addConstraint:[NSLayoutConstraint constraintWithItem:imgView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:35]];
      [imgView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
      [lblHeader setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
      sv.axis = UILayoutConstraintAxisHorizontal;
      sv.spacing = 5.0;
      self.navigationItem.titleView =  sv; ///UIStackView(arrangedSubviews: [imageView, titleLbl]);
      UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
      initWithTarget:self action:@selector(btnGroupImageTapped)];
      [self.navigationItem.titleView addGestureRecognizer:tapRecognizer];
}

-(void)headerShowMessage {
    CGFloat topbarHeight = ([UIApplication sharedApplication].statusBarFrame.size.height +
           (self.navigationController.navigationBar.frame.size.height ?: 0.0));
   reportView = [[UIView alloc] initWithFrame:CGRectMake(0, topbarHeight, self.collectionView.bounds.size.width, 90)];
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(48, 5, self.collectionView.bounds.size.width-54, 60)];
    UIImageView *imageNowifi = [[UIImageView alloc] initWithFrame:CGRectMake(16, 20, 24, 24)];
    [reportView setBackgroundColor:[UIColor colorWithRed:237/255.0 green:255/255.0 blue:238/255.0 alpha:1]];
        lblTitle.textColor = [UIColor colorWithRed:19/255.0 green:187/255.0 blue:26/255.0 alpha:1];
    lblTitle.text = @"Thank you for submitting a report, The reported message/media will be remove from the conversation, and we will review your report.";
    [imageNowifi setImage:[UIImage imageNamed:@"CircleRight"]];
    [lblTitle setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:16.0]];
    lblTitle.numberOfLines = 0;
    lblTitle.textAlignment = NSTextAlignmentLeft;
    [reportView addSubview:lblTitle];
    [reportView addSubview:imageNowifi];
}

-(void)didchatReportSuccess:(NSNotification *) notification{
    [self.navigationController.view addSubview:reportView];
    [self getChatHistory];
    NSTimeInterval delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [reportView removeFromSuperview];
    });
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
    self.navigationItem.titleView =  nil;
    self.navigationController.navigationBar.topItem.title=@"";
    UIView *titleHeaderView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width-20, 60)];
    UIImage *img = [UIImage imageNamed:@"DefaultUserIcon"];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0 , 4, 35, 35)];
    [imgView setImage:img];
    [imgView setContentMode:UIViewContentModeScaleAspectFill];
    imgView.layer.cornerRadius= imgView.frame.size.height/2;
    imgView.layer.masksToBounds = YES;
    
    if (self.dictGroupinfo.count > 0) {
        if (self.dictGroupinfo[User_ProfilePic_Thumb] != nil && self.dictGroupinfo[User_ProfilePic_Thumb] != [NSNull null]) {
            NSString *imageURL = [NSString stringWithFormat:@"%@",self.dictGroupinfo[User_ProfilePic_Thumb]];
            [imgView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
        }
    }
    
    lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x+40, 12, 110, 20)];

    if (self.dictGroupinfo[Group_Name] != nil) {
        lblHeader.text = self.dictGroupinfo[Group_Name];
    }
    lblHeader.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:18];
    lblHeader.textAlignment = NSTextAlignmentLeft;
   // [titleHeaderView addSubview:imgView];
   // [titleHeaderView addSubview:lblHeader];
    statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x+40, lblHeader.frame.origin.x, 110, 20)];
    statusLabel.text = @"typing...";
    statusLabel.textAlignment  = NSTextAlignmentLeft;
    statusLabel.hidden = true;
    statusLabel.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:12];
    UIStackView *sh = [[UIStackView alloc] initWithArrangedSubviews:@[lblHeader, statusLabel]];
    sh.axis = UILayoutConstraintAxisVertical;
    UIStackView *sv = [[UIStackView alloc] initWithArrangedSubviews:@[imgView, sh]];
      [sv addConstraint:[NSLayoutConstraint constraintWithItem:imgView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:35]];
      [sv addConstraint:[NSLayoutConstraint constraintWithItem:imgView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:35]];
      [imgView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
      [lblHeader setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
      sv.axis = UILayoutConstraintAxisHorizontal;
      sv.spacing = 5.0;
      self.navigationItem.titleView =  sv; ///UIStackView(arrangedSubviews: [imageView, titleLbl]);
      UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
      initWithTarget:self action:@selector(btnGroupImageTapped)];
      [self.navigationItem.titleView addGestureRecognizer:tapRecognizer];
}


-(void)didPressAudioButton {
    [self.view makeToast:@"Hold To Record"];
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
    
    rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 45, 25)];
    
    [rightButton setImage:[UIImage imageNamed:@"sendNew"] forState:UIControlStateSelected];
    [rightButton setImage:[UIImage imageNamed:@"MicrophoneNew"] forState:UIControlStateNormal];
    
    UILongPressGestureRecognizer *lpg = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(rightButtonAudioLongPress:)];
    lpg.cancelsTouchesInView = false;
    lpg.allowableMovement = 10;
    lpg.minimumPressDuration = 0.5;
    [rightButton addGestureRecognizer:lpg];
    self.inputToolbar.contentView.leftBarButtonItem =leftButton;
    self.inputToolbar.contentView.rightBarButtonItem =rightButton;
    
    CGRect frame = self.inputToolbar.contentView.textView.frame;
    CGFloat  cornerRadius = 10.0;
    self.inputToolbar.contentView.textView.textContainerInset = UIEdgeInsetsMake(8, cornerRadius/2, 0, 0);
    self.inputToolbar.contentView.textView.frame = frame;

    self.inputToolbar.contentView.textView.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:17];
    self.inputToolbar.contentView.backgroundColor =[UIColor whiteColor];
    self.inputToolbar.contentView.textView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor clearColor]);
    self.inputToolbar.contentView.textView.layer.cornerRadius = cornerRadius;
    self.inputToolbar.contentView.textView.backgroundColor =[UIColor colorWithRed:238.0f/255.0f green:245.0f/255.0f blue:255.0f/255.0f alpha:1.0];
    [self.inputToolbar.contentView.textView setHidden:NO];
    [self.inputToolbar.contentView.recorderView setHidden:YES];
    
    
    UIView *recorderView = self.inputToolbar.contentView.recorderView;
    CGRect audioRercorder = recorderView.bounds;
    
    self.audioRecorderView = [[JSQAudioRecorderView alloc] initWithFrame:audioRercorder];
    [self.audioRecorderView setJsqARVDelegate:self];
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
//    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    

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
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            NSLog(@"Permission granted");
        }
        else {
            NSLog(@"Permission denied");
        }
    }];
}
- (void)rightButtonAudioLongPress:(UILongPressGestureRecognizer*)gesture {
    if (self.inputToolbar.contentView.rightBarButtonItem.isSelected == NO) {
        gesture.view.tag = -1;
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                if (granted) {
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
                            [self.audioRecorderView stopAudioRecording];
                            break;
                        default:
                            break;
                    }
                }
                else {
                    [self.view makeToast:@"Please enable permission!"];
                }
            }];
    }
}

-(void)btnGroupImageTapped{
    if (isFrozenChannel || isBlockUI) {
        
    }else{
    [self callApiGetGroupByGroupId:@""];
    }
}


-(void)callApiGetGroupByGroupId:(NSString *)strType {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        NSMutableDictionary*dict = [[NSMutableDictionary alloc]init];
        [KVNProgress show];
        if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_ID] != nil) {
            [dict setValue:self.dictGroupinfo[Group_GroupId] forKey:Group_GroupId];
            
            [[eRTCChatManager sharedChatInstance] getGroupByGroupId:dict andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                [KVNProgress dismiss];
                NSDictionary *dictResponse = (NSDictionary *)json;
                if (dictResponse[@"success"] != nil) {
                    BOOL success = (BOOL)dictResponse[@"success"];
                    if (success) {
                        if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *result = (NSDictionary *)dictResponse[@"result"];
                            NSMutableDictionary *dictActiveGroup = @{}.mutableCopy;
                            if(isGroupActivated == true) {
                            [dictActiveGroup setValue:@true forKey:@"isActivated"];
                            }else{
                            [dictActiveGroup setValue:@false forKey:@"isActivated"];
                            }
                            //dictActiveGroup = [NSMutableDictionary dictionaryWithDictionary:result];
                            [dictActiveGroup addEntriesFromDictionary:result];
                            if (result.count > 0) {
                            if ([strType isEqualToString:Freeze]) {
                                NSDictionary *dictFreez = result[Freeze];
                                self->isFrozenChannel = [dictFreez[Enabled] boolValue];
                                [self Frozen_Channel:isFrozenChannel];
                            }else{
                            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle bundleForClass:InfoGroupViewController.class]];
                            InfoGroupViewController *vcInfo = [story instantiateViewControllerWithIdentifier:NSStringFromClass(InfoGroupViewController.class)];
                            vcInfo.dictGroupInfo = [NSMutableDictionary dictionaryWithDictionary:dictActiveGroup];
                            [self.navigationController pushViewController:vcInfo animated:YES];
                        }
                    }else{
                        [self removeChannel:true];
                        isRemovedChannel = true;
                }
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
            }andFailure:^(NSError * _Nonnull error) {
                [KVNProgress dismiss];
                NSLog(@"GroupListViewController ->  callAPIForGetGroupByGroupID -> %@",error);
                [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
            }];
        }
    }else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}

-(void)Frozen_Channel:(BOOL *)isFrozenChannel {
    [frozenView removeFromSuperview];
    if (isFrozenChannel) {
        NSTimeInterval delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            CGFloat topbarHeight = ([UIApplication sharedApplication].statusBarFrame.size.height +
                                    (self.navigationController.navigationBar.frame.size.height ?: 0.0));
            self->frozenView = [[UIView alloc] initWithFrame:CGRectMake(0, topbarHeight, self.collectionView.bounds.size.width, 64)];
            UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(48, 5, self.collectionView.bounds.size.width-54, 60)];
            UIImageView *imageNowifi = [[UIImageView alloc] initWithFrame:CGRectMake(16, 20, 24, 24)];
            [self->frozenView setBackgroundColor:[UIColor colorWithRed:255/255.0 green:237/255.0 blue:237/255.0 alpha:1]];
            lblTitle.textColor = UIColor.redColor;
            lblTitle.text = @"This channel is currently frozen, and you are unable to send messages or share media.";
            [imageNowifi setImage:[UIImage imageNamed:@"FrozenChannel"]];
            [lblTitle setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:16.0]];
            lblTitle.numberOfLines = 0;
            lblTitle.textAlignment = NSTextAlignmentLeft;
            [self->frozenView addSubview:lblTitle];
            [self->frozenView addSubview:imageNowifi];
            [self.view addSubview:self->frozenView];
        });
        self.inputToolbar.hidden = true;
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->frozenView removeFromSuperview];
            //self->frozenView.hidden = true;
        });
        
        self.inputToolbar.hidden = false;
    }
}


-(void)removeChannel:(BOOL *)isChannelRemoved {
    if (isChannelRemoved) {
        NSTimeInterval delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            CGFloat topbarHeight = ([UIApplication sharedApplication].statusBarFrame.size.height +
                                    (self.navigationController.navigationBar.frame.size.height ?: 0.0));
            self->removeView = [[UIView alloc] initWithFrame:CGRectMake(0, topbarHeight, self.collectionView.bounds.size.width, 70)];
            UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(48, 5, self.collectionView.bounds.size.width-54, 60)];
            UIImageView *imageNowifi = [[UIImageView alloc] initWithFrame:CGRectMake(16, 20, 24, 24)];
            [self->removeView setBackgroundColor:[UIColor colorWithRed:255/255.0 green:237/255.0 blue:237/255.0 alpha:1]];
            lblTitle.textColor = UIColor.redColor;
            lblTitle.text = @"This channel has been removed. You will no longer be able to send messages or access the channel.";
            [imageNowifi setImage:[UIImage imageNamed:@"FrozenChannel"]];
            [lblTitle setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:16.0]];
            lblTitle.numberOfLines = 0;
            lblTitle.textAlignment = NSTextAlignmentLeft;
            [self->removeView addSubview:lblTitle];
            [self->removeView addSubview:imageNowifi];
            [self.view addSubview:self->removeView];
        });
        self.inputToolbar.hidden = true;
    }else{
        [removeView removeFromSuperview];
        self.inputToolbar.hidden = false;
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

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        //[self.inputToolbar.contentView.textView becomeFirstResponder];
        [self.view endEditing:YES];
        return;
    }
    
    switch (buttonIndex) {
        case 0:
            [self pickImage:nil];
            // [self.message addPhotoMediaMessage];
            break;
            
        case 1:
        {
            //__weak UICollectionView *weakView = self.collectionView;
            [self pickImageFromGallary:nil];
            //[self.message addLocationMediaMessageCompletion:^{
            // [weakView reloadData];
            //  }];
        }
            break;
            
        case 2:{
            [locManager startLocationUpdate];
//            [self callAPIForShareCurrentLocation:^{
//                [self finishSendingMessageAnimated:YES];
//            }];
        }
            break;
            
        case 3:
            [self contactsDetailsFromPhoneContactBook];
            break;
            
        case 4:
            //[self openDocumentPicker];
            [self openGIF];
            break;
        case 5:
            [self openGIF];
            break;
    }
    
    // [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    [self finishSendingMessageAnimated:YES];
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
            pickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie,kUTTypeImage,kUTTypeAudio,kUTTypeQuickTimeMovie, kUTTypeMP3,nil];
            pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            pickerController.allowsEditing = YES;
            pickerController.delegate = self;
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
    pickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie,kUTTypeImage,kUTTypeAudio,kUTTypeQuickTimeMovie, kUTTypeMP3,  nil];
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.allowsEditing = YES;
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [self dismissViewControllerAnimated:YES completion:^{
        NSString*mediaType = info[UIImagePickerControllerMediaType];
        NSLog(@"SingleChatViewController ->  imagePickerController -> mediaType -> %%",mediaType);
        
        if ( [mediaType isEqualToString:@"public.image"]){
            UIImage *selectedImage = info[UIImagePickerControllerEditedImage];
            UIImage *imageReduced = [self reduceImageSize:selectedImage];
            
            [self addPhotoMediaMessage:imageReduced];
        }
        else if ( [mediaType isEqualToString:@"public.movie"]){
            NSLog(@"Picked a vedio  URL %@",  [info objectForKey:UIImagePickerControllerMediaURL]);
            NSURL *url =  [info objectForKey:UIImagePickerControllerMediaURL];
            NSLog(@"SingleChatViewController ->  imagePickerController -> movie -> %@",[url absoluteString]);
            NSError *err;
            if ([url checkResourceIsReachableAndReturnError:&err] == NO)
            {
                [self.view makeToast:messageLargeVideoFile];
                NSLog(@"resource not reachable");
            }else{
                NSError *attributesError;
                NSURL *videoUrl=[info objectForKey:UIImagePickerControllerMediaURL];
                NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[videoUrl path] error:&attributesError];
                NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
                long long fileSize = [fileSizeNumber longValue];
                float videsize = (fileSize/1024/1024);
                NSLog(@"SIZE OF VIDEO: %0.2f Mb", videsize);
            if (videsize > 25.0)  {
                [self.view makeToast:messageLargeVideoFile];
            }else{
                [self addVideoMediaMessage:url];
        }
    }
        }
        else if ( [mediaType isEqualToString:@"public.audio"])
        {
            NSLog(@"Picked a vedio  URL %@",  [info objectForKey:UIImagePickerControllerMediaURL]);
            NSURL *url =  [info objectForKey:UIImagePickerControllerMediaURL];
            NSLog(@"SingleChatViewController ->  imagePickerController -> audio -> %%",[url absoluteString]);
            NSString*str =[url absoluteString];
            NSData * audioData = [NSData dataWithContentsOfFile:str];
            if (audioData != nil && audioData.length>0) {
                [self addAudioMediaMessage:audioData];
            }
        }
        [self finishSendingMessageAnimated:YES];
        
    }];
}

-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    
    NSString *strdata;
    if (self->isSelectedMentionUser == true && [self->mentionsUser length] > 0) {
        NSString *strUserData = text;
        for (int i = 0; i < [self->arrMentionUser count]; i++)
        {
            NSString *struserName = arrMentionUser[i];
            NSString *strUserEmail = arrMentionEmail[i];
            strdata = [strUserData stringByReplacingOccurrencesOfString:strUserEmail
                                                            withString:struserName];
            strUserData = strdata;
        }
    }else{
        strdata =  [[eRTCAppUsers sharedInstance] getProfanityAndDomainAsteriskMessage: self->dictDomainProfinityFilter withMessage:text.mutableCopy isMentionUser:self->isSelectedMentionUser];
    }

    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:[NSDate date]
                                                          text:strdata];
    message.msgStatus =@"sending...";
    // [JSQSystemSoundPlayer jsq_playMessageSentSound];
    NSLog(@"%@: %@",senderDisplayName, text);
    NSLog(@"SingleChatViewController ->  didPressSendButton -> %@ %@",senderDisplayName,text);
    if ([self isMessageEditing]){
        if ([self isMessageEdited]){
            [self sendEditedTextMessage:editingMessage.copy];
            [self clearEditedDetalils];
        }else {
            [self clearEditedDetalils];
            return;
        }
    }else {
        [_message addObject:message];
        [self sendTextMessage:strdata];
        [self finishSendingMessageAnimated:YES];
    }
    
    self->isSelectedMentionUser = false;
    self->mentionsUser = @"";
    self->mentionUserEmail = @"";
    arrMentionEmail = [NSMutableArray new];
    arrMentionUser = [NSMutableArray new];
}

-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesBubbleImageFactory *bubble = [[JSQMessagesBubbleImageFactory alloc] init];
    UIColor *senderColor = [UIColor colorWithRed:0.9 green:0.93 blue:1.0 alpha:1.0];
    UIColor *recvColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.0];
    UIColor *replyColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.0];
    
    UIColor *color = senderColor;
    if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row ){
        NSDictionary * dicMessage = [_chatHistory objectAtIndex:indexPath.row];
        if ([dicMessage[@"replyMsgConfig"] boolValue]){
            color = replyColor;
        }else  if([dicMessage[MsgType] isEqual:@"groupEvent"]){
            color = [UIColor clearColor];
        }else if([[[_message objectAtIndex:indexPath.item] senderId] isEqualToString:self.senderId]) {
            color = senderColor;
        } else{
            color = recvColor;
        }
    }
    return [bubble outgoingMessagesBubbleImageWithColor:color];
}


-(id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
     /*JSQMessage *message = [_message objectAtIndex:indexPath.item];

        if (![message.senderId isEqualToString:self.senderId]) {
            JSQMessagesAvatarImage *cookImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"profile"]
                                                                                           diameter:kJSQMessagesCollectionViewAvatarSizeDefault];

            return cookImage;

        } else {
            return nil;
        }
    */

    return nil;
    
}


- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [_message objectAtIndex:indexPath.item];

    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    NSDictionary *msgObject;
    if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row ){
        msgObject = [_chatHistory objectAtIndex:indexPath.row];
    }

    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [_message objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
//
    /**
     *  Don't specify attributes to use the defaults.
     */
    
    NSString *userName = @"";
    if (msgObject[@"name"] != nil && msgObject[@"name"] != [NSNull null]) {
        userName = msgObject[@"name"];
    }
    
    
    return [[NSAttributedString alloc] initWithString:userName];
   // return [[NSAttributedString alloc] initWithString:message.senderDisplayName];

}


- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [_message objectAtIndex:indexPath.item];
    if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row ){
       NSDictionary* msgObject = [_chatHistory objectAtIndex:indexPath.row];
        if([msgObject[MsgType] isEqual:@"groupEvent"]){
            return 30;
        }
    }
    
//    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
//        return 0.0f;
//    }


//    if (indexPath.item - 1 > 0) {
//        JSQMessage *previousMessage = [_message objectAtIndex:indexPath.item - 1];
//        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
//            return 0.0f;
//        }
//    }
    
    CGFloat topLabelHeight = 10.0f;
    NSDictionary *msgObject;
    if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row ){
        msgObject = [_chatHistory objectAtIndex:indexPath.row];
    }

    if ([msgObject[ReplyMsgConfig] boolValue] == true){
        if ([msgObject[MsgType] isEqualToString:Key_video] || [msgObject[MsgType] isEqualToString:Image] || [msgObject[MsgType] isEqualToString:LocationType] || [msgObject[MsgType] isEqualToString:GifyFileName] || [msgObject[MsgType] isEqualToString:ContactType] || [msgObject[MsgType] isEqualToString:AudioFileName] ) {
            topLabelHeight = 35.0f;
        }
    }
    
    return topLabelHeight;
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
   // NSLog(@"messageDataForItemAtIndexPath:%@",[_message objectAtIndex:indexPath.item]);
    JSQMessage *jsqM = [_message objectAtIndex:indexPath.item];
    if([jsqM.media isKindOfClass:[JSQGIFMediaItem class]]){
        JSQGIFMediaItem *item = (JSQGIFMediaItem *)jsqM.media;
        [item.cachedImageView setNeedsLayout];
    }
    return [_message objectAtIndex:indexPath.item];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_message count];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *msgObject;
    if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row ){
        msgObject = [_chatHistory objectAtIndex:indexPath.row];
      [[eRTCChatManager sharedChatInstance] updateMessageWithReadStatus:msgObject];
    }
}



-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *msgObject;
    CGSize size = [super collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
    
    JSQMessage *message = self.message[indexPath.row];
    if ([message.media isKindOfClass:JSQLinkPreviewMediaItem.class]){
        JSQLinkPreviewMediaItem *item = (JSQLinkPreviewMediaItem*)message.media;
        size.height = [item mediaViewDisplaySize].height;
        
        if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row ){
            msgObject = [_chatHistory objectAtIndex:indexPath.row];
            
            if([msgObject[MsgType] isEqual:@"groupEvent"]){
                size.height = 30;
            }else if ([msgObject valueForKey:@"reaction"] != nil && [msgObject valueForKey:@"reaction"] != [NSNull null] ) {
                CGFloat height = [self convertDataToEmoji:[msgObject valueForKey:@"reaction"]];
                size.height  +=  height;
            }
        }
    }

    if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row ){
        msgObject = [_chatHistory objectAtIndex:indexPath.row];
        if([msgObject[MsgType] isEqual:@"groupEvent"]){
            size.height = 35;
        }
    }
    
    if ([msgObject valueForKey:@"isReported"] != nil && [msgObject valueForKey:@"isReported"] != [NSNull null] ) {
        if ([msgObject[MsgType] isEqualToString:@"text"]){
        size = CGSizeMake(self.view.frame.size.width-16, 150);
        }else{
            size = CGSizeMake(self.view.frame.size.width-16, 150);
        }
    }
    
    if ([msgObject[IsEdited] isEqual:@1] && [msgObject[IsForwarded] isEqual:@1]){
        size.height  += 25;
    }else if ([msgObject[IsEdited] isEqual:@1] && [msgObject[ReplyMsgConfig] boolValue] == true) {
        size.height  += 15;
    }
    return  size;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = _message[indexPath.row];
    
    JSQMessagesCollectionViewCell *cell  = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    NSDictionary *msgObject;
    if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row ){
        msgObject = [_chatHistory objectAtIndex:indexPath.row];
    }
    
    
    /*
    if ([msgObject valueForKey:@"name"] != nil && [msgObject valueForKey:@"name"] != [NSNull null] ) {
    NSString *str = [NSString stringWithFormat:@"%@", [msgObject valueForKeyPath:@"message"]];
    NSMutableDictionary *dictJira = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        if (dictJira.count > 0) {
            NSMutableArray *aryJira = dictJira[@"res"];
             if (msgObject != NULL && [msgObject[MsgType] isEqual:@"text"]){
                 JiraBotCollectionCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"JiraBotCollectionCell" forIndexPath:indexPath];
                cell.cellTopLabel.hidden = true;
                cell.cellBottomLabel.hidden = true;
                cell.arrayDataSource = aryJira;
                return cell;
             }
        }else{
            JiraBotCollectionCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"JiraBotCollectionCell" forIndexPath:indexPath];
           cell.cellTopLabel.hidden = true;
           cell.cellBottomLabel.hidden = true;
           return cell;
        }
    }*/
    
    
    if (msgObject && [msgObject valueForKey:@"isReported"] != nil && [msgObject valueForKey:@"isReported"] != [NSNull null] ) {
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"JSQReportCell" forIndexPath:indexPath];
        cell.delegate = self;
        cell.cellTopLabel.hidden = true;
        cell.cellBottomLabel.hidden = true;
    }
    
    if ([msgObject[ReplyMsgConfig] boolValue] == true){
        if ([msgObject[MsgType] isEqualToString:Key_video] || [msgObject[MsgType] isEqualToString:Image] || [msgObject[MsgType] isEqualToString:LocationType] || [msgObject[MsgType] isEqualToString:GifyFileName] || [msgObject[MsgType] isEqualToString:ContactType] || [msgObject[MsgType] isEqualToString:AudioFileName] ) {
            NSString *strParentMsg = msgObject[Parent_Msg];
            cell.messageBubbleTopLabel.text = [NSString stringWithFormat:@"Replied to a thread: %@",strParentMsg];
            cell.messageBubbleTopLabel.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:15];
        }
    }
   
    cell.textView.selectable = false;
    cell.textView.textColor = [UIColor blackColor];
    cell.textView.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:16];
    
    UIView *labelView = [cell.cellTopLabel viewWithTag:898];
    if (labelView){
        [labelView removeFromSuperview];
    }
    
    if (cell.textView.text != nil && [cell.textView.text length] > 0) {
        if (msgObject != NULL && [msgObject[MsgType] isEqual:ContactType]){
            cell.textView.attributedText = [[NSAttributedString alloc]
                                            initWithString:cell.textView.text
                                            attributes:@{
                                                NSForegroundColorAttributeName:[UIColor systemBlueColor],
                                                NSFontAttributeName: [UIFont fontWithName:@"SFProDisplay-Semibold" size:15]
                                                
             }];
        }else if ([msgObject[IsEdited] isEqual:@1] && [msgObject[IsForwarded] isEqual:@1]){
            if ([msgObject[MsgType] isEqualToString:@"text"]){
                NSMutableAttributedString *attrString =  [Helper mentionHighlightedAttributedStringByNames:_userNames message:@" Forwarded \n  "].mutableCopy;
                NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                [style setLineSpacing:5];
                [attrString addAttributes:@{
                    NSForegroundColorAttributeName:[UIColor grayColor],
                    NSFontAttributeName: [UIFont fontWithName:@"SFProDisplay-Regular" size:14],
                    NSParagraphStyleAttributeName: style
                } range:NSMakeRange(0, ForwardedString.length)];
                NSMutableAttributedString *attrEdit = [Helper mentionHighlightedAttributedStringByNames:_userNames message:message.text].mutableCopy;
                NSString *orignalMessage = [attrEdit.string stringByReplacingOccurrencesOfString:EditedString withString:@""];

                NSRange textRange = NSMakeRange(0, attrEdit.length);
                NSRange range = NSMakeRange(orignalMessage.length, EditedString.length);
                if (NSEqualRanges(NSIntersectionRange(textRange, range), range)) {
                    [attrEdit addAttributes:@{
                        NSForegroundColorAttributeName:[UIColor lightGrayColor],
                        NSFontAttributeName: [UIFont fontWithName:@"SFProDisplay-Regular" size:14]
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
                    NSFontAttributeName: [UIFont fontWithName:@"SFProDisplay-Regular" size:14]
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
                    NSFontAttributeName: [UIFont fontWithName:@"SFProDisplay-Regular" size:14],
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
                NSString*str = [NSString stringWithFormat:@"Replied to a thread:%@\n%@",strParentMsg,msgObject[@"message"]];
                NSMutableAttributedString *attrString =  [Helper mentionHighlightedAttributedStringByNames:_userNames message:str].mutableCopy;
                NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                
                [style setLineSpacing:5];
                [attrString addAttributes:@{
                    NSForegroundColorAttributeName:[UIColor grayColor],
                    NSFontAttributeName: [UIFont fontWithName:@"SFProDisplay-Regular" size:15],
                    NSParagraphStyleAttributeName: style
                } range:NSMakeRange(0, 20+strParentMsg.length)];
            cell.textView.attributedText = attrString.copy;
        }
        }else if([msgObject[MsgType] isEqual:@"groupEvent"]){
            cell.cellTopLabel.text = @"";
            UILabel *label = [UILabel new];
            //cell.messageBubbleContainerView.hidden = true;
            label.tag = 898;
            label.attributedText = [[NSAttributedString alloc]
                                    initWithString:cell.textView.text
                                    attributes:@{
                                        NSForegroundColorAttributeName:[UIColor grayColor],
                                        NSFontAttributeName: [UIFont fontWithName:@"SFProDisplay-Regular" size:15]
                                        
                                    }];
            [label sizeToFit];
            CGRect frame = cell.cellTopLabel.bounds;
            
            frame.size.height = 30;
            CGFloat width = collectionView.frame.size.width;
            CGFloat labelWidth = label.frame.size.width + 20;
            CGFloat x = (width - labelWidth) / 2;
            frame.origin.x = x;
            frame.size.width = labelWidth;
            label.frame = frame;
            label.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.0];
            label.layer.masksToBounds = TRUE;
            label.layer.cornerRadius = frame.size.height / 2;
            label.textAlignment = NSTextAlignmentCenter;
            [cell.cellTopLabel addSubview:label];
            
//            cell.cellTopLabel.attributedText = [[NSAttributedString alloc]
//                                            initWithString:cell.textView.text
//                                            attributes:@{
//                                                NSForegroundColorAttributeName:[UIColor systemBlueColor],
//                                                NSFontAttributeName: [UIFont fontWithName:@"SFProDisplay-Semibold" size:18]
//
//                                            }];
            cell.textView.text = @"";
        }else {
//            cell.textView.attributedText =  [Helper mentionHighlightedAttributedStringByNames:_userNames message:cell.textView.text];
//            cell.textView.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:17];
            
            cell.textView.attributedText = [Helper getuserMentionName:_userNames message:cell.textView.text];
            cell.textView.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:17];
        }
    }
    chatReplyCount *replyCountView = [cell.cellBottomLabel viewWithTag:1000];
    CGFloat trailingSpace = 0;
    if (_chatHistory.count - 1 == indexPath.row){
        trailingSpace = -40;
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
    if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row )
    {
        cell.contentView.userInteractionEnabled = YES;
        cell.cellBottomLabel.userInteractionEnabled = YES;
        NSDictionary *dicMessage = [_chatHistory objectAtIndex:indexPath.row];
        
        if ([dicMessage valueForKey:@"replyMsgCount"] != nil && [dicMessage valueForKey:@"replyMsgCount"] != [NSNull null] )
        {
            NSInteger isReplyAvailble = [[dicMessage valueForKey:@"replyMsgCount"] integerValue];
            [replyCountView showHideThreadReplyView:NO];
            
            if (isReplyAvailble > 0) {
                [replyCountView.btnReplyThread addTarget:self action:@selector(pushToReplyThreadVC:) forControlEvents:UIControlEventTouchUpInside];
                [cell bringSubviewToFront:replyCountView.btnReplyThread];
                replyCountView.btnReplyThread.tag = indexPath.row;
                replyCountView.lblCount.text = [NSString stringWithFormat:@"Replies %@",[dicMessage valueForKey:@"replyMsgCount"]];
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
                // Out Going
                [replyCountView messageSent:YES];
            } else {
                // In Coming
                [replyCountView messageSent:NO];
            }
//            [replyCountView.collectionView scrollsToTop];
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
                    consSize = 19.f;
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
        if (_chatHistory.count - 1 == indexPath.row){
            [replyCountView setPaddingForLastMessage];
        }
    }
    
    if (_searchMessage[MsgUniqueId] != nil && _searchMessage[MsgUniqueId] != [NSNull null]) {
        NSString *strMsgUniqId  = [NSString stringWithFormat:@"%@",_searchMessage[MsgUniqueId]];
        NSDictionary * dicMessage = [_chatHistory objectAtIndex:indexPath.row];
        if ([strMsgUniqId isEqualToString:dicMessage[MsgUniqueId]]) {
            cell.messageBubbleImageView.backgroundColor = UIColor.lightGrayColor;
            NSTimeInterval delayInSeconds = 1.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                _searchMessage = [NSDictionary new];
                cell.messageBubbleImageView.backgroundColor = UIColor.whiteColor;
            });
        }else{
        }
    }
    
    
    
    
    return cell;
}
-(void)removeConstrainsFromCellBottomLable:(UIView*)view {
    [[view constraints] enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.secondItem isKindOfClass:chatReplyCount.class]){
            [view removeConstraint:obj];
        }
    }];
}

-(void) addLayoutConstraintsToParent:(UIView*)parent childView:(UIView*)childView trailing:(CGFloat) trailingSpace {
    NSLayoutConstraint *trailing =[NSLayoutConstraint
                                               constraintWithItem:childView
                                               attribute:NSLayoutAttributeTrailing
                                               relatedBy:NSLayoutRelationEqual
                                               toItem:parent
                                               attribute:NSLayoutAttributeTrailing
                                               multiplier:1.0f
                                               constant:trailingSpace];
               
               NSLayoutConstraint *top =[NSLayoutConstraint
                                            constraintWithItem:childView
                                            attribute:NSLayoutAttributeTop
                                            relatedBy:NSLayoutRelationEqual
                                            toItem:parent
                                            attribute:NSLayoutAttributeTop
                                            multiplier:1.0f
                                            constant:0.f];
               
               NSLayoutConstraint *bottom =[NSLayoutConstraint
                                               constraintWithItem:childView
                                               attribute:NSLayoutAttributeBottom
                                               relatedBy:NSLayoutRelationEqual
                                               toItem:parent
                                               attribute:NSLayoutAttributeBottom
                                               multiplier:1.0f
                                               constant:0.f];
               
               NSLayoutConstraint *leadiing =[NSLayoutConstraint
                                            constraintWithItem:childView
                                            attribute:NSLayoutAttributeLeading
                                            relatedBy:NSLayoutRelationEqual
                                            toItem:parent
                                            attribute:NSLayoutAttributeLeading
                                            multiplier:1.0f
                                            constant:0.f];
               
               [parent addConstraint:trailing];
               [parent addConstraint:top];
               [parent addConstraint:bottom];
               [parent addConstraint:leadiing];
}
-(void)messageDidReceived:(NSString *)message andSenderId:(NSString *)senderId
{
    [self.message addObject:[JSQMessage messageWithSenderId:senderId displayName:senderId text:message]];
    [[super collectionView] reloadData];
}
#pragma mark - UICollectionView Delegate

#pragma mark - Custom menu items

//-(BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
//    return YES;
//}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath{
    //    UICollectionView *cell = [collectionView cellForItemAtIndexPath:indexPath];
    //[self hadleLongPressAction:indexPath];
    JSQMessage *message = [self.message objectAtIndex:indexPath.row];
    if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row ){
        NSDictionary *dict = [_chatHistory objectAtIndex:indexPath.item];
        /*
         if (![dict[@"replyMsgConfig"] boolValue] && ![dict[MsgType] isEqual:@"groupEvent"]){
         [self hadleLongPressAction:indexPath];
         }
         */
        if (dict != NULL && ![dict[@"msgType"] isEqualToString:@"groupEvent"]){
            BOOL isDeleted = [dict[IsDeletedMSG] isEqual:@1];
            BOOL isReported = dict[@"isReported"];
            
            if (![message.msgStatus containsString:@"sending"] && !isDeleted){
                if (isFrozenChannel || isBlockUI || isReported || isRemovedChannel || isGroupActivated) {
                    
                }else{
                    if (message.isMediaMessage && [dict[MsgStatusEvent] containsString:@"sending"]){
                        [self.view makeToast:@"Please wait for message to send"];
                    }else{
                        [self hadleLongPressAction:indexPath];
//                        NSDictionary *dictConfig = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
//                        if ([dictConfig[@"chatBots"] boolValue] == false) {
//                        
//                        }
                    }
                }
            }
        }
    }
    if (message.isMediaMessage && [message.msgStatus containsString:@"sending"]){
        [self.view makeToast:@"Please wait for message to send"];
    }
    return NO;
}

-(void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
}

//- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
//{
//    if (action == @selector(customAction:)) {
//        return YES;
//    }
//
//    return [super collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
//}

//- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
//{
//    if (action == @selector(customAction:)) {
//        [self customAction:sender];
//        return;
//    }
//
//    [super collectionView:collectionView performAction:action forItemAtIndexPath:indexPath withSender:sender];
//}

//ActionSheet

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
//- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
//{
//
//
//}

-(void)showAddContactController:(CNContact*) contact{
    //Pass nil to show default contact adding screen
    CNContactViewController *addContactVC = [CNContactViewController viewControllerForNewContact:contact];
    addContactVC.delegate=self;
    UINavigationController *navController   = [[UINavigationController alloc] initWithRootViewController:addContactVC];
    [self presentViewController:navController animated:true completion:^{}];
}
- (void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(nullable CNContact *)contact{
    //You will get the callback here
    [viewController dismissViewControllerAnimated:true completion:^{}];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    JSQMessage *meesageData = _message[indexPath.row];
    if ([meesageData.msgStatus containsString:@"sending"] && meesageData.isMediaMessage){
        [self.view hideAllToasts:YES clearQueue:YES];
        [self.view makeToast:@"Please wait for message to send"];
        return;
    }
    NSDictionary *msgObject;
    if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row) {
        msgObject = _chatHistory[indexPath.row];
    }
    self.imgURL = [NSArray new];
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
        imageVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.imgURL = [NSArray arrayWithObjects:photoItemNew.image, nil];
        [self presentViewController:imageVC animated:YES completion:nil];
        
    }
    else if ([meesageData.media isKindOfClass:[JSQGIFMediaItem class]]){
        JSQGIFMediaItem *photoItemNew = (JSQGIFMediaItem *)meesageData.media;
        BFRImageViewController *imageVC = [[BFRImageViewController alloc] initWithImageSource:[NSArray arrayWithObjects: [UIImage sd_imageWithGIFData:photoItemNew.imageData], nil]];
        imageVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.imgURL = [NSArray arrayWithObjects: [UIImage sd_imageWithGIFData:photoItemNew.imageData], nil];
        [self presentViewController:imageVC animated:YES completion:nil];
        
    }
    else if(([meesageData.media isKindOfClass:[JSQFileMediaItem class]])){
    JSQFileMediaItem *fileMediaItem = (JSQFileMediaItem *)meesageData.media;
     
    NSURL *URL = fileMediaItem.fileURL;
    if (URL) {
      UIDocumentInteractionController *documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:URL];
      [documentInteractionController setDelegate:self];
      [documentInteractionController presentPreviewAnimated:YES];
     }
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
    }else if (msgObject != NULL && [msgObject isKindOfClass:NSDictionary.class] && [msgObject[@"replyMsgConfig"]  isEqual: @1]){
        for (NSDictionary *parentMsg in [_chatHistory reverseObjectEnumerator])
        {
            if (parentMsg[@"msgUniqueId"] != NULL && msgObject[@"parentMessageID"] != NULL &&
                [parentMsg[@"msgUniqueId"] isEqualToString:msgObject[@"parentMessageID"]] ){
                [self openThreadChatGroupView:parentMsg];
                break;
            }
        }
    }else if (msgObject != NULL && [msgObject[MsgType] isEqualToString:@"contact"]) {
        if (![Helper objectIsNilOrEmpty:msgObject andKey:ContactType]) {
            NSDictionary *dictContact = msgObject[ContactType];
            if ([dictContact count] > 0 && ![Helper objectIsNilOrEmpty:dictContact andKey:Numbers]) {
                NSArray *aryNumbers = dictContact[Numbers];
                if ([aryNumbers count] > 0) {
                    NSDictionary *dictNumber = [aryNumbers objectAtIndex:0];
                    if (![Helper stringIsNilOrEmpty:dictNumber[Number]] && [dictNumber[Number] length] > 0) {
                        double timeStamp = [[msgObject valueForKey:@"createdAt"]doubleValue];
                        NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
                        NSString *strContactPersonName = dictContact[User_Name];
                    }
                    CNContact *contact = [Helper getCNContactFrom:msgObject];
                    if (contact != NULL){
                        [self showAddContactController:contact];
                    }
                }else{
                    double timeStamp = [[msgObject valueForKey:@"createdAt"]doubleValue];
                    NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
                    NSString *strContactPersonName = dictContact[User_Name];
                    CNContact *contact = [Helper getCNContactFrom:msgObject];
                    if (contact != NULL){
                        [self showAddContactController:contact];
                    }
                }
            }
        }
    }
    
}
- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
  return self;
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
    CGFloat bottomHeight = 12.0f;
    if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row) {
        NSDictionary *dicMessage = [_chatHistory objectAtIndex:indexPath.row];
        BOOL isReplyView = false;
        
        if ([dicMessage[MsgType] isEqualToString:@"groupEvent"]){
            return  0;
        }
        
        if ([dicMessage valueForKey:@"replyMsgCount"] != nil && [dicMessage valueForKey:@"replyMsgCount"] != [NSNull null] )
        {
            NSInteger isReplyAvailble = [[dicMessage valueForKey:@"replyMsgCount"] integerValue];
            if (isReplyAvailble > 0) {
                bottomHeight = 45.0f;
                isReplyView = true;
            }
        }
        if ([dicMessage valueForKey:@"reaction"] != nil && [dicMessage valueForKey:@"reaction"] != [NSNull null] ) {
            CGFloat height = [self convertDataToEmoji:[dicMessage valueForKey:@"reaction"]];
            if (isReplyView) {
                bottomHeight = 50.0F + height;// 100.0f;
            } else {
                bottomHeight = height;//40.0f;
            }
        }
//        if ([dicMessage valueForKey:@"isReported"] != nil && [dicMessage valueForKey:@"isReported"] != [NSNull null] ) {
//            bottomHeight = 120.0F;
//        }
        
    }
    return bottomHeight;
}

- (CGFloat)convertDataToEmoji:(NSDate *)data {
    //    self.arrEmojis = [NSMutableArray new];
    //    self.arrUsers = [NSMutableArray new];
    NSArray *arrData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if ([arrData count] == 0) {
        return 0.0f;
    } else if ([arrData count] <= 5) {
        return 40.0f;
    } else if ([arrData count] <= 10) {
        return 80.0f;
    } else {
        return 120.0f;
    }
}

-(NSString*)getSeenMsgStatusIndexFromGroupChat:(NSInteger)indexItem{
    NSDictionary *dict = NULL;
    if (_chatHistory.count > 0 && _chatHistory.count > indexItem ){
        dict = [self->_chatHistory objectAtIndex:indexItem];
    }
    
    if (indexItem == self->_chatHistory.count - 1){
        if ([[dict valueForKey:@"msgStatusEvent"] isEqualToString:@"seen"]){
            if ([dict[@"msgType"] isEqualToString:@"text"]){
                return @"Read";
            }else{
                return @"Delivered";
            }
            // return strMsgStatus;
        }
        return [[dict valueForKey:@"msgStatusEvent"] capitalizedString];
    }
    return @"";
}


-(NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath{
    currentMessage  = [self.message objectAtIndex:indexPath.item];
    JSQMessage *message = [self.message objectAtIndex:indexPath.item];
    //check if outgoing
    NSDictionary *dict = NULL;
    if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row ){
        dict = [self->_chatHistory objectAtIndex:indexPath.item];
    }
    BOOL isLastMessage = [self.message.lastObject isEqual:currentMessage];
    BOOL isSending = [message.msgStatus containsString:@"sending"];
    BOOL isSelf = [currentMessage.senderId isEqualToString:self.senderId];
    if ((isLastMessage && isSelf) || isSending) {
        //status could be: 'sent', 'sending', etc
        if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row ){
        NSDictionary *dict = [self->_chatHistory objectAtIndex:indexPath.item];
        //if (currentMessage.msgStatus != nil){
            if ([dict valueForKey:@"msgStatusEvent"] != nil){
                NSString *strMsgStatus = [self getSeenMsgStatusIndexFromGroupChat:indexPath.row];
                return [[NSAttributedString alloc] initWithString:strMsgStatus];
            //return [[NSAttributedString alloc] initWithString:[dict valueForKey:@"msgStatusEvent"]];
          //  return [[NSAttributedString alloc] initWithString:currentMessage.msgStatus];
        } else {
            return [[NSAttributedString alloc] initWithString:(currentMessage.msgStatus != NULL) ? currentMessage.msgStatus : @""];
           // return [[NSAttributedString alloc] initWithString:@""];
        }
        //return [[NSAttributedString alloc] initWithString:@"delivered"];
    }else if (currentMessage.msgStatus != nil){
        return [[NSAttributedString alloc] initWithString:currentMessage.msgStatus];
    }
    }
    //return nothing for incoming messages
    return nil;
}

#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights


- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    
    JSQMessage *message = [self.message objectAtIndex:indexPath.item];
    if (_chatHistory.count > indexPath.row) {
        NSDictionary * dict = [_chatHistory objectAtIndex:indexPath.row];
        if ([dict[IsForwarded] boolValue] && (message.isMediaMessage || [dict[MsgType] isEqualToString:ContactType])){
            return kJSQMessagesCollectionViewCellLabelHeightDefault;
        }
        if (dict != NULL && [dict[@"msgType"] isEqualToString:@"groupEvent"]){
            return 30;
        }
    }
    
    if (indexPath.item == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.message objectAtIndex:indexPath.item - 1];
        if ([message.date timeIntervalSinceDate:previousMessage.date] / 60 > 1) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault;
        }
    }

//     if (indexPath.item % 3 == 0) {
//    return kJSQMessagesCollectionViewCellLabelHeightDefault;
//     }
    return 0.0f;
    
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    JSQMessage *message = [self.message objectAtIndex:indexPath.item];
    if (_chatHistory.count > indexPath.row) {
        float headPadding = 10.0;
        float tailPadding = 14.0;
        NSDictionary * dict = [_chatHistory objectAtIndex:indexPath.row];
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
        paragraphStyle.alignment  =  ([message.senderId  isEqualToString:self.senderId]) ? NSTextAlignmentRight : NSTextAlignmentLeft;

        [paragraphStyle setHeadIndent:headPadding];
        [paragraphStyle setFirstLineHeadIndent:headPadding];
        [paragraphStyle setTailIndent:-tailPadding];
//        NSUInteger offset = ([message.senderId  isEqualToString:self.senderId]) ? 3 : -3;
        if ( ![dict[IsDeletedMSG] boolValue] && [dict[IsForwarded] boolValue] &&  (message.isMediaMessage || [dict[MsgType] isEqualToString:ContactType])){
            return [[NSAttributedString alloc] initWithString:@"Forwarded" attributes:@{
                NSForegroundColorAttributeName:[UIColor grayColor],
                NSFontAttributeName: [UIFont fontWithName:@"SFProDisplay-Regular" size:13],
                NSParagraphStyleAttributeName:paragraphStyle,
//                NSBaselineOffsetAttributeName: @(offset)
            }];
        }
    }

    if (indexPath.item == 0) {
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.message objectAtIndex:indexPath.item - 1];
        if ([message.date timeIntervalSinceDate:previousMessage.date] / 60 > 1) {
            return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
        }
        
    }
    return nil;
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

/*-(void)textViewDidChange:(UITextView *)textView{
//    self.inputToolbar.contentView.textView.attributedText = [self colorHashtag:textView.text];
  //  self.inputToolbar.contentView.textView.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:16];
    if ([textView.text length] == 1){
        if ([textView.text isEqualToString:@"@"]) {
            // [self performSelector:@selector(showUser) withObject:nil afterDelay:0.5];
            [self showMentionUserList:textView.text];
        }else{
            NSLog(@"TBl Mentioned Hide 1");
        }
    }
    else if ([textView.text length] > 0){
        self.inputToolbar.contentView.textView.attributedText = [self colorHashtag:textView.text];
        if (!self.tblMention.isHidden){
            NSString *str = textView.text;
            unichar firstChar = [str characterAtIndex:0];
            if ( firstChar == '@' ) {
                NSString *strSearch = [str stringByReplacingOccurrencesOfString:@"@" withString:@""];
                [self showMentionUserList:strSearch];
            }
        }else{
            NSLog(@"TBl Mentioned Hide 2");
        }
    }else{
        if (!self.tblMention.isHidden){
            [self.numbersArrayList removeAllObjects];
            [self.tblMention reloadData];
            [self.tblMention setHidden:YES];
        }else{
            NSLog(@"TBl Mentioned Hide 3");
        }
    }
 //   self.inputToolbar.contentView.textView.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:16];
}*/

-(void)textViewDidChange:(UITextView *)textView {
    BOOL shouldEnableDomainFilter = NO;
    BOOL shouldDisableProfanityFilter = NO;
    
    NSDictionary *dictConfig = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
    NSLog(@"dictConfig>>>>>>>>>>>%@",dictConfig);
    if (dictConfig[configDomainFilter] != nil && dictConfig[configDomainFilter] != [NSNull null]) {
        shouldEnableDomainFilter = [dictConfig[configDomainFilter]  boolValue];
    }
    if (dictConfig[configprofanityEnable] != nil && dictConfig[configprofanityEnable] != [NSNull null]) {
        shouldDisableProfanityFilter = [dictConfig[configprofanityEnable] boolValue];
    }
   
    if ([textView.text length] > 1) {
        NSString *search = [textView.text stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceCharacterSet]];
        BOOL shouldShowDomainFilter = NO;
        BOOL shouldShowProfinityFilter = NO;
        [self setShowProfanityFilter:false];
        [self setDomainFilter:false];
        for (NSString *strdomain in _aryDomainFilter) {
            if ([search.lowercaseString containsString:strdomain] && isDomainFilt == @0) {
                shouldShowDomainFilter = YES;
                //[self.inputToolbar.contentView.rightBarButtonItem setHidden:YES];
            }else {
               // [self.inputToolbar.contentView.rightBarButtonItem setHidden:NO];
            }
        }
        for (NSString *strProfinity in _aryProfinityFilter) {
            if ([search.lowercaseString containsString:strProfinity] && isProfanity == false) {
                shouldShowProfinityFilter = YES;
               // [self.inputToolbar.contentView.rightBarButtonItem setHidden:YES];
            }else {
               // [self.inputToolbar.contentView.rightBarButtonItem setHidden:NO];
            }
        }
        if(shouldShowDomainFilter == YES){
            if (shouldEnableDomainFilter == YES) {
                [self setDomainFilter:true];
                [self.inputToolbar.contentView.rightBarButtonItem setHidden:YES];
            }
        
        }else if(shouldShowProfinityFilter == YES){
            if (shouldDisableProfanityFilter == YES) {
                [self setShowProfanityFilter:true];
                [self.inputToolbar.contentView.rightBarButtonItem setHidden:YES];
            }
        //[self.inputToolbar.contentView.rightBarButtonItem setHidden:YES];
        }
    }else{
        [self setShowProfanityFilter:false];
        [self setDomainFilter:false];
        [self.inputToolbar.contentView.rightBarButtonItem setHidden:NO];
    }

    [self.inputToolbar toggleSendButtonEnabled];
    if ([self isMessageEditing]){
        NSMutableDictionary *editedMessage = [editingMessage[@"editingMessage"] mutableCopy];
        editedMessage[Message] = textView.text;
        editingMessage[@"editedMessage"] = editedMessage.copy;
    }
    
    if (textView != self.inputToolbar.contentView.textView || !self.isUserSearchActive) {
        if (!self.tblMention.isHidden){
            [self.numbersArrayList removeAllObjects];
            [self.tblMention reloadData];
            [self.tblMention setHidden:YES];
        }
        self.inputToolbar.contentView.textView.attributedText = [Helper getAttributedString: [self colorHashtag:textView.text]
                                                                                     font: [UIFont fontWithName:@"SFProDisplay-Regular" size:18]];
        return;
    }
    if ([textView.text containsString:@"@"]){
        NSString *str = textView.text;
        unichar firstChar = [str characterAtIndex:[str length] - 1];
         if ( firstChar == '@' ) {
            [self showMentionUserList:@"@"];
        }
        
        else if ([textView.text length] > 1){
            NSString *strSearch = [str stringByReplacingOccurrencesOfString:@"@" withString:@""];
            if (self.strNonSearchText != nil) {
                if ([self.strNonSearchText length] > 0) {
                    NSString *strSearchText = self.strNonSearchText;
                    
                    strSearchText = [strSearchText stringByReplacingOccurrencesOfString:@"@" withString:@""];
                    strSearch = [strSearch stringByReplacingOccurrencesOfString:strSearchText withString:@""];
                    strSearch = [strSearch stringByReplacingOccurrencesOfString:@" " withString:@""];
                }
            }
            [self showMentionUserList:strSearch];
        }else{
            [self showMentionUserList:str];
        }
        
    }else{
        if (!self.tblMention.isHidden){
            [self.numbersArrayList removeAllObjects];
            [self.tblMention reloadData];
            [self.tblMention setHidden:YES];
        }else{
            NSLog(@"TBl Mentioned Hide 3");
        }
    }
    //self.inputToolbar.contentView.textView.attributedText =  [Helper getAttributedString: [self colorHashtag:textView.text]
                                                                                  //font: [UIFont fontWithName:@"SFProDisplay-Regular" size:18]];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
//    self.inputToolbar.contentView.textView.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:17];
    if ([text isEqualToString:@"@"]) {
        // [self performSelector:@selector(showUser) withObject:nil afterDelay:0.5];
        self.isUserSearchActive = YES;
        self.strNonSearchText = textView.text;
        [self showMentionUserList:text];
//        self.inputToolbar.contentView.textView.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:17];
        return YES;
    }
    
    if ([textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length>0) {
        if (isTypingActive !=true) {
            [self sendTypingStatusToRecepient:YES];
        } else {
            [self stopTypingIndicator];
        }
        
        return textView.text;
    }
    self.inputToolbar.contentView.textView.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:17];
    return YES;
}

-(void)sendTypingStatusToRecepient:(BOOL)isON {
    NSMutableDictionary * dictParam = [NSMutableDictionary new];
    if ([self.dictGroupinfo valueForKey:Group_GroupId] != nil || [self.dictGroupinfo valueForKey:Group_GroupId] != [NSNull null]) {
        [dictParam setObject:self.dictGroupinfo[Group_GroupId] forKey:App_User_ID]; // current selected user
    }
    [dictParam setObject:[[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] forKey:User_eRTCUserId]; // logged in user
    [dictParam setObject:[[UserModel sharedInstance] getUserDetailsUsingKey:User_Name] forKey:User_Name];
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
//
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

- (void)addPhotoMediaMessage:(id)image
{
    JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:image];
    photoItem.appliesMediaViewMaskAsOutgoing = YES;

   // JSQMessage *photoMessage = [JSQMessage messageWithSenderId:self.senderId
                                                 //  displayName:self.senderDisplayName
                                                    //     media:photoItem];
    JSQMessage *photoMessage = [[JSQMessage alloc]initWithSenderId:self.senderId senderDisplayName:self.senderDisplayName date:[NSDate date] media:photoItem];
    photoMessage.msgStatus =@"sending...";

    [self.message addObject:photoMessage];
    [self sendPhotoMediaItemWithData:UIImageJPEGRepresentation(image, 1.0)];
}

- (void)addVideoMediaMessage:(id)videoUrl
{
    JSQVideoMediaItem *videoItem = [[JSQVideoMediaItem alloc] initWithFileURL:videoUrl isReadyToPlay:YES];
    videoItem.appliesMediaViewMaskAsOutgoing = YES;

//    JSQMessage *videoMessage = [JSQMessage messageWithSenderId:self.senderId
//                                                   displayName:self.senderDisplayName
//                                                         media:videoItem];
    JSQMessage *videoMessage = [[JSQMessage alloc]initWithSenderId:self.senderId senderDisplayName:self.senderDisplayName date:[NSDate date] media:videoItem];
    videoMessage.msgStatus =@"sending...";

    [self.message addObject:videoMessage];
    //rakesh
    
    [self sendVideoMediaItemWithData:[NSData dataWithContentsOfURL:videoUrl]];
}

- (void)addAudioMediaMessage:(NSData*)audioFile
{
    if ((audioFile.length/1024/1024) > 25.0)  {
        [self.view makeToast:messageLargeAudioFile];
    }else{
        JSQAudioMediaItem *audioItem = [[JSQAudioMediaItem alloc] initWithData:audioFile];
        audioItem.delegate = self;
        audioItem.appliesMediaViewMaskAsOutgoing = YES;
        //JSQMessage *audioMessage = [JSQMessage messageWithSenderId:self.senderId displayName:self.senderDisplayName media:audioItem];
        JSQMessage *audioMessage = [[JSQMessage alloc]initWithSenderId:self.senderId senderDisplayName:self.senderDisplayName date:[NSDate date] media:audioItem];
        audioMessage.msgStatus =@"sending...";

        [self.message addObject:audioMessage];
        [self sendAudioMediaItemWithData:audioFile];
        [self finishReceivingMessageAnimated:YES];
    }
}

- (void)loadPhotoMediaMessage:(NSDictionary*)dictMessage
{
    
    JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageNamed:@"LogoutIcon.png"]];
    photoItem.appliesMediaViewMaskAsOutgoing = NO;
    
    NSString*strSendereRTCUserId = [dictMessage valueForKeyPath:@"sender.eRTCUserId"];
    NSString*strSenderappUserId = [dictMessage valueForKeyPath:@"sender.name"];
    
    JSQMessage *photoMessage = [JSQMessage messageWithSenderId:strSendereRTCUserId
                                                   displayName:strSenderappUserId
                                                         media:photoItem];
    [self.message addObject:photoMessage];
    [self finishReceivingMessageAnimated:YES];
    
    
}
#pragma mark - Actions
- (void)receiveMessageWithSenderId:(NSString *)senderId andDisplayName:(NSString *) displayName andtextMessage:(NSString *) textMessage msgType:(NSString*)msgType andReplyMsgConfig:(NSString*)isReplyThreadMsg andReplyBaseMsgId:(NSString*)threadBaseMsgId andDictionary:(NSDictionary*)dictResponse{
    
    [self scrollToBottomAnimated:YES];
    JSQMessage *copyMessage = nil;
    if (!copyMessage) {
        copyMessage = [JSQMessage messageWithSenderId:senderId
                                          displayName:displayName
                                                 text:textMessage];
    }
    
    JSQMessage *newMessage = nil;
    id<JSQMessageMediaData> newMediaData = nil;
    id newMediaAttachmentCopy = nil;
    
    if ([msgType isEqualToString:@"image"]) {
        NSString*strURL = textMessage;
        
        
        JSQPhotoMediaItem *photoItemCopy = [[JSQPhotoMediaItem alloc] init];
        
        if ([strURL containsString:@"https:"]) {
            [NSData ertc_dataWithContentsOfStringURL:strURL onCompletionHandler:^(NSData * _Nullable data) {
                
                [photoItemCopy setImage:[UIImage sd_imageWithData:data]];
                [self finishReceivingMessage];
                
            }];
            
        } else {
            [NSData ertc_dataWithContentsOfStringURL:strURL onCompletionHandler:^(NSData * _Nullable data) {
                [photoItemCopy setImage:[UIImage imageWithData:data]];
                [self finishReceivingMessage];
                
            }];
            
        }
        
        photoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
        newMediaAttachmentCopy = [UIImage imageWithCGImage:photoItemCopy.image.CGImage];
        photoItemCopy.image = nil;
        newMediaData = photoItemCopy;
        newMessage = [JSQMessage messageWithSenderId:senderId
                                         displayName:displayName
                                               media:newMediaData];
    } else if ([msgType isEqualToString:@"file"]) {
       NSString*strURL = textMessage;
         JSQFileMediaItem *photoItemCopy = [[JSQFileMediaItem alloc] init];
        // [NSData ertc_dataWithContentsOfStringURL:strURL onCompletionHandler:^(NSData * _Nullable data) {
            
         photoItemCopy.fileURL = [NSURL fileURLWithPath:strURL];
         
         [photoItemCopy setFileExtension:strURL.pathExtension];
         photoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
         newMediaAttachmentCopy = [UIImage imageWithCGImage:photoItemCopy.cachedImageView.image.CGImage];
         newMediaData = photoItemCopy;
         newMessage = [JSQMessage messageWithSenderId:senderId displayName:displayName media:newMediaData];
    }
    
    else if ([msgType isEqualToString:@"gify"]) {
        NSString*strURL = textMessage;
        
        
        JSQGIFMediaItem *photoItemCopy = [[JSQGIFMediaItem alloc]init];
        if ([strURL length] > 0) {
            [NSData ertc_dataWithContentsOfStringURL:strURL onCompletionHandler:^(NSData * _Nullable data) {
                [photoItemCopy setImageData:data];
                [self finishReceivingMessage];
            }];
        }
        
        
        photoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
        newMediaAttachmentCopy = [UIImage imageWithData:photoItemCopy.imageData];
       // photoItemCopy.imageData = nil;
        newMediaData = photoItemCopy;
        newMessage = [JSQMessage messageWithSenderId:senderId displayName:displayName media:newMediaData];
        
    } else if ([msgType isEqualToString:@"video"]) {
        NSString*strURL = textMessage;
        if ([strURL containsString:@"https:"]) {
            JSQVideoMediaItem *videoItemCopy = [[JSQVideoMediaItem alloc] initWithFileURL:[NSURL URLWithString:textMessage] isReadyToPlay:YES];
            videoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
            newMediaAttachmentCopy = [videoItemCopy.fileURL copy];
            newMediaData = videoItemCopy;
            newMessage = [JSQMessage messageWithSenderId:senderId
                                             displayName:displayName
                                                   media:newMediaData];
        }else{
            JSQVideoMediaItem *videoItemCopy = [[JSQVideoMediaItem alloc] initWithFileURL:[NSURL fileURLWithPath:textMessage] isReadyToPlay:YES];
            
            videoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
            newMediaAttachmentCopy = [videoItemCopy.fileURL copy];
            newMediaData = videoItemCopy;
            newMessage = [JSQMessage messageWithSenderId:senderId
                                             displayName:displayName
                                                   media:newMediaData];
        }
        
        
        newMessage = [JSQMessage messageWithSenderId:senderId displayName:displayName media:newMediaData];
    } else if ([msgType isEqualToString:@"video"]) {
        
        
        JSQVideoMediaItem *videoItemCopy = [[JSQVideoMediaItem alloc] initWithFileURL:[NSURL URLWithString:textMessage] isReadyToPlay:YES];
        
        videoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
        newMediaAttachmentCopy = [videoItemCopy.fileURL copy];
        newMediaData = videoItemCopy;
        newMessage = [JSQMessage messageWithSenderId:senderId
                                         displayName:displayName
                                               media:newMediaData];
    }
    else if ([msgType isEqualToString:@"audio"]) {
        NSString*strURL = textMessage;
        
        
        JSQAudioMediaItem *audioItem = [[JSQAudioMediaItem alloc] init];
        audioItem.delegate = self;
        if ([[NSFileManager defaultManager] fileExistsAtPath:strURL]) {
            [audioItem setAudioData:[NSData dataWithContentsOfFile:strURL]];
        }else {
            [NSData ertc_dataWithContentsOfStringURL:strURL onCompletionHandler:^(NSData * _Nullable data) {
                [audioItem setAudioData:data];
                
                
                
                [self.collectionView reloadData];
            }];
        }
        
        
        audioItem.appliesMediaViewMaskAsOutgoing = NO;
        newMediaAttachmentCopy = [audioItem.audioData copy];
        
        newMediaData = audioItem;
        
        newMessage = [JSQMessage messageWithSenderId:senderId
                                         displayName:displayName
                                               media:newMediaData];
    }
    else if ([msgType isEqualToString:@"location"]) {
        
//        CLLocation *clLocation = [[CLLocation alloc] initWithLatitude:[dictLocation[Latitude] doubleValue] longitude:[dictLocation[Longitude] doubleValue] ];
//
//        JSQLocationMediaItem *locationItem = [[JSQLocationMediaItem alloc] initWithLocation:self->locationManager.location];
//        locationItem.appliesMediaViewMaskAsOutgoing = NO;
//        newMediaData = locationItem;
//        newMessage = [JSQMessage messageWithSenderId:senderId
//                                         displayName:displayName
//                                               media:newMediaData];
    }
    else {
        NSString *strMessage = @"";
        if ([isReplyThreadMsg boolValue]){
           // strMessage = [NSString stringWithFormat:@"Replied to a thread:\n%@",copyMessage.text];
            NSString *strbaseMsgId =[NSString stringWithFormat:@"%@", [dictResponse valueForKeyPath:@"msgUniqueId"]];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"msgUniqueId == %@",strbaseMsgId];
            NSArray *aryFilter = [self->_chatHistory filteredArrayUsingPredicate:predicate];
            if (aryFilter.count > 0){
                NSString *strParentMsg;
                if ([[[aryFilter objectAtIndex:0] valueForKey:@"msgType"] isEqualToString:@"text"]) {
                    strParentMsg = [[aryFilter objectAtIndex:0] valueForKey:@"parentMsg"];
                }else if ([[[aryFilter objectAtIndex:0] valueForKey:@"msgType"] isEqualToString:@"image"]) {
                    strParentMsg = [[aryFilter objectAtIndex:0] valueForKey:@"mediaFileName"];
                }else if ([[[aryFilter objectAtIndex:0] valueForKey:@"msgType"] isEqualToString:@"location"]) {
                    NSDictionary *dictLocation = [[aryFilter objectAtIndex:0] valueForKey:@"location"];
                    strParentMsg = [dictLocation valueForKey:@"address"];
                }else if ([[[aryFilter objectAtIndex:0] valueForKey:@"msgType"] isEqualToString:@"gif"]) {
                    strParentMsg = [[aryFilter objectAtIndex:0] valueForKey:@"mediaFileName"];
                }else if ([[[aryFilter objectAtIndex:0] valueForKey:@"msgType"] isEqualToString:@"contact"]){
                    NSDictionary *dictLocation = [[aryFilter objectAtIndex:0] valueForKey:@"contact"];
                    strParentMsg = [dictLocation valueForKey:@"name"];
                }else {
                    strParentMsg = [[aryFilter objectAtIndex:0] valueForKey:@"mediaFileName"];
                }
                
                if ([strParentMsg length] > 35) {
                    NSRange range = [strParentMsg rangeOfComposedCharacterSequencesForRange:(NSRange){0, 35}];
                    strParentMsg = [strParentMsg substringWithRange:range];
                    strParentMsg = [strParentMsg stringByAppendingString:@"…"];
                }
                strMessage = [NSString stringWithFormat:@"Replied to a thread:%@\n%@",strParentMsg,copyMessage.text];
            }else {
                strMessage = [NSString stringWithFormat:@"Replied to a thread:\n%@",copyMessage.text];
            }
        }else{
            if (dictResponse[@"forwardChatFeatureData"] != NULL &&
                dictResponse[@"forwardChatFeatureData"][IsForwarded] != NULL &&
                [dictResponse[@"forwardChatFeatureData"][IsForwarded] boolValue]){
                strMessage = [NSString stringWithFormat:@"%@\n%@",ForwardedString, copyMessage.text];
            }else {
                strMessage = copyMessage.text;
            }
        }
        
        
        
        NSURL *first = [Helper getFirstUrlIfExistInMessage:strMessage];
        double timeStamp = [[dictResponse valueForKey:@"createdAt"]doubleValue];
        NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
        if (first){
            JSQLinkPreviewMediaItem *item = [[JSQLinkPreviewMediaItem alloc] initWithURL:first details:dictResponse completionHandler:^(NSDictionary * _Nonnull details, NSError * _Nullable error) {
                NSString *msgId = details[MsgUniqueId];
                NSString *threadId = details[@"thread"][ThreadID];
                NSUInteger index = [self getIndexOfMessageId:msgId threadId:threadId];
                if (index != -1 && index <= self->_chatHistory.count){
                    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
                }
            }];
            newMessage = [[JSQMessage alloc] initWithSenderId:senderId
                                            senderDisplayName:displayName
                                                         date:msgdate
                                                        media:item];
        }else {
            newMessage = [JSQMessage messageWithSenderId:senderId displayName:displayName text:strMessage];
            
        }
    }
    newMessage.msgStatus = @"seen";
    [self.message addObject:newMessage];
    [self finishReceivingMessageAnimated:YES];
    
    if (newMessage.isMediaMessage) {
        //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([newMediaData isKindOfClass:[JSQPhotoMediaItem class]]) {
            ((JSQPhotoMediaItem *)newMediaData).image = newMediaAttachmentCopy;
            [self.collectionView reloadData];
        }
        else if ([newMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
            [((JSQLocationMediaItem *)newMediaData)setLocation:newMediaAttachmentCopy withCompletionHandler:^{
                [self.collectionView reloadData];
            }];
        }
        else if ([newMediaData isKindOfClass:[JSQVideoMediaItem class]]) {
            ((JSQVideoMediaItem *)newMediaData).fileURL = newMediaAttachmentCopy;
            ((JSQVideoMediaItem *)newMediaData).isReadyToPlay = YES;
            [self.collectionView reloadData];
        }
        else if ([newMediaData isKindOfClass:[JSQAudioMediaItem class]]) {
            ((JSQAudioMediaItem *)newMediaData).audioData = newMediaAttachmentCopy;
            [self.collectionView reloadData];
        }
        else if ([newMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
            ((JSQLocationMediaItem *)newMediaData).location = newMediaAttachmentCopy;
            [self.collectionView reloadData];
        }
        else {
            NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
        }
        
        //            });
    }
    //    });
}


-(void)refershControlAction {
    NSLog(@"[refershControlAction]");
    NSMutableDictionary *details = @{}.mutableCopy;
    details[@"pageSize"] = @20;
    if (_chatHistory != NULL && _chatHistory.count > 0 && _chatHistory.firstObject[MsgUniqueId] != NULL){
        details[@"currentMsgId"] =  _chatHistory.firstObject[MsgUniqueId] ;
        details[@"includeCurrentMsg"] = @"false";
    }
    
    details[@"direction"] = @"past";
    [self loadPreviousMessages:details completion:^{
        [self->refreshControl endRefreshing];
    }];
}

-(void)setupPullToRefereash {
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(refershControlAction) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
}

#pragma mark - 3D Touch
- (void)check3DTouch {
    [self registerForPreviewingWithDelegate:self sourceView:self.view];
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    if ([self.imgURL count] > 0) {
        return [[BFRImageViewController alloc] initWithImageSource:self.imgURL];
    }
    return nil;
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

#pragma mark - Send message API

- (void)updateChatThreadHistory {
    
    if (self.strThreadId != nil ) {
        [[eRTCCoreDataManager sharedInstance] getUserChatHistoryWithThreadID:self.strThreadId andCompletionHandler:^(id ary, NSError *err) {
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
            NSArray *sortedArray=[ary sortedArrayUsingDescriptors:@[sort]];
            self->_chatHistory = [NSMutableArray arrayWithArray:sortedArray];
            [self->_chatHistory enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj[MsgType] isEqualToString:@"text"] && idx < self.message.count){
                    JSQMessage *message = self.message[idx];
                    NSString *messageTXT = obj[Message];
                    NSURL *url = [Helper getFirstUrlIfExistInMessage:messageTXT];
                    if (url && (message.media == NULL || ![message.media isKindOfClass:JSQLinkPreviewMediaItem.class])){
                        NSString *senderID = obj[SendereRTCUserId];
                        NSString *_strDisplayName = @"";
                        if ([obj[SendereRTCUserId] isEqualToString:self.senderId]) {
                            _strDisplayName = self.senderDisplayName;
//                            isOutgoingMsg =YES;
                        }
                        double timeStamp = [[obj valueForKey:@"createdAt"]doubleValue];
                        NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
                        message = [self getLinkPreviewMediaItem:url details:obj senderId:senderID displayName:_strDisplayName date:msgdate];
                        self.message[idx] = message;
                    }
                }
            }];
        }];
    }
}
-(JSQMessage*)getLinkPreviewMediaItem:(NSURL*)url
                                details:(NSDictionary*)dict
                               senderId:(NSString*)senderId
                            displayName:(NSString*) displayName
                                   date: (NSDate*)date{
    JSQLinkPreviewMediaItem *item = [[JSQLinkPreviewMediaItem alloc] initWithURL:url details:dict completionHandler:^(NSDictionary * _Nonnull details, NSError * _Nullable error) {
        NSString *msgId = dict[MsgUniqueId];
        NSString *threadId = dict[ThreadID];
        NSUInteger index = [self getIndexOfMessageId:msgId threadId:threadId];
        if (index != -1 && index <= self->_chatHistory.count){
            [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
        }
    }];
    return [[JSQMessage alloc] initWithSenderId:senderId
                                    senderDisplayName:displayName
                                                 date:date
                                                media:item];
}

-(void)sendTextMessage:(NSString*)message {
    if (self.inputToolbar.contentView.rightBarButtonItem.isSelected == YES && message.length>0) {
       // NSString *mentionString = [Helper getNamesTaggedStringFromNames:_userNames message:message];
        if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil) {
            NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
            if (self.dictGroupinfo[Group_GroupId] != nil && self.dictGroupinfo[Group_GroupId] != [NSNull null]) {
                NSMutableDictionary * dictParam = [NSMutableDictionary new];
                [dictParam setObject:userId forKey:SendereRTCUserId];
                [dictParam setObject:message forKey:Message];
                [dictParam setObject:self.strThreadId forKey:ThreadID];
                [dictParam setValue:self.aryMentioned forKey:@"mentions"];
                [dictParam setObject:self->arrUser forKey:ArParticipants];
                
                
                
                [[eRTCChatManager sharedChatInstance] sendTextMessageWithParam:[NSDictionary dictionaryWithDictionary:dictParam] andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                    NSDictionary *dictResponse = (NSDictionary *)json;
                    if ([dictResponse[@"success"] boolValue] == false) {
                   // [_message removeLastObject];
                    [self performSelector:@selector(showAlert:) withObject:dictResponse[@"msg"] afterDelay:0.1];
                    }else{
                    self->currentMessage.msgStatus = @"Sent";
                    [self updateChatThreadHistory];
                    [self.collectionView reloadData];
                    }
                    _aryMentioned = [NSMutableArray new];
                } andFailure:^(NSError * _Nonnull error) {
                    NSLog(@"error--> %@",error);
                    NSString *errMsg = [NSString stringWithFormat:@"%@", error.localizedDescription];
                    [self performSelector:@selector(showAlert:) withObject:errMsg afterDelay:0.3];
                    _aryMentioned = [NSMutableArray new];
                }];
            }
        }
    }
}

-(void)showAlert:(NSString *)strMessage{
    [Helper showAlertOnController:@"eRTC" withMessage:strMessage onController:self];
}

-(void)sendEditedTextMessage:(NSDictionary*)editingMesssage {
    NSIndexPath *indexPath = editingMesssage[@"position"];
    NSDictionary *object = editingMesssage[@"editedMessage"];
    NSString *message = [object[Message] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *mentionString = [Helper getNamesTaggedStringFromNames:_userNames message:message];
    
    if (self.inputToolbar.contentView.rightBarButtonItem.isSelected == YES && message.length>0) {
        if (isTypingActive) {
            [self userTypingFinished];
        }
        NSMutableDictionary * dictDeleteMessage = [NSMutableDictionary new];
        if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil) {
            NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
            if (self.dictGroupinfo[Group_GroupId] != nil && self.dictGroupinfo[Group_GroupId] != [NSNull null]) {
                [dictDeleteMessage setObject:mentionString forKey:Message];
                [dictDeleteMessage setObject:userId forKey:SendereRTCUserId];
                [dictDeleteMessage setValue:object[ThreadID] forKey:@"threadId"];
                [dictDeleteMessage setValue:object[MsgUniqueId] forKey:@"msgUniqueId"];
                [dictDeleteMessage setObject:self->arrUser forKey:ArParticipants];
                
                [[eRTCChatManager sharedChatInstance] editMessageWithParam:[NSDictionary dictionaryWithDictionary:dictDeleteMessage] andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                    
                    [self updateMessageCellAtIndexPath:indexPath message:object];
                } andFailure:^(NSError * _Nonnull error) {
                    NSLog(@"error--> %@",error);
                    [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
                    if (error.code == 403) {
                        [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self completion:^{
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:IsLoggedIn];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            [[UserModel sharedInstance]logOutUser];
                            [[AppDelegate sharedAppDelegate] willChangeLoginAsRootOfApplication];
                        }];
                    }else {
                        [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
                    }
                }];
            }
        }
    }
}



-(void)sendPhotoMediaItemWithData:(NSData*)data {
    if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil) {
        NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
        NSMutableDictionary * dictParam = [NSMutableDictionary new];
        [dictParam setObject:userId forKey:SendereRTCUserId];
        //  [dictParam setObject:@"image" forKey:@"msgType"];
        [dictParam setObject:self.strThreadId forKey:ThreadID];
//        [[eRTCChatManager sharedChatInstance] sendPhotoMediaItemWithParam:dictParam andFileData:data];
        [[eRTCChatManager sharedChatInstance] sendPhotoMediaItemWithParam:dictParam andFileData:data andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            NSDictionary *dictResponse = (NSDictionary *)json;
            if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary * dictFollow = [NSMutableDictionary new];
                NSDictionary *dictResult = json[@"result"];
                if (dictResult.count > 0) {
                [dictFollow setObject:dictResult[MsgUniqueId] forKey:MsgUniqueId];
                [dictFollow setObject:dictResult[ThreadID] forKey:ThreadID];
                [self followUnFollowMsg:false dict:dictFollow];
                }
             }
            NSLog(@"Photo sent succesfully!!!");
            self->currentMessage.msgStatus = @"Sent";
            [self finishSendingMessageAnimated:YES];
            [self updateChatThreadHistory];

        } andFailure:^(NSError * _Nonnull error) {
            NSLog(@"Failed to send Photo");
            [_message removeLastObject];
            NSString *errMsg = [NSString stringWithFormat:@"%@", error.localizedDescription];
            [self performSelector:@selector(showAlert:) withObject:errMsg afterDelay:0.3];
        }];

    }
}

-(void)sendAudioMediaItemWithData:(NSData*)data {
    if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil) {
        NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
        if (self.dictGroupinfo[Group_GroupId] != nil && self.dictGroupinfo[Group_GroupId] != [NSNull null]) {
            NSMutableDictionary * dictParam = [NSMutableDictionary new];
            [dictParam setObject:userId forKey:SendereRTCUserId];
            //   [dictParam setObject:@"audio" forKey:@"msgType"];
            [dictParam setObject:self.strThreadId forKey:ThreadID];
//            [[eRTCChatManager sharedChatInstance] sendAudioMediaItemWithParam:dictParam andFileData:data];
            [[eRTCChatManager sharedChatInstance] sendAudioMediaItemWithParam:dictParam andFileData:data andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                NSDictionary *dictResponse = (NSDictionary *)json;
                
                NSLog(@"dictResponse >>>>>>>>>>>>>>>>>>>>%@",dictResponse);
//                if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
//                    NSMutableDictionary * dictFollow = [NSMutableDictionary new];
//                    NSDictionary *dictResult = json[@"result"];
//                    if (dictResult.count > 0) {
//                    [dictFollow setObject:dictResult[MsgUniqueId] forKey:MsgUniqueId];
//                    [dictFollow setObject:dictResult[ThreadID] forKey:ThreadID];
//                    [self followUnFollowMsg:false dict:dictFollow];
//                    }
//                 }
                NSLog(@"Audio sent succesfully!!!");
                self->currentMessage.msgStatus = @"sent";
                [self finishSendingMessageAnimated:YES];
                [self updateChatThreadHistory];

            } andFailure:^(NSError * _Nonnull error) {
                [_message removeLastObject];
                NSString *errMsg = [NSString stringWithFormat:@"%@", error.localizedDescription];
                [self performSelector:@selector(showAlert:) withObject:errMsg afterDelay:0.3];
            }];

        }
    }
}

-(void)sendVideoMediaItemWithData:(NSData*)data {
    if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil) {
        NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
        
        if (self.dictGroupinfo[Group_GroupId] != nil && self.dictGroupinfo[Group_GroupId] != [NSNull null]) {
            NSMutableDictionary * dictParam = [NSMutableDictionary new];
            [dictParam setObject:userId forKey:SendereRTCUserId];
            [dictParam setObject:self.strThreadId forKey:ThreadID];
//            [[eRTCChatManager sharedChatInstance] sendVideoMediaItemWithParam:dictParam andFileData:data];
            [[eRTCChatManager sharedChatInstance] sendVideoMediaItemWithParam:dictParam andFileData:data andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                NSDictionary *dictResponse = (NSDictionary *)json;
//                if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
//                    NSMutableDictionary * dictFollow = [NSMutableDictionary new];
//                    NSDictionary *dictResult = json[@"result"];
//                    if (dictResult.count > 0) {
//                    [dictFollow setObject:dictResult[MsgUniqueId] forKey:MsgUniqueId];
//                    [dictFollow setObject:dictResult[ThreadID] forKey:ThreadID];
//                    [self followUnFollowMsg:false dict:dictFollow];
//                    }
//                 }
                NSLog(@"Video sent succesfully!!!");
                self->currentMessage.msgStatus = @"Sent";
                [self finishSendingMessageAnimated:YES];
                [self updateChatThreadHistory];

            } andFailure:^(NSError * _Nonnull error) {
                NSLog(@"Failed to send Video");
                [_message removeLastObject];
                NSString *errMsg = [NSString stringWithFormat:@"%@", error.localizedDescription];
                [self performSelector:@selector(showAlert:) withObject:errMsg afterDelay:0.3];
            }];
        }
    }
}

-(void)sendFileMediaItemWithData:(NSURL*)url andFileExtension:(NSString *)fileExtension{

  NSData *data = [NSData dataWithContentsOfURL:url];
  // NSURL *rtfUrl = [[NSBundle mainBundle] URLForResource:@"order_receipt" withExtension:@"pdf"];
  //  NSData * dataa = [NSData dataWithContentsOfURL:rtfUrl];
  //  NSString * fileExtension = [rtfUrl pathExtension];
  if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil) {
    NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
     
    if (self.dictGroupinfo[Group_GroupId] != nil && self.dictGroupinfo[Group_GroupId] != [NSNull null]) {
      NSMutableDictionary * dictParam = [NSMutableDictionary new];
      [dictParam setObject:userId forKey:SendereRTCUserId];
      [dictParam setObject:self.strThreadId forKey:ThreadID];
//      [[eRTCChatManager sharedChatInstance] sendMediaFileItemWithParam:dictParam andFileData:data andFileExtension:fileExtension];
       [[eRTCChatManager sharedChatInstance] sendMediaFileItemWithParam:dictParam andFileData:data andFileExtension:fileExtension andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
           NSLog(@"File sent succesfully!!!");
           self->currentMessage.msgStatus = @"sent";
           [self finishSendingMessageAnimated:YES];
           [self updateChatThreadHistory];

       } andFailure:^(NSError * _Nonnull error) {
           NSLog(@"Failed to send File");
       }];

      JSQFileMediaItem *photoItem = [[JSQFileMediaItem alloc] init];
      photoItem.fileURL = url;
      [photoItem setFileExtension:fileExtension];
      JSQMessage *photoMessage = [JSQMessage messageWithSenderId:self.senderId
                              displayName:self.senderDisplayName
                                 media:photoItem];
        photoMessage.msgStatus =@"sending...";

      [self.message addObject:photoMessage];
      [self finishSendingMessageAnimated:YES];
    }
  }
}

-(void)sendGIFMediaItemWithURL:(NSString*)gifURL {
    if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil && [gifURL length] > 0) {
        NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
        if (self.dictGroupinfo[Group_GroupId] != nil && self.dictGroupinfo[Group_GroupId] != [NSNull null]) {
            NSMutableDictionary * dictParam = [NSMutableDictionary new];
            [dictParam setObject:userId forKey:SendereRTCUserId];
            [dictParam setObject:gifURL forKey:GifyFileName];
//            [dictParam setObject:@"gify" forKey:MsgType];
            [dictParam setObject:self.strThreadId forKey:ThreadID];
            [dictParam setObject:self->arrUser forKey:ArParticipants];
            
            
            JSQGIFMediaItem *photoItem = [[JSQGIFMediaItem alloc] init];
            JSQMessage *photoMessage = [JSQMessage messageWithSenderId:self.senderId
            displayName:self.senderDisplayName
                  media:photoItem];
            photoMessage.msgStatus =@"sending";
            NSDictionary *dictConfig = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
            NSUInteger index;
            if ([dictConfig[@"gifyGroupChat"] boolValue] == false) {
               
            }else{
                [self.message addObject:photoMessage];
                [self finishReceivingMessageAnimated:TRUE];
                index = self.message.count - 1;
            }
            [[eRTCChatManager sharedChatInstance] sendGIFFileWithParam:dictParam andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                NSDictionary *dictResponse = (NSDictionary *)json;
                if (dictResponse[@"success"] != nil) {
                    BOOL success = [dictResponse[@"success"] boolValue];
                    if (success == true) {
                        if (errMsg == nil) {
                                NSDictionary *config = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
                                NSLog(@"config>>>>>>>>>>>>%@",config);
                                
                                if ([config[@"e2eGify"] boolValue] == true) {
                                        photoMessage.msgStatus = @"Sent".capitalizedString;
                                        [NSData ertc_dataWithContentsOfStringURL:gifURL onCompletionHandler:^(NSData * _Nullable data) {
                                            [photoItem setImageData:data];
                                            [self updateChatThreadHistory];
                                            self->currentMessage.msgStatus = @"Sent".capitalizedString;
                                            [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
                                        }];
                                }else{
                                if (json[@"result"] != nil) {
                                NSDictionary *result = json[@"result"];
                                if (result[@"metadata"][@"localFilePath"] != nil) {
                                    NSString *strGIF =  result[@"metadata"][@"localFilePath"];
                                    photoMessage.msgStatus = @"Sent".capitalizedString;
                                    [NSData ertc_dataWithContentsOfStringURL:strGIF onCompletionHandler:^(NSData * _Nullable data) {
                                        
                                        [photoItem setImageData:data];
                                        [self updateChatThreadHistory];
                                        self->currentMessage.msgStatus = @"Sent".capitalizedString;
                                        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
                                    }];
                                }
                            }//
                          }
                        }
                    }else{
                        [self.view endEditing:true];
                        [_message removeLastObject];
                        [self.collectionView reloadData];
                        [self.view makeToast:dictResponse[@"msg"]];
                    }
                }
            } andFailure:^(NSError * _Nonnull error) {
                NSLog(@"Failed to send Gif");
                NSString *errMsg = [NSString stringWithFormat:@"%@", error.localizedDescription];
                [self performSelector:@selector(showAlert:) withObject:errMsg afterDelay:0.3];
            }];
        }
    }
}


-(void)getGroupDetails {
    NSString *gID = self.dictGroupinfo[Group_GroupId];
        [[eRTCCoreDataManager sharedInstance] fetchGroup:gID andCompletionHandler:^(NSDictionary *data, NSError *err) {
        if ([data isKindOfClass:NSDictionary.class] && [data[@"participants"] isKindOfClass:NSArray.class]){
            NSArray *participants = data[@"participants"];
            BOOL isUserParticipant = false;
            NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
            for (NSDictionary *user in participants) {
                if (user[@"eRTCUserId"] && [user[@"eRTCUserId"] isEqualToString:userId]){
                    isUserParticipant = true;
                    break;
                }
            }
            if (isUserParticipant){
               // [self removeChannel:false];
                [self unblockUI];
            }else {
                
                [self showBlockUI];
            }
        }
    }];
}

-(void)showBlockUI{
    self.inputToolbar.userInteractionEnabled = true;
    self.inputToolbar.frame = CGRectMake(0, self.view.frame.size.height -100, self.view.frame.size.width, 100);
//    self.inputToolbar.hidden = TRUE;
    if (!blockUnblockLabel){
       // [self removeChannel:true];
        blockUnblockLabel = [UILabel new];
        blockUnblockLabel.text = @"You are not part of this Channel";
        blockUnblockLabel.font = [UIFont fontWithName:@"SFProDisplay-Semibold" size:18];
        blockUnblockLabel.textAlignment = NSTextAlignmentCenter;
        blockUnblockLabel.textColor = [UIColor blackColor];
        blockUnblockLabel.backgroundColor = [UIColor whiteColor];
        [self.inputToolbar.contentView.rightBarButtonItem setHidden:YES];
        [self.inputToolbar.contentView.leftBarButtonItem setHidden:YES];
    }
    [self.view layoutIfNeeded];
   // self.view.userInteractionEnabled = FALSE;
    [self.inputToolbar.contentView addSubview:blockUnblockLabel];
    self.inputToolbar.userInteractionEnabled = false;
    isBlockUI = true;
}

-(void)viewWillLayoutSubviews{
    blockUnblockLabel.frame = self.inputToolbar.contentView.bounds;
}

-(void)unblockUI{
    self.inputToolbar.userInteractionEnabled = TRUE;
   // self.view.userInteractionEnabled = false;
//    self.inputToolbar.hidden = FALSE;
    [blockUnblockLabel removeFromSuperview];
    isBlockUI = false;
    [self.inputToolbar.contentView.rightBarButtonItem setHidden:NO];
    [self.inputToolbar.contentView.leftBarButtonItem setHidden:NO];
}
      
-(void)didReceivedGroupEvent:(NSNotification *)notification {
    NSLog (@"Successfully received the Group Event notification! %@",[notification userInfo]);
    NSDictionary *data = [notification userInfo];
    
    if (data && data[@"eventList"] && [data[@"eventList"] isKindOfClass:NSArray.class] &&
        data[@"threadId"] && [self.strThreadId isEqualToString:data[@"threadId"]]){
        NSDictionary *eventObj =  [(NSArray*)data[@"eventList"] firstObject];
        if (eventObj[@"eventType"] != nil && eventObj[@"eventType"] != [NSNull null]) {
            if ([eventObj[@"eventType"] isEqualToString:@"frozen"]) {
                self->isFrozenChannel = true;
                [self Frozen_Channel:true];
            }else if ([eventObj[@"eventType"] isEqualToString:@"unfrozen"]) {
                self->isFrozenChannel = false;
                [self Frozen_Channel:false];
                [self->frozenView removeFromSuperview];
            }else if ([eventObj[@"eventType"] isEqualToString:@"deactivated"]) {
                [self isShowDeactivatedMessage:true];
                [_dictGroupinfo setValue:@true forKey:@"isActivated"];
                [self.view endEditing:true];
                self->isGroupActivated = true;
            }else if ([eventObj[@"eventType"] isEqualToString:@"activated"]) {
                [_dictGroupinfo setValue:@false forKey:@"isActivated"];
                [self isShowDeactivatedMessage:false];
                self->isGroupActivated = false;
            }
        }
        
        NSString *groupId = [NSString stringWithFormat:@"%@",self.dictGroupinfo[Group_GroupId]];
        if ([groupId isEqualToString:data[Group_GroupId]]) {
        NSString *reMoveProfile = eventObj[@"eventType"];
        self.navigationItem.titleView =  nil;
        self.navigationController.navigationBar.topItem.title=@"";
        UIView *titleHeaderView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width-20, 60)];
        UIImage *img = [UIImage imageNamed:@"DefaultUserIcon"];
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0 , 4, 35, 35)];
        [imgView setImage:img];
        [imgView setContentMode:UIViewContentModeScaleAspectFill];
        imgView.layer.cornerRadius= imgView.frame.size.height/2;
        imgView.layer.masksToBounds = YES;
         
        if ([reMoveProfile isEqualToString:ProfilePicChanged])
        {
            NSDictionary *changeData = eventObj[@"eventData"][@"changeData"];
            NSDictionary *profilePicThumb = changeData[@"profilePicThumb"];
            NSString *imageURL = [NSString stringWithFormat:@"%@",profilePicThumb[@"new"]];
            NSString *strUrl = [imageBaseUrl stringByAppendingString:imageURL];
            [imgView sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
            [dictImage setValue:strUrl forKey:@"profilePicThumb"];
            //lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x+40, 12, 110, 20)];
        }else{
            NSString *imageURL = [NSString stringWithFormat:@"%@",dictImage[@"profilePicThumb"]];
            [imgView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
        }
           if ([eventObj[@"eventType"] isEqualToString:@"nameChanged"]){
                NSDictionary *changeData = eventObj[@"eventData"][@"changeData"];
                NSDictionary *name = changeData[@"name"];
                lblHeader.text = name[@"new"];
               //[_dictGroupinfo setValue:strUrl forKey:@"profilePicThumb"];
            }
            
            
            
        lblHeader.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:18];
        lblHeader.textAlignment = NSTextAlignmentLeft;
       // [titleHeaderView addSubview:imgView];
       // [titleHeaderView addSubview:lblHeader];
        statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x+40, lblHeader.frame.origin.x, 110, 20)];
        statusLabel.text = @"typing...";
        statusLabel.textAlignment  = NSTextAlignmentLeft;
        statusLabel.hidden = true;
        statusLabel.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:12];
        UIStackView *sh = [[UIStackView alloc] initWithArrangedSubviews:@[lblHeader, statusLabel]];
        sh.axis = UILayoutConstraintAxisVertical;
        UIStackView *sv = [[UIStackView alloc] initWithArrangedSubviews:@[imgView, sh]];
          [sv addConstraint:[NSLayoutConstraint constraintWithItem:imgView
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0
                                                          constant:35]];
          [sv addConstraint:[NSLayoutConstraint constraintWithItem:imgView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0
                                                          constant:35]];
          [imgView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
          [lblHeader setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
          sv.axis = UILayoutConstraintAxisHorizontal;
          sv.spacing = 5.0;
          self.navigationItem.titleView =  sv; ///UIStackView(arrangedSubviews: [imageView, titleLbl]);
          UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
          initWithTarget:self action:@selector(btnGroupImageTapped)];
          [self.navigationItem.titleView addGestureRecognizer:tapRecognizer];
        }
        /*
        if ([eventObj[@"eventType"] isEqualToString:@"adminMade"]){
            NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
            NSDictionary * dictEventTriggeredByUser = data[@"eventTriggeredByUser"];
                if (dictEventTriggeredByUser[User_eRTCUserId] && userId  && [dictEventTriggeredByUser[User_eRTCUserId] isEqualToString: userId]){
                    //[self.view makeToast:@"You are not part of this Channel"];
                    [self removeChannel:true];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.navigationController popToRootViewControllerAnimated:true];
                    });
                }
         }*/
        
        
        if (eventObj && [eventObj[@"eventType"] isEqualToString:@"participantsRemoved"]){ // && eventObj[@"eventData"]
            NSDictionary *changeData =  eventObj[@"changeData"][@"profilePic"];
            [self showUserIconAndNameOnNavigationTitle];
            
            NSArray *eventTriggeredOnUserList = eventObj[@"eventData"][@"eventTriggeredOnUserList"];
            if (eventTriggeredOnUserList && [eventTriggeredOnUserList isKindOfClass:NSArray.class]){
                BOOL isAdminRemovedYou = FALSE;
                NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
                for (NSDictionary *user in eventTriggeredOnUserList) {
                    if (user[User_eRTCUserId] && userId  && [user[User_eRTCUserId] isEqualToString: userId]){
                        isAdminRemovedYou = TRUE;
                        break;
                    }
                }
                if (isAdminRemovedYou){
                    [self getGroupDetails];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.navigationController popToRootViewControllerAnimated:true];
                    });
                    return;
                }
            }
        }else if (eventObj && [eventObj[@"eventType"] isEqualToString:@"participantsAdded"] && eventObj[@"eventData"]){
            [self getGroupDetails];
        }else if ([eventObj[@"eventType"] isEqualToString:@"deleted"]) {
            [self removeChannel:true];
            isRemovedChannel = true;
        }
    }
    [self refreshChatData];
}

- (void)jsq_setCollectionViewInsetsTopValue:(CGFloat)top bottomValue:(CGFloat)bottom
{
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0.0f, bottom+15, 0.0f);
    self.collectionView.contentInset = insets;
    self.collectionView.scrollIndicatorInsets = insets;
}

-(void)didDeleteChatMsgNotification:(NSNotification *) notification{
    NSDictionary *userInfo = notification.userInfo;
    if (!userInfo) return;
    NSArray *chats = userInfo[@"chats"];
    if (![chats isKindOfClass:NSArray.class] || !(chats.count > 0))return;
    NSDictionary *chat = chats.firstObject;
    id msgId = chat[@"msgUniqueId"];
    id threadId = userInfo[@"threadId"];
    
    if ([userInfo[@"updateType"] isEqualToString:@"delete"] && [userInfo[@"deleteType"] isEqualToString:@"everyone"]) {
        for (int i = 0; i < [self->_chatHistory count]; i++)
        {
            NSMutableDictionary * dictParam = [NSMutableDictionary new];
            dictParam = [self->_chatHistory objectAtIndex:i];
            if ([dictParam[MsgUniqueId] isEqualToString:chat[MsgUniqueId]]) {
                NSString *chatReportId = dictParam[Chat_ReportId];
                if ([dictParam[IsFavourite] intValue])
                {
                    NSMutableDictionary * dictParama = [NSMutableDictionary new];
                    [dictParama setValue:[NSNumber numberWithInt:1] forKey:IsFavourite];
                    [dictParama setValue:msgId forKey:MsgUniqueId];
                    [self isMarkFavouriteWithIndexPath:dictParama favouriteUser:true];
                }
                
                if ((![chatReportId isEqual:[NSNull null]]) && ([chatReportId length] != 0)) {
                    [[eRTCChatManager sharedChatInstance] deleteChatReport:@{@"chatReportId": chatReportId} andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                        [KVNProgress dismiss];
                        [self getChatHistory];
                    }andFailure:^(NSError * _Nonnull error) {
                        [KVNProgress dismiss];
                        [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
                    }];
                }
            }
        }
    }
    
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
        if (indexPath != -1 && message != NULL){
            [self updateMessageCellAtIndexPath:[NSIndexPath indexPathForRow:indexPath inSection:0] message:message];
            if ([message[@"msgType"] isEqualToString:@"audio"]) {
                [currentAudioMediaItem pause];
            }
        }
    }
}

-(void)didUpdateChatMsgNotification:(NSNotification *) notification{
    NSDictionary *userInfo = notification.userInfo;
    if (!userInfo) return;
    NSArray *chats = userInfo[@"chats"];
    if (![chats isKindOfClass:NSArray.class] || !(chats.count > 0))return;
    NSDictionary *chat = chats.firstObject;
    
    id msgId = chat[@"msgUniqueId"];
    id threadId = userInfo[@"threadId"];
    
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
        if (indexPath != -1 && message != NULL){
            [self updateMessageCellAtIndexPath:[NSIndexPath indexPathForRow:indexPath inSection:0] message:message];
        }
    }
}

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

- (void)didReceiveMessageNotification:(NSNotification *) notification
{
    NSLog (@"Successfully received the test notification! %@",[notification userInfo]);
    NSDictionary * dictMessage = [notification userInfo];
    if ([dictMessage isKindOfClass:[NSDictionary class]]){
        if (self.strThreadId!= nil && dictMessage[ThreadID] != [NSNull null]) {
            NSString *strReplyStatus = @"";
            NSString *strBaseMsgId = @"";
            if (![Helper stringIsNilOrEmpty:[dictMessage valueForKeyPath:@"replyThreadFeatureData.replyMsgConfig"]]){
                strReplyStatus = [NSString stringWithFormat:@"%@", [dictMessage valueForKeyPath:@"replyThreadFeatureData.replyMsgConfig"]];
                strBaseMsgId = [NSString stringWithFormat:@"%@", [dictMessage valueForKeyPath:@"replyThreadFeatureData.baseMsgUniqueId"]];
            }
            if  ([Helper stringIsNilOrEmpty:dictMessage[ReplyThreadFeatureData]] || [strReplyStatus  isEqual: @"1"]) {
                 [self updateChatThreadHistory];
            NSString*strCurrentMsgThreadID = [NSString stringWithFormat:@"%@",[dictMessage valueForKeyPath:@"thread.threadId"]];
                
            if ([self.strThreadId isEqualToString:strCurrentMsgThreadID]){
                NSString*strSendereRTCUserId = [dictMessage valueForKeyPath:@"sender.eRTCUserId"];
                NSString*strSenderappUserId = [dictMessage valueForKeyPath:@"sender.name"];
                
                if ([dictMessage[@"msgType"]isEqualToString:@"text"]) {
                    [self receiveMessageWithSenderId:strSendereRTCUserId andDisplayName:strSenderappUserId andtextMessage:dictMessage[@"message"]msgType:dictMessage[@"msgType"] andReplyMsgConfig:strReplyStatus andReplyBaseMsgId:strBaseMsgId andDictionary:dictMessage];
                } else if ([dictMessage[@"msgType"]isEqualToString:@"gify"]) {
                    NSString *filePath = @"";
                    if (![Helper stringIsNilOrEmpty:dictMessage[LocalFilePath]] && [dictMessage[LocalFilePath] length] > 0) {
                       // if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                            filePath = dictMessage[LocalFilePath];
                       // }
                    } else {
                        filePath = dictMessage[GifyFileName];
                    }
                    [self receiveMessageWithSenderId:strSendereRTCUserId andDisplayName:strSenderappUserId andtextMessage:filePath msgType:dictMessage[@"msgType"] andReplyMsgConfig:strReplyStatus andReplyBaseMsgId:strBaseMsgId andDictionary:dictMessage];
                }else if ([dictMessage[MsgType] isEqualToString:@"location"]) {
                    if (![Helper objectIsNilOrEmpty:dictMessage andKey:LocationType]) {
                        NSDictionary *dictLocation = dictMessage[LocationType];
                        if (![Helper stringIsNilOrEmpty:dictLocation[Latitude]] && ![Helper stringIsNilOrEmpty:dictLocation[Longitude]]) {
                            CLLocation *clLocation = [[CLLocation alloc] initWithLatitude:[dictLocation[Latitude] doubleValue] longitude:[dictLocation[Longitude] doubleValue] ];
                            JSQLocationMediaItem *locationItem = [[JSQLocationMediaItem alloc] init];
                            locationItem.appliesMediaViewMaskAsOutgoing = NO;
                            double timeStamp = [[dictMessage valueForKey:@"createdAt"]doubleValue];
                            NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
                           JSQMessage *newMessage = [[JSQMessage alloc] initWithSenderId:strSendereRTCUserId senderDisplayName:strSenderappUserId date:msgdate media:locationItem];
                            newMessage.msgStatus = @"seen";
                            [self.message addObject:newMessage];

                            [locationItem setLocation:clLocation withCompletionHandler:^{
                             [self.collectionView reloadData];
                             [self finishReceivingMessageAnimated:YES];

                            }];
                        }
                    }
                }
                else if ([dictMessage[MsgType] isEqualToString:@"contact"]) {
                    if (![Helper objectIsNilOrEmpty:dictMessage andKey:ContactType]) {
                        NSDictionary *dictContact = dictMessage[ContactType];
                        NSLog(@"dictContact>>>>>>>>>>>>>>>>%@",dictContact);
                        if ([dictContact count] > 0 && ![Helper objectIsNilOrEmpty:dictContact andKey:Numbers]) {
                            NSArray *aryNumbers = dictContact[Numbers];
                            if ([aryNumbers count] > 0) {
                                NSDictionary *dictNumber = [aryNumbers objectAtIndex:0];
                                if (![Helper stringIsNilOrEmpty:dictNumber[Number]] && [dictNumber[Number] length] > 0) {
                                    double timeStamp = [[dictMessage valueForKey:@"createdAt"]doubleValue];
                                    NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
                                    NSString *strContactPersonName = [Helper getContactNameString:dictContact];
                                   JSQMessage *newMessage = [[JSQMessage alloc] initWithSenderId:strSenderappUserId
                                                                    senderDisplayName:strSenderappUserId
                                                                                 date:msgdate
                                                                                 text:[NSString stringWithFormat:@"%@",strContactPersonName]]; //  \n%@ ,dictNumber[Number]
                                    newMessage.msgStatus = @"seen";
                                    [self.message addObject:newMessage];
                                    [self finishReceivingMessageAnimated:YES];
                                }
                            }else{
                                double timeStamp = [[dictMessage valueForKey:@"createdAt"]doubleValue];
                                NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
                                NSString *strContactPersonName = [Helper getContactNameString:dictContact];
                               JSQMessage *newMessage = [[JSQMessage alloc] initWithSenderId:strSenderappUserId
                                                                senderDisplayName:strSenderappUserId
                                                                             date:msgdate
                                                                             text:[NSString stringWithFormat:@"%@",strContactPersonName]]; //  \n%@ ,dictNumber[Number]
                                newMessage.msgStatus = @"seen";
                                [self.message addObject:newMessage];
                                [self finishReceivingMessageAnimated:YES];
                            }
                     }
                    }
                }
                else {
                    if (dictMessage[LocalFilePath]) {
                        [self receiveMessageWithSenderId:strSendereRTCUserId andDisplayName:strSenderappUserId andtextMessage:dictMessage[LocalFilePath] msgType:dictMessage[@"msgType"] andReplyMsgConfig:strReplyStatus andReplyBaseMsgId:strBaseMsgId andDictionary:dictMessage];
                    } else {
                        [self receiveMessageWithSenderId:strSendereRTCUserId andDisplayName:strSenderappUserId andtextMessage:dictMessage[FilePath] msgType:dictMessage[@"msgType"] andReplyMsgConfig:strReplyStatus andReplyBaseMsgId:strBaseMsgId andDictionary:dictMessage];
                    }
                    
                    // [self loadPhotoMediaMessage:dictMessage];
                }
            }
        }else{
                [self updateChatThreadHistory];
                [self.collectionView reloadData];
                [[eRTCChatManager sharedChatInstance] updateMessageWithReadStatus:dictMessage];
            }
        }
        
     /// IgnoreMessage
       
    }
}

- (void)didReceiveTypingStatusNotification:(NSNotification *) notification{
    NSDictionary *dictTypingData = notification.userInfo;
    NSLog(@"dictTypingData%@",dictTypingData);
    if ([dictTypingData isKindOfClass:[NSDictionary class]]){
        if (self.strThreadId!= nil && dictTypingData[ThreadID] != [NSNull null]) {
            if ([self.strThreadId isEqualToString:dictTypingData[ThreadID]]){
                if (!typingNames){
                    typingNames = [NSSet new];
                }
                NSMutableSet *mTypingNames = typingNames.mutableCopy;
               
                    if (dictTypingData[@"name"] != NULL){
                        if ([[dictTypingData valueForKey:@"typingStatusEvent"]isEqualToString:@"on"]) {
                            [mTypingNames addObject:dictTypingData[@"name"]];
                        } else {
                            [mTypingNames removeObject:dictTypingData[@"name"]];
                        }
                    }
                typingNames = mTypingNames.copy;
                if (typingNames.count > 0){
                    statusLabel.hidden = FALSE;
                    statusLabel.text = [self getTypingNameString];
                }else {
                    statusLabel.hidden = TRUE;
                }
//
//
            }
        }
        
    }
}
-(NSString*)getTypingNameString {
    if (typingNames.count > 2){
        return @"Multiple Typing...";
    }else {
        NSMutableString *names = @"".mutableCopy;
        NSUInteger counter = 0;
        for (NSString *name in typingNames) {
            [names appendString:name];
            if (counter < typingNames.count - 1){
                [names appendString:@", "];
            }
            counter++;
        }
        [names appendString:@" typing..."];
        return names;
    }
}

-(void)didReceiveMsgStatus:(NSNotification *) notification{
    // NSLog(@"didReceiveMsgStatus--%@",notification.userInfo);
    NSDictionary *chatMsg = notification.userInfo;
   /* if(chatMsg[MsgStatusEvent] != nil) {
        currentMessage.msgStatus = chatMsg[MsgStatusEvent];
    } else {
        currentMessage.msgStatus = @"Delivered";
    }*/
    if([chatMsg valueForKey:MsgStatusEvent]!= nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"msgUniqueId == %@", [chatMsg valueForKey:@"msgUniqueId"]];
        NSArray *aryFilter = [self->_chatHistory filteredArrayUsingPredicate:predicate];
        if (aryFilter.count > 0){
            NSMutableDictionary *dict = [[aryFilter objectAtIndex:0] mutableCopy];
            NSUInteger index = [self->_chatHistory indexOfObject:dict];
            if (index != NSNotFound){
                if ([dict[MsgType] isEqualToString:@"groupEvent"])
                {
                    [dict setValue:@"" forKey:@"msgStatusEvent"];
                }else{
                    [dict setValue:[chatMsg valueForKey:@"msgStatusEvent"] forKey:@"msgStatusEvent"];
                }
                [self->_chatHistory replaceObjectAtIndex:index withObject:dict.copy];
            }else{
                NSLog(@"Index Not found");
            }
        }else{
            NSLog(@"MSG Not found");
        }
    }
    [self.collectionView reloadData];
    //[self performSelector:@selector(getChatHistory) withObject:nil afterDelay:1];
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
    if (audioData != nil && audioData.length>0) {
        [self addAudioMediaMessage:audioData];
    }
}

#pragma mark API
-(void)callAPIForShareCurrentLocation:(JSQLocationMediaItemCompletionBlock)completion {
    
    /* CLLocation *ferryBuildingInSF = [[CLLocation alloc] initWithLatitude:[self->userLat doubleValue] longitude:[self->userLong doubleValue] ];
     JSQLocationMediaItem *locationItem = [[JSQLocationMediaItem alloc] init];
     [locationItem setLocation:ferryBuildingInSF withCompletionHandler:completion];
     
     JSQMessage *locationMessage = [JSQMessage messageWithSenderId:self.senderId
     displayName:self.senderDisplayName
     media:locationItem];
     
     NSLog(@"location%@", locationMessage);
     [self.message addObject:locationMessage];*/
    
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        NSMutableDictionary*dictParam = [[NSMutableDictionary alloc]init];
        
        if (self.dictGroupinfo[Group_GroupId] != nil && self.dictGroupinfo[Group_GroupId] != [NSNull null]) {
            
            NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
            
            [dictParam setValue:self.strThreadId forKey:ThreadID];
            
            [dictParam setValue:userId forKey:SendereRTCUserId];
            //[dictParam setValue:_message forKey:Message];
            [dictParam setValue:dictlocation forKey:@"location"];
            [dictParam setObject:self->arrUser forKey:ArParticipants];
            
            [[eRTCChatManager sharedChatInstance] sendLocationMessageWithParam:dictParam andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                NSDictionary *dictResponse = (NSDictionary *)json;
//                if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
//                    NSMutableDictionary * dictFollow = [NSMutableDictionary new];
//                    NSDictionary *dictResult = json[@"result"];
//                    if (dictResult.count > 0) {
//                    [dictFollow setObject:dictResult[MsgUniqueId] forKey:MsgUniqueId];
//                    [dictFollow setObject:dictResult[ThreadID] forKey:ThreadID];
//                    [self followUnFollowMsg:false dict:dictFollow];
//                    }
//                 }
                if (dictResponse[@"success"] != nil) {
                    BOOL success = (BOOL)dictResponse[@"success"];
                    if (success) {
                        if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                            
                            CLLocation *ferryBuildingInSF = [[CLLocation alloc] initWithLatitude:[self->userLat doubleValue] longitude:[self->userLong doubleValue] ];
                            JSQLocationMediaItem *locationItem = [[JSQLocationMediaItem alloc] init];
                            [locationItem setLocation:ferryBuildingInSF withCompletionHandler:completion];
                            
                            JSQMessage *locationMessage = [JSQMessage messageWithSenderId:self.senderId
                                                                              displayName:self.senderDisplayName
                                                                                    media:locationItem];
                            
                            NSLog(@"location%@", locationMessage);
                            locationMessage.msgStatus =@"Sent";
                            [self.message addObject:locationMessage];
                            [self updateChatThreadHistory];
                            
                        }
                    }
                }
                if (dictResponse[@"msg"] != nil) {
                    NSString *message = (NSString *)dictResponse[@"msg"];
                    if ([message length]>0) {
                        // [Helper showAlertOnController:@"eRTC" withMessage:message onController:self];
                    }
                }
                
            } andFailure:^(NSError * _Nonnull error) {
                [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
            }];
        }
    }else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}

//#Reaction
-(void)updateMessageCellAtIndexPath:(NSIndexPath*)path message:(NSDictionary*)details{
    if (self.isEmojiResponse == false)
    {
    self.isEmojiResponse = true;
    [[eRTCCoreDataManager sharedInstance] getUserChatHistoryWithThreadID:self.strThreadId andCompletionHandler:^(id ary, NSError *err) {
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
                    dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSelector:@selector(changeBoolValueAfterEmojiResponse) withObject:self afterDelay:2.0];
                    });
                }
                return;
            }
        }];
    }];
    }
}

-(void)changeBoolValueAfterEmojiResponse{
    self.isEmojiResponse = false;
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
            strMessage = [NSString stringWithFormat:@"Replied to a thread:%@\n%@",dict[Parent_Msg],dict[Message]];
        }else if (![dict[IsDeletedMSG] boolValue] && [dict[IsEdited] boolValue]){
            strMessage = [NSString stringWithFormat:@"%@%@",dict[Message], EditedString];
        }else if (![dict[IsDeletedMSG] boolValue] && [dict[IsForwarded] boolValue]){
            strMessage = [NSString stringWithFormat:@"%@\n%@",ForwardedString, dict[Message]];
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
                                                                     text:[NSString stringWithFormat:@"%@",strContactPersonName]]; // \n%@, dictNumber[Number]
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

-(void)refreshReactionData:(NSNotification *) notification{
    
    NSDictionary *userInfo = notification.userInfo;
    id msgId = userInfo[@"msgUniqueId"];
    id threadId = userInfo[@"threadId"];
    
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
        if (indexPath != -1 && message != NULL){
            [self updateMessageCellAtIndexPath:[NSIndexPath indexPathForRow:indexPath inSection:0] message:message];
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError: (NSError *)error {
    NSLog(@"didFailWithError: %@", error);
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
    //[self getCountryDet:lattitude1];
    [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (error == nil && [placemarks count] > 0)
        {
            
            self->placeMark = [placemarks lastObject];
            
            self->userLat = [NSNumber numberWithDouble:newLocation.coordinate.latitude];
            self->userLong= [NSNumber numberWithDouble:newLocation.coordinate.longitude];
            // For user address
            NSString *locatedAt = [[self->placeMark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@","];
            self->address = [[NSString alloc]initWithString:locatedAt];
            NSString *Area = [[NSString alloc]initWithString:self->placeMark.locality];
            NSString *Country = [[NSString alloc]initWithString:self->placeMark.country];
            NSString *CountryArea = [NSString stringWithFormat:@"%@, %@", Area,Country];
            NSLog(@"%@",CountryArea);
            
            self->dictlocation = [[NSMutableDictionary alloc]init];
            [self->dictlocation setValue: self->userLat forKey:@"latitude"];
            [self->dictlocation setValue:self->userLong forKey:@"longitude"];
            [self->dictlocation setValue:self->address forKey:@"address"];
            
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    }];
    // Turn off the location manager to save power.
    [manager stopUpdatingLocation];
}


-(void)contactsDetailsFromPhoneContactBook{
    CNContactPickerViewController *picker = [[CNContactPickerViewController alloc] init];
    picker.delegate = self;
    picker.displayedPropertyKeys = @[CNContactPhoneNumbersKey];
    [self presentViewController:picker animated:YES completion:nil];
}


-(void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact{
    NSLog(@"%@",contact);
      NSString*ContactEmail;
      NSString *emailtype;
      NSArray <CNLabeledValue<CNPhoneNumber *> *> *phoneNumbers = contact.phoneNumbers;
    if (phoneNumbers.count == 0) {
        [self.view makeToast:@"Contact should contains atleast one phone number. Please add number in your selected contact."];
        return;
    }
        NSString *pName = contact.namePrefix;
        NSString *fName = contact.givenName;
        NSString *mName = contact.middleName;
        NSString *lName = contact.familyName;
        NSString *sName = contact.nameSuffix;
    NSString *Name = [[NSString alloc]init];
    if (![pName isEqualToString:@""] && ![fName isEqualToString:@""] && ![mName isEqualToString:@""] && ![lName isEqualToString:@""] && ![sName isEqualToString:@""])
    {
        Name = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",pName, fName, mName, lName, sName];
    }
    else if (![fName isEqualToString:@""] && ![mName isEqualToString:@""] && ![lName isEqualToString:@""] && ![sName isEqualToString:@""])
    {
        Name = [NSString stringWithFormat:@"%@ %@ %@ %@",fName, mName, lName, sName];
    }
    else if (![fName isEqualToString:@""] && ![mName isEqualToString:@""] && ![lName isEqualToString:@""])
    {
        Name = [NSString stringWithFormat:@"%@ %@ %@",fName, mName, lName];
    }
    else if (![fName isEqualToString:@""] && ![lName isEqualToString:@""] && ![sName isEqualToString:@""])
    {
        Name = [NSString stringWithFormat:@"%@ %@ %@",fName, lName, sName];
    }
    else if (![fName isEqualToString:@""] && ![lName isEqualToString:@""])
    {
        Name = [NSString stringWithFormat:@"%@ %@",fName, lName];
    }
    else if (![fName isEqualToString:@""])
    {
        Name = [NSString stringWithFormat:@"%@",fName];
    }
    else if (![lName isEqualToString:@""])
    {
        Name = [NSString stringWithFormat:@"%@",lName];
    }
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
    if ((Name == NULL || [Name isEqualToString:@""]) && (contact.organizationName != NULL && ![contact.organizationName isEqualToString:@""])){
        Name = contact.organizationName;
    }
      dictContact = [[NSMutableDictionary alloc]init];
      [dictContact setValue:Name forKey:Key_Name];
      NSMutableDictionary*dictphone = [[NSMutableDictionary alloc]init];
    //  [dictphone setValue:phoneNumbertype forKey:@"type"];
      [dictphone setValue:@"Home" forKey:@"type"];

      [dictphone setValue:phoneMobile forKey:@"number"];
      NSArray*contactnumber = [NSArray arrayWithObjects:dictphone,nil];
     // NSMutableDictionary*dictEmail = [[NSMutableDictionary alloc]init];
      
      //        [dictEmail setValue:emailtype forKey:@"type"];
      //        [dictEmail setValue:ContactEmail forKey:@"email"];
      [dictContact setValue:contactnumber forKey:Key_Number];
     // NSArray*email = [NSArray arrayWithObjects: dictEmail,nil];
     // [dictContact setValue:email forKey:Key_Email];
      JSQMessage *contactmessage = [[JSQMessage alloc] initWithSenderId:self.senderId
                                                      senderDisplayName:self.senderDisplayName
                                                                   date:[NSDate date]
                                                                   text:[NSString stringWithFormat:@"%@",[Helper getContactNameString:dictContact]]]; //  \n%@ phoneMobile
      contactmessage.msgStatus =@"sending...";

      
      NSLog(@"%@ dictContact",dictContact);
      
      
      [self sendContactNumber:dictContact];
      [_message addObject:contactmessage];
      [self finishSendingMessageAnimated:YES];
}

/*- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContacts:(NSArray<CNContact *> *)contacts {
    
    if (contacts.count>1) {
        NSLog(@"can't select more then one");
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:@"Can't select more than one contact"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* OkButton = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
            
        }];
        [alert addAction:OkButton];
        [self presentViewController:alert animated:YES completion:nil];

        return;
    }
    for (CNContact *contact in contacts) {
        NSLog(@"%@",contact);
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
      //  [dictphone setValue:phoneNumbertype forKey:@"type"];
        [dictphone setValue:@"Home" forKey:@"type"];

        [dictphone setValue:phoneMobile forKey:@"number"];
        NSArray*contactnumber = [NSArray arrayWithObjects:dictphone,nil];
       // NSMutableDictionary*dictEmail = [[NSMutableDictionary alloc]init];
        
        //        [dictEmail setValue:emailtype forKey:@"type"];
        //        [dictEmail setValue:ContactEmail forKey:@"email"];
        [dictContact setValue:contactnumber forKey:Key_Number];
       // NSArray*email = [NSArray arrayWithObjects: dictEmail,nil];
       // [dictContact setValue:email forKey:Key_Email];
        JSQMessage *contactmessage = [[JSQMessage alloc] initWithSenderId:self.senderId
                                                        senderDisplayName:self.senderDisplayName
                                                                     date:[NSDate date]
                                                                     text:[NSString stringWithFormat:@"%@ \n%@",phoneMobile,Name]];
        contactmessage.msgStatus =@"sending...";

        
        NSLog(@"%@ dictContact",dictContact);
        
        
        [self sendContactNumber:dictContact];
        [_message addObject:contactmessage];
        [self finishSendingMessageAnimated:YES];
        
        
    }
}*/
-(void)contactPickerDidCancel:(CNContactPickerViewController *)picker {
    NSLog(@"Cancelled");
}

#pragma mark API
-(void) sendContactNumber:(NSDictionary*)contact {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        NSMutableDictionary*dictParam = [[NSMutableDictionary alloc]init];
        if (self.dictGroupinfo[Group_GroupId] != nil && self.dictGroupinfo[Group_GroupId] != [NSNull null]) {
            // Turn off the location manager to save power.
            NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
            [dictParam setValue:self.strThreadId forKey:ThreadID];
            [dictParam setValue:userId forKey:SendereRTCUserId];
            [dictParam setValue:contact forKey:@"contact"];
            [dictParam setObject:self->arrUser forKey:ArParticipants];
            
            
            [[eRTCChatManager sharedChatInstance] sendContactMessageWithParam:dictParam andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                NSDictionary *dictResponse = (NSDictionary *)json;

                if (dictResponse[@"success"] != nil) {
                    BOOL success = (BOOL)dictResponse[@"success"];
                    if (success) {
                        NSTimeInterval delayInSeconds = 2.0;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            self->currentMessage.msgStatus = @"Sent".capitalizedString;
                            [self finishSendingMessageAnimated:YES];
                            [self updateChatThreadHistory];
                        });
                    }
                }else{
                    if (dictResponse[@"msg"] != nil) {
                        NSString *message = (NSString *)dictResponse[@"msg"];
                        if ([message length]>0) {
                            [Helper showAlertOnController:@"eRTC" withMessage:message onController:self];
                            
                        }
                    }
                }
                
                
            } andFailure:^(NSError * _Nonnull error) {
                NSLog(@"error--%@",error.localizedDescription);
                [_message removeLastObject];
                NSString *errMsg = [NSString stringWithFormat:@"%@", error.localizedDescription];
                [self performSelector:@selector(showAlert:) withObject:errMsg afterDelay:0.3];
            }];
        }else {
            [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
        }
    }
}

#pragma mark - custom actions

-(void)pushToReplyThreadVC:(UIButton *)sender{
    /*
     
     if ([dicMessage valueForKey:@"replyMsgConfig"] != nil && [dicMessage valueForKey:@"replyMsgConfig"] != [NSNull null] )
                    {
                        if (replyCountView == nil) {
                          replyCountView = [[[NSBundle mainBundle] loadNibNamed:@"chatReplyCount" owner:self options:nil] objectAtIndex:0];
                          replyCountView.tag = 1000;
                          [cell.cellBottomLabel addSubview:replyCountView];
                           
                        }
                        
                        BOOL isReplyAvailble = [[dicMessage valueForKey:@"replyMsgConfig"] boolValue];
                        [replyCountView setHidden:YES];

                        if (isReplyAvailble == YES) {
                            [replyCountView.btnReplyThread addTarget:self action:@selector(pushToReplyThreadVC:) forControlEvents:UIControlEventTouchUpInside];
                            [cell bringSubviewToFront:replyCountView.btnReplyThread];
                            replyCountView.btnReplyThread.tag = indexPath.row;
                            replyCountView.lblCount.text = [NSString stringWithFormat:@"Replies %@",[dicMessage valueForKey:@"replyMsgCount"]];
                            [replyCountView setHidden:NO];
                          //  replyCountView.frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
                           // replyCountView.tag = 1000;
                        }
                    }
     */
    NSInteger selectedInedx = sender.tag;
    NSDictionary * dictMessage = [NSDictionary new];
    if (_chatHistory.count > selectedInedx) {
        dictMessage = [_chatHistory objectAtIndex:selectedInedx];
    }
    [self openThreadChatGroupView:dictMessage];
}
-(void)openThreadChatGroupView:(NSDictionary*)dictMessage {
    ThreadChatGroupViewController *_vcProfile = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"ThreadChatGroupViewController"];
    _vcProfile.dictGroupinfo = self.dictGroupinfo;
    _vcProfile.dictGroupThreadMsgDetails = dictMessage;
    _vcProfile.isGroupDeleted = isRemovedChannel;
    _vcProfile.isFrozenthreadChannel = self->isFrozenChannel;
    [self.navigationController pushViewController:_vcProfile animated:YES];
    
}


- (void)hadleLongPressAction:(NSIndexPath *) indexPath {
    
    NSDictionary *config = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
    [self.inputToolbar.contentView.textView resignFirstResponder];
    NSString * strFavourite = @"Add to favorites";//@"Set as Favourite";
    NSDictionary * dictMessage = [NSDictionary new];
    if (_chatHistory.count > indexPath.row) {
         dictMessage = [_chatHistory objectAtIndex:indexPath.row];
        self.longPressMessage = [dictMessage valueForKey:@"message"];
        if (![Helper objectIsNilOrEmpty:dictMessage andKey:IsFavourite]) {
            if ([dictMessage[IsFavourite] intValue]) {
                strFavourite = @"Remove From Favourites";
            }
        }
    }
    
    NSString *strComparId = dictMessage[SendereRTCUserId];
    UIAlertController * view =  [UIAlertController
                                 alertControllerWithTitle:@""
                                 message:@""
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* copy = [UIAlertAction
                           actionWithTitle:@"Copy"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
        [self copyMessageWithIndexPath:indexPath];
    }];
    
    UIAlertAction* favourite = [UIAlertAction
                                actionWithTitle:strFavourite
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
        NSLog(@"Fav Un Fav");
        NSDictionary * dictMessage = [NSDictionary new];
        if (_chatHistory.count > selectedChatIndexPath.row) {
            dictMessage = [_chatHistory objectAtIndex:selectedChatIndexPath.row];
        }
        [self isMarkFavouriteWithIndexPath:dictMessage favouriteUser:false];
    }];
    
    NSString *strThreadTitle = @"Start a thread";
  /*  if (![Helper stringIsNilOrEmpty:[dictMessage valueForKey:@"replyMsgConfig"]] && ![Helper stringIsNilOrEmpty:[dictMessage valueForKey:@"replyMsgConfig"]]){
        if ([dictMessage valueForKey:@"replyMsgConfig"] != nil && [dictMessage valueForKey:@"replyMsgConfig"] != [NSNull null] )
        {
            BOOL isReplyAvailble = [[dictMessage valueForKey:@"replyMsgConfig"] boolValue];
            if (isReplyAvailble)
            {
                strThreadTitle =   @"View thread";
            }
        }
    }*/
    
    if (![Helper stringIsNilOrEmpty:[dictMessage valueForKey:@"replyMsgCount"]] && ![Helper stringIsNilOrEmpty:[dictMessage valueForKey:@"replyMsgCount"]]){
        if ([dictMessage valueForKey:@"replyMsgCount"] != nil && [dictMessage valueForKey:@"replyMsgCount"] != [NSNull null] )
        {
            NSInteger isReplyAvailble = [[dictMessage valueForKey:@"replyMsgCount"] integerValue];
            if (isReplyAvailble > 0)
            {
                strThreadTitle =   @"View thread";
            }
        }
    }
    
    NSString *imgFavUnFav = @"";
    if (![Helper objectIsNilOrEmpty:dictMessage andKey:IsFavourite]) {
        if ([dictMessage[IsFavourite] intValue])
        {
            imgFavUnFav = @"fav";
        }
        else
        {
            imgFavUnFav = @"favNew";
        }
    }
    else
    {
        imgFavUnFav = @"unFav";
    }
    
    NSMutableArray *arrData = [NSMutableArray new];
    
    NSMutableDictionary *dictData = [NSMutableDictionary new];
    [arrData addObject:dictData];
    
    if (_chatHistory.count > indexPath.row) {
        if ([dictMessage[MsgType] isEqualToString:@"text"] && [dictMessage[@"sendereRTCUserId"] isEqual:self.senderId]){
            //Disable Edit
//            if ([config[@"e2eChat"] boolValue]){
//            }else{
                [arrData addObject:@{
                    @"name": @"Edit",
                    @"image": @"editChat"
                }.mutableCopy];
            //}
        }
    }

    
    if ([[dictMessage valueForKey:@"msgType"] isEqualToString:@"text"]) {
        [dictData setObject:@"Copy" forKey:@"name"];
        [dictData setObject:@"copyNew" forKey:@"image"];
        
        [arrData addObject:dictData];
    }
    
    dictData = [NSMutableDictionary new];
    [dictData setObject:strFavourite forKey:@"name"];
    [dictData setObject:imgFavUnFav forKey:@"image"];
    [arrData addObject:dictData];
    
    if (dictMessage[ParentMessageID] != nil && dictMessage[ParentMessageID] != [NSNull null]) {
    }else{
    dictData = [NSMutableDictionary new];
    [dictData setObject:strThreadTitle forKey:@"name"];
    [dictData setObject:@"startTheadeNew" forKey:@"image"];
    [arrData addObject:dictData];
    }
    
    //Disable Forward
    dictData = [NSMutableDictionary new];
    [dictData setObject:@"Forward" forKey:@"name"];
    [dictData setObject:@"forwardIcon" forKey:@"image"];
//     if ([config[@"e2eChat"] boolValue]){
//     }else{
         [arrData addObject:dictData];
    // }
    
        dictData = [NSMutableDictionary new];
        [dictData setObject:@"Delete" forKey:@"name"];
        [dictData setObject:@"deleteChat" forKey:@"image"];
        [arrData addObject:dictData];
    
    NSDictionary * dictMessages = [NSDictionary new];
    if (_chatHistory.count > selectedChatIndexPath.row) {
        dictMessages = [_chatHistory objectAtIndex:selectedChatIndexPath.row];
    }
        
    if ([dictMessage[@"follow"] isEqual:@1]){
        dictData = [NSMutableDictionary new];
        [dictData setObject:@"Unfollow thread" forKey:@"name"];
        [dictData setObject:@"followThread" forKey:@"image"];
        [arrData addObject:dictData];
    }else{
        dictData = [NSMutableDictionary new];
        [dictData setObject:@"Follow thread" forKey:@"name"];
        [dictData setObject:@"followThread" forKey:@"image"];
        [arrData addObject:dictData];
    }
    
        NSString *strAppUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
        if ([strAppUserId isEqualToString:strComparId]) {
        }else{
        dictData = [NSMutableDictionary new];
        [dictData setObject:@"Report Message" forKey:@"name"];
        [dictData setObject:@"reportMessage" forKey:@"image"];
        [arrData addObject:dictData];
        }
    
    selectedChatIndexPath = indexPath;
    [self.view endEditing:YES];
    ChatReactionsViewController *chatReactions = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"ChatReactionsViewController"];
    chatReactions.arrayDataSource = [arrData mutableCopy];
    chatReactions.delegate = self;
    chatReactions.userMessage = self.longPressMessage;
    chatReactions.selectedIndexPath = indexPath;
    BOOL isThread = NO;
    if ([dictMessage[@"replyMsgConfig"] isEqual:@1]){
        isThread = YES;
    }
    chatReactions.isThread = isThread;
    chatReactions.message = @"";
    [chatReactions setMessageType: dictMessage[MsgType]];
    [self presentPanModal:chatReactions];
    return;
    
//    UIAlertAction* startThread = [UIAlertAction
//                                  actionWithTitle:strThreadTitle
//                                  style:UIAlertActionStyleDefault
//                                  handler:^(UIAlertAction * action)
//                                  {
//        ThreadChatGroupViewController *_vcProfile = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"ThreadChatGroupViewController"];
//        _vcProfile.dictGroupinfo = self.dictGroupinfo;
//        _vcProfile.dictGroupThreadMsgDetails = dictMessage;
//        [self.navigationController pushViewController:_vcProfile animated:YES];
//    }];
//    UIAlertAction* more = [UIAlertAction
//                           actionWithTitle:@"More..."
//                           style:UIAlertActionStyleDefault
//                           handler:^(UIAlertAction * action)
//                           {
//    }];
//
//    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel"
//                                                     style:UIAlertActionStyleCancel
//                                                   handler:^(UIAlertAction * action) {
//        //Do some thing here
//    }];
//      [copy setValue:[[UIImage imageNamed:@"copythread"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
//       [copy setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
//
//    if (![Helper objectIsNilOrEmpty:dictMessage andKey:IsFavourite]) {
//        if ([dictMessage[IsFavourite] intValue])
//        {
//            [favourite setValue:[[UIImage imageNamed:@"favNew"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
//        }
//        else
//        {
//            [favourite setValue:[[UIImage imageNamed:@"unFav"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
//        }
//    }
//    else
//    {
//        [favourite setValue:[[UIImage imageNamed:@"unFav"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
//    }
//      // [favourite setValue:[[UIImage imageNamed:@"unFav"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
//       [favourite setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
//
//       [startThread setValue:[[UIImage imageNamed:@"startThread"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
//       [startThread setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
////
////    [more setValue:[[UIImage imageNamed:@"Icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
////    [more setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
//
//    [view addAction:copy];
//    [view addAction:favourite];
//    [view addAction:startThread];
////    [view addAction:more];
//    [view addAction:cancel];
//    [self presentViewController:view animated:YES completion:nil];
}

-(void)isMarkFavouriteWithIndexPath:(NSDictionary *) dictMessage favouriteUser:(BOOL)isFavouriteEvent {
        if (![Helper objectIsNilOrEmpty:dictMessage andKey:MsgUniqueId]) {
            BOOL isFavouite = YES;
            if (isFavouriteEvent) {
                
            }else{
            [self sendFavouriteAndUnfavourateMessage:dictMessage];
            }
            if (![Helper objectIsNilOrEmpty:dictMessage andKey:IsFavourite]) {
                if ([dictMessage[IsFavourite] intValue])
                {
                    isFavouite = NO;
                }else {
                    isFavouite = YES;
                }
            }
            [[eRTCCoreDataManager sharedInstance] isMarkFavouriteWithMessageUniqueId:dictMessage[MsgUniqueId] andMarkFavourite:isFavouite andCompletionHandler:^(BOOL isMarkFavourite) {
                NSLog(@"favourite %d", isMarkFavourite);
                NSMutableDictionary * dictTemp = [NSMutableDictionary dictionaryWithDictionary:dictMessage];
                [dictTemp setObject:[NSNumber numberWithBool:(isMarkFavourite) ? isFavouite : !isFavouite] forKey:IsFavourite];
                for (int i = 0; i < [self->_chatHistory count]; i++)
                {
                    NSMutableDictionary * dictParam = [NSMutableDictionary new];
                    dictParam = [self->_chatHistory objectAtIndex:i];
                    if ([dictParam[MsgUniqueId] isEqualToString:dictMessage[MsgUniqueId]]) {
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                        [self->_chatHistory replaceObjectAtIndex:i withObject:dictTemp];
                        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
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
            BOOL isFavouite = YES;
            if (![Helper objectIsNilOrEmpty:dictMessage andKey:IsFavourite]) {
                if ([dictMessage[IsFavourite] intValue]) {  isFavouite = NO; }
                else { isFavouite = YES; }
            }
            [[eRTCCoreDataManager sharedInstance] isMarkFavouriteWithMessageUniqueId:dictMessage[MsgUniqueId] andMarkFavourite:isFavouite andCompletionHandler:^(BOOL isMarkFavourite) {
                NSLog(@"favourite %d", isMarkFavourite);
                NSMutableDictionary * dictTemp = [NSMutableDictionary dictionaryWithDictionary:dictMessage];
               // [dictTemp setObject:[NSNumber numberWithBool:isMarkFavourite] forKey:IsFavourite];
                [dictTemp setObject:[NSNumber numberWithBool:(isMarkFavourite) ? isFavouite : !isFavouite] forKey:IsFavourite];
                [self->_chatHistory replaceObjectAtIndex:indexPath.row withObject:dictTemp];
                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
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

-(void)openGIF{
    GiphyViewController *giphy = [[GiphyViewController alloc]init ] ;
//    giphy.layout = GPHGridLayoutWaterfall;
    giphy.theme = [[GPHTheme alloc] initWithType:GPHThemeTypeLight];
    giphy.rating = GPHRatingTypeRatedPG13;
    giphy.delegate = self;
    giphy.showConfirmationScreen = false ;
    [giphy setMediaConfigWithTypes: [ [NSMutableArray alloc] initWithObjects:
                                     @(GPHContentTypeGifs),@(GPHContentTypeStickers), @(GPHContentTypeText),@(GPHContentTypeEmoji), nil] ];
    [self presentViewController:giphy animated:true completion:nil] ;
}

- (void) didSelectMediaWithGiphyViewController:(GiphyViewController *)giphyViewController media:(GPHMedia *)media {
    [giphyViewController dismissViewControllerAnimated:YES completion:^{
        if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
            if (media.jsonRepresentation[@"images"][@"original"][@"url"] != nil) {
                NSString *strGIF = [NSString stringWithFormat:@"%@",media.jsonRepresentation[@"images"][@"original"][@"url"]];
                //[self sendGIFMediaItemWithURL:strGIF];
                __weak id weakSelf = self;
                ShowGIFViewController *vc = [[ShowGIFViewController alloc] initWithURL:[NSURL URLWithString:strGIF] didSelect:^{
                    [weakSelf sendGIFMediaItemWithURL:strGIF];
                    [weakSelf dismissViewControllerAnimated:TRUE completion:nil];
                } didCancel:^{
                    [weakSelf dismissViewControllerAnimated:TRUE completion:nil];
                }];
                [self presentViewController : vc animated:true completion:nil];
            }
        } else {
            [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
        }
    }];
}
- (void) didDismissWithController:(GiphyViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - Document sharing
-(void)openDocumentPicker {
    NSArray *types = @[@"com.microsoft.word.doc",@"org.openxmlformats.wordprocessingml.document", (NSString*)kUTTypeImage,(NSString*)kUTTypeSpreadsheet,(NSString*)kUTTypePresentation,(NSString*)kUTTypeDatabase,(NSString*)kUTTypeFolder,(NSString*)kUTTypeZipArchive,(NSString*)kUTTypePDF];
    UIDocumentPickerViewController *docPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:types inMode:UIDocumentPickerModeImport];
    docPicker.delegate = self;
    docPicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:docPicker animated:YES completion:nil];
}

#pragma mark UIDocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls{
    if ([urls count]>0){
        if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
            if (controller.documentPickerMode == UIDocumentPickerModeImport){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self sendFileMediaItemWithData:[urls firstObject] andFileExtension:[urls firstObject].pathExtension];
                    [controller dismissViewControllerAnimated:YES completion:nil];
                });
            }
        }else {
            [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
        }
    }
}


- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    if (url){
        if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
            if (controller.documentPickerMode == UIDocumentPickerModeImport){
                
                [controller dismissViewControllerAnimated:YES completion:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self sendFileMediaItemWithData:url andFileExtension:url.pathExtension];
                    });
                }];
            }
        } else {
            [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
        }
    }
}

// called if the user dismisses the document picker without selecting a document (using the Cancel button)
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(void)refreshChatData{
    [self performSelector:@selector(getChatHistory) withObject:nil afterDelay:0.5];
    
}


#pragma mark - UITableView Delegates and DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.numbersArrayList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifierOne"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifierOne"];
        cell.textLabel.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:18];
        cell.textLabel.textColor = [UIColor blackColor];//[UIColor colorWithRed:0.141 green:0.204 blue:0.263 alpha:1.0];
        cell.detailTextLabel.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:14];
        cell.detailTextLabel.textColor = [Helper colorWithHexString:@"5691C8"];//[UIColor colorWithRed:0.141 green:0.204 blue:0.263 alpha:1.0];
    }
    
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.imageView.image = [UIImage imageNamed:@"DefaultUserIcon"];
    cell.textLabel.text = [[self.numbersArrayList objectAtIndex:indexPath.row] valueForKey:@"name"];
    cell.detailTextLabel.text = [[self.numbersArrayList objectAtIndex:indexPath.row] valueForKey:@"appUserId"];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected user == %@", self.numbersArrayList[indexPath.row]);
    NSDictionary *config = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
    if ([config[@"userMentionsChat"] boolValue] == true){
        self.isUserSearchActive = NO;
        self->isSelectedMentionUser = YES;
        NSString *strUser = [[self.numbersArrayList objectAtIndex:indexPath.row] valueForKey:@"name"];
        self->mentionUserEmail = [[self.numbersArrayList objectAtIndex:indexPath.row] valueForKey:@"appUserId"];
        self->mentionsUser = [[self.numbersArrayList objectAtIndex:indexPath.row] valueForKey:@"name"];
        NSString *userEmail = [NSString stringWithFormat:@"@%@",self->mentionUserEmail];
        NSString *userName = [NSString stringWithFormat:@"@%@", self->mentionsUser];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            NSString *strtext = [userName stringByReplacingOccurrencesOfString:@"@" withString:@""];
            NSMutableString *string = strtext.mutableCopy;
            NSRange range = NSMakeRange(0, string.length);
            [string replaceCharactersInRange:range withString:[NSString stringWithFormat:@"<@%@>", strtext]];
            [self->arrMentionUser addObject:string];
            [self->arrMentionEmail addObject:userName];
        });
        
        if ((self->mentionsUser != nil && [self->mentionsUser length] > 0) && (self->mentionUserEmail != nil && [self->mentionUserEmail length] > 0) ) {
            if (self.searchText != nil && [self.searchText length] > 0 ) {
                if (![self.searchText isEqualToString:@"@"]) {
                    self.inputToolbar.contentView.textView.text = [self.inputToolbar.contentView.textView.text substringToIndex:([self.inputToolbar.contentView.textView.text length] - [self.searchText length])];
                }
            }
            NSString *strMsg = [NSString stringWithFormat:@"%@%@", self.inputToolbar.contentView.textView.text, strUser];
            NSMutableDictionary *dict = [NSMutableDictionary new];
            if ([[[self.numbersArrayList objectAtIndex:indexPath.row] valueForKey:@"name"] isEqualToString:@"channel"]){
                [dict setValue:@"generic" forKey:@"type"];
                [dict setValue:@"channel" forKey:@"value"];
            }else if ([[[self.numbersArrayList objectAtIndex:indexPath.row] valueForKey:@"name"] isEqualToString:@"here"]) {
                [dict setValue:@"generic" forKey:@"type"];
                [dict setValue:@"here" forKey:@"value"];
            }else{
                [dict setValue:@"user" forKey:@"type"];
                [dict setValue:[[self.numbersArrayList objectAtIndex:indexPath.row] valueForKey:@"userId"] forKey:@"value"];
            }
            [self.aryMentioned addObject:dict];
            self.inputToolbar.contentView.textView.attributedText = [Helper getAttributedString: [self colorHashtag:strMsg] font: [UIFont fontWithName:@"SFProDisplay-Regular" size:18]];
            if ([self isMessageEditing]){
                NSMutableDictionary *editedMessage = [editingMessage[@"editingMessage"] mutableCopy];
                editedMessage[Message] = strMsg;
                editingMessage[@"editedMessage"] = editedMessage.copy;
            }
            self.inputToolbar.contentView.textView.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:18];
            [self.numbersArrayList removeAllObjects];
            [self.tblMention reloadData];
            [self.tblMention setHidden:YES];
        }
    }else{
        [self.numbersArrayList removeAllObjects];
        [self.tblMention reloadData];
        [self.tblMention setHidden:YES];
        self.inputToolbar.contentView.textView.text = @"";
        NSString *msg = @"Channel Mention is not available now. Please contact your administrator.";
        [Helper showAlertOnController:@"eRTC" withMessage:msg onController:self];
    }
}

- (void)keyboardWasShown:(NSNotification *)notification
{
// Get the size of the keyboard.
CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

//Given size may not account for screen rotation
    int height = MIN(keyboardSize.height,keyboardSize.width);
    //int width = MAX(keyboardSize.height,keyboardSize.width);
    NSLog(@"KeyboardHeightUP == %d", height);
    if (height <= 216 ){
        self.keyboardheight = height + 50;
    }else{
        self.keyboardheight = height;
    }
    if (!self.tblMention.isHidden){
        dispatch_async(dispatch_get_main_queue(), ^{
            //NSLog(@"KeyboardHDown");
            [self setMentiontblHeight];
        });
    }
}

- (void)keyboardWasHide:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"KeyboardHDown");
        self.keyboardheight = 0;
        [self setMentiontblHeight];
    });
}

-(void)showMentionUserList:(NSString*)strText{

  //  self.tblMention = [[UITableView alloc] init];
    if ([strText isEqualToString:@" "] || !self.isUserSearchActive) {
        return;
    }
    self.searchText = strText;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.name contains[c] %@",strText];
        NSArray *filterArray = [self.aryWhole filteredArrayUsingPredicate:predicate];
        
        if ([strText isEqualToString:@"@"]){
            self.numbersArrayList = [self.aryWhole mutableCopy];
        }
       else if (filterArray.count > 0){
            self.numbersArrayList = [filterArray mutableCopy];
        }
       else{
           [self.numbersArrayList removeAllObjects];
       }
        [self setMentiontblHeight];
        [self.view addSubview:_tblMention];
        [self.tblMention setDelegate:self];
        [self.tblMention setDataSource:self];
        [self.tblMention setHidden:NO];
        [self.tblMention reloadData];
    });
}

-(void)setMentiontblHeight{
    
    //  NSLog(self.keyboardController.currentKeyboardFrame);
    int height = self.keyboardController.currentKeyboardFrame.size.height;
    self.keyboardheight = height;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    NSInteger tblHeight = self.numbersArrayList.count * 60;
    if (tblHeight > screenHeight ){
        tblHeight = screenHeight - 100;
    }
    
    if (self.keyboardheight >= 260 && self.numbersArrayList.count > 5){
        tblHeight = screenHeight - self.keyboardheight - 64;
    }
    CGFloat tblY = screenHeight - tblHeight - self.inputToolbar.contentView.frame.size.height - self.keyboardheight;
    if (tblY < 0.0)
    {
        tblY = 0.0;
    }
    self.tblMention.frame = CGRectMake(5, tblY+100, screenWidth - 10, tblHeight-50);
    self.tblMention.translatesAutoresizingMaskIntoConstraints = false;
    self.tblMention.layer.cornerRadius = 5.0;
    self.tblMention.layer.borderWidth = 1.0;
    self.tblMention.layer.borderColor  = [[UIColor lightGrayColor] CGColor];
    UIView *customview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - self.inputToolbar.contentView.frame.size.height)];
    customview.backgroundColor = [UIColor blackColor];
    customview.alpha = 0.5;
    // self.view.alpha = 0.5;
    // customview.layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4].CGColor;
    //  [self.view addSubview:customview];
}

-(NSAttributedString*)colorHashtag:(NSString*)message
{
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:message];
    NSString *str = message;
    NSError *error = nil;
    NSRegularExpression *regex;
    NSArray *matches;
    regex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)(\\s+)(\\w+)(\\s+)(\\w+) |@(\\w+)(\\s+) |@(\\w+)(\\s+)(\\w+)|@channel|@here" options:0 error:&error];
    matches = [regex matchesInString:message options:0 range:NSMakeRange(0, message.length)];
    for (NSTextCheckingResult *match in matches) {
    NSRange wordRange = [match rangeAtIndex:0];
    NSString *name = [message substringWithRange:wordRange];
    NSArray *list = [name componentsSeparatedByString:@" "];
    NSMutableSet *set = [[NSMutableSet alloc] initWithObjects:[name stringByReplacingOccurrencesOfString:@"@" withString:@""], nil];
        
    if (list.count > 1){
        [set addObject:[list.firstObject stringByReplacingOccurrencesOfString:@"@" withString:@""]];
    }

        

    for(NSString *item in set){
        if ([name isKindOfClass:[NSString class]] ){
            wordRange.length = item.length + 1;
           [string addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:wordRange];
        }
    }
    NSLog(@"Search DATA %@", [message substringWithRange:wordRange]);
}
    return string;

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
        [mSet addObject:@"channel"];
        [mSet addObject:@"here"];
        self.userNames = mSet.copy;
    }];
}

- (void)refreshTableDataWith:(NSArray *) ary {
    NSString *strAppUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"appUserId != %@",strAppUserId];
    NSArray *filteredArr = [ary filteredArrayUsingPredicate:predicate];
    
    if (filteredArr.count >0) {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSArray *sortedArray=[filteredArr sortedArrayUsingDescriptors:@[sort]];
    if (sortedArray.count > 0) {
      //  self->arrUsers = [NSArray arrayWithArray:sortedArray];
        self.aryWhole = [[NSArray arrayWithArray:sortedArray] mutableCopy];
        NSMutableDictionary *dictChannel = [NSMutableDictionary new];
        [dictChannel setValue:@"generic" forKey:@"type"];
        [dictChannel setValue:@"channel" forKey:@"name"];
        [dictChannel setValue:@"channel" forKey:@"appUserId"];
        NSMutableDictionary *dictHere = [NSMutableDictionary new];
        [dictHere setValue:@"generic" forKey:@"type"];
        [dictHere setValue:@"here" forKey:@"name"];
        [dictHere setValue:@"here" forKey:@"appUserId"];
        [self.aryWhole addObject:dictChannel];
        [self.aryWhole addObject:dictHere];
        
        //strUser
        //self->vcSearch.searchResults = [NSMutableArray arrayWithArray:sortedArray];
//        dispatch_async(dispatch_get_main_queue(), ^{
          //  [self.tblContacts reloadData];
//        });
    }
    }
}

- (void)updateEditMessageToolbarViewLayout:(NSDictionary *)object {
    if (!editMessageView){
        UITextView *editMessageLabel = [UITextView new];
        editMessageView = editMessageLabel;
        CGRect viewFrame = editMessageLabel.frame;
        viewFrame.origin.y = self.view.frame.size.height;
        editMessageLabel.frame = viewFrame;
        [self.view addSubview:editMessageLabel];
        editMessageLabel.textColor = [UIColor darkGrayColor];
        editMessageLabel.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:17];
//        editMessageLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
        editMessageLabel.editable = false;
        editMessageLabel.textContainerInset = UIEdgeInsetsMake(8, 50, 8, 50);
        editMessageLabel.scrollEnabled = FALSE;
        editMessageLabel.textContainer.maximumNumberOfLines = 2;
        editMessageLabel.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
        editMessageLabel.translatesAutoresizingMaskIntoConstraints = false;
        
        NSArray *horizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[view]" options:0 metrics:nil views:@{@"view" : editMessageView}];
        NSArray *vertical = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[view]-(0)-|" options:0 metrics:nil views:@{@"view" : editMessageView}];
        NSArray *vertical1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[editMessageView]-(0)-[toolbar]" options:0 metrics:nil views:@{@"editMessageView" : editMessageView, @"toolbar": self.inputToolbar}];
        editMessageViewconstrainsts = @[vertical, horizontal, vertical1];
        
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"editMessageLBorder"]];
        CGRect frame = imageView.frame;
        frame.origin.x = 45;
        frame.origin.y = 8;
        imageView.frame = frame;
        [editMessageLabel setAutoresizingMask:UIViewAutoresizingFlexibleHeight| UIViewAutoresizingFlexibleLeftMargin];
        [editMessageLabel addSubview:imageView];
        
        UIView *border = [UIView new];
        border.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [border setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];
        border.frame = CGRectMake(0, 0, self.view.frame.size.width, 1);
        [editMessageLabel addSubview:border];
        
        
    }
    if ([editMessageView isKindOfClass:UITextView.class]){
        [self.view addSubview:editMessageView];
        UITextView *editMessageLabel = (UITextView*)editMessageView;
        NSMutableAttributedString *message = [[NSMutableAttributedString alloc]
                                       initWithString:@"Edit Message\n"
                                       attributes:@{
                                           NSForegroundColorAttributeName:[UIColor blackColor],
                                           NSFontAttributeName: [UIFont fontWithName:@"SFProDisplay-Medium" size:14]
                                       }];
        NSAttributedString *attr = [Helper mentionHighlightedAttributedStringByNames:_userNames message:object[Message]];
        [message appendAttributedString:attr];
        editMessageLabel.attributedText = message;
        [editMessageViewconstrainsts enumerateObjectsUsingBlock:^(NSArray<NSLayoutConstraint *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.view addConstraints:obj];
        }];
    }
}


- (void)configureInputToolBarForEditMessage:(NSDictionary *)object {
    self.inputToolbar.contentView.textView.attributedText = [Helper mentionHighlightedAttributedStringByNames:_userNames message:object[Message]];
    [self.inputToolbar.contentView.textView becomeFirstResponder];
    [self.inputToolbar.contentView.rightBarButtonItem setSelected:TRUE];
    
    [rightButton.titleLabel setFont: [UIFont fontWithName:@"SFProDisplay-Bold" size:15]];
    [rightButton setTitle:@"Save" forState:UIControlStateSelected];
    [rightButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateSelected];
    [rightButton setImage:nil forState:UIControlStateSelected];
    [rightButton setImage:nil forState:UIControlStateNormal];
    [rightButton setSelected:TRUE];
    [self updateEditMessageToolbarViewLayout:object];
    
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *flipButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Cancel"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(cancelEditMessage:)];
    self.navigationItem.leftBarButtonItems = @[flipButton];
    
}
-(void)cancelEditMessage:(id)object{
    self.navigationItem.leftBarButtonItems = @[];
    [self clearEditedDetalils];
}



-(void)clearEditedDetalils{
    editingMessage = NULL;
    [UIView animateWithDuration:0.5 animations:^{
        [self.inputToolbar.contentView.textView setText:@""];
        [self.inputToolbar.contentView.textView resignFirstResponder];
        
        [self->rightButton setSelected:FALSE];
        [self->rightButton setTitle:@"" forState:UIControlStateSelected|UIControlStateNormal];
        [self->rightButton setImage:[UIImage imageNamed:@"sendNew"] forState:UIControlStateSelected];
        [self->rightButton setImage:[UIImage imageNamed:@"MicrophoneNew"] forState:UIControlStateNormal];
        
        self->editMessageView.alpha = 0;
        CGRect viewFrame = self->editMessageView.frame;
        viewFrame.origin.y = self.view.frame.size.height;
        self->editMessageView.frame = viewFrame;
        self.navigationItem.hidesBackButton = FALSE;
        self.navigationItem.leftBarButtonItems = @[];
    } completion:^(BOOL finished) {
        self->editMessageView.alpha = 1;
        [self->editMessageView removeFromSuperview];
    }];
}
- (void)chatReactDelegate:(ReactType)sender {
    switch (sender) {
        case Copy: {
            NSLog(@"Copy");
            NSDictionary *dictConfig = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
            if ([dictConfig[@"copyChatEnable"] boolValue]) {
                [self copyMessageWithIndexPath:selectedChatIndexPath];
                [self.view makeToast:@"Copied" duration:1 position:CSToastPositionCenter];
            }else{
                [self.view makeToast:@"Copy message is not available now. Please contact your administrator."];
            }
            break;
        }
        case FavUnFav: {
            NSLog(@"Fav Un Fav");
            NSDictionary * dictMessage = [NSDictionary new];
            if (_chatHistory.count > selectedChatIndexPath.row) {
                dictMessage = [_chatHistory objectAtIndex:selectedChatIndexPath.row];
            }
            [self isMarkFavouriteWithIndexPath:dictMessage favouriteUser:false];
            break;
            
        }
        case StartThread: {
            NSLog(@"Start Thread");
            NSDictionary * dictMessage = [NSDictionary new];
            if (_chatHistory.count > selectedChatIndexPath.row) {
                dictMessage = [_chatHistory objectAtIndex:selectedChatIndexPath.row];
//                NSDictionary *config = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
//                 if ([config[@"replyThreadGroupChat"] boolValue]){
                     ThreadChatGroupViewController *_vcProfile = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"ThreadChatGroupViewController"];
                     _vcProfile.dictGroupinfo = self.dictGroupinfo;
                     _vcProfile.dictGroupThreadMsgDetails = dictMessage;
                     [self.navigationController pushViewController:_vcProfile animated:YES];
//                 }else {
//                     NSString *msg = @"Thread chat group not available. Please contact your administrator.";
//                     [Helper showAlertOnController:@"eRTC" withMessage:msg onController:self];
//                 }
                break;
            }
        }
        case More: {
            NSLog(@"Do Nothing");
            break;
        }
        case Forward: {
            NSDictionary * dictMessage = [NSDictionary new];
            if (_chatHistory.count > selectedChatIndexPath.row) {
                dictMessage = [_chatHistory objectAtIndex:selectedChatIndexPath.row];
            }
            ForwardToViewController *forwardToVc = [[Helper newFeaturesStoryBoard] instantiateViewControllerWithIdentifier:@"ForwardToViewController"];
            forwardToVc.dictMessageDetails = [dictMessage mutableCopy];
            forwardToVc.threadId = self.strThreadId;
            forwardToVc.isGroup = YES;
            forwardToVc.dictUserDetails = [self.dictGroupinfo mutableCopy];
            [self.navigationController pushViewController:forwardToVc animated:YES];
            break;
        }
        case Delete: {
                    UIAlertController *deleteMessageType = [UIAlertController alertControllerWithTitle:@"" message:@"Do you want to delete the message?" preferredStyle:UIAlertControllerStyleActionSheet];
                    NSMutableArray<UIAlertAction*> *actions =  @[].mutableCopy;
                    if (selectedChatIndexPath != NULL){
                        JSQMessage *messageObject = _message[selectedChatIndexPath.row];
                        if([[messageObject senderId] isEqualToString:self.senderId]){
                            UIAlertAction *meAction = [UIAlertAction actionWithTitle:@"Delete just for me" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                NSLog(@"Me Action");
                                [self deleteMessage:@"self"];
                            }];
                            [actions addObject:meAction];
                            UIAlertAction *everyOneAction = [UIAlertAction actionWithTitle:@"Delete for everyone" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                NSLog(@"everyone action Action");
                                [self deleteMessage:@"everyone"];
                            }];
                            [actions addObject:everyOneAction];
                        }else {
                            UIAlertAction *meAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                NSLog(@"Me Action");
                                [self deleteMessage:@"self"];
                            }];
                            [actions addObject:meAction];
                        }
                    }
                    UIAlertAction *cancelActionType = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        NSLog(@"Cancel Clicked Type");
                    }];
                    [actions addObject:cancelActionType];
                    
                    [actions enumerateObjectsUsingBlock:^(UIAlertAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        [deleteMessageType addAction:obj];
                    }];
                    [self.navigationController presentViewController:deleteMessageType animated:true completion:nil];
                    break;
                }case Edit: {
                    if (self->_chatHistory.count > selectedChatIndexPath.row) {
                        NSDictionary *object = _chatHistory[selectedChatIndexPath.row];
                        editingMessage = @{
                            @"editingMessage" : object.copy,
                            @"position": selectedChatIndexPath
                        }.mutableCopy;
                        [self configureInputToolBarForEditMessage:object];
                        break;
                    }

                }case Report: {
                    ReportsMessageViewController * _vcMessage = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"ReportsMessageViewController"];
                    _vcMessage.dictMessage = _chatHistory[selectedChatIndexPath.row];
                    [self.navigationController pushViewController:_vcMessage animated:YES];
                    break;
                }case Follow: {
                    NSDictionary * dictMessage = [NSDictionary new];
                    if (_chatHistory.count > selectedChatIndexPath.row) {
                        dictMessage = [_chatHistory objectAtIndex:selectedChatIndexPath.row];
                    }
                    [self followUnFollowMsg:true dict:dictMessage];
                    break;
                }
            }
}

- (void)followUnFollowMsg:(BOOL)isFollow dict:(NSDictionary *)dict {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
    NSMutableDictionary * dictMsgFollowUnfollow = [NSMutableDictionary new];
    if (dict[Follow_Message] != NULL && [dict[Follow_Message]  isEqual: @1]){
        [dictMsgFollowUnfollow setValue:@false forKey:@"follow"];
    }else{
        [dictMsgFollowUnfollow setValue:@true forKey:@"follow"];
    }
    [dictMsgFollowUnfollow setValue:dict[Message] forKey:@"message"];
    [dictMsgFollowUnfollow setValue:dict[ThreadID] forKey:ThreadID];
    [dictMsgFollowUnfollow setValue:dict[MsgUniqueId] forKey:MsgUniqueId];
    [dictMsgFollowUnfollow setValue:@"true" forKey:@"isStarred"];
    //[dictMsgFollowUnfollow setValue:@false forKey:@"follow"];

    [[eRTCChatManager sharedChatInstance] followUnFollowChatMessage:dictMsgFollowUnfollow andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        NSDictionary *dictResponse = (NSDictionary *)json;
        
        if (dictResponse[@"success"] != nil) {
            BOOL success = (BOOL)dictResponse[@"success"];
            [self getChatHistory];
            if (isFollow) {
            if (success) {
                if (dict[Follow_Message] != NULL && [dict[Follow_Message]  isEqual: @1]){
                    [self.view makeToast:ThreadUnFollowMessage];
                }else{
                    [self.view makeToast:FollowThreadMessage];
                }
            }
                
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

- (void)DeleteAlertController
{
     UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Delete message?"
                                 message:@"All messages and files within conversation will be deleted."
                                 preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Cancel"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                    
                                }];
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Delete"
                               style:UIAlertActionStyleDestructive
                               handler:^(UIAlertAction * action) {
                                
                               }];

    //Add your buttons to alert controller
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deleteMessage:(NSString *)type {
    NSDictionary * dictMessage = [NSDictionary new];
    NSMutableDictionary * dictDeleteChat = [NSMutableDictionary new];
    NSMutableDictionary * dictDeleteMessage = [NSMutableDictionary new];
    NSString * messageUniqueID = @"";
    if (self->_chatHistory.count > self->selectedChatIndexPath.row) {
        dictMessage = [self->_chatHistory objectAtIndex:self->selectedChatIndexPath.row];
        messageUniqueID = [NSString stringWithFormat:@"%@", [dictMessage valueForKey:@"msgUniqueId"]];
        [dictDeleteChat setValue:messageUniqueID forKey:@"msgUniqueId"];
    }
    NSArray *arrData = [NSArray arrayWithObject:dictDeleteChat];
    [dictDeleteMessage setValue:arrData forKey:@"chats"];
    [dictDeleteMessage setValue:dictMessage[ThreadID] forKey:@"threadId"];
    [dictDeleteMessage setValue:dictMessage[MsgUniqueId] forKey:@"msgUniqueId"];
    [dictDeleteMessage setValue:type forKey:@"deleteType"];
    [dictDeleteMessage setValue:[Helper getEpochTime] forKey:@"msgCorrelationId"];
    [[eRTCChatManager sharedChatInstance] DeleteMessageWithParam:dictDeleteMessage andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        if (![Helper stringIsNilOrEmpty:json[@"success"]]) {
            NSString *strSuccess = [NSString stringWithFormat:@"%@", json[@"success"]];
            if ([strSuccess intValue] == 0) {
                if (![Helper stringIsNilOrEmpty:json[Key_Message]]) {
                    [Helper showAlertOnController:@"eRTC" withMessage:json[Key_Message] onController:self];
                }
            }else {
                NSString *mQid = dictMessage[MsgUniqueId];
                NSString *tID = dictMessage[ThreadID];
                if (mQid && tID){
                    NSInteger index = [self getIndexOfMessageId:mQid threadId:tID];
                    if (index != -1){
                       NSDictionary *msg = [[eRTCCoreDataManager sharedInstance] getMessageByUniqueID:mQid];
                        NSIndexPath *iPath =  [NSIndexPath indexPathForRow:index inSection:0];
                        [self updateMessageCellAtIndexPath:iPath message:msg];
                    }
                }
               
            }
        }
        if (![Helper objectIsNilOrEmpty:dictMessage andKey:IsFavourite]) {
            if ([dictMessage[IsFavourite] intValue]){
            [self isMarkFavouriteWithIndexPath:dictMessage favouriteUser:false];
            }
        }
    } andFailure:^(NSError * _Nonnull error) {
         [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
        
    }];
}

- (void)recentChatReactionDelegate:(int)tagId selectedIndexPath:(NSIndexPath *)indexPath emojiCode:(NSString *)message {
    if (tagId == 106) {
        EmojisViewController *emojisVC = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"EmojisViewController"];
        emojisVC.delegate = self;
        emojisVC.selectedIndexPath = indexPath;
        [self presentPanModal:emojisVC];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
         //api call
            NSMutableArray *arrdata = nil;
            arrdata = self.message;
            
            NSDictionary * dictMessage = [NSDictionary new];
            NSLog(@"Ram Shyam Ram Shaym>>>>>>>>>>>>>>>>>>>>");
            if (_chatHistory.count > indexPath.row) {
                dictMessage = [_chatHistory objectAtIndex:indexPath.row];
                NSLog(@"Jai Jai Ram Shyam Ram Shaym>>>>>>>>>>>>>>>>>>>>");
            }
            NSDictionary *myDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"Test123", @"abc", nil];
            NSData *data1 = [NSJSONSerialization dataWithJSONObject:myDictionary options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonString = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
            //sendTextReactionWithParam:[NSString stringWithFormat:@"%@", [dictMessage valueForKey:@"msgUniqueId"]] andEmojiCode:message andEmojiAction:@"set" andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            [[eRTCChatManager sharedChatInstance] sendTextReactionWithParam:[NSString stringWithFormat:@"%@", [dictMessage valueForKey:@"msgUniqueId"]] andEmojiCode:message andEmojiAction:@"set" andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                if([json isKindOfClass:[NSDictionary class]]) {
                    if (![Helper stringIsNilOrEmpty:json[@"success"]]) {
                        NSString *strSuccess = [NSString stringWithFormat:@"%@", json[@"success"]];
                        if ([strSuccess intValue] == 0) {
                            if (![Helper stringIsNilOrEmpty:json[Key_Message]]) {
                                [Helper showAlertOnController:@"eRTC" withMessage:json[Key_Message] onController:self];
                            }
                        }
                    }
                }
                 [self updateMessageCellAtIndexPath:indexPath message:dictMessage];
                //});
            } andFailure:^(NSError * _Nonnull error) {
                //[Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
                //NSLog(@"Error -->%@", error);
            }];
             //UI operations, when you receive data.
         });
    }
}

- (void)sendMesage:(NSString *)message selectedindexPath:(NSIndexPath *)indexpath {
    dispatch_async(dispatch_get_main_queue(), ^{

     //api call
        NSMutableArray *arrdata = nil;
        arrdata = self.message;
        NSDictionary * dictMessage = [NSDictionary new];
        if (_chatHistory.count > indexpath.row) {
            dictMessage = [_chatHistory objectAtIndex:indexpath.row];
        }
        else
        {
            return;
        }
        NSDictionary *myDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"Test123", @"abc", nil];
        NSData *data1 = [NSJSONSerialization dataWithJSONObject:myDictionary options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
        
        [[eRTCChatManager sharedChatInstance] sendTextReactionWithParam:[NSString stringWithFormat:@"%@", [dictMessage valueForKey:@"msgUniqueId"]] andEmojiCode:message andEmojiAction:@"set" andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {

            if (![json  isEqual: @""])
            {
            if (![Helper stringIsNilOrEmpty:json[@"success"]]) {
                NSString *strSuccess = [NSString stringWithFormat:@"%@", json[@"success"]];
                if ([strSuccess intValue] == 0) {
                    if (![Helper stringIsNilOrEmpty:json[Key_Message]]) {
                        [Helper showAlertOnController:@"eRTC" withMessage:json[Key_Message] onController:self];
                    }
                }
            }
            }
            [self updateMessageCellAtIndexPath:indexpath message:dictMessage];
    //});
        } andFailure:^(NSError * _Nonnull error) {
            NSLog(@"Error -->%@", error);
            [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
        }];
         //UI operations, when you receive data.
     });

    
}

#pragma mark - ButtonUndo
-(void)btnUndoChatMessage:(NSIndexPath *)indexPath {
    
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
        NSMutableDictionary * dictUndoChatReport = [NSMutableDictionary new];
        NSMutableDictionary * dictMessage = [NSMutableDictionary new];
        dictMessage = [_chatHistory objectAtIndex:indexPath.row];
        [dictUndoChatReport setValue:dictMessage[Chat_ReportId] forKey:@"chatReportId"];
        [dictUndoChatReport setValue:ReportedIgnored forKey:ChatReportAction];
        
        [[eRTCChatManager sharedChatInstance] undoChatReport:dictUndoChatReport andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            [KVNProgress dismiss];
            NSDictionary *dictResponse = (NSDictionary *)json;
            if (dictResponse[@"success"] != nil) {
                BOOL success = (BOOL)dictResponse[@"success"];
                if (success) {
                [self getChatHistory];
                }
            }
        }andFailure:^(NSError * _Nonnull error) {
            [KVNProgress dismiss];
            [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
        }];
    } else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}

- (void)sendEmoji:(NSString *)string selectedIndexPath:(NSIndexPath *)indexPath {
    dispatch_async(dispatch_get_main_queue(), ^{

    NSMutableArray *arrdata = nil;
    arrdata = self.message;
    NSDictionary * dictMessage = [NSDictionary new];
    if (_chatHistory.count > indexPath.row) {
        dictMessage = [_chatHistory objectAtIndex:indexPath.row];
    }
    else
    {
        return;
    }
    
    NSString *emojiCode = [[string componentsSeparatedByString:@" "] objectAtIndex:0];
    NSLog(@"EmojiCode %@", emojiCode);
    NSArray *emojis = [[eRTCCoreDataManager sharedInstance] convertDataIntoObjectWith:dictMessage[@"reaction"]];
    __block BOOL reactedByMe = FALSE;
    if (emojis != NULL && [emojis isKindOfClass:NSArray.class]){
        [emojis enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj[@"emojiCode"] isEqual:emojiCode]){
                NSArray *reactionUsers = obj[@"reactionUsers"];
                [reactionUsers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj[@"eRTCUserId"] != NULL && [obj[@"eRTCUserId"] isEqual:self.senderId]){
                        reactedByMe = TRUE;
                        return;
                    }
                }];
            }
        }];
    }
    if (reactedByMe){
        
        dispatch_async(dispatch_get_main_queue(), ^{
         //api call
//            NSDictionary *myDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"Test123", @"abc", nil];
//            NSData *data1 = [NSJSONSerialization dataWithJSONObject:myDictionary options:NSJSONWritingPrettyPrinted error:nil];
//            NSString *jsonString = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
            [[eRTCChatManager sharedChatInstance] sendTextReactionWithParam:[NSString stringWithFormat:@"%@", [dictMessage valueForKey:@"msgUniqueId"]] andEmojiCode:emojiCode andEmojiAction:@"clear" andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                if (self.isEmojiResponse == false)
                {
            [self updateMessageCellAtIndexPath:indexPath message:dictMessage];
               // });
                }

            }andFailure:^(NSError * _Nonnull error) {
                NSLog(@"Error -->%@", error);
                [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
            }];
             //UI operations, when you receive data.
         });
    }else {
        [self sendMesage:string selectedindexPath:indexPath];
    }
    });
}

- (void)showUserWhoReacted:(NSString *)emojiString selectedIndexPath:(NSIndexPath *)indexPath {
        NSDictionary * dictMessage = [NSDictionary new];
        if (_chatHistory.count > indexPath.row) {
            dictMessage = [_chatHistory objectAtIndex:indexPath.row];
        }
        
        [[eRTCChatManager sharedChatInstance] getChatReationUserListWithMsgId:[NSString stringWithFormat:@"%@", [dictMessage valueForKey:@"msgUniqueId"]] andEmojiCode:emojiString andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            NSMutableArray *arrEmojiAndUserArray = [NSMutableArray new];
            arrEmojiAndUserArray = json;
            if ([arrEmojiAndUserArray count] > 0) {
                ChatReactionUserListViewController *emojisVC = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"ChatReactionUserListViewController"];
                emojisVC.emoji = emojiString;
                emojisVC.arrayDataSource = [arrEmojiAndUserArray mutableCopy];
                [self presentPanModal:emojisVC];
            }
        } andFailure:^(NSError * _Nonnull error) {
            NSLog(@"Error = %@", error.localizedDescription);
        }];
}

- (void)audioMediaItem:(JSQAudioMediaItem *)audioMediaItem didChangeAudioCategory:(NSString *)category options:(AVAudioSessionCategoryOptions)options error:(NSError *)error {
//    if (currentAudioMediaItem != nil) {
//        [currentAudioMediaItem clearCachedMediaViews];
//        currentAudioMediaItem = nil;
//    }
//    currentAudioMediaItem = [[JSQAudioMediaItem alloc]init];
    if (currentAudioMediaItem != NULL && audioMediaItem != currentAudioMediaItem && currentAudioMediaItem.gAudioPlayer != NULL && currentAudioMediaItem.gAudioPlayer.isPlaying){
            [currentAudioMediaItem pause];
        }
    currentAudioMediaItem = audioMediaItem;
}


-(void)selectedUndoButton:(UITableViewCell *)cell {
    
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        NSMutableDictionary * dictUndoChatReport = [NSMutableDictionary new];
        NSMutableDictionary * dictMessage = [NSMutableDictionary new];
        dictMessage = [_chatHistory objectAtIndex:indexPath.row];
        [dictUndoChatReport setValue:dictMessage[Chat_ReportId] forKey:@"chatReportId"];
        [dictUndoChatReport setValue:ReportedIgnored forKey:ChatReportAction];
        
        [[eRTCChatManager sharedChatInstance] undoChatReport:dictUndoChatReport andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            [KVNProgress dismiss];
            NSDictionary *dictResponse = (NSDictionary *)json;
            if (dictResponse[@"success"] != nil) {
                BOOL success = (BOOL)dictResponse[@"success"];
                if (success) {
                    [self getChatHistory];
                }
            }
        }andFailure:^(NSError * _Nonnull error) {
            [KVNProgress dismiss];
            [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
        }];
    } else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}

-(void)callApiGetChatSetting {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [[eRTCChatManager sharedChatInstance] getChatSettings:nil andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            NSDictionary *dictResponse = (NSDictionary *)json;
            if (dictResponse[@"success"] != nil) {
                BOOL success = (BOOL)dictResponse[@"success"];
                if (success) {
                    //[self ProfanityAndDomain:dictResponse];
                    self->dictDomainProfinityFilter = dictResponse;
                }
            }
        } andFailure:^(NSError * _Nonnull error) {
            [KVNProgress dismiss];
            [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
        }];
    } else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}

-(void)addDomanFilterOnInputToolbar{
    self->bottemView = [[UIView alloc] initWithFrame:CGRectMake(0, -82, self.collectionView.bounds.size.width, 80)];
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(48, 5, self.collectionView.bounds.size.width-70, 60)];
    UIImageView *imageNowifi = [[UIImageView alloc] initWithFrame:CGRectMake(16, 20, 24, 24)];
    [self->bottemView setBackgroundColor:[UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1]];
    lblTitle.textColor = [UIColor colorWithRed:33/255.0 green:36/255.0 blue:41/255.0 alpha:1];
    lblTitle.text = DomainFilterMsg;
    [imageNowifi setImage:[UIImage imageNamed:@"domainFilter"]];
    [lblTitle setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:14.0]];
    lblTitle.numberOfLines = 0;
    lblTitle.textAlignment = NSTextAlignmentLeft;
    [self->bottemView addSubview:lblTitle];
    [self->bottemView addSubview:imageNowifi];
    [self.inputToolbar addSubview:self->bottemView];
    [self.inputToolbar.contentView.rightBarButtonItem setHidden:YES];
    
}

-(void)setDomainFilter:(BOOL)isFilterShow {
    if (isFilterShow) {
        self->bottemView.hidden = false;
        [self.inputToolbar.contentView.rightBarButtonItem setHidden:YES];
    }else{
        self->bottemView.hidden = true;
        [self.inputToolbar.contentView.rightBarButtonItem setHidden:NO];
    }
}

-(void)showProfanityFilter {
    self->profenityView = [[UIView alloc] initWithFrame:CGRectMake(0, -90, self.collectionView.bounds.size.width, 80)];
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(48, 5, self.collectionView.bounds.size.width-70, 60)];
    UIImageView *imageNowifi = [[UIImageView alloc] initWithFrame:CGRectMake(16, 20, 24, 24)];
    [self->profenityView setBackgroundColor:[UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1]];
    lblTitle.textColor = [UIColor colorWithRed:33/255.0 green:36/255.0 blue:41/255.0 alpha:1];
    lblTitle.text = ProfanityFilterMsg;
    [imageNowifi setImage:[UIImage imageNamed:@"domainFilter"]];
    [lblTitle setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:14.0]];
    lblTitle.numberOfLines = 0;
    lblTitle.textAlignment = NSTextAlignmentLeft;
    [self->profenityView addSubview:lblTitle];
    [self->profenityView addSubview:imageNowifi];
    [self.inputToolbar.contentView.rightBarButtonItem setHidden:YES];
    [self.inputToolbar addSubview:self->profenityView];
}

-(void)setShowProfanityFilter:(BOOL)isFilterShow {
    if (isFilterShow == YES) {
        self->profenityView.hidden = false;
        [self.inputToolbar.contentView.rightBarButtonItem setHidden:YES];
    }else{
        self->profenityView.hidden = true;
        [self.inputToolbar.contentView.rightBarButtonItem setHidden:NO];
    }
}
    
    -(void)showDeactivatedMessagePopup {
        self->deactivatedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.collectionView.bounds.size.width, 120)];
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(48, 5, self.collectionView.bounds.size.width-70, 60)];
        [self->deactivatedView setBackgroundColor:UIColor.redColor];
        lblTitle.textColor = UIColor.whiteColor;
        lblTitle.text = @"Group has been deactivated by admin";
        [lblTitle setFont:[UIFont fontWithName:@"SFProDisplay-Semibold" size:18.0]];
        lblTitle.numberOfLines = 0;
        lblTitle.textAlignment = NSTextAlignmentLeft;
        [self->deactivatedView addSubview:lblTitle];
        [self.inputToolbar addSubview:self->deactivatedView];
    }
    
 -(void)isShowDeactivatedMessage:(BOOL)isDeactivated {
     if (isDeactivated == YES) {
         self->deactivatedView.hidden = false;
     }else{
         self->deactivatedView.hidden = true;
         
     }
    }

-(void)didReceiveEventList:(NSNotification *) notification{
    NSDictionary *userData = notification.object;
    NSDictionary *dictUserTrigger = userData[@"eventTriggeredByUser"];
    if (userData && [userData[@"eventType"] isEqualToString:@"participantsRemoved"]){ // && eventObj[@"eventData"]
        NSArray *eventTriggeredOnUserList = userData[@"eventData"][@"eventTriggeredOnUserList"];
        if (eventTriggeredOnUserList && [eventTriggeredOnUserList isKindOfClass:NSArray.class]){
            BOOL isAdminRemovedYou = FALSE;
            NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
            for (NSDictionary *user in eventTriggeredOnUserList) {
                if (user[User_eRTCUserId] && userId  && [user[User_eRTCUserId] isEqualToString: userId]){
                    isAdminRemovedYou = TRUE;
                    break;
                }
            }
            if (isAdminRemovedYou){
                [self getGroupDetails];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popToRootViewControllerAnimated:true];
                });
                return;
            }
        }
    }
}

-(void)didchatStarFavourite:(NSNotification *) notification{
    NSDictionary *userobj = notification.object;
    NSString *strAppUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
    if ([strAppUserId isEqualToString:userobj[User_eRTCUserId]]){
        NSArray*aryChats = userobj[@"chats"];
        NSDictionary*dictChats = aryChats[0];
        if (dictChats[@"isStarred"] != nil && dictChats[@"isStarred"] != [NSNull null]) {
        if ([userobj[@"eRTCUserId"] isEqualToString:strAppUserId]){
            NSMutableDictionary * dictParam = [NSMutableDictionary new];
            if ([[dictChats valueForKey:@"isStarred"] boolValue] ){
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
    }
}

-(void)sendFavouriteAndUnfavourateMessage:(NSDictionary*)editstarFavourite {
        NSMutableDictionary * dictFavouriteMessage = [NSMutableDictionary new];
        if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil) {
            if (self.dictGroupinfo[Group_GroupId] != nil && self.dictGroupinfo[Group_GroupId] != [NSNull null]) {
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

- (void)didgetchatSetting:(NSNotification *) notification{
    NSDictionary *dictResponse = notification.object;
    if (dictResponse[@"success"] != nil) {
        BOOL success = (BOOL)dictResponse[@"success"];
        if (success) {
            [self ProfanityAndDomain:dictResponse];
        }
    }
}

-(void)ProfanityAndDomain:(NSDictionary*)dictRespnse {
    if ([dictRespnse[@"result"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictResult = [[NSDictionary alloc] init];
        dictResult = (NSDictionary *)dictRespnse[@"result"];
        if (dictResult[ProfanityFilter] != nil && dictResult[ProfanityFilter] != [NSNull null]) {
            NSDictionary *dictProfinity = dictResult[ProfanityFilter];
            if(dictProfinity.count != 0){
                if (dictProfinity[@"keywords"] != nil && dictProfinity[@"keywords"] != [NSNull null]) {
                self-> _aryProfinityFilter = dictProfinity[@"keywords"];
                }
                if ([dictProfinity[@"actionType"] isEqualToString:@"block"]) {
                    self->isProfanity = false;
                }else if ([dictProfinity[@"actionType"] isEqualToString:@"replace"]){
                    self->isProfanity = true;
                }
            }
    }
        
    if (dictResult[DomainFilter] != nil && dictResult[DomainFilter] != [NSNull null]) {
        NSDictionary *dictDomain = dictResult[DomainFilter];
        if(dictDomain.count != 0){
            if (dictDomain[@"domains"] != nil && dictDomain[@"domains"] != [NSNull null]) {
            self-> _aryDomainFilter = dictDomain[@"domains"];
            }
            if ([dictDomain[@"actionType"] isEqualToString:@"block"]) {
                isDomainFilt = @0;
            }else if ([dictDomain[@"actionType"] isEqualToString:@"replace"]){
                isDomainFilt = @1;
            }else if ([dictDomain[@"actionType"] isEqualToString:@"allow"]){
                isDomainFilt = @2;
            }
        }
      }
    }
}


- (NSArray *)groupByThreadId:(NSString *)threadId {
    NSMutableDictionary*dict = [[NSMutableDictionary alloc]init];
    [dict setValue:threadId forKey:ThreadID];
    [[eRTCChatManager sharedChatInstance]  getgroupByThreadId:dict andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        NSDictionary *dictResponse = (NSDictionary *)json;
        if (dictResponse[@"success"] != nil) {
            BOOL success = (BOOL)dictResponse[@"success"];
            if (success) {
                if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *result = (NSDictionary *)dictResponse[@"result"];
                    NSArray *groups = (NSArray *)result[@"groups"];
                    [self refreshTableDataWith:groups];
                    self->arrUser = [self getAllUsersdata:result[@"participants"]];
                    NSLog(@"self->arrUser>>>>>>>>>>>>>>>%@",self->arrUser);
                    return;
                }
            }
        }
    }andFailure:^(NSError * _Nonnull error) {
        NSLog(@"NewGroupViewController ->  getgroupByThreadId %@",error);
    }];
    NSMutableArray *mutableAry = [NSMutableArray new];
    return mutableAry.copy;
}

-(NSArray *)getAllUsersdata:(NSArray *)arrParticipants {
    NSMutableArray *arr = [NSMutableArray new];
    for (NSDictionary*dictUsers in arrParticipants) {
        NSArray *e2eParticipants = (NSArray *)dictUsers[@"e2eEncryptionKeys"];
        NSDictionary *dictUserdata = [e2eParticipants firstObject];
        if (dictUserdata[@"eRTCUserId"] != nil && dictUserdata[@"eRTCUserId"] != [NSNull null]) {
        NSString *strID = [NSString stringWithFormat:@"%@",dictUserdata[@"eRTCUserId"]];
            [arr addObject:strID];
        }
        
        NSLog(@"dictUsers>>>>>>>>>>>>>>>%@",arr);
    }
    return  arr.copy;
}

    
    /*
-(void)showDeactivated:(BOOL *)isDeactivated {
    if (isDeactivated) {
        NSTimeInterval delayInSeconds = 0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self->deactivatedView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-70, self.view.bounds.size.width, 100)];
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 70)];
        [self->deactivatedView setBackgroundColor:UIColor.redColor];
            lblTitle.textColor = UIColor.whiteColor;
            lblTitle.text = @"Group has been deactivated by admin";
            lblTitle.textAlignment = NSTextAlignmentCenter;
        [lblTitle setFont:[UIFont fontWithName:@"SFProDisplay-Semibold" size:18.0]];
        lblTitle.numberOfLines = 0;
            [self->deactivatedView addSubview:lblTitle];
           [self.view addSubview:self->deactivatedView];
        });
    }else{
        self->deactivatedView.alpha = 1;
        [deactivatedView removeFromSuperview];
    }
}*/

@end

