//
//  ThreadChatGroupViewController.m
//  eRTCApp
//
//  Created by rakesh  palotra on 05/05/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import "ThreadChatGroupViewController.h"
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
#import <JSQMessagesViewController/JSQMessages.h>
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
#import "ForwardToViewController.h"
#import "JSQLinkPreviewMediaItem.h"
#import "ShowGIFViewController.h"
#import "JSQAudioMediaItem+JSQAudioMediaItemX.h"
#import "UIApplication+X.h"
#import "ReportsMessageViewController.h"
#import "JSQReportCell.h"
//#import "JiraBotCollectionCell.h"

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

@interface ThreadChatGroupViewController()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIViewControllerPreviewingDelegate,MPMediaPickerControllerDelegate, JSQAudioRecorderViewDelegate,CLLocationManagerDelegate,CNContactViewControllerDelegate,CNContactPickerDelegate, UIGestureRecognizerDelegate,GiphyDelegate,UIDocumentPickerDelegate,UIDocumentInteractionControllerDelegate, UITableViewDelegate, UITableViewDataSource, ChatReactionsDelegateDelegate, EmojisViewControllerDelegate, ChatReplyCountDelegate, JSQAudioMediaItemDelegate, AudioClickable,ChatUndoMsgDelegate>
{
      NSTimer * typingTimer;
      BOOL  isTypingActive;
      BOOL  isProfanity;
      JSQMessage *currentMessage;
      CLLocationManager *locationManager;
      CLGeocoder *geoCoder;
      CLPlacemark *placeMark;
      NSMutableArray *arrMentionUser;
      NSMutableArray *arrMentionEmail;
      NSString*address;
      NSNumber *userLat,*userLong;
      NSMutableDictionary*dictlocation;
      NSMutableDictionary*dictContact;
      NSMutableArray *_chatHistory;
      UIView *headerView;
      UIView *reportView;
      int ReplyCount;
    NSIndexPath *selectedChatIndexPath;
    JSQAudioMediaItem *currentAudioMediaItem;
    LocationManager *locManager;
    NSMutableDictionary *editingMessage;
    UIView *editMessageView;
    UIButton *rightButton;
    UIView *bottemView;
    UIView *profenityView;
    UIView *deactivatedView;
    NSNumber *isDomainFilt;
    NSDictionary *thread;
    UIView *removeView;
    BOOL  isRemovedChannel;
    BOOL  isFrozenChannel;
    BOOL  isGroupActivated;
    BOOL  isSelectedMentionUser;
    NSString *mentionsUser;
    UIView *frozenView;
    NSString *mentionUserEmail;
    NSDictionary *dictDomainProfinityFilter;
    NSString *editTags;
    NSMutableArray *arrUser;
    NSArray<NSArray<NSLayoutConstraint*>*> *editMessageViewconstrainsts;
}


@property (strong, nonatomic) NSSet *userNames;//removeView
@property(nonatomic, strong) JSQAudioRecorderView *audioRecorderView;
@property(nonatomic, strong) NSMutableArray *message;
@property (strong, nonatomic) NSArray *imgURL;
@property(nonatomic, strong) NSString *strThreadId;
@property (strong, nonatomic) NSMutableArray *numbersArrayList;
@property (strong, nonatomic) NSMutableArray *aryMentioned;
@property (assign) int keyboardheight;
@property (strong, nonatomic) NSMutableArray *aryWhole;
@property(nonatomic, strong) NSString *strReplyStatus;
@end

@implementation ThreadChatGroupViewController
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
    [self addObservers];
    NSLog(@"_dictGroupThreadMsgDetails ---------->>---->>%@",_dictGroupThreadMsgDetails);
    // Do any additional setup after loading the view.
    self.strReplyStatus = @"0";
    self.numbersArrayList  = @[@"One", @"Two", @"Three", @"Four", @"Five", @"Six"];
    [self.tblMention setHidden:YES];
    self->isSelectedMentionUser = NO;
    self.keyboardheight = 0;
    ReplyCount = 0;
    
    arrMentionUser = [NSMutableArray new];
    arrMentionEmail = [NSMutableArray new];
    _aryMentioned = [NSMutableArray new];
    
    [self showUserIconAndNameOnNavigationTitle];
    [self configureChatWindow];
    _message = [[NSMutableArray alloc] init];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JSQReportCell" bundle:nil] forCellWithReuseIdentifier:@"JSQReportCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JiraBotCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"JiraBotCollectionCell"];

    NSString *strAppUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
    NSString *strUserName = [[UserModel sharedInstance] getUserDetailsUsingKey:User_Name];
    self.senderId = strAppUserId;
    
    if (strUserName !=nil) {
           self.senderDisplayName = strUserName;
       }else{
           self.senderDisplayName = @"";

       }
    self.strThreadId = [NSString stringWithFormat:@"%@",_dictGroupinfo[ThreadID]];
    [self performSelector:@selector(getChatHistory) withObject:nil afterDelay:0.5];

    [self geoLocation];
    [Giphy configureWithApiKey:@"6bUrIxVye4HJtD0B9PtYq3tMwiCSvcup" verificationMode:false] ;
    
    [self callAPIForGetContactsUserList];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"GroupChatThreadHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"GroupChatThreadHeaderView"];
//    UICollectionViewFlowLayout *layout = self.collectionView.collectionViewLayout;
//    layout.sectionHeadersPinToVisibleBounds = true;
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
    
    NSTimeInterval delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    [self headerShowMessage];
    });
    
    /*
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [headerView removeFromSuperview];
    }else{
    NSTimeInterval delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    CGFloat topbarHeight = ([UIApplication sharedApplication].statusBarFrame.size.height +
           (self.navigationController.navigationBar.frame.size.height ?: 0.0));
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, topbarHeight, self.collectionView.bounds.size.width, 64)];
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(48, 5, self.collectionView.bounds.size.width-54, 60)];
    UIImageView *imageNowifi = [[UIImageView alloc] initWithFrame:CGRectMake(16, 20, 24, 24)];
    
    [headerView setBackgroundColor:[UIColor colorWithRed:255/255.0 green:237/255.0 blue:237/255.0 alpha:1]];
    lblTitle.textColor = UIColor.redColor;
    lblTitle.text = @"You are offline, please make sure you are connected to the internet.";
    [imageNowifi setImage:[UIImage imageNamed:@"no-wifi"]];
    
    [lblTitle setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:16.0]];
    lblTitle.numberOfLines = 0;
    lblTitle.textAlignment = NSTextAlignmentLeft;
    [headerView addSubview:lblTitle];
    [headerView addSubview:imageNowifi];
    [self.navigationController.view addSubview:headerView];
    });
    //[headerView removeFromSuperview];
    }*/
    //[self onLineOffLineMessgeShow];
    [self callApiGetChatSetting];
    
//    if (_isGroupDeleted){
//        [self removeChannel:YES];
//        self.inputToolbar.hidden = true;
//        self.inputToolbar.userInteractionEnabled = FALSE;
//        [self.inputToolbar.contentView.rightBarButtonItem setHidden:YES];
//        [self.inputToolbar.contentView.leftBarButtonItem setHidden:YES];
//    }else{
//        [self removeChannel:false];
//        self.inputToolbar.userInteractionEnabled = TRUE;
//        [self.inputToolbar.contentView.rightBarButtonItem setHidden:false];
//        [self.inputToolbar.contentView.leftBarButtonItem setHidden:false];
//        self.inputToolbar.hidden = true;
//    }
    
    if (_isFrozenthreadChannel == true || _isGroupDeleted == true) {
        if (_isGroupDeleted == true) {
            [self removeChannel:YES];
            [self showUserBlock:YES];
        }else{
            [self Frozen_Channel:YES];
        }
        [self showBlockUI];
    }else{
        [self unblockUI];
        [self Frozen_Channel:false];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateChatMsgNotification:)
                                                 name:DidUpdateChatNotification
                                               object:nil];
    [UIView setAnimationsEnabled:NO];
    
    [self showProfanityFilter]; //add Profanity filter on input Toolbar
    [self addDomanFilterOnInputToolbar]; //add Domain filter on input Toolbar
    
    [self setShowProfanityFilter:false]; // Show profanity filter view inputtoolbar
    [self setDomainFilter:false]; //// Show Domain filter view inputtoolbar
    
    [self groupByThreadId:self.strThreadId];
}

-(void)viewWillAppear:(BOOL)animated{
    [AppDelegate sharedAppDelegate].isUpdateChatHistory = YES;
    if ([_dictGroupinfo[@"isActivated"] boolValue] == true){
        [self showDeactivated:true];
        self->isGroupActivated = true;
    }else{
        [self showDeactivated:false];
        [self.view endEditing:YES];
        self->isGroupActivated = false;
    }

}

-(void)showBlockUI{
    self.inputToolbar.userInteractionEnabled = FALSE;
    [self.inputToolbar.contentView.rightBarButtonItem setHidden:YES];
    [self.inputToolbar.contentView.leftBarButtonItem setHidden:YES];
    
    [self.view layoutIfNeeded];
}

-(void)unblockUI{
    self.inputToolbar.userInteractionEnabled = TRUE;
    [self.inputToolbar.contentView.rightBarButtonItem setHidden:false];
    [self.inputToolbar.contentView.leftBarButtonItem setHidden:false];
}

-(void)onLineOffLineMessgeShow {
    NSTimeInterval delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    [self headerShowMessage];
    });
    
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [headerView removeFromSuperview];
    }else{
    NSTimeInterval delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    CGFloat topbarHeight = ([UIApplication sharedApplication].statusBarFrame.size.height +
           (self.navigationController.navigationBar.frame.size.height ?: 0.0));
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, topbarHeight, self.collectionView.bounds.size.width, 64)];
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(48, 5, self.collectionView.bounds.size.width-54, 60)];
    UIImageView *imageNowifi = [[UIImageView alloc] initWithFrame:CGRectMake(16, 20, 24, 24)];
    
    [headerView setBackgroundColor:[UIColor colorWithRed:255/255.0 green:237/255.0 blue:237/255.0 alpha:1]];
    lblTitle.textColor = UIColor.redColor;
    lblTitle.text = @"You are offline, please make sure you are connected to the internet.";
    [imageNowifi setImage:[UIImage imageNamed:@"no-wifi"]];
    
    [lblTitle setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:16.0]];
    lblTitle.numberOfLines = 0;
    lblTitle.textAlignment = NSTextAlignmentLeft;
    [headerView addSubview:lblTitle];
    [headerView addSubview:imageNowifi];
    [self.navigationController.view addSubview:headerView];
    });
    }
}

-(void)geoLocation
{
    geoCoder = [[CLGeocoder alloc] init];
    /*if (locationManager == nil)
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.delegate = self;
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];*/
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
                                             selector:@selector(refreshReactionData:)
                                                name:DidRecievedReactionNotification
                                                object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(didUpdateChatMsgNotification:)
//                                                 name:DidUpdateChatNotification
//                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDeleteChatMsgNotification:)
                                                 name:DidDeleteChatMessageNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didchatStarFavourite:)
                                                 name:DidReceveEventStarFavouriteMessage
                                               object:nil];
     
     [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(didchatReportSuccess:)
                                                  name:ChatReportSuccessfully
                                                object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didgetchatSetting:)
                                                 name:DidGetChatSettingNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(didReceivedGroupEvent:)
                                                name:DidReceivedGroupEvent
                                              object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(refreshChatData)
        name:DidRecievedReactionNotification
      object:nil];

}

-(void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:DidRecievedMessageNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:DidRecievedTypingStatusNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:DidRecievedMessageReadStatusNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:UpdatChatWindowNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:DidRecievedReactionNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:DidUpdateChatNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:DidDeleteChatMessageNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (currentAudioMediaItem != nil) {
            [currentAudioMediaItem pause];
        }
    [self.view addSubview:self->removeView];
}

/*
-(void)refershControlAction {
    NSLog(@"[refershControlAction]");
    NSMutableDictionary *details = @{}.mutableCopy;
    details[@"pageSize"] = @20;
    if (_chatHistory != NULL && _chatHistory.count > 0 && _chatHistory.firstObject[MsgUniqueId] != NULL){
        details[@"currentMsgId"] =  _dictGroupThreadMsgDetails[MsgUniqueId] ;
        details[@"includeCurrentMsg"] = @"true";
    }
    details[@"direction"] = @"past";
    [self loadPreviousMessages:details completion:^{
       // [self->refreshControl endRefreshing];
    }];
}*/

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [headerView removeFromSuperview];
    [frozenView removeFromSuperview];
    [removeView removeFromSuperview];
}

-(void) dealloc {
    [self removeObservers];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}


- (CGSize)collectionView:(JSQMessagesCollectionView *)collectionView
                  layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = [collectionViewLayout sizeForItemAtIndexPath:indexPath];
    JSQMessage *message = self.message[indexPath.row];
    if ([message.media isKindOfClass:JSQLinkPreviewMediaItem.class]){
        JSQLinkPreviewMediaItem *item = (JSQLinkPreviewMediaItem*)message.media;
        size.height = [item mediaViewDisplaySize].height;
        if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row) {
            NSDictionary *dicMessage = [_chatHistory objectAtIndex:indexPath.row];
            if ([dicMessage valueForKey:@"reaction"] != nil && [dicMessage valueForKey:@"reaction"] != [NSNull null] ) {
                CGFloat height = [self convertDataToEmoji:[dicMessage valueForKey:@"reaction"]];
                size.height  +=  height;
            }
        }
    }
    NSDictionary *msgObject;
    if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row ){
        msgObject = [_chatHistory objectAtIndex:indexPath.row];
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
    }
    
    
    //for Jira cell implement
    /*
    if (msgObject != NULL && [msgObject[MsgType] isEqual:@"text"]){
    NSString *str = [NSString stringWithFormat:@"%@", [msgObject valueForKeyPath:@"message"]];
    NSMutableDictionary *dictJira = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        if ([msgObject valueForKey:@"name"] != nil && [msgObject valueForKey:@"name"] != [NSNull null] ) {
            if ([msgObject[MsgType] isEqualToString:@"text"]){
            size = CGSizeMake(self.view.frame.size.width, 350);
            }else{
            size = CGSizeMake(self.view.frame.size.width, 350);
            }
        }
    }*/

    
    
    return size;
}

- (void)getChatHistory {
    
    if (self.strThreadId != nil ) {
        if (![Helper stringIsNilOrEmpty:[self.dictGroupThreadMsgDetails valueForKey:MsgUniqueId]]) {
            
        [[eRTCCoreDataManager sharedInstance] getUserReplyThreadChatHistoryWithThreadID:self.strThreadId withParentID:[self.dictGroupThreadMsgDetails valueForKey:MsgUniqueId] andCompletionHandler:^(id ary, NSError *err) {
            
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
            NSArray *sortedArray=[ary sortedArrayUsingDescriptors:@[sort]];
            self->_chatHistory = [NSMutableArray arrayWithArray:sortedArray];
            self->_message = [[NSMutableArray alloc] init];
            [self showChatFromLocalDB:self->_chatHistory];
        }];
        }

    }
}


- (void)loadPreviousMessages:(NSMutableDictionary *)details completion:(LoadPreviouseMessageCompletion) completion {
    [[eRTCChatManager sharedChatInstance] loadPreviousChatHistoryWithThreadID:_dictGroupThreadMsgDetails[ThreadID] parameters:details.copy
                                                                andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        
        //[[eRTCCoreDataManager sharedInstance] getUserReplyThreadChatHistoryWithThreadID:_dictThreadMsgDetails[ThreadID] withParentID:[self.dictThreadMsgDetails valueForKey:MsgUniqueId] andCompletionHandler:^(id ary, NSError *err) {
        [[eRTCCoreDataManager sharedInstance] getUserReplyThreadChatHistoryWithThreadID:_dictGroupThreadMsgDetails[ThreadID] andCompletionHandler:^(id ary, NSError *err) {
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
            NSArray *sortedArray=[ary sortedArrayUsingDescriptors:@[sort]];
            self->_chatHistory = [NSMutableArray arrayWithArray:sortedArray];
            self->_message = [[NSMutableArray alloc] init];
           // [self showChatFromLocalDB:self->_chatHistory];
            completion();
        }];
    }andFailure:^(NSError * _Nonnull error) {
        completion();
    }];
}

- (void)showChatFromLocalDB:(NSMutableArray *) aryChat {
    NSLog(@"aryChat>>>>>>>>>>>>>%@",aryChat);
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

        if (![Helper stringIsNilOrEmpty:dict[MsgType]]) {
            if ([dict[MsgType] isEqualToString:@"gify"]) {
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
                _strDisplayName = (_strDisplayName != NULL ? _strDisplayName : @"");
                newMessage = [[JSQMessage alloc] initWithSenderId:_strSenderID senderDisplayName:_strDisplayName date:msgdate media:photoItemCopy];
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
                [NSData ertc_dataWithContentsOfStringURL:strURL onCompletionHandler:^(NSData * _Nullable data) {
                    [photoItemCopy setImage:[UIImage imageWithData:data]];
                    [self finishReceivingMessage];
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
                
                JSQVideoMediaItem *videoItem = [[JSQVideoMediaItem alloc] initWithFileURL:videoURL isReadyToPlay:YES];
                if (isOutgoingMsg) {
                    videoItem.appliesMediaViewMaskAsOutgoing = YES;
                    
                } else {
                    videoItem.appliesMediaViewMaskAsOutgoing = NO;
                }
                double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
                NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
               // newMessage = [JSQMessage messageWithSenderId:_strSenderID displayName:_strDisplayName media:videoItem];
                newMessage = [[JSQMessage alloc] initWithSenderId:_strSenderID senderDisplayName:_strDisplayName date:msgdate media:videoItem];

            } else if ([dict[MsgType] isEqualToString:@"audio"]) {
                NSURL * audioURL = nil;
                if (![Helper stringIsNilOrEmpty:dict[LocalFilePath]] && [dict[LocalFilePath] length] > 0) {
                    audioURL = [NSURL URLWithString:[@"file://" stringByAppendingString:dict[LocalFilePath]]];
                } else {
                    audioURL = [NSURL URLWithString:dict[FilePath]];
                }
                JSQAudioMediaItem *audioItem = [[JSQAudioMediaItem alloc] init];
                audioItem.delegate = self;
                if (isOutgoingMsg ) {
                    audioItem.appliesMediaViewMaskAsOutgoing = YES;
                    
                } else {
                    audioItem.appliesMediaViewMaskAsOutgoing = NO;
                }
                [NSData ertc_dataWithContentsOfStringURL:[audioURL absoluteString] onCompletionHandler:^(NSData * _Nullable data) {
                    [audioItem setAudioData:data];
                    [self finishSendingMessage];
                    
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
                if (![dict[IsDeletedMSG] boolValue] &&[dict[@"isEdited"] boolValue]){
                    strMessage = [NSString stringWithFormat:@"%@%@",dict[Message], EditedString];
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
            [self scrollToBottomAnimated:YES];
        });
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
    
    CGFloat width = self.navigationController.navigationBar.frame.size.width - 80 - 20;
    // UIView *titleHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 44)];

     //titleHeaderView.backgroundColor = [UIColor redColor];
     UILabel *lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 44)];
     if (self.dictGroupinfo[User_Name] != nil) {
         lblHeader.text = [NSString stringWithFormat:@"Thread\n%@",self.dictGroupinfo[User_Name]];
     }
    // titleHeaderView.clipsToBounds = YES;
     lblHeader.font = [UIFont systemFontOfSize:16];
     lblHeader.numberOfLines = 2;
     lblHeader.textAlignment = NSTextAlignmentCenter;
    // [titleHeaderView addSubview:lblHeader];
     self.navigationItem.titleView = lblHeader;
    
    /*UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width-20, 60)];
    UIImage *img = [UIImage imageNamed:@"DefaultUserIcon"];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,5, 35, 35)];
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
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(40, 12, 140, 20)];
    if (self.dictGroupinfo[Group_Name] != nil) {
        lbl.text = self.dictGroupinfo[Group_Name];
    }
    lbl.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:18];
    lbl.textAlignment = NSTextAlignmentLeft;
    [titleView addSubview:imgView];
    [titleView addSubview:lbl];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:titleView.frame];
    [btn addTarget:self action:@selector(btnGroupImageTapped) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:btn];
    self.navigationItem.titleView = titleView;*/
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
    CGFloat cornerRadius = 10.0;
    self.inputToolbar.contentView.textView.textContainerInset = UIEdgeInsetsMake(8, cornerRadius/2, 0, 0);
    self.inputToolbar.contentView.textView.frame = frame;

    self.inputToolbar.contentView.textView.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:17];
    self.inputToolbar.contentView.backgroundColor =[UIColor whiteColor];
    self.inputToolbar.contentView.textView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor clearColor]);
    self.inputToolbar.contentView.textView.layer.cornerRadius = cornerRadius;
    self.inputToolbar.contentView.textView.backgroundColor =[UIColor colorWithRed:238.0f/255.0f green:245.0f/255.0f blue:255.0f/255.0f alpha:1.0];

    [self.inputToolbar.contentView.textView setHidden:NO];
    [self.inputToolbar.contentView.recorderView setHidden:YES];
    
    UIButton *btn = [self getCheckButton];

    [btn setImage:[UIImage imageNamed:@"unselectCheck"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(isMarkMainThread:) forControlEvents:UIControlEventTouchUpInside];

    [self increaseHeightOfToolBar];
    
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


- (void)jsq_setCollectionViewInsetsTopValue:(CGFloat)top bottomValue:(CGFloat)bottom
{
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0.0f, bottom+40, 0.0f);
    self.collectionView.contentInset = insets;
    self.collectionView.scrollIndicatorInsets = insets;
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
                            //[self.inputToolbar.contentView.textView setText:@""];
                            [self.audioRecorderView stopAudioRecording];
                            break;
                        default:
                            break;
                    }
                }
                else {
                    // Microphone disabled code
                    [self.view makeToast:@"Please enable permission!"];
                }
            }];
    }
}

-(void)btnGroupImageTapped{
        if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
            NSMutableDictionary*dict = [[NSMutableDictionary alloc]init];
            [KVNProgress show];
            if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_ID] != nil) {
                [dict setValue:self.dictGroupinfo[Group_GroupId] forKey:Group_GroupId];
                [[eRTCChatManager sharedChatInstance]getGroupByGroupId:dict andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                    [KVNProgress dismiss];
                    
                    NSDictionary *dictResponse = (NSDictionary *)json;
                    if (dictResponse[@"success"] != nil) {
                        BOOL success = (BOOL)dictResponse[@"success"];
                        if (success) {
                            if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                                NSDictionary *result = (NSDictionary *)dictResponse[@"result"];
                                // NSArray *groups = (NSArray *)result[@"groups"];
                                // [self refreshTableDataWith:groups];
                                

                                UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle bundleForClass:InfoGroupViewController.class]];
                                InfoGroupViewController *vcInfo = [story instantiateViewControllerWithIdentifier:NSStringFromClass(InfoGroupViewController.class)];
                                vcInfo.dictGroupInfo = [NSMutableDictionary dictionaryWithDictionary:result];
                                [self.navigationController pushViewController:vcInfo animated:YES];
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
//                 [self finishSendingMessageAnimated:YES];
//            }];
        }
            break;
            
        case 3:
            [self contactsDetailsFromPhoneContactBook];
            break;
            
        case 4:
           // [self openDocumentPicker];
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
                NSLog(@"resource not reachable");
                [self.view makeToast:messageLargeVideoFile];
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
//            [self.view makeToast:@"message not edited" duration:2 position:CSToastPositionTop];
            [self clearEditedDetalils];
            return;
        }
        
    }else {
        NSDictionary *config = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
        if ([config[@"replyThreadGroupChat"] boolValue] == true){
            [_message addObject:message];
            [self sendTextMessage:strdata];
            [self finishSendingMessageAnimated:YES];
        }else{
            self.inputToolbar.contentView.textView.text = @"";
            NSString *msg = @"Thread chat not available. Please contact your administrator.";
            [Helper showAlertOnController:@"eRTC" withMessage:msg onController:self];
        }
    }
    
    self->isSelectedMentionUser = NO;
    self->mentionsUser = @"";
    self->mentionUserEmail = @"";
    arrMentionEmail = [NSMutableArray new];
    arrMentionUser = [NSMutableArray new];
   
    
}

-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesBubbleImageFactory *bubble = [[JSQMessagesBubbleImageFactory alloc] init];
     if(![[[_message objectAtIndex:indexPath.item] senderId] isEqualToString:self.senderId])
        {
            return [bubble incomingMessagesBubbleImageWithColor:[UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.0]];
        }
        else
            return [bubble outgoingMessagesBubbleImageWithColor:[UIColor colorWithRed:0.9 green:0.93 blue:1.0 alpha:1.0]];
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
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }

    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [_message objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
   
    JSQMessage *jsqM = [_message objectAtIndex:indexPath.item];
    if([jsqM.media isKindOfClass:[JSQGIFMediaItem class]]){
        JSQGIFMediaItem *item = (JSQGIFMediaItem *)jsqM.media;
        [item.cachedImageView setNeedsLayout];
    }
    
    
    return [_message objectAtIndex:indexPath.item];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        GroupChatThreadHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"GroupChatThreadHeaderView" forIndexPath:indexPath];
        NSString *erctId = [NSString stringWithFormat:@"%@", [self.dictGroupThreadMsgDetails valueForKey:SendereRTCUserId]];
        NSString *epochTime = [NSString stringWithFormat:@"%@", [self.dictGroupThreadMsgDetails valueForKey:@"createdAt"]];
        NSTimeInterval seconds = [epochTime doubleValue];
        NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:(seconds / 1000)];
        NSDateComponents *components;
        components = [[NSCalendar currentCalendar] components: NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:epochNSDate toDate:  [[NSDate alloc] init] options: 0];
        if ([components day] > 0) {
            headerView.lblTime.text = [NSString stringWithFormat:@"%ld days ago", (long)[components day]];
            if ([components day] == 1) {
                headerView.lblTime.text = [NSString stringWithFormat:@"%ld day ago", (long)[components day]];
            }
        } else if ([components hour] > 0) {
            headerView.lblTime.text = [NSString stringWithFormat:@"%ld hours ago", (long)[components hour]];
            if ([components hour] == 1) {
                headerView.lblTime.text = [NSString stringWithFormat:@"%ld hour ago", (long)[components hour]];
            }
        } else if ([components minute] > 0) {
            headerView.lblTime.text = [NSString stringWithFormat:@"%ld minutes ago", (long)[components minute]];
            if ([components minute] == 1) {
                headerView.lblTime.text = [NSString stringWithFormat:@"%ld minute ago", (long)[components minute]];
            }
        } else if ([components second] > 0) {
            headerView.lblTime.text = [NSString stringWithFormat:@"%ld seconds ago", (long)[components second]];
            if ([components second] == 1) {
                headerView.lblTime.text = [NSString stringWithFormat:@"%ld second ago", (long)[components second]];
            }
        } else {
            headerView.lblTime.text = @"A while ago";
        }
        headerView.imgUser.layer.cornerRadius = 15;
        [[eRTCChatManager sharedChatInstance] getuserInfoWithERTCId:erctId andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            NSMutableArray *arrUser = [NSMutableArray new];
            arrUser = json;
            if (arrUser.count > 0) {
                NSDictionary *dictUser = [arrUser objectAtIndex:0];
                if (dictUser[User_Name] != nil && dictUser[User_Name] != [NSNull null]) {
                    headerView.lblName.text = [NSString stringWithFormat:@"%@",_dictGroupThreadMsgDetails[User_Name]];
                }else{
                    headerView.lblName.text = [NSString stringWithFormat:@"%@",_dictGroupThreadMsgDetails[User_Name]];
                }
                NSString *imgURl = [NSString stringWithFormat:@"%@", [[arrUser objectAtIndex:0] valueForKey:User_ProfilePic_Thumb]];
                [headerView.imgUser sd_setImageWithURL:[NSURL URLWithString:imgURl] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
            }
        } andFailure:^(NSError * _Nonnull error) {
            headerView.lblName.text = @"";
            headerView.imgUser.image = [UIImage imageNamed:@"DefaultUserIcon"];
        }];
        if ( [self.dictGroupThreadMsgDetails valueForKey:@"message"] != nil &&  [self.dictGroupThreadMsgDetails valueForKey:@"message"] != [NSNull null]) {
            if ( [[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"text"]) {
                NSString *removedTags = [Helper getRemoveMentionTags:  [self.dictGroupThreadMsgDetails valueForKey:@"message"]];
                NSString *strMessage = @"";
                if (editTags != nil) {
                    NSString *_message = removedTags;
                    strMessage = [NSString stringWithFormat:@"%@%@",_message, EditedString];
                    NSMutableAttributedString *attrString = [Helper mentionHighlightedAttributedStringByNames:_userNames message:strMessage].mutableCopy;
                    NSString *orignalMessage = [attrString.string stringByReplacingOccurrencesOfString:EditedString withString:@""];
                    NSRange textRange = NSMakeRange(0, attrString.length);
                    NSRange range = NSMakeRange(orignalMessage.length, EditedString.length);
                    if (NSEqualRanges(NSIntersectionRange(textRange, range), range)) {
                        [attrString addAttributes:@{
                            NSForegroundColorAttributeName:[UIColor lightGrayColor],
                            NSFontAttributeName: [UIFont fontWithName:@"SFProDisplay-Regular" size:14]
                        } range:NSMakeRange(orignalMessage.length, EditedString.length)];
                    }
                    headerView.lblMessage.attributedText = attrString.copy;
                }else{
                    if (_dictGroupThreadMsgDetails != NULL && ![_dictGroupThreadMsgDetails[IsDeletedMSG] boolValue] && [_dictGroupThreadMsgDetails[IsEdited] isEqual:@1]){
                        NSString *_message = removedTags;
                        strMessage = [NSString stringWithFormat:@"%@%@",_message, EditedString];
                        NSMutableAttributedString *attrString = [Helper mentionHighlightedAttributedStringByNames:_userNames message:strMessage].mutableCopy;
                        NSString *orignalMessage = [attrString.string stringByReplacingOccurrencesOfString:EditedString withString:@""];
                        NSRange textRange = NSMakeRange(0, attrString.length);
                        NSRange range = NSMakeRange(orignalMessage.length, EditedString.length);
                        if (NSEqualRanges(NSIntersectionRange(textRange, range), range)) {
                            [attrString addAttributes:@{
                                NSForegroundColorAttributeName:[UIColor lightGrayColor],
                                NSFontAttributeName: [UIFont fontWithName:@"SFProDisplay-Regular" size:14]
                            } range:NSMakeRange(orignalMessage.length, EditedString.length)];
                        }
                        headerView.lblMessage.attributedText = attrString.copy;
                    }else{
                    headerView.lblMessage.attributedText =[self colorHashtag:removedTags];
                    }
                }
            } else {
                headerView.lblMessage.text = [[NSString stringWithFormat:@"%@", [self.dictGroupThreadMsgDetails valueForKey:@"msgType"]] capitalizedString];
            }
        } else {
            headerView.lblMessage.text = [[NSString stringWithFormat:@"%@", [self.dictGroupThreadMsgDetails valueForKey:@"msgType"]] capitalizedString];
        }
        [headerView.btnFav addTarget:self action:@selector(isMarkThreadMessageFavouriteWithIndexPath:) forControlEvents:UIControlEventTouchUpInside];
        if ([self.dictGroupThreadMsgDetails valueForKey:@"isFavourite"] != nil && [self.dictGroupThreadMsgDetails valueForKey:@"isFavourite"] != [NSNull null]) {
            if ([[self.dictGroupThreadMsgDetails valueForKey:@"isFavourite"] intValue] == 0) {
                // Not Fav
                [headerView.btnFav setImage:[UIImage imageNamed:@"unFav"] forState:UIControlStateNormal];
            } else {
                // Fav
                [headerView.btnFav setImage:[UIImage imageNamed:@"fav"] forState:UIControlStateNormal];
            }
        }
        reusableview = headerView;
    }
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.frame.size.width, 86.0);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeZero;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_message count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //JSQMessagesCollectionViewCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    JSQMessage *message = _message[indexPath.row];
    NSDictionary *msgObject;
    if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row ){
        msgObject = [_chatHistory objectAtIndex:indexPath.row];
    }
   
    JSQMessagesCollectionViewCell *cell  = [super collectionView:self.collectionView cellForItemAtIndexPath:indexPath];//[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    if (msgObject && [msgObject valueForKey:@"isReported"] != nil && [msgObject valueForKey:@"isReported"] != [NSNull null] ){
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"JSQReportCell" forIndexPath:indexPath];
        cell.delegate = self;
        cell.cellTopLabel.hidden = true;
        cell.cellBottomLabel.hidden = true;
    }
    
    cell.textView.selectable = false;
    cell.textView.textColor = [UIColor blackColor];
    cell.textView.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:15];
    if (cell.textView.text != nil && [cell.textView.text length] > 0) {
        if (msgObject != NULL && [msgObject[MsgType] isEqual:ContactType]){
            cell.textView.attributedText = [[NSAttributedString alloc]
                                            initWithString:cell.textView.text
                                            attributes:@{
                                                NSForegroundColorAttributeName:[UIColor systemBlueColor],
                                                NSFontAttributeName: [UIFont fontWithName:@"SFProDisplay-Semibold" size:18]
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
        }else {
            //cell.textView.attributedText =  [Helper mentionHighlightedAttributedStringByNames:_userNames message:cell.textView.text];
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
        if (_chatHistory.count - 1 == indexPath.row){
            [replyCountView setPaddingForLastMessage];
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
    JSQMessage *message = [self.message objectAtIndex:indexPath.row];
    if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row ){
        NSDictionary *dict = _chatHistory[indexPath.row];
        BOOL isDeleted = [dict[IsDeletedMSG] isEqual:@1];
        BOOL isReported = dict[@"isReported"];
        if (![message.msgStatus containsString:@"sending"] && !isDeleted){
            if (isReported || isRemovedChannel || isFrozenChannel || _isGroupDeleted || isGroupActivated){
            }else{
                if (message.isMediaMessage && [dict[MsgStatusEvent] containsString:@"sending"]){
                    [self.view makeToast:@"Please wait for message to send"];
                }else{
                    
                    [self hadleLongPressAction:indexPath];
//                    NSDictionary *dictConfig = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
//                    if ([dictConfig[@"chatBots"] boolValue] == false) {
//
//                    }
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
/*
-(void)headerShowMessage {
    CGFloat topbarHeight = ([UIApplication sharedApplication].statusBarFrame.size.height +
           (self.navigationController.navigationBar.frame.size.height ?: 0.0));
    
   headerView = [[UIView alloc] initWithFrame:CGRectMake(0, topbarHeight, self.collectionView.bounds.size.width, 90)];
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(48, 5, self.collectionView.bounds.size.width-54, 60)];
    UIImageView *imageNowifi = [[UIImageView alloc] initWithFrame:CGRectMake(16, 20, 24, 24)];
    [headerView setBackgroundColor:[UIColor colorWithRed:237/255.0 green:255/255.0 blue:238/255.0 alpha:1]];
        lblTitle.textColor = [UIColor colorWithRed:19/255.0 green:187/255.0 blue:26/255.0 alpha:1];
    lblTitle.text = @"Thank you for submitting a report, The reported message/media will be remove from the conversation, and we will review your report.";
    [imageNowifi setImage:[UIImage imageNamed:@"CircleRight"]];
UIView *bottemView = [[UIView alloc] initWithFrame:CGRectMake(16, -115,self.collectionView.bounds.size.width-48, 90)];
   
[bottemView setBackgroundColor:[UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1]];
    bottemView.layer.cornerRadius = 10;
UILabel *lblMsgTitle = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, bottemView.bounds.size.width-16, 20)];
UILabel *lblMsgSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(8, lblMsgTitle.frame.size.height+12, bottemView.bounds.size.width-16, 50)];
    lblMsgSubTitle.textColor = [UIColor colorWithRed:113/255.0 green:134/255.0 blue:156/255.0 alpha:1];
    lblMsgTitle.textColor = UIColor.blackColor;
    lblMsgTitle.text = @"Message Reported";
    lblMsgSubTitle.text = @"The message was deleted because you reported it";
    lblMsgSubTitle.numberOfLines = 0;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Undo" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:0.0/255.0 green:122/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
    button.frame = CGRectMake(bottemView.frame.size.width-60, 2, 50.0, 40.0);
    [button addTarget:self action:@selector(btnUndu:) forControlEvents:UIControlEventTouchUpInside];
    [bottemView addSubview:button];
    
    [bottemView addSubview:lblMsgTitle];
    [bottemView addSubview:lblMsgSubTitle];
    
   
    [lblTitle setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:16.0]];
    lblTitle.numberOfLines = 0;
    lblTitle.textAlignment = NSTextAlignmentLeft;
    [headerView addSubview:lblTitle];
    [headerView addSubview:imageNowifi];
}
*/

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






- (void)customAction:(id)sender
{
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Custom Action", nil)
                                message:nil
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles:nil]
     show];
}

-(void)copyThreadMessage{
    NSLog(@"copied");
    [self copyMessageWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

-(void)startThreadChat{
    NSLog(@"open keyboard");
     [self.inputToolbar.contentView.textView becomeFirstResponder];
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
        if ([dicMessage valueForKey:@"reaction"] != nil && [dicMessage valueForKey:@"reaction"] != [NSNull null] ) {
            CGFloat height = [self convertDataToEmoji:[dicMessage valueForKey:@"reaction"]];
            bottomHeight = height;
        }
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

-(NSString*)getSeenMsgStatusIndexFromThreadGroupChat:(NSInteger)indexItem{
    NSDictionary *dict = NULL;
    if (_chatHistory.count > 0 && _chatHistory.count > indexItem ){
        dict = [self->_chatHistory objectAtIndex:indexItem];
    }
    if (indexItem == self->_chatHistory.count - 1){
        
        
        if ([[dict valueForKey:@"msgStatusEvent"] isEqualToString:@"seen"]){
            if ([dict[@"msgType"] isEqualToString:@"text"]){
                return @"Read";
            }else{
                return @"delivered";
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
                NSString *strMsgStatus = [self getSeenMsgStatusIndexFromThreadGroupChat:indexPath.row];
                return [[NSAttributedString alloc] initWithString:strMsgStatus];
            //return [[NSAttributedString alloc] initWithString:[dict valueForKey:@"msgStatusEvent"]];
          //  return [[NSAttributedString alloc] initWithString:currentMessage.msgStatus];
        } else {
            return [[NSAttributedString alloc] initWithString:currentMessage.msgStatus];
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

/*-(NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath{
    currentMessage  = [self.message objectAtIndex:indexPath.item];
    //check if outgoing
    if ([currentMessage.senderId isEqualToString:self.senderId]) {
        //status could be: 'sent', 'sending', etc
        if (currentMessage.msgStatus != nil){
            return [[NSAttributedString alloc] initWithString:currentMessage.msgStatus];
        } else {
            return [[NSAttributedString alloc] initWithString:@""];
        }
        //return [[NSAttributedString alloc] initWithString:@"delivered"];
    }
    //return nothing for incoming messages
    return nil;
}*/

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
    
    if (indexPath.item == 0 || indexPath.item == 1) {
           return kJSQMessagesCollectionViewCellLabelHeightDefault;
       }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.message objectAtIndex:indexPath.item - 1];
        JSQMessage *message = [self.message objectAtIndex:indexPath.item];
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
    
    if (indexPath.item == 0 || indexPath.item == 1) {
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

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
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
//            [self sendTypingStatusToRecepient:YES];
        } else {
//            [self stopTypingIndicator];
        }
        
        return textView.text;
    }
//    self.inputToolbar.contentView.textView.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:17];
    return YES;
}

-(void)sendTypingStatusToRecepient:(BOOL)isON {
    NSMutableDictionary * dictParam = [NSMutableDictionary new];
    [dictParam setObject:self.dictGroupinfo[Group_GroupId] forKey:Group_GroupId]; // current selected user
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


- (void)receiveMessageWithSenderId:(NSString *)senderId andDisplayName:(NSString *) displayName andtextMessage:(NSString *) textMessage msgType:(NSString*)msgType andDictionary:(NSDictionary*)dictResponse{ //andMsgStatus:(NSString *) msgStatus
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
        NSLog(@"receiveMessageWithSenderId:strURL:%@",strURL);
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
        NSLog(@"SingleChatViewController -> receiveMessageWithSenderId -> gify -> %@",textMessage);
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
        NSLog(@"video strURL---%@",textMessage);
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
        NSLog(@"SingleChatViewController ->  receiveMessageWithSenderId -> audio -> %@",textMessage);
        
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
        
        
        NSURL *first = [Helper getFirstUrlIfExistInMessage:copyMessage.text];
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
            newMessage = [JSQMessage messageWithSenderId:senderId displayName:displayName text:copyMessage.text];
            
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

-(void)updateGroupReplyThreadChatHistory{
    if (self.strThreadId != nil ) {
        if (![Helper stringIsNilOrEmpty:[self.dictGroupThreadMsgDetails valueForKey:MsgUniqueId]]) {
            [[eRTCCoreDataManager sharedInstance] getUserReplyThreadChatHistoryWithThreadID:self.strThreadId withParentID:[self.dictGroupThreadMsgDetails valueForKey:MsgUniqueId] andCompletionHandler:^(id ary, NSError *err) {
                
                self->_chatHistory = [NSMutableArray arrayWithArray:ary];
//                [self->_chatHistory insertObject:self.dictGroupThreadMsgDetails atIndex:0];
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

-(void)sendEditedTextMessage:(NSDictionary*)editingMesssage {
    
    NSIndexPath *indexPath = editingMesssage[@"position"];
    NSDictionary *object = editingMesssage[@"editedMessage"];
    NSString *message = [object[Message] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
   // NSString *mentionString = [Helper getNamesTaggedStringFromNames:_userNames message:message];
    if (self.inputToolbar.contentView.rightBarButtonItem.isSelected == YES && message.length>0) {
        if (isTypingActive) {
            [self userTypingFinished];
        }
        NSMutableDictionary * dictDeleteMessage = [NSMutableDictionary new];
        if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil) {
            if (self.dictGroupinfo[Group_GroupId] != nil && self.dictGroupinfo[Group_GroupId] != [NSNull null]) {
                NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
                [dictDeleteMessage setObject:message forKey:Message];
                [dictDeleteMessage setObject:userId forKey:SendereRTCUserId];
                [dictDeleteMessage setValue:object[ThreadID] forKey:@"threadId"];
                [dictDeleteMessage setValue:object[MsgUniqueId] forKey:@"msgUniqueId"];
                [dictDeleteMessage setObject:self->arrUser forKey:ArParticipants];
                
                [[eRTCChatManager sharedChatInstance] editMessageWithParam:[NSDictionary dictionaryWithDictionary:dictDeleteMessage] andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                    [self updateMessageCellAtIndexPath:indexPath message:object];
                    
                } andFailure:^(NSError * _Nonnull error) {
                    NSLog(@"error--> %@",error);
                    [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
                }];
            }
        }
    }
}

/*
-(void)sendFavouriteAndUnfavourateMessage:(NSDictionary*)editstarFavourite {
        NSMutableDictionary * dictFavouriteMessage = [NSMutableDictionary new];
        if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil) {
            if (self.dictUserDetails[App_User_ID] != nil && self.dictUserDetails[App_User_ID] != [NSNull null]) {
                [dictFavouriteMessage setValue:editstarFavourite[ThreadID] forKey:ThreadID];
                [dictFavouriteMessage setValue:editstarFavourite[Message] forKey:Message];
                [dictFavouriteMessage setValue:editstarFavourite[MsgUniqueId] forKey:MsgUniqueId];
                NSNumber *isFavourate = editstarFavourite[IsFavourite];
                if ([isFavourate isEqualToNumber:@(YES)]) {
                [dictFavouriteMessage setValue:Istrue forKey:IsStarred];
                }else{
                [dictFavouriteMessage setValue:IsFalse forKey:IsStarred];
                }
                [[eRTCChatManager sharedChatInstance] addandRemoveFavouriteMessage:dictFavouriteMessage andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                //[self updateMessageCellAtIndexPath:indexPath message:object];
                } andFailure:^(NSError * _Nonnull error) {
                    NSLog(@"error--> %@",error);
                   [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
                }];
            }
        }
    }*/

-(void)sendTextMessage:(NSString*)message {
    if (self.inputToolbar.contentView.rightBarButtonItem.isSelected == YES && message.length>0) {
//        if (isTypingActive) {
//            [self userTypingFinished];
//        }
        
        NSString *mentionString = [Helper getNamesTaggedStringFromNames:_userNames message:message];
        if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil) {
            NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
            
            if (self.dictGroupinfo[Group_GroupId] != nil && self.dictGroupinfo[Group_GroupId] != [NSNull null]) {
                NSMutableDictionary * dictParam = [NSMutableDictionary new];
                if ([self.strReplyStatus isEqualToString:@"1"]){
                        if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"text"]){
                            [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:Message] forKey:Parent_Msg];
                        }
                    
                        else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"image"]){
                            [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:@"mediaFileName"] forKey:Parent_Msg];
                        }
                    
                        else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"video"]){
                            [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:@"mediaFileName"] forKey:Parent_Msg];
                        }
                    
                        else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"gify"]){
                            [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:@"mediaFileName"] forKey:Parent_Msg];
                        }
                        else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:AudioFileName]){
                            [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:@"mediaFileName"] forKey:Parent_Msg];
                        }
                    
                        else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"location"]){
                            if (![Helper stringIsNilOrEmpty:[self.dictGroupThreadMsgDetails valueForKeyPath:@"location.address"]]){
                                [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKeyPath:@"location.address"] forKey:Parent_Msg];
                            }else{
                                [dictParam setObject:@"" forKey:Parent_Msg];
                            }
                        }
                    
                        else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"contact"]){
                            if (![Helper stringIsNilOrEmpty:[self.dictGroupThreadMsgDetails valueForKeyPath:@"contact.name"]]){
                                [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKeyPath:@"contact.name"] forKey:Parent_Msg];
                            }else{
                                [dictParam setObject:@"" forKey:Parent_Msg];
                            }
                        }
                        else{
                            [dictParam setObject:@"" forKey:Parent_Msg];
                        }
                }else{
                    [dictParam setObject:@"" forKey:Parent_Msg];
                }
                [dictParam setObject:userId forKey:SendereRTCUserId];
                [dictParam setObject:mentionString forKey:Message];
                [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:ThreadID] forKey:ThreadID];
                [dictParam setObject:@"startThread" forKey:Start_Thread];
                [dictParam setValue:self.aryMentioned forKey:@"mentions"];
                [dictParam setObject:self.strReplyStatus forKey:ReplyMsgConfigStatus];
                [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:MsgUniqueId] forKey:ParentID];
               // NSString *strErtcUserId = [self getErtcUserIdWiththreadID:[self.dictGroupThreadMsgDetails valueForKey:ThreadID]];
                [dictParam setObject:self->arrUser forKey:ArParticipants];
                
                [[eRTCChatManager sharedChatInstance] sendTextMessageWithParam:[NSDictionary dictionaryWithDictionary:dictParam] andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                    self->ReplyCount = self->ReplyCount+1;
                    self->currentMessage.msgStatus = @"sent";
                    [self updateGroupReplyThreadChatHistory];
                    [self.collectionView reloadData];
                    _aryMentioned = [NSMutableArray new];
                    //[self followUnFollowMsg:_dictGroupThreadMsgDetails];
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


-(void)sendPhotoMediaItemWithData:(NSData*)data {
    if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil) {
        NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
        NSMutableDictionary * dictParam = [NSMutableDictionary new];
        if ([self.strReplyStatus isEqualToString:@"1"]){
                if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"text"]){
                    [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:Message] forKey:Parent_Msg];
                }
            
                else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"image"]){
                    [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:@"mediaFileName"] forKey:Parent_Msg];
                }
            
                else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"video"]){
                    [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:@"mediaFileName"] forKey:Parent_Msg];
                }
            
                else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"gify"]){
                    [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:@"mediaFileName"] forKey:Parent_Msg];
                }
                else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:AudioFileName]){
                    [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:@"mediaFileName"] forKey:Parent_Msg];
                }
            
                else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"location"]){
                    if (![Helper stringIsNilOrEmpty:[self.dictGroupThreadMsgDetails valueForKeyPath:@"location.address"]]){
                        [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKeyPath:@"location.address"] forKey:Parent_Msg];
                    }else{
                        [dictParam setObject:@"" forKey:Parent_Msg];
                    }
                }
            
                else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"contact"]){
                    if (![Helper stringIsNilOrEmpty:[self.dictGroupThreadMsgDetails valueForKeyPath:@"contact.name"]]){
                        [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKeyPath:@"contact.name"] forKey:Parent_Msg];
                    }else{
                        [dictParam setObject:@"" forKey:Parent_Msg];
                    }
                }
            
                else{
                    [dictParam setObject:@"" forKey:Parent_Msg];
                }
        }else{
            [dictParam setObject:@"" forKey:Parent_Msg];
        }
        
        [dictParam setObject:userId forKey:SendereRTCUserId];
        //  [dictParam setObject:@"image" forKey:@"msgType"];
//        [dictParam setObject:self.strThreadId forKey:ThreadID];
        [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:ThreadID] forKey:ThreadID];
        [dictParam setObject:@"startThread" forKey:Start_Thread];
        [dictParam setObject:self.strReplyStatus forKey:ReplyMsgConfigStatus];
        [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:MsgUniqueId] forKey:ParentID];
//        [[eRTCChatManager sharedChatInstance] sendPhotoMediaItemWithParam:dictParam andFileData:data];
        [[eRTCChatManager sharedChatInstance] sendPhotoMediaItemWithParam:dictParam andFileData:data andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            NSLog(@"Photo sent succesfully!!!");
            self->ReplyCount = self->ReplyCount+1;
            self->currentMessage.msgStatus = @"sent";
            [self finishSendingMessageAnimated:YES];
            [self updateGroupReplyThreadChatHistory];
           // [self followUnFollowMsg:_dictGroupThreadMsgDetails];
        } andFailure:^(NSError * _Nonnull error) {
            NSLog(@"Failed to send Photo");
            [self->_message removeLastObject];
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
            
            if ([self.strReplyStatus isEqualToString:@"1"]){
                    if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"text"]){
                        [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:Message] forKey:Parent_Msg];
                    }
                
                    else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"image"]){
                        [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:@"mediaFileName"] forKey:Parent_Msg];
                    }
                
                    else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"video"]){
                        [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:@"mediaFileName"] forKey:Parent_Msg];
                    }
                
                    else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"gify"]){
                        [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:@"mediaFileName"] forKey:Parent_Msg];
                    }
                    else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:AudioFileName]){
                        [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:@"mediaFileName"] forKey:Parent_Msg];
                    }
                
                    else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"location"]){
                        if (![Helper stringIsNilOrEmpty:[self.dictGroupThreadMsgDetails valueForKeyPath:@"location.address"]]){
                            [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKeyPath:@"location.address"] forKey:Parent_Msg];
                        }else{
                            [dictParam setObject:@"" forKey:Parent_Msg];
                        }
                    }
                
                    else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"contact"]){
                        if (![Helper stringIsNilOrEmpty:[self.dictGroupThreadMsgDetails valueForKeyPath:@"contact.name"]]){
                            [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKeyPath:@"contact.name"] forKey:Parent_Msg];
                        }else{
                            [dictParam setObject:@"" forKey:Parent_Msg];
                        }
                    }
                
                    else{
                        [dictParam setObject:@"" forKey:Parent_Msg];
                    }
            }else{
                [dictParam setObject:@"" forKey:Parent_Msg];
            }

            [dictParam setObject:userId forKey:SendereRTCUserId];
            //   [dictParam setObject:@"audio" forKey:@"msgType"];
         //   [dictParam setObject:self.strThreadId forKey:ThreadID];
            [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:ThreadID] forKey:ThreadID];
            [dictParam setObject:@"startThread" forKey:Start_Thread];
            [dictParam setObject:self.strReplyStatus forKey:ReplyMsgConfigStatus];
            [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:MsgUniqueId] forKey:ParentID];
//            [[eRTCChatManager sharedChatInstance] sendAudioMediaItemWithParam:dictParam andFileData:data];
            [[eRTCChatManager sharedChatInstance] sendAudioMediaItemWithParam:dictParam andFileData:data andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                NSLog(@"Audio sent succesfully!!!");
                self->ReplyCount = self->ReplyCount+1;
                self->currentMessage.msgStatus = @"sent";
                [self finishSendingMessageAnimated:YES];
                [self updateGroupReplyThreadChatHistory];
                //[self followUnFollowMsg:_dictGroupThreadMsgDetails];
            } andFailure:^(NSError * _Nonnull error) {
                NSLog(@"Failed to send Audio");
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
            
            if ([self.strReplyStatus isEqualToString:@"1"]){
                    if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"text"]){
                        [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:Message] forKey:Parent_Msg];
                    }
                
                    else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"image"]){
                        [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:@"mediaFileName"] forKey:Parent_Msg];
                    }
                
                    else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"video"]){
                        [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:@"mediaFileName"] forKey:Parent_Msg];
                    }
                
                    else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"gify"]){
                        [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:@"mediaFileName"] forKey:Parent_Msg];
                    }
                    else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:AudioFileName]){
                        [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:@"mediaFileName"] forKey:Parent_Msg];
                    }
                
                    else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"location"]){
                        if (![Helper stringIsNilOrEmpty:[self.dictGroupThreadMsgDetails valueForKeyPath:@"location.address"]]){
                            [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKeyPath:@"location.address"] forKey:Parent_Msg];
                        }else{
                            [dictParam setObject:@"" forKey:Parent_Msg];
                        }
                    }
                
                    else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"contact"]){
                        if (![Helper stringIsNilOrEmpty:[self.dictGroupThreadMsgDetails valueForKeyPath:@"contact.name"]]){
                            [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKeyPath:@"contact.name"] forKey:Parent_Msg];
                        }else{
                            [dictParam setObject:@"" forKey:Parent_Msg];
                        }
                    }
                
                    else{
                        [dictParam setObject:@"" forKey:Parent_Msg];
                    }
            }else{
                [dictParam setObject:@"" forKey:Parent_Msg];
            }

            
            [dictParam setObject:userId forKey:SendereRTCUserId];
           // [dictParam setObject:self.strThreadId forKey:ThreadID];
//            [[eRTCChatManager sharedChatInstance] sendVideoMediaItemWithParam:dictParam andFileData:data];
            [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:ThreadID] forKey:ThreadID];
            [dictParam setObject:@"startThread" forKey:Start_Thread];
            [dictParam setObject:self.strReplyStatus forKey:ReplyMsgConfigStatus];
            [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:MsgUniqueId] forKey:ParentID];
            [[eRTCChatManager sharedChatInstance] sendVideoMediaItemWithParam:dictParam andFileData:data andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                NSLog(@"Video sent succesfully!!!");
                self->ReplyCount = self->ReplyCount+1;
                self->currentMessage.msgStatus = @"sent";
                [self finishSendingMessageAnimated:YES];
                [self updateGroupReplyThreadChatHistory];
               // [self followUnFollowMsg:_dictGroupThreadMsgDetails];
            } andFailure:^(NSError * _Nonnull error) {
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
     // [dictParam setObject:self.strThreadId forKey:ThreadID];
        [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:ThreadID] forKey:ThreadID];
        [dictParam setObject:@"startThread" forKey:Start_Thread];
        [dictParam setObject:self.strReplyStatus forKey:ReplyMsgConfigStatus];
        [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:MsgUniqueId] forKey:ParentID];
//      [[eRTCChatManager sharedChatInstance] sendMediaFileItemWithParam:dictParam andFileData:data andFileExtension:fileExtension];
       [[eRTCChatManager sharedChatInstance] sendMediaFileItemWithParam:dictParam andFileData:data andFileExtension:fileExtension andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
           NSLog(@"File sent succesfully!!!");
           self->ReplyCount = self->ReplyCount+1;
           self->currentMessage.msgStatus = @"sent";
           [self finishSendingMessageAnimated:YES];
           [self updateGroupReplyThreadChatHistory];

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
       
      // [self scrollToBottomAnimated:YES];
      [self finishSendingMessageAnimated:YES];
    }
  }
}

-(void)sendGIFMediaItemWithURL:(NSString*)gifURL {
    if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil && [gifURL length] > 0) {
        NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
        if (self.dictGroupinfo[Group_GroupId] != nil && self.dictGroupinfo[Group_GroupId] != [NSNull null]) {
            NSMutableDictionary * dictParam = [NSMutableDictionary new];
            if ([self.strReplyStatus isEqualToString:@"1"]){
                    if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"text"]){
                        [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:Message] forKey:Parent_Msg];
                    }
                
                    else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"image"]){
                        [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:@"mediaFileName"] forKey:Parent_Msg];
                    }
                
                    else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"video"]){
                        [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:@"mediaFileName"] forKey:Parent_Msg];
                    }
                
                    else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"gify"]){
                        [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:@"mediaFileName"] forKey:Parent_Msg];
                    }
                    else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:AudioFileName]){
                        [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:@"mediaFileName"] forKey:Parent_Msg];
                    }
                
                    else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"location"]){
                        if (![Helper stringIsNilOrEmpty:[self.dictGroupThreadMsgDetails valueForKeyPath:@"location.address"]]){
                            [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKeyPath:@"location.address"] forKey:Parent_Msg];
                        }else{
                            [dictParam setObject:@"" forKey:Parent_Msg];
                        }
                    }
                
                    else if ([[self.dictGroupThreadMsgDetails valueForKey:@"msgType"] isEqualToString:@"contact"]){
                        if (![Helper stringIsNilOrEmpty:[self.dictGroupThreadMsgDetails valueForKeyPath:@"contact.name"]]){
                            [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKeyPath:@"contact.name"] forKey:Parent_Msg];
                        }else{
                            [dictParam setObject:@"" forKey:Parent_Msg];
                        }
                    }
                
                    else{
                        [dictParam setObject:@"" forKey:Parent_Msg];
                    }
            }else{
                [dictParam setObject:@"" forKey:Parent_Msg];
            }
           
            [dictParam setObject:userId forKey:SendereRTCUserId];
            [dictParam setObject:gifURL forKey:GifyFileName];
//            [dictParam setObject:@"gify" forKey:MsgType];
          //  [dictParam setObject:self.strThreadId forKey:ThreadID];
            [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:ThreadID] forKey:ThreadID];
            [dictParam setObject:@"startThread" forKey:Start_Thread];
            [dictParam setObject:self.strReplyStatus forKey:ReplyMsgConfigStatus];
            [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:MsgUniqueId] forKey:ParentID];
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
                                            [self updateGroupReplyThreadChatHistory];
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
                                        [self updateGroupReplyThreadChatHistory];
                                        self->currentMessage.msgStatus = @"Sent".capitalizedString;
                                        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
                                    }];
                                }
                            }//
                          }
                        }
                    }else{
                        [_message removeLastObject];
                        [self.collectionView reloadData];
                        [self.view makeToast:dictResponse[@"msg"]];
                    }
                }
               
            } andFailure:^(NSError * _Nonnull error) {
                NSString *errMsg = [NSString stringWithFormat:@"%@", error.localizedDescription];
                [self performSelector:@selector(showAlert:) withObject:errMsg afterDelay:0.3];
            }];
        }
    }
}

-(void)didDeleteChatMsgNotification:(NSNotification *) notification {
    
    
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
    NSLog(@"didUpdateChatMsgNotification22222%@",userInfo);
    if (!userInfo) return;
    NSArray *chats = userInfo[@"chats"];
    if (![chats isKindOfClass:NSArray.class] || !(chats.count > 0))return;
    NSDictionary *chat = chats.firstObject;
    if (![Helper objectIsNilOrEmpty:chat andKey:@"message"]) {
        self->editTags = chat[@"message"];
    }
    
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
    [self.collectionView reloadData];
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
  

    NSDictionary * dictMessage = [notification userInfo];
    
    if ([dictMessage isKindOfClass:[NSDictionary class]]){
        if (self.strThreadId!= nil && dictMessage[ThreadID] != [NSNull null]) {
            if (![Helper stringIsNilOrEmpty:[self.dictGroupThreadMsgDetails valueForKey:MsgUniqueId]]){
                if (![Helper stringIsNilOrEmpty:[dictMessage valueForKey:@"replyThreadFeatureData"]]){
                    
                    if ([[self.dictGroupThreadMsgDetails valueForKey:MsgUniqueId] isEqual: [dictMessage valueForKeyPath:@"replyThreadFeatureData.baseMsgUniqueId"]]){
                        self->ReplyCount = self->ReplyCount+1;
                        [self updateGroupReplyThreadChatHistory];
                        NSString*strCurrentMsgThreadID = [NSString stringWithFormat:@"%@",[dictMessage valueForKeyPath:@"thread.threadId"]];
                        if ([self.strThreadId isEqualToString:strCurrentMsgThreadID]){
                            NSString*strSendereRTCUserId = [dictMessage valueForKeyPath:@"sender.eRTCUserId"];
                            NSString*strSenderappUserId = [dictMessage valueForKeyPath:@"sender.name"];
                            if ([dictMessage[@"msgType"]isEqualToString:@"text"]) {
                                [self receiveMessageWithSenderId:strSendereRTCUserId andDisplayName:strSenderappUserId andtextMessage:dictMessage[@"message"]msgType:dictMessage[@"msgType"]andDictionary:dictMessage];
                            } else if ([dictMessage[@"msgType"]isEqualToString:@"gify"]) {
                                NSString *filePath = @"";
                                if (![Helper stringIsNilOrEmpty:dictMessage[LocalFilePath]] && [dictMessage[LocalFilePath] length] > 0) {
                                    // if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                                    filePath = dictMessage[LocalFilePath];
                                    // }
                                } else {
                                    filePath = dictMessage[GifyFileName];
                                }
                                [self receiveMessageWithSenderId:strSendereRTCUserId andDisplayName:strSenderappUserId andtextMessage:filePath msgType:dictMessage[@"msgType"]andDictionary:dictMessage];
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
                                            //                                [self.collectionView reloadData];
                                            [self finishReceivingMessageAnimated:YES];
                                            
                                        }];
                                    }
                                }
                            }
                            else if ([dictMessage[MsgType] isEqualToString:@"contact"]) {
                                if (![Helper objectIsNilOrEmpty:dictMessage andKey:ContactType]) {
                                    NSDictionary *dictContact = dictMessage[ContactType];
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
                                    [self receiveMessageWithSenderId:strSendereRTCUserId andDisplayName:strSenderappUserId andtextMessage:dictMessage[LocalFilePath] msgType:dictMessage[@"msgType"]andDictionary:dictMessage];
                                } else {
                                    [self receiveMessageWithSenderId:strSendereRTCUserId andDisplayName:strSenderappUserId andtextMessage:dictMessage[FilePath] msgType:dictMessage[@"msgType"]andDictionary:dictMessage];
                                }
                                
                                // [self loadPhotoMediaMessage:dictMessage];
                            }
                            [[eRTCChatManager sharedChatInstance] updateMessageWithReadStatus:dictMessage];
                        }
                    }
                }
            }
            
        }
            
    }
}
- (void)didReceiveTypingStatusNotification:(NSNotification *) notification{
    NSDictionary *dictTypingData = notification.userInfo;
    NSLog(@"dictTypingData%@",dictTypingData);
    if ([dictTypingData isKindOfClass:[NSDictionary class]]){
        if (self.strThreadId!= nil && dictTypingData[ThreadID] != [NSNull null]) {
            if ([self.strThreadId isEqualToString:dictTypingData[ThreadID]]){
                if ([[dictTypingData valueForKey:@"typingStatusEvent"]isEqualToString:@"on"]) {
                    if (self.showTypingIndicator!=true) {
                        [self setShowTypingIndicator:YES];
                    }
                } else {
                    [self setShowTypingIndicator:NO];
                }
                [self scrollToBottomAnimated:YES];
            }
        }
        
    }
}

-(void)didReceiveMsgStatus:(NSNotification *) notification{
    // NSLog(@"didReceiveMsgStatus--%@",notification.userInfo);
   /* NSDictionary *chatMsg = notification.userInfo;
    if(chatMsg[MsgStatusEvent] != nil) {
        currentMessage.msgStatus = chatMsg[MsgStatusEvent];
    } else {
        currentMessage.msgStatus = @"Delivered";
    }
    [self.collectionView reloadData];*/
    //[self performSelector:@selector(getChatHistory) withObject:nil afterDelay:1];
    NSDictionary *chatMsg = notification.userInfo;
    if([chatMsg valueForKey:MsgStatusEvent]!= nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"msgUniqueId == %@", [chatMsg valueForKey:@"msgUniqueId"]];
        NSArray *aryFilter = [self->_chatHistory filteredArrayUsingPredicate:predicate];
        if (aryFilter.count > 0){
            NSMutableDictionary *dict = [[aryFilter objectAtIndex:0] mutableCopy];
            NSUInteger index = [self->_chatHistory indexOfObject:dict];
            if (index != NSNotFound){
                [dict setValue:[chatMsg valueForKey:@"msgStatusEvent"] forKey:@"msgStatusEvent"];
                [self->_chatHistory replaceObjectAtIndex:index withObject:dict.copy];
            }else{
                NSLog(@"Index Not found");
            }
        }else{
            NSLog(@"MSG Not found");
        }
        
    }
    [self.collectionView reloadData];
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

#pragma mark Reaction
-(void)updateMessageCellAtIndexPath:(NSIndexPath*)path message:(NSDictionary*)details{
    [[eRTCCoreDataManager sharedInstance] getUserReplyThreadChatHistoryWithThreadID:self.strThreadId withParentID:[self.dictGroupThreadMsgDetails valueForKey:MsgUniqueId] andCompletionHandler:^(id ary, NSError *err) {
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
            strMessage = [NSString stringWithFormat:@"Replied to a thread:%@\n%@",dict[Parent_Msg],dict[Message]];
        }else if (![dict[IsDeletedMSG] boolValue] && [dict[@"isEdited"] boolValue]){
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
                                                senderDisplayName:@""
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
                senderDisplayName:@""
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

#pragma mark API
-(void)callAPIForShareCurrentLocation:(JSQLocationMediaItemCompletionBlock)completion {
 
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        NSMutableDictionary*dictParam = [[NSMutableDictionary alloc]init];
        
        if (self.dictGroupinfo[Group_GroupId] != nil && self.dictGroupinfo[Group_GroupId] != [NSNull null]) {
            
            NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
            
            [dictParam setValue:self.strThreadId forKey:ThreadID];
            
            [dictParam setValue:userId forKey:SendereRTCUserId];
            //[dictParam setValue:_message forKey:Message];
//            [dictParam setValue:@"location" forKey:MsgType];
            [dictParam setValue:dictlocation forKey:@"location"];
            [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:ThreadID] forKey:ThreadID];
            [dictParam setObject:@"startThread" forKey:Start_Thread];
            [dictParam setObject:@"0" forKey:ReplyMsgConfigStatus];
            [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:MsgUniqueId] forKey:ParentID];
            [dictParam setObject:self->arrUser forKey:ArParticipants];
            
            [[eRTCChatManager sharedChatInstance] sendLocationMessageWithParam:dictParam andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                
                NSDictionary *dictResponse = (NSDictionary *)json;
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
                            [self.message addObject:locationMessage];
                            self->ReplyCount = self->ReplyCount+1;
                            [self updateGroupReplyThreadChatHistory];
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
                                                                   text:[NSString stringWithFormat:@"%@", [Helper getContactNameString:dictContact]]]; //  \n%@ phoneMobile
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
        if (self.dictGroupinfo[Group_GroupId] != nil && self.dictGroupinfo[Group_GroupId] != [NSNull null]) {
            NSMutableDictionary*dictParam = [[NSMutableDictionary alloc]init];
            
            // Turn off the location manager to save power.
            
            NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
            
            [dictParam setValue:self.strThreadId forKey:ThreadID];
            
            [dictParam setValue:userId forKey:SendereRTCUserId];
            //[dictParam setValue:_message forKey:Message];
//            [dictParam setValue:@"contact" forKey:MsgType];
            [dictParam setValue:contact forKey:@"contact"];
            [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:ThreadID] forKey:ThreadID];
            [dictParam setObject:@"startThread" forKey:Start_Thread];
            [dictParam setObject:@"0" forKey:ReplyMsgConfigStatus];
            [dictParam setObject:[self.dictGroupThreadMsgDetails valueForKey:MsgUniqueId] forKey:ParentID];
            [dictParam setObject:self->arrUser forKey:ArParticipants];;
            
            [[eRTCChatManager sharedChatInstance] sendContactMessageWithParam:dictParam andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                
                NSDictionary *dictResponse = (NSDictionary *)json;
                if (dictResponse[@"success"] != nil) {
                    BOOL success = (BOOL)dictResponse[@"success"];
                    if (success) {
                        NSTimeInterval delayInSeconds = 2.0;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        self->ReplyCount = self->ReplyCount+1;
                        self->currentMessage.msgStatus = @"sent";
                        [self finishSendingMessageAnimated:YES];
                        [self updateGroupReplyThreadChatHistory];
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
               // [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
            }];
        }else {
            [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
        }
    }
}

#pragma mark - custom actions

- (void)hadleLongPressAction:(NSIndexPath *) indexPath {
    NSDictionary *config = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
    [self.inputToolbar.contentView.textView resignFirstResponder];
    NSString * strFavourite = @"Add to favorites";
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
    chatReactions.isThread = YES;
    [chatReactions setMessageType: dictMessage[MsgType]];
    [self presentPanModal:chatReactions];
    return;
    
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
   /* UIAlertAction* startThread = [UIAlertAction
                                  actionWithTitle:@"Start a thread"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action)
                                  {
    }];
    UIAlertAction* more = [UIAlertAction
                           actionWithTitle:@"More..."
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
    }];
    */
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
        //Do some thing here
    }];
    [copy setValue:[[UIImage imageNamed:@"copy"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [copy setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    
    [favourite setValue:[[UIImage imageNamed:@"Vector"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [favourite setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    
//    [startThread setValue:[[UIImage imageNamed:@"Messages"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
//    [startThread setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
//
//    [more setValue:[[UIImage imageNamed:@"Icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
//    [more setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    
    [view addAction:copy];
    [view addAction:favourite];
//    [view addAction:startThread];
//    [view addAction:more];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
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

-(void)isMarkThreadMessageFavouriteWithIndexPath:(UIButton *)sender{
    if ([sender isSelected]) {
        [sender setSelected:NO];
        [sender setImage:[UIImage imageNamed:@"unFav"] forState:UIControlStateNormal];
        
    }else{
        [sender setSelected:YES];
        [sender setImage:[UIImage imageNamed:@"favNew"] forState:UIControlStateNormal];


    }
    NSLog(@"Fav Un Fav");
    NSDictionary * dictMessage = [NSDictionary new];
    if (_chatHistory.count > selectedChatIndexPath.row) {
        dictMessage = [_chatHistory objectAtIndex:selectedChatIndexPath.row];
    }
    [self isMarkFavouriteWithIndexPath:dictMessage favouriteUser:false];
}

-(void)isMarkMainThread:(UIButton *)sender{
    if ([sender isSelected]) {
        [sender setSelected:NO];
       // [sender setBackgroundImage:[UIImage imageNamed:@"checkBG"] forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"unselectCheck"] forState:UIControlStateNormal];

       // [sender setImage:[UIImage imageNamed:@"unFav"] forState:UIControlStateNormal];
        self.strReplyStatus = @"0";
        
    }else{
        [sender setSelected:YES];
        [sender setImage:[UIImage imageNamed:@"checkBG"] forState:UIControlStateNormal];
        //[sender setImage:[UIImage imageNamed:@"favNew"] forState:UIControlStateNormal];
        self.strReplyStatus = @"1";
    }
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
    [self performSelector:@selector(getChatHistory) withObject:nil afterDelay:0.2];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
            
            //  self.inputToolbar.contentView.textView.text = strMsg;
            self.inputToolbar.contentView.textView.attributedText = [self colorHashtag:strMsg];
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

-(NSAttributedString*)colorHashtag:(NSString*)message
{
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:message];
    NSString *str = message;
    NSError *error = nil;
    NSRegularExpression *regex;
    NSArray *matches;
    regex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)(\\s+)(\\w+)(\\s+)(\\w+)|@(\\w+)(\\s+) |@(\\w+)(\\s+)(\\w+)|@channel|@here" options:0 error:&error];
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



-(void)textViewDidChange:(UITextView *)textView {
    BOOL shouldEnableDomainFilter = NO;
    BOOL shouldDisableProfanityFilter = NO;
    
    NSDictionary *dictConfig = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
   // NSLog(@"dictConfig>>>>>>>>>>>%@",dictConfig);
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
               // [self.inputToolbar.contentView.rightBarButtonItem setHidden:YES];
            }else {
              //  [self.inputToolbar.contentView.rightBarButtonItem setHidden:NO];
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
        self.inputToolbar.contentView.textView.attributedText = [Helper getAttributedString:[self colorHashtag:textView.text] font:[UIFont fontWithName:@"SFProDisplay-Regular" size:18]];
//        self.inputToolbar.contentView.textView.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:17];
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
    self.inputToolbar.contentView.textView.attributedText = [Helper getAttributedString:[self colorHashtag:textView.text]
                                                                                   font:[UIFont fontWithName:@"SFProDisplay-Regular" size:18]];
}

-(void)showMentionUserList:(NSString*)strText{
  //  self.tblMention = [[UITableView alloc] init];
    if ([strText isEqualToString:@" "] || !self.isUserSearchActive) {
        return;
    }
    self.searchText = strText;
    dispatch_async(dispatch_get_main_queue(), ^{
       // self.aryWhole = @[@"One", @"Two", @"Three", @"Four", @"Five"];
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
        [self.view addSubview:self.tblMention];
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
    
    if (self.keyboardheight == 260 && self.numbersArrayList.count > 5){
        tblHeight = screenHeight - self.keyboardheight - 64;
    }
       CGFloat tblY = screenHeight - tblHeight - self.inputToolbar.contentView.frame.size.height - self.keyboardheight;
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

- (void)keyboardWasShown:(NSNotification *)notification {
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
    //your other code here..........
}

- (void)keyboardWasHide:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"KeyboardHDown");
        self.keyboardheight = 0;
        [self setMentiontblHeight];
    });
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

        }case Follow:{
            [self followUnFollowMsg];
            break;
        }case Report: {
            NSLog(@"[selectedChatIndexPath.row]>>>>>>>>>>%d",selectedChatIndexPath.row);
            ReportsMessageViewController * _vcMessage = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"ReportsMessageViewController"];
            _vcMessage.dictMessage = _chatHistory[selectedChatIndexPath.row];
            [self.navigationController pushViewController:_vcMessage animated:YES];
            NSLog(@"[selectedChatIndexPath.row]>>>>>>>>>>%@",_chatHistory[selectedChatIndexPath.row]);
            break;
        }
    }
}

- (void)followUnFollowMsg {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
    NSDictionary * dictMessage = [NSDictionary new];
    if (_chatHistory.count > selectedChatIndexPath.row) {
        dictMessage = [_chatHistory objectAtIndex:selectedChatIndexPath.row];
    }
    NSMutableDictionary * dictMsgFollowUnfollow = [NSMutableDictionary new];
    if (dictMessage[Follow_Message] != NULL && [dictMessage[Follow_Message]  isEqual: @1]){
        [dictMsgFollowUnfollow setValue:@false forKey:@"follow"];
    }else{
        [dictMsgFollowUnfollow setValue:@true forKey:@"follow"];
    }
    [dictMsgFollowUnfollow setValue:dictMessage[Message] forKey:@"message"];
    [dictMsgFollowUnfollow setValue:dictMessage[ThreadID] forKey:ThreadID];
    [dictMsgFollowUnfollow setValue:dictMessage[MsgUniqueId] forKey:MsgUniqueId];
    [dictMsgFollowUnfollow setValue:@"true" forKey:@"isStarred"];
        
        
    [[eRTCChatManager sharedChatInstance] followUnFollowThreadChatMessage:dictMsgFollowUnfollow andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        NSDictionary *dictResponse = (NSDictionary *)json;
        if (dictResponse[@"success"] != nil) {
            BOOL success = (BOOL)dictResponse[@"success"];
            if (success) {
                if (dictMessage[Follow_Message] != NULL && [dictMessage[Follow_Message]  isEqual: @1]){
                    [self.view makeToast:ThreadUnFollowMessage];
                }else{
                    [self.view makeToast:FollowThreadMessage];
                }
                [self getChatHistory];
                [KVNProgress dismiss];
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

- (void)deleteMessage:(NSString *)type {
    NSLog(@"Thread Group Delete %@ type", type);
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
                       NSDictionary *msg = [[eRTCCoreDataManager sharedInstance] getThreadMessageByUniqueID:mQid];
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
        NSMutableArray *arrdata = nil;
        arrdata = self.message;
        
        NSDictionary * dictMessage = [NSDictionary new];
        if (_chatHistory.count > indexPath.row) {
            dictMessage = [_chatHistory objectAtIndex:indexPath.row];
        }
        
        
        NSMutableDictionary *dictParam = [NSMutableDictionary new];
        [dictParam setValue:[NSString stringWithFormat:@"%@", [dictMessage valueForKey:@"msgUniqueId"]] forKey:@"msgUniqueId"];
        [dictParam setValue:message forKey:@"emojiCode"];
        [dictParam setValue:@"set" forKey:@"action"];
//        NSDictionary *myDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"Test123", @"abc", nil];
//        NSData *data1 = [NSJSONSerialization dataWithJSONObject:myDictionary options:NSJSONWritingPrettyPrinted error:nil];
//        NSString *jsonString = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
//        [dictParam setObject:jsonString forKey:customData];
        
        [[eRTCChatManager sharedChatInstance] sendReactionOnThreadWithParam:dictParam andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            if([json isKindOfClass:[NSDictionary class]]) {
                if (![Helper stringIsNilOrEmpty:json[@"success"]]) {
                    NSString *strSuccess = [NSString stringWithFormat:@"%@", json[@"success"]];
                    if ([strSuccess intValue] == 0) {
                        if (![Helper stringIsNilOrEmpty:json[Key_Message]]) {
                            [Helper showAlertOnController:@"eRTC" withMessage:json[Key_Message] onController:self];
                        }
                    }
                     [self updateMessageCellAtIndexPath:indexPath message:dictMessage];
                }
            }
        } andFailure:^(NSError * _Nonnull error) {
            NSLog(@"Error -->%@", error);
            NSString *errMsg = [NSString stringWithFormat:@"%@", error.localizedDescription];
            [self performSelector:@selector(showAlert:) withObject:errMsg afterDelay:0.3];
        }];
        
//        [[eRTCChatManager sharedChatInstance] sendTextReactionWithParam:[NSString stringWithFormat:@"%@", [dictMessage valueForKey:@"msgUniqueId"]] andEmojiCode:message andEmojiAction:@"set" andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
//            NSLog(@"JSON -->%@", json);
//            [self getChatHistory];
//            [self.collectionView reloadData];
//        } andFailure:^(NSError * _Nonnull error) {
//            NSLog(@"Error -->%@", error);
//        }];
    }
}

- (void)sendMesage:(NSString *)message selectedindexPath:(NSIndexPath *)indexpath {
    
    NSMutableArray *arrdata = nil;
    arrdata = self.message;
    
    NSDictionary * dictMessage = [NSDictionary new];
    if (_chatHistory.count > indexpath.row) {
        dictMessage = [_chatHistory objectAtIndex:indexpath.row];
    }
    
    NSMutableDictionary *dictParam = [NSMutableDictionary new];
    [dictParam setValue:[NSString stringWithFormat:@"%@", [dictMessage valueForKey:@"msgUniqueId"]] forKey:@"msgUniqueId"];
    [dictParam setValue:message forKey:@"emojiCode"];
    [dictParam setValue:@"set" forKey:@"action"];
//    NSDictionary *myDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"Test123", @"abc", nil];
//    NSData *data1 = [NSJSONSerialization dataWithJSONObject:myDictionary options:NSJSONWritingPrettyPrinted error:nil];
//    NSString *jsonString = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
//    [dictParam setObject:jsonString forKey:customData];
        [[eRTCChatManager sharedChatInstance] sendReactionOnThreadWithParam:dictParam andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
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
    } andFailure:^(NSError * _Nonnull error) {
        NSLog(@"Error -->%@", error);
        NSString *errMsg = [NSString stringWithFormat:@"%@", error.localizedDescription];
        [self performSelector:@selector(showAlert:) withObject:errMsg afterDelay:0.3];
    }];
}

- (void)sendEmoji:(NSString *)string selectedIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableArray *arrdata = nil;
    arrdata = self.message;
    
    NSDictionary * dictMessage = [NSDictionary new];
    if (_chatHistory.count > indexPath.row) {
        dictMessage = [_chatHistory objectAtIndex:indexPath.row];
    }
    NSMutableDictionary *dictParam = [NSMutableDictionary new];
    [dictParam setValue:[NSString stringWithFormat:@"%@", [dictMessage valueForKey:@"msgUniqueId"]] forKey:@"msgUniqueId"];
    [dictParam setValue:string forKey:@"emojiCode"];
    [dictParam setValue:@"clear" forKey:@"action"];
    
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
//        NSDictionary *myDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"Test123", @"abc", nil];
//        NSData *data1 = [NSJSONSerialization dataWithJSONObject:myDictionary options:NSJSONWritingPrettyPrinted error:nil];
//        NSString *jsonString = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
//        [dictParam setObject:jsonString forKey:customData];
       [[eRTCChatManager sharedChatInstance] sendReactionOnThreadWithParam:dictParam andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            [self updateMessageCellAtIndexPath:indexPath message:dictMessage];
        } andFailure:^(NSError * _Nonnull error) {
            NSLog(@"Error -->%@", error);
            NSString *errMsg = [NSString stringWithFormat:@"%@", error.localizedDescription];
            [self performSelector:@selector(showAlert:) withObject:errMsg afterDelay:0.3];
        }];
    }else {
        [self sendMesage:string selectedindexPath:indexPath];
    }

}

- (void)showUserWhoReacted:(NSString *)emojiString selectedIndexPath:(NSIndexPath *)indexPath {
        NSDictionary * dictMessage = [NSDictionary new];
        if (_chatHistory.count > indexPath.row) {
            dictMessage = [_chatHistory objectAtIndex:indexPath.row];
        }
        
        [[eRTCChatManager sharedChatInstance] getThreadReationUserListWithMsgId:[NSString stringWithFormat:@"%@", [dictMessage valueForKey:@"msgUniqueId"]] andEmojiCode:emojiString andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
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


-(void)didchatReportSuccess:(NSNotification *) notification{
    [self.navigationController.view addSubview:reportView];
    [self getChatHistory];
    NSTimeInterval delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [reportView removeFromSuperview];
    });
}

- (void)followUnFollowMsg:(NSDictionary*)dictMessage {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
        
    NSMutableDictionary * dictMsgFollowUnfollow = [NSMutableDictionary new];
    if (dictMessage[Follow_Message] != NULL && [dictMessage[Follow_Message]  isEqual: @1]){
        [dictMsgFollowUnfollow setValue:@false forKey:@"follow"];
    }else{
        [dictMsgFollowUnfollow setValue:@true forKey:@"follow"];
    }
    [dictMsgFollowUnfollow setValue:dictMessage[Message] forKey:@"message"];
    [dictMsgFollowUnfollow setValue:dictMessage[ThreadID] forKey:ThreadID];
    [dictMsgFollowUnfollow setValue:dictMessage[MsgUniqueId] forKey:MsgUniqueId];
    [dictMsgFollowUnfollow setValue:@"true" forKey:@"isStarred"];

    [[eRTCChatManager sharedChatInstance] followUnFollowChatMessage:dictMsgFollowUnfollow andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        NSDictionary *dictResponse = (NSDictionary *)json;
        if (dictResponse[@"success"] != nil) {
            BOOL success = (BOOL)dictResponse[@"success"];
            if (success) {
                [KVNProgress dismiss];
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

-(void)selectedUndoButton:(UITableViewCell *)cell {
    
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        
        [KVNProgress show];
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        
        NSMutableDictionary * dictMessage = [NSMutableDictionary new];
        dictMessage = [_chatHistory objectAtIndex:indexPath.row];
        NSString *chatReportId = dictMessage[Chat_ReportId];
        
        [[eRTCChatManager sharedChatInstance] undoChatReport:@{@"chatReportId": chatReportId} andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
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


/*
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
}*/


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
            self->isRemovedChannel = true;
        });
        self.inputToolbar.hidden = true;
    }else{
        [self unblockUI];
        [removeView removeFromSuperview];
        self.inputToolbar.hidden = false;
        self->isRemovedChannel = false;
    }
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
                [self Frozen_Channel:isFrozenChannel];
            }else if ([eventObj[@"eventType"] isEqualToString:@"deactivated"]) {
                [self showDeactivated:true];
                [self.view endEditing:YES];
                self->isGroupActivated = true;
            }else if ([eventObj[@"eventType"] isEqualToString:@"activated"]) {
                [deactivatedView removeFromSuperview];
                [self showDeactivated:false];
                [self.view endEditing:YES];
                self->isGroupActivated = false;
            }

        }
        if ([eventObj[@"eventType"] isEqualToString:@"deleted"]) {
            [self removeChannel:true];
            [self showUserBlock:true];
            [self showBlockUI];
        }
    }
}

-(void)Frozen_Channel:(BOOL *)isFrozenChannel {
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
            [self.navigationController.view addSubview:self->frozenView];
        });
        self.inputToolbar.hidden = true;
    }else{
        [frozenView removeFromSuperview];
        self.inputToolbar.hidden = false;
    }
}


-(void)showUserBlock:(BOOL *)blockUnBlock {
    if (blockUnBlock) {
        [self.inputToolbar.contentView.rightBarButtonItem setHidden:YES];
        [self.inputToolbar.contentView.leftBarButtonItem setHidden:YES];
        self.inputToolbar.userInteractionEnabled = FALSE;
        [self.view layoutIfNeeded];
        NSTimeInterval delayInSeconds = 0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self->bottemView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-110, self.view.bounds.size.width, 110)];
        [self->bottemView setBackgroundColor:UIColor.whiteColor];
           [self.view addSubview:self->bottemView];
        });
    }else{
        [self.inputToolbar.contentView.rightBarButtonItem setHidden:NO];
        [self.inputToolbar.contentView.leftBarButtonItem setHidden:NO];
        self.inputToolbar.userInteractionEnabled = true;
        [bottemView removeFromSuperview];
    }
}

-(void)showDeactivated:(BOOL *)isDeactivated {
    if (isDeactivated) {
        NSTimeInterval delayInSeconds = 0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self->deactivatedView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-70, self.view.bounds.size.width, 200)];
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

@end
