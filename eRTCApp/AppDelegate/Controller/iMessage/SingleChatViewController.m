//
//  SingleChatViewController.m
//  eRTC
//
//  Created by rakesh  palotra on 28/03/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#import "SingleChatViewController.h"
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
#import "ThreadChatViewController.h"
#import "chatReplyCount.h"
#import "ChatReactions.h"
#import <HWPanModal/HWPanModal.h>
#import "FavViewCell.h"
#import "LocationManager.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
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
#import "PreferencesVC.h"
#import "GoogleDriveCell.h"
#import "JiraBotCollectionCell.h"



//#import "Helper.h"

//#import "eRTCApp-Swift.h"

#import "JSQGIFMediaItem.h"
@import GiphyUISDK;
@import GiphyCoreSDK;

typedef void (^LoadPreviouseMessageCompletion)(void);
@interface NSData (Download)

+ (void) ertc_dataWithContentsOfStringURL:(nullable NSString *)strURL onCompletionHandler:(void (^)(NSData * _Nullable data)) onCompletionHandler ;

@end

@implementation NSData (Download)

+ (void) ertc_dataWithContentsOfStringURL:(nullable NSString *)strURL onCompletionHandler:(void (^)(NSData  * _Nullable data)) onCompletionHandler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        __block NSData *dataDownloaded = [NSData new];
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
@interface SingleChatViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIViewControllerPreviewingDelegate,MPMediaPickerControllerDelegate, JSQAudioRecorderViewDelegate,CLLocationManagerDelegate,CNContactViewControllerDelegate,CNContactPickerDelegate, UIGestureRecognizerDelegate,GiphyDelegate,UIDocumentPickerDelegate,UIDocumentInteractionControllerDelegate,ChatReactionsDelegateDelegate, EmojisViewControllerDelegate, ChatReplyCountDelegate, JSQAudioMediaItemDelegate, AudioClickable, ObserverRemovable, ChatUndoMsgDelegate> {
    
    // Typing Indicator
    NSTimer * typingTimer;
    BOOL  isTypingActive;
    BOOL  isBlockUI;
    JSQMessage *currentMessage;
    CLLocationManager *locationManager;
    CLGeocoder *geoCoder;
    CLPlacemark *placeMark;
    NSString*address;
    NSNumber *userLat,*userLong;
    NSDictionary *dictDomainProfinityFilter;
    NSMutableDictionary*dictlocation;
    NSMutableDictionary*dictContact;
    NSMutableArray *_chatHistory;
    NSMutableArray *arrMentionUser;
    NSMutableArray *arrMentionEmail;
    NSIndexPath *selectedChatIndexPath;
    JSQAudioMediaItem *currentAudioMediaItem;
    //    UIView *titleHeaderView;
    //    UILabel *lblHeader;
    LocationManager *locManager;
    UILabel *blockUnblockLabel;
    NSMutableDictionary *editingMessage;
    UIView *editMessageView;
    UIView *headerView;
    UIView *reportView;
    UIView *bottemView;
    UIButton *rightButton;
    NSDictionary *thread;
    UIRefreshControl *refreshControl;
    UILabel *lblHeader;
    UILabel *statusLabel;
    UIView *profenityView;
    NSString *blockUnblockUser;
    NSIndexPath *selectedPath;
    BOOL  isSearchMessage;
    BOOL  isProfanity;
    BOOL  isSelectedMentionUser;
    NSString *mentionsUser;
    NSString *mentionUserEmail;
    NSNumber *isDomainFilt;
}
@property (strong, nonatomic) NSSet *userNames;
@property(nonatomic, strong) JSQAudioRecorderView *audioRecorderView;
@property(nonatomic, strong) NSMutableArray *message;
@property (strong, nonatomic) NSArray *imgURL;
@property (strong, nonatomic) NSSet *userDomain;

@property (strong, nonatomic) NSMutableArray *numbersArrayList;
@property (strong, nonatomic) NSMutableArray *aryMentioned;
@property (assign) int keyboardheight;
@property (strong, nonatomic) NSMutableArray *aryWhole;
@property (assign) BOOL isScrollToBottom;

//@property(nonatomic, strong) UIView *titleHeaderView;
//@property(nonatomic, strong) UILabel *lblHeader;

@end

@implementation SingleChatViewController
@synthesize playerViewController;

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
    //Do any additional setup after loading the view.
    
    //self.collectionView.registerNib(UINib(nibName: "CellWithConfimationButtons", bundle: nil), forCellWithReuseIdentifier: "incomingCell")
    [self.collectionView registerNib:[UINib nibWithNibName:@"JSQReportCell" bundle:nil] forCellWithReuseIdentifier:@"JSQReportCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JiraBotCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"JiraBotCollectionCell"];
    self.isScrollToBottom = YES;
    self.isUserSearchActive = false;
    [self.tblMention setHidden:YES];
    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.numbersArrayList  = @[@"One", @"Two", @"Three", @"Four", @"Five", @"Six"];
    self.keyboardheight = 0;
    [AppDelegate sharedAppDelegate].isUpdateChatHistory = NO;
    [self showUserIconAndNameOnNavigationTitle];
    self->isSelectedMentionUser = NO;
    [self configureChatWindow];
    _message = [[NSMutableArray alloc] init];
    
    arrMentionUser = [NSMutableArray new];
    arrMentionEmail = [NSMutableArray new];
    _aryMentioned = [NSMutableArray new];
    
    NSString *strAppUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
    NSString *strUserName = [[UserModel sharedInstance] getUserDetailsUsingKey:User_Name];
    self.senderId = strAppUserId;
    
    if (strUserName !=nil) {
        self.senderDisplayName = strUserName;
    }else{
        self.senderDisplayName = @"";
    }
    
    [self generateThreadId];
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
    UIImage* imgDot = [UIImage imageNamed:@"Horiz"];
    CGRect frameimg = CGRectMake(15,5, 25,25);
    UIButton *btnDoted = [[UIButton alloc] initWithFrame:frameimg];
    [btnDoted setBackgroundImage:imgDot forState:UIControlStateNormal];
    [btnDoted addTarget:self action:@selector(btnMoreOptions:)
       forControlEvents:UIControlEventTouchUpInside];
    [btnDoted setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem *btnDotMore =[[UIBarButtonItem alloc] initWithCustomView:btnDoted];
    self.navigationItem.rightBarButtonItem = btnDotMore;
    // [btnDoted release];
    [self.inputToolbar addSubview:self->bottemView];
    //[self showDisappearing:true];
    
    NSTimeInterval reportSeconds = 1.0;
    dispatch_time_t reportpopTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(reportSeconds * NSEC_PER_SEC));
    dispatch_after(reportpopTime, dispatch_get_main_queue(), ^(void){
        [self headerShowMessage];
    });
    [self callApiGetChatSetting];
    
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
    } else {
        // Fallback on earlier versions
    }
    [UIView setAnimationsEnabled:NO];
    self.inputToolbar.contentView.textView.linkTextAttributes = @{
        NSParagraphStyleAttributeName:[UIColor systemBlueColor],
        NSStrikethroughColorAttributeName:@(NSUnderlineStyleSingle)
    };
    
    [self showProfanityFilter]; //add Profanity filter on input Toolbar
    [self addDomanFilterOnInputToolbar]; //add Domain filter on input Toolbar
    
    [self setShowProfanityFilter:false]; // Show profanity filter view inputtoolbar
    [self setDomainFilter:false]; //// Show Domain filter view inputtoolbar
    
    
    UIDevice *device = [UIDevice currentDevice];
    NSString  *currentDeviceId = [[device identifierForVendor]UUIDString];
    
  
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

- (void)jsq_setCollectionViewInsetsTopValue:(CGFloat)top bottomValue:(CGFloat)bottom
{
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0.0f, bottom+15, 0.0f);
    self.collectionView.contentInset = insets;
    self.collectionView.scrollIndicatorInsets = insets;
}

-(void)geoLocation
{
    geoCoder = [[CLGeocoder alloc] init];
    /*
     if (locationManager == nil)
     {
     locationManager = [[CLLocationManager alloc] init];
     locationManager.desiredAccuracy = kCLLocationAccuracyBest;
     locationManager.delegate = self;
     [locationManager requestAlwaysAuthorization];
     }
     [locationManager startUpdatingLocation];
     */
}

-(void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMsgNotification:)
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
                                             selector:@selector(didchatStarFavourite:)
                                                 name:DidReceveEventStarFavouriteMessage
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didupdateStatus:)
                                                 name:DidUpdateUserBlockStatusNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didgetchatSetting:)
                                                 name:DidGetChatSettingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateProfileAndStatus:)
                                                 name:DidupdateProfileAndStatus
                                               object:nil];
    
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"blockUnblockUser" object:@{@"blockUnblock": blockUnblock}];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"blockUnblockUser" object:NULL queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        if (note.object != NULL && [note.object isKindOfClass:NSDictionary.class]){
            NSMutableDictionary *_dic = self->_dictUserDetails.mutableCopy;
            if ([note.object[@"blockUnblock"] isEqualToString:@"block"]){
                _dic[BlockedStatus] = @"blocked";
                self->_dictUserDetails = _dic;
                [self showBlockUI];
            }else if ([note.object[@"blockUnblock"] isEqualToString:@"unblock"]){
                _dic[BlockedStatus] = @"unblocked";
                self->_dictUserDetails = _dic;
                [self unblockUI];
            }
            [self->_tblMention reloadData];
        }
    }];
    
}

- (void)didupdateStatus:(NSNotification *) notification{
    
    NSDictionary *dictData = notification.object;
    if (dictData[@"eventData"] != nil && dictData[@"eventData"] != [NSNull null]) {
        NSDictionary *eventData = dictData[@"eventData"];
        NSMutableDictionary *_dic = self->_dictUserDetails.mutableCopy;
        if([eventData[@"blockedStatus"] isEqualToString:@"blocked"]) {
            _dic[BlockedStatus] = @"blocked";
            self->_dictUserDetails = _dic;
            [self showBlockUI];
        }else{
            _dic[BlockedStatus] = @"unblocked";
            self->_dictUserDetails = _dic;
            [self unblockUI];
        }
    }
    
}

-(void)showBlockUI{
    isBlockUI = true;
    self.inputToolbar.userInteractionEnabled = FALSE;
    if (!blockUnblockLabel){
        [self showUserBlock:true];
    }
    [self.inputToolbar.contentView.rightBarButtonItem setHidden:YES];
    [self.inputToolbar.contentView.leftBarButtonItem setHidden:YES];
    [self.view layoutIfNeeded];
}

-(void)unblockUI{
    isBlockUI = false;
    self.inputToolbar.userInteractionEnabled = TRUE;
    [self showUserBlock:false];
    [self.inputToolbar.contentView.rightBarButtonItem setHidden:false];
    [self.inputToolbar.contentView.leftBarButtonItem setHidden:false];
}

-(void)viewWillLayoutSubviews{
    blockUnblockLabel.frame = self.inputToolbar.contentView.bounds;
}


-(void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:DidRecievedMessageNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:DidRecievedTypingStatusNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:DidRecievedMessageReadStatusNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:UpdatChatWindowNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:DidRecievedReactionNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:DidUpdateChatNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:DidDeleteChatMessageNotification];
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated {
    //    [super viewWillAppear:animated];
    if ([[AppDelegate sharedAppDelegate] isUpdateChatHistory]) {
        [AppDelegate sharedAppDelegate].isUpdateChatHistory = NO;
        [self refreshChatData];
    }
    // self.inputToolbar.contentView.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : UIColor.redColor };
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (currentAudioMediaItem != nil) {
        [currentAudioMediaItem pause];
    }
    // JSQAudioMediaItem *audioItem = [[JSQAudioMediaItem alloc] init];
    // [audioItem stopAudio];
    // [[NSNotificationCenter defaultCenter] removeObserver:self name:DidRecievedMessageNotification object:nil];
    //[self removeObservers];
    
}
-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [headerView removeFromSuperview];
    // [[NSNotificationCenter defaultCenter] removeObserver:DidRecievedMessageNotification];
}




-(void)refershControlAction {
    NSLog(@"[refershControlAction]");
    NSMutableDictionary *details = @{}.mutableCopy;
    details[@"pageSize"] = @20;
    if (_chatHistory != NULL && _chatHistory.count > 0 && _chatHistory.firstObject[MsgUniqueId] != NULL){
        details[@"currentMsgId"] = _chatHistory.firstObject[MsgUniqueId] ;
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

-(void) dealloc {
    [self removeObservers];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)updateProfileAndStatus:(NSNotification *) notification{
    NSDictionary *dictData = notification.object;
    self->_dictUserDetails = dictData.copy;
    [self showUserIconAndNameOnNavigationTitle];
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
                self->thread = dictResult;
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

- (CGSize)collectionView:(JSQMessagesCollectionView *)collectionView
                  layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = self.message[indexPath.row];
    CGSize size = [collectionViewLayout sizeForItemAtIndexPath:indexPath];
    NSDictionary *msgObject;
    if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row ){
        msgObject = [_chatHistory objectAtIndex:indexPath.row];
    }
    
    if ([message.media isKindOfClass:JSQLinkPreviewMediaItem.class]){
        JSQLinkPreviewMediaItem *item = (JSQLinkPreviewMediaItem*)message.media;
        size.height = [item mediaViewDisplaySize].height;
        // }
        if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row) {
            NSDictionary *dicMessage = [_chatHistory objectAtIndex:indexPath.row];
            if ([dicMessage valueForKey:@"reaction"] != nil && [dicMessage valueForKey:@"reaction"] != [NSNull null] ) {
                CGFloat height = [self convertDataToEmoji:[dicMessage valueForKey:@"reaction"]];
                size.height  +=  height;
            }
        }
    }
    if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row ){
        msgObject = [_chatHistory objectAtIndex:indexPath.row];
    }
    
    if ([msgObject valueForKey:@"isReported"] != nil && [msgObject valueForKey:@"isReported"] != [NSNull null] ) {
        if ([msgObject[MsgType] isEqualToString:@"text"]){
            size = CGSizeMake(self.view.frame.size.width, 140);
        }else{
            size = CGSizeMake(self.view.frame.size.width, 140);
        }
    }
    
    if ([msgObject[IsEdited] isEqual:@1] && [msgObject[IsForwarded] isEqual:@1]){
        size.height  += 25;
    }else if ([msgObject[IsEdited] isEqual:@1] && [msgObject[ReplyMsgConfig] boolValue] == true) {
        size.height  += 15;
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

- (void)loadPreviousMessages:(NSMutableDictionary *)details completion:(LoadPreviouseMessageCompletion) completion {
    [[eRTCChatManager sharedChatInstance] loadPreviousChatHistoryWithThreadID:thread[ThreadID] parameters:details.copy
                                                                andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        
        [[eRTCCoreDataManager sharedInstance] getUserChatHistoryWithThreadID:self.strThreadId andCompletionHandler:^(NSArray* ary, NSError *err) {
            
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"msgType.length > 0"];
            NSArray *sortedArray=[ary sortedArrayUsingDescriptors:@[sort]];
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

-(void)showDisappering:(BOOL *)isOfflineMessage {
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
                    NSLog(@"details>>>>>>>>>>>>>>>>%@",details);
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
                double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
                NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
                NSString *strMessage = @"";
                if ([dict[@"replyMsgConfig"] boolValue]){
                    NSString *parentMsg = dict[Parent_Msg];
                    if ([parentMsg length] > 35) {
                        NSRange range = [parentMsg rangeOfComposedCharacterSequencesForRange:(NSRange){0, 35}];
                        parentMsg = [parentMsg substringWithRange:range];
                        parentMsg = [parentMsg stringByAppendingString:@"…"];
                    }
                    strMessage = [NSString stringWithFormat:@"Replied to a thread:%@\n%@",parentMsg,dict[Message]];
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
            //            [self scrollToBottomAnimated:YES];
            /*if (self.isScrollToBottom == YES){
             [self scrollToBottomAnimated:YES];
             }else{
             self.isScrollToBottom = YES;
             }*/
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
                double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
                NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
                NSString *strMessage = @"";
                if ([dict[@"replyMsgConfig"] boolValue]){
                    NSString *parentMsg = dict[Parent_Msg];
                    if ([parentMsg length] > 35) {
                        NSRange range = [parentMsg rangeOfComposedCharacterSequencesForRange:(NSRange){0, 35}];
                        parentMsg = [parentMsg substringWithRange:range];
                        parentMsg = [parentMsg stringByAppendingString:@"…"];
                    }
                    strMessage = [NSString stringWithFormat:@"Replied to a thread:%@\n%@",parentMsg,dict[Message]];
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
            
            if (newMessage != nil) {
                [self.message addObject:newMessage];
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
        self->isSearchMessage = false;
        
        if (self.searchMessage[MsgUniqueId] != nil && self.searchMessage[MsgUniqueId] != [NSNull null]) {
            for (int i = 0; i < [self->_chatHistory count]; i++)
            {
                NSMutableDictionary * dictSelectMessage = [NSMutableDictionary new];
                dictSelectMessage = [self->_chatHistory objectAtIndex:i];
                
                NSString *strMsgUniqId  = [NSString stringWithFormat:@"%@",_searchMessage[MsgUniqueId]];
                //self->_searchMessage[MsgUniqueId];
                NSString *strMatchIdMsg  = [NSString stringWithFormat:@"%@",dictSelectMessage[MsgUniqueId]];
                
                if ([strMatchIdMsg isEqualToString:strMsgUniqId]) {
                    self->selectedPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [self.collectionView reloadData];
                    NSTimeInterval delayInSeconds = 1.0;
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

- (void) showUserIconAndNameOnNavigationTitle {
    self.navigationController.navigationBar.topItem.title=@"";
    UIView *titleHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 60)];
    UIImage *img = [UIImage imageNamed:@"DefaultUserIcon"];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,4, 35, 35)];
    // imgView.center = titleHeaderView.center
    [imgView setImage:img];
    [imgView setContentMode:UIViewContentModeScaleAspectFill];
    imgView.layer.cornerRadius= imgView.frame.size.height/2;
    imgView.layer.masksToBounds = YES;
    [titleHeaderView setBackgroundColor:[UIColor whiteColor]];
    if (self.dictUserDetails.count > 0) {
        if (self.dictUserDetails[User_ProfilePic_Thumb] != nil && self.dictUserDetails[User_ProfilePic_Thumb] != [NSNull null]) {
            NSString *imageURL = [NSString stringWithFormat:@"%@",self.dictUserDetails[User_ProfilePic_Thumb]];
            [imgView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
        }
    }
    
    lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x+40, 12, 110, 20)];
    if (self.dictUserDetails[User_Name] != nil) {
        lblHeader.text = self.dictUserDetails[User_Name];
    }
    lblHeader.font = [UIFont fontWithName:@"SFProDisplay-Semibold" size:18];
    lblHeader.textAlignment = NSTextAlignmentLeft;
    //    [titleHeaderView addSubview:imgView];
    //    [titleHeaderView addSubview:lblHeader];
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
    self.navigationItem.titleView =  sv;
    
    ///UIStackView(arrangedSubviews: [imageView, titleLbl]);
    //    UIButton *btn = [[UIButton alloc] initWithFrame:sv.frame];
    //    [btn addTarget:self action:@selector(btnProfileImageTapped:) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(btnProfileImageTapped:)];
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
    // self.showTypingIndicator = NO;
    
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
    CGFloat  cornerRadius = 18.0;
    self.inputToolbar.contentView.textView.textContainerInset = UIEdgeInsetsMake(8, cornerRadius/2, 0, 0);
    self.inputToolbar.contentView.textView.frame = frame;
    
    self.inputToolbar.contentView.textView.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:18];
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
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    
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
    
    if (self.dictUserDetails[BlockedStatus] != nil) {
        if ([self.dictUserDetails[BlockedStatus]isEqualToString:@"blocked"]) {
            [self showBlockUI];
            blockUnblockUser = @"unblock";
        }else {
            [self unblockUI];
            blockUnblockUser = @"block";
        }
    }
}

- (IBAction)btnProfileImageTapped:(id)sender {
    ProfileViewController * _vcProfile = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    _vcProfile.isSingleChat = true;
    _vcProfile.dictUserDetails = _dictUserDetails;
    _vcProfile.strThreadId = self.strThreadId;
    [self.navigationController pushViewController:_vcProfile animated:YES];
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

-(void)showCollectionView:(BOOL)isHidden{
    [self.collectionView setHidden:isHidden];
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
            //            [[LocationManager sharedInstance] addCompletion:^(CLLocation * _Nonnull location, NSError * _Nonnull error) {
            //                NSLog(@"looooasdasd");
            //            }];
            //            [self callAPIForShareCurrentLocation:^{
            //                  [self finishSendingMessageAnimated:YES];
            //
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
        if ( [mediaType isEqualToString:@"public.image"]){
            UIImage *selectedImage = info[UIImagePickerControllerEditedImage];
            UIImage *imageReduced = [self reduceImageSize:selectedImage];
            NSData *imageData1 = [[NSData alloc] initWithData:UIImageJPEGRepresentation(selectedImage, 0.5)];
            int imageSize = imageData1.length;
            NSLog(@"SIZE OF IMAGE: %0.2f Mb", ((float)imageSize/1024/1024));
            if ((((float)imageSize/1024/1024)) > 25.0)  {
                [self.view makeToast:messageLargeImageFile];
            }else{
                [self addPhotoMediaMessage:imageReduced];
            }
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
                
                NSString *displayFileSize = [NSByteCountFormatter stringFromByteCount:fileSize
                                                                           countStyle:NSByteCountFormatterCountStyleFile];
                
                
                NSLog(@"fileSize OF VIDEO: %@ Mb", displayFileSize);
                
                if (videsize > 25.0)  {
                    [self.view makeToast:messageLargeVideoFile];
                }else{
                    [self addVideoMediaMessage:url];
                }
            }
        }
        else if ( [mediaType isEqualToString:@"public.audio"])
        {
            NSLog(@"Picked a audio  URL %@",  [info objectForKey:UIImagePickerControllerMediaURL]);
            NSURL *url =  [info objectForKey:UIImagePickerControllerMediaURL];
            NSLog(@"SingleChatViewController ->  imagePickerController -> audio -> %@",[url absoluteString]);
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
        [_message addObject:message];
        [self sendTextMessage:strdata];
        [self finishSendingMessageAnimated:YES];
    }
    //[_message addObject:[JSQMessage messageWithSenderId:senderId displayName:senderDisplayName text:text]];
    //[[super collectionView] reloadData];
    self->isSelectedMentionUser = NO;
    self->mentionsUser = @"";
    self->mentionUserEmail = @"";
    arrMentionEmail = [NSMutableArray new];
    arrMentionUser = [NSMutableArray new];
}

-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesBubbleImageFactory *bubble = [[JSQMessagesBubbleImageFactory alloc] initWithBubbleImage:[UIImage jsq_bubbleRegularTaillessImage] capInsets:UIEdgeInsetsZero];
    if(![[[_message objectAtIndex:indexPath.item] senderId] isEqualToString:self.senderId])
    {
        return [bubble incomingMessagesBubbleImageWithColor:[UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.0]];
        
    }
    else
        if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row ){
            NSDictionary * dicMessage = [_chatHistory objectAtIndex:indexPath.row];
            //               if ([dicMessage[@"replyMsgConfig"] boolValue]){
            //                   return [bubble outgoingMessagesBubbleImageWithColor:[UIColor colorWithRed:0.0f/255.0f green:122.0f/255.0f blue:255.0f/255.0f alpha:0.3]];
            //               }else{
            
            return [bubble outgoingMessagesBubbleImageWithColor:[UIColor colorWithRed:0.9 green:0.93 blue:1.0 alpha:1.0]];
            // }
        }
    
    return [bubble outgoingMessagesBubbleImageWithColor:[UIColor colorWithRed:0.9 green:0.93 blue:1.0 alpha:1.0]];
}

-(id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat topLabelHeight = 0.0f;
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
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[eRTCChatManager sharedChatInstance] updateMessageWithReadStatus:msgObject];
    });
}

//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView; {
//    return 2;
//}

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
    
    if ([msgObject[ReplyMsgConfig] boolValue] == true){
        if ([msgObject[MsgType] isEqualToString:Key_video] || [msgObject[MsgType] isEqualToString:Image] || [msgObject[MsgType] isEqualToString:LocationType] || [msgObject[MsgType] isEqualToString:GifyFileName] || [msgObject[MsgType] isEqualToString:ContactType] || [msgObject[MsgType] isEqualToString:AudioFileName] ) {
            NSString *strParentMsg = msgObject[Parent_Msg];
            cell.messageBubbleTopLabel.text = [NSString stringWithFormat:@"Replied to a thread:%@",strParentMsg];
            cell.messageBubbleTopLabel.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:15];
        }
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
        }else {
            cell.textView.attributedText = [Helper getuserMentionName:_userNames message:cell.textView.text];
            cell.textView.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:17];
        }
    }
    
    chatReplyCount *replyCountView = [cell.cellBottomLabel viewWithTag:1000];
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
    
    if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row)
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
        if ([obj.firstItem isKindOfClass:chatReplyCount.class]){
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

-(BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath{
    //    UICollectionView *cell = [collectionView cellForItemAtIndexPath:indexPath];
    // if (_chatHistory.count > 0 && [[[_chatHistory objectAtIndex:indexPath.item] valueForKey:MsgType] isEqualToString:@"text"]){
    /*if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row ){
     NSDictionary *dict = [_chatHistory objectAtIndex:indexPath.item];
     if (![dict[@"replyMsgConfig"] boolValue]){
     [self handleLongPressAction:indexPath];
     }
     }
     */
    
    JSQMessage *message = [self.message objectAtIndex:indexPath.row];
    if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row ){
        NSDictionary *dict = _chatHistory[indexPath.row];
        BOOL isDeleted = [dict[IsDeletedMSG] isEqual:@1];
        BOOL isReported = dict[@"isReported"];
        if (![message.msgStatus containsString:@"sending"] && !isDeleted){
            if (isReported || isBlockUI){
            }else{
                if (message.isMediaMessage && [dict[MsgStatusEvent] containsString:@"sending"]){
                    [self.view makeToast:@"Please wait for message to send"];
                }else{
                    [self handleLongPressAction:indexPath];
                    //                    NSDictionary *dictConfig = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
                    //                    if ([dictConfig[@"chatBots"] boolValue] == false) {
                    //
                    //                    }
                }
            }
        }
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
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    
}
-(void)collectionView:(JSQMessagesCollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
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
                [self openThreadView:parentMsg];
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
    NSLog(@"Tapped");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped");
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat bottomHeight = 12.0f;
    if (_chatHistory.count > 0 && _chatHistory.count > indexPath.row) {
        NSDictionary *dicMessage = [_chatHistory objectAtIndex:indexPath.row];
        BOOL isReplyView = false;
        
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
        //            bottomHeight = 150.0F;
        //        }
    }
    
    return bottomHeight;
}

- (CGFloat)convertDataToEmoji:(NSDate *)data {
    NSArray *arrData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if ([arrData count] == 0) {
        return 0.0f;
    } else if ([arrData count] <= 6) {
        return 40.0f;
    } else if ([arrData count] <= 12) {
        return 80.0f;
    } else {
        return 120.0f;
    }
}

-(NSString*)getSeenMsgStatusIndexFromChat:(NSInteger)indexItem{
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
                NSString *strMsgStatus = [self getSeenMsgStatusIndexFromChat:indexPath.row];
                
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
        if ([dict[IsForwarded] boolValue] &&  (message.isMediaMessage || [dict[MsgType] isEqualToString:ContactType])){
            return kJSQMessagesCollectionViewCellLabelHeightDefault;
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
    // if (indexPath.item % 3 == 0) {
    //return kJSQMessagesCollectionViewCellLabelHeightDefault;
    // }
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
        if ( ![dict[IsDeletedMSG] boolValue] && [dict[IsForwarded] boolValue] && (message.isMediaMessage || [dict[MsgType] isEqualToString:ContactType])){
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
        BOOL shouldShowMentionUserFilter = NO;
        [self setShowProfanityFilter:false];
        [self setDomainFilter:false];
        
//        NSLog(@"self.aryWhole >>>>>>>>>%@",self.aryWhole);
//        
//        for (NSDictionary *dictData in self.aryWhole) {
//            if ([search.lowercaseString containsString:dictData[App_User_ID]]) {
//                shouldShowMentionUserFilter = YES;
//            }
//        }
        
        
        
        for (NSString *strdomain in _aryDomainFilter) {
            if ([search.lowercaseString containsString:strdomain] && isDomainFilt == @0) {
                shouldShowDomainFilter = YES;
            }
        }
        
        for (NSString *strProfinity in _aryProfinityFilter) {
            if ([search.lowercaseString containsString:strProfinity] && isProfanity == false) {
                shouldShowProfinityFilter = YES;
            }
        }
        if(shouldShowDomainFilter == YES){
            if (shouldEnableDomainFilter == true) {
                [self setDomainFilter:true];
                [self.inputToolbar.contentView.rightBarButtonItem setHidden:YES];
            }
       
        }else if(shouldShowProfinityFilter == YES){
            if (shouldDisableProfanityFilter == true) {
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
    self.arrAllUsers = [ary mutableCopy];
    NSString *strAppUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"appUserId != %@",strAppUserId];
    NSArray *filteredArr = [ary filteredArrayUsingPredicate:predicate];
    
    if (filteredArr.count >0) {
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        NSArray *sortedArray=[filteredArr sortedArrayUsingDescriptors:@[sort]];
        if (sortedArray.count > 0) {
            //  self->arrUsers = [NSArray arrayWithArray:sortedArray];
            self.aryWhole = [[NSArray arrayWithArray:sortedArray] mutableCopy];
           
        }
    }
}

-(NSAttributedString*)colorHashtag:(NSString*)message {
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:message];
    NSString *str = message;
    NSError *error = nil;
    
    //I Use regex to detect the pattern I want to change color
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)(\\s+)(\\w+)(\\s+)(\\w+) |@(\\w+)(\\s+) |@(\\w+)(\\s+)(\\w+)" options:0 error:&error];
    NSArray *matches = [regex matchesInString:message options:0 range:NSMakeRange(0, message.length)];
    
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:0];
        NSString *name = [message substringWithRange:wordRange];
        
        NSArray *list = [name componentsSeparatedByString:@" "];
        NSMutableSet *set = [[NSMutableSet alloc] initWithObjects:[name stringByReplacingOccurrencesOfString:@"@" withString:@""], nil];
        if (list.count > 1){
            [set addObject:[list.firstObject stringByReplacingOccurrencesOfString:@"@" withString:@""]];
        }
        
        for(NSString *item in set)
        {
            if ([name isKindOfClass:[NSString class]]){
                wordRange.length = item.length + 1;
                [string addAttribute:NSForegroundColorAttributeName value:[UIColor systemBlueColor] range:wordRange];
            }
        }
    }
    
    return string;
}

-(NSString*)getNamesStringFromNames:(NSSet*)nameSat message:(NSString*)message
{
    //    NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:message];
    
    NSString *str = message;
    NSError *error = nil;
    
    //I Use regex to detect the pattern I want to change color
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)(\\s+)(\\w+)|@(\\w+).com" options:0 error:&error];
    NSArray *matches = [regex matchesInString:message options:0 range:NSMakeRange(0, message.length)];
    NSMutableString *string = message.mutableCopy;
    NSUInteger counter = 0;
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:0];
        NSRange _range = wordRange;
        _range.location = _range.location + counter;
        
        NSString *name = [message substringWithRange:wordRange];
        NSArray *list = [name componentsSeparatedByString:@" "];
        NSMutableSet *set = [[NSMutableSet alloc] initWithObjects:[name stringByReplacingOccurrencesOfString:@"@" withString:@""], nil];
        
        if (list.count > 1){
            [set addObject:[list.firstObject stringByReplacingOccurrencesOfString:@"@" withString:@""]];
        }
        
        for(NSString *item in set)
        {
            if ([name isKindOfClass:[NSString class]] && [nameSat containsObject:item]){
                [string replaceCharactersInRange:_range withString:[NSString stringWithFormat:@"<%@>", name]];
            }
        }
        counter += 2;
        NSLog(@"Search DATA %@", [message substringWithRange:wordRange]);
    }
    return string;
    //[textView setAttributedText:string];
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
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:15];
        cell.textLabel.textColor = [UIColor blackColor];//[UIColor colorWithRed:0.141 green:0.204 blue:0.263 alpha:1.0];
        cell.detailTextLabel.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:16];
        cell.detailTextLabel.textColor = [Helper colorWithHexString:@"5691C8"];
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
    NSDictionary *config = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
    if ([config[@"userMentionsChat"] boolValue] == true){
        NSLog(@"Selected user == %@", self.numbersArrayList[indexPath.row]);
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
            
            NSString *strUserTxtMsg = [strUser stringByReplacingOccurrencesOfString:@"@" withString:@""];
            NSMutableString *stringMsg = strUserTxtMsg.mutableCopy;
            NSRange range = NSMakeRange(0, stringMsg.length);
            [stringMsg replaceCharactersInRange:range withString:[NSString stringWithFormat:@"<%@>", strUserTxtMsg]];
            
            NSString *strMsg = [NSString stringWithFormat:@"%@%@", self.inputToolbar.contentView.textView.text, strUser];
            NSLog(@"strMsg >>>>>>>>>>>%@",strMsg);
            
            NSMutableDictionary *dict = [NSMutableDictionary new];
            if ([[[self.numbersArrayList objectAtIndex:indexPath.row] valueForKey:@"name"] isEqualToString:@"channel"] || [[[self.numbersArrayList objectAtIndex:indexPath.row] valueForKey:@"name"] isEqualToString:@"here"]){
                [dict setValue:@"generic" forKey:@"type"];
                [dict setValue:@"channel" forKey:@"value"];
            }else{
                [dict setValue:@"user" forKey:@"type"];
                NSString *strID = [NSString stringWithFormat:@"%@",[[self.numbersArrayList objectAtIndex:indexPath.row] valueForKey:@"userId"]];
                [dict setValue:strID forKey:@"value"];
            }
            [self.aryMentioned addObject:dict];
            NSLog(@"strMsg>>>>>>>>>%@",strMsg);
            self.inputToolbar.contentView.textView.attributedText = [Helper getAttributedString: [self colorHashtag:strMsg] font: [UIFont fontWithName:@"SFProDisplay-Regular" size:18]];
            
            
            
            if ([self isMessageEditing]){
                NSMutableDictionary *editedMessage = [editingMessage[@"editingMessage"] mutableCopy];
                editedMessage[Message] = strMsg;
                editingMessage[@"editedMessage"] = editedMessage.copy;
            }
            //    self.inputToolbar.contentView.textView.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:17];
            [self.numbersArrayList removeAllObjects];
            [self.tblMention reloadData];
            [self.tblMention setHidden:YES];
        }
    }else{
        [self.numbersArrayList removeAllObjects];
        [self.tblMention reloadData];
        [self.tblMention setHidden:YES];
        self.inputToolbar.contentView.textView.text = @"";
        NSString *msg = @"User Mention is not available now. Please contact your administrator.";
        [Helper showAlertOnController:@"eRTC" withMessage:msg onController:self];
    }
    
}

-(void)sendTypingStatusToRecepient:(BOOL)isON {
    NSMutableDictionary * dictParam = [NSMutableDictionary new];
    if ([self.dictUserDetails valueForKey:App_User_ID] != nil || [self.dictUserDetails valueForKey:App_User_ID] != [NSNull null]) {
        if (self.dictUserDetails[App_User_ID] != nil) {
            [dictParam setObject:self.dictUserDetails[App_User_ID] forKey:App_User_ID]; // current selected user
        }
    }
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
    }else
    {
        JSQAudioMediaItem *audioItem = [[JSQAudioMediaItem alloc] initWithData:audioFile];
        NSLog(@"audioItem >>>>>>>>>>>>>>%@",audioItem);
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
    NSString*strSenderappUserId = [dictMessage valueForKeyPath:@"sender.appUserId"];
    
    JSQMessage *photoMessage = [JSQMessage messageWithSenderId:strSendereRTCUserId
                                                   displayName:strSenderappUserId
                                                         media:photoItem];
    [self.message addObject:photoMessage];
    [self finishReceivingMessageAnimated:YES];
    
}
#pragma mark - Actions


- (void)receiveMessageWithSenderId:(NSString *)senderId andDisplayName:(NSString *) displayName andtextMessage:(NSString *) textMessage msgType:(NSString*)msgType andDictionary:(NSDictionary*)dictResponse { //andMsgStatus:(NSString *) msgStatus
    
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
    }
    /*else if ([msgType isEqualToString:@"video"]) {
     NSLog(@"SingleChatViewController ->  receiveMessageWithSenderId -> video -> %@",textMessage);
     
     JSQVideoMediaItem *videoItemCopy = [[JSQVideoMediaItem alloc] initWithFileURL:[NSURL URLWithString:textMessage] isReadyToPlay:YES];
     
     videoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
     newMediaAttachmentCopy = [videoItemCopy.fileURL copy];
     newMediaData = videoItemCopy;
     newMessage = [JSQMessage messageWithSenderId:senderId
     displayName:displayName
     media:newMediaData];
     }*/
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
        if (![Helper stringIsNilOrEmpty:[dictResponse valueForKeyPath:@"replyThreadFeatureData.replyMsgConfig"]]){
            NSString *strReplyStatus = [dictResponse valueForKeyPath:@"replyThreadFeatureData.replyMsgConfig"];
            
            if ([strReplyStatus boolValue]){
                NSString *strbaseMsgId =[NSString stringWithFormat:@"%@", [dictResponse valueForKeyPath:@"replyThreadFeatureData.baseMsgUniqueId"]];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"msgUniqueId == %@",strbaseMsgId];
                NSArray *aryFilter = [self->_chatHistory filteredArrayUsingPredicate:predicate];
                
                if (aryFilter.count > 0){
                    NSString *strParentMsg;
                    if ([[[aryFilter objectAtIndex:0] valueForKey:@"msgType"] isEqualToString:@"text"]) {
                        strParentMsg = [[aryFilter objectAtIndex:0] valueForKey:@"message"];
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
                    
                    strParentMsg = (strParentMsg != NULL) ? strParentMsg : @"";
                    if ([strParentMsg length] > 30) {
                        NSRange range = [strParentMsg rangeOfComposedCharacterSequencesForRange:(NSRange){0, 30}];
                        strParentMsg = [strParentMsg substringWithRange:range];
                        strParentMsg = [strParentMsg stringByAppendingString:@"…"];
                    }
                    strMessage = [NSString stringWithFormat:@"Replied to a thread:%@\n%@",strParentMsg,copyMessage.text];
                }else {
                    strMessage = [NSString stringWithFormat:@"Replied to a thread:\n%@",copyMessage.text];
                }
            }else{
                strMessage = copyMessage.text;
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
        /*  newMessage = [JSQMessage messageWithSenderId:senderId
         displayName:displayName text:copyMessage.text];*/
        
        
        
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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
                }else if ([obj[MsgType] isEqualToString:@"gif"]){
                    [self getChatHistory];
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
        if (isTypingActive) {
            [self userTypingFinished];
        }
        // NSString *mentionString = [Helper getNamesTaggedStringFromNames:_userNames message:message];
        if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil) {
            NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
            if (self.dictUserDetails[App_User_ID] != nil && self.dictUserDetails[App_User_ID] != [NSNull null]) {
                NSMutableDictionary * dictParam = [NSMutableDictionary new];
                [dictParam setObject:userId forKey:SendereRTCUserId];
                [dictParam setObject:message forKey:Message];
                [dictParam setObject:self.strThreadId forKey:ThreadID];
                [dictParam setValue:self.aryMentioned forKey:@"mentions"];
                [dictParam setObject:self.dictUserDetails[User_eRTCUserId] forKey:User_eRTCUserId];
                
                [[eRTCChatManager sharedChatInstance] sendTextMessageWithParam:[NSDictionary dictionaryWithDictionary:dictParam] andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                    
                    NSDictionary *dictResponse = (NSDictionary *)json;
                    if (dictResponse[@"success"] != nil) {
                        BOOL success = [dictResponse[@"success"] boolValue];
                        if (success == true) {
                    self->currentMessage.msgStatus = @"Sent".capitalizedString;
                    [self updateChatThreadHistory];
                    [self.collectionView reloadData];
                    _aryMentioned = [NSMutableArray new];
                        }else{
                        [self.view endEditing:true];
                        [_message removeLastObject];
                        [self.collectionView reloadData];
                        [self.view makeToast:dictResponse[@"msg"]];
                        }
                    }
                } andFailure:^(NSError * _Nonnull error) {
                    NSLog(@"error--> %@",error);
                    NSString *errMsg = [NSString stringWithFormat:@"%@", error.localizedDescription];
                    [self performSelector:@selector(showAlert:) withObject:errMsg afterDelay:0.3];
                    
                }];
            }
        }
    }
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
            [dictDeleteMessage setObject:userId forKey:SendereRTCUserId];
            if (self.dictUserDetails[App_User_ID] != nil && self.dictUserDetails[App_User_ID] != [NSNull null]) {
                [dictDeleteMessage setObject:mentionString forKey:Message];
                [dictDeleteMessage setValue:object[ThreadID] forKey:@"threadId"];
                [dictDeleteMessage setValue:object[MsgUniqueId] forKey:@"msgUniqueId"];
                [dictDeleteMessage setObject:self.dictUserDetails[User_eRTCUserId] forKey:User_eRTCUserId];
               
                
                [[eRTCChatManager sharedChatInstance] editMessageWithParam:[NSDictionary dictionaryWithDictionary:dictDeleteMessage] andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                    NSDictionary *dictResponse = (NSDictionary *)json;
                    if (dictResponse[@"success"] != nil) {
                        BOOL success = [dictResponse[@"success"] boolValue];
                        if (success == true) {
                        [self updateMessageCellAtIndexPath:indexPath message:object];
                        }else{
                        [self.view makeToast:dictResponse[@"msg"]];
                        }
                    }
                } andFailure:^(NSError * _Nonnull error) {
                    NSLog(@"error--> %@",error);
                    [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
                }];
            }
        }
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

-(void)sendPhotoMediaItemWithData:(NSData*)data {
    if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil) {
        [self getSizeInMB:data];
        NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
        
        NSMutableDictionary * dictParam = [NSMutableDictionary new];
        [dictParam setObject:userId forKey:SendereRTCUserId];
        //  [dictParam setObject:@"image" forKey:@"msgType"];
        [dictParam setObject:self.strThreadId forKey:ThreadID];
        //        NSDictionary *myDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"Test123", @"abc", nil];
        //        NSData *data1 = [NSJSONSerialization dataWithJSONObject:myDictionary options:NSJSONWritingPrettyPrinted error:nil];
        //        NSString *jsonString = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
        //        [dictParam setObject:jsonString forKey:customData];
        
        //        [[eRTCChatManager sharedChatInstance] sendPhotoMediaItemWithParam:dictParam andFileData:data];
        [[eRTCChatManager sharedChatInstance] sendPhotoMediaItemWithParam:[NSDictionary dictionaryWithDictionary:dictParam] andFileData:data andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            NSDictionary *dictResponse = (NSDictionary *)json;
            if (dictResponse[@"success"] != nil) {
                BOOL success = [dictResponse[@"success"] boolValue];
                if (success == true) {
                    
                    //            if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                    //                NSMutableDictionary * dictFollow = [NSMutableDictionary new];
                    //                NSDictionary *dictResult = json[@"result"];
                    //                if (dictResult.count > 0) {
                    //                [dictFollow setObject:dictResult[MsgUniqueId] forKey:MsgUniqueId];
                    //                [dictFollow setObject:dictResult[ThreadID] forKey:ThreadID];
                    //                [self followUnFollowMsg:false dict:dictFollow];
                    //                }
                    //             }
                    self->currentMessage.msgStatus = @"Sent".capitalizedString;
                    [self finishSendingMessageAnimated:YES];
                    [self updateChatThreadHistory];
                }else{
                    [self.view endEditing:true];
                    [_message removeLastObject];
                    [self.collectionView reloadData];
                    [self.view makeToast:dictResponse[@"msg"]];
                }
            }
        } andFailure:^(NSError * _Nonnull error) {
            NSLog(@"Failed to send Photo");
            [_message removeLastObject];
            NSString *errMsg = [NSString stringWithFormat:@"%@", error.localizedDescription];
            [self performSelector:@selector(showAlert:) withObject:errMsg afterDelay:0.3];
        }];
        
    }
}

-(void)getSizeInMB:(NSData*)data{
    //long long fileSize = 14378165;
    NSString *displayFileSize = [NSByteCountFormatter stringFromByteCount:data.length
                                                               countStyle:NSByteCountFormatterCountStyleFile];
}

-(void)sendAudioMediaItemWithData:(NSData*)data {
    if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil) {
        [self getSizeInMB:data];
        NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
        if (self.dictUserDetails[App_User_ID] != nil && self.dictUserDetails[App_User_ID] != [NSNull null]) {
            NSMutableDictionary * dictParam = [NSMutableDictionary new];
            [dictParam setObject:userId forKey:SendereRTCUserId];
            //   [dictParam setObject:@"audio" forKey:@"msgType"];
            [dictParam setObject:self.strThreadId forKey:ThreadID];
            [[eRTCChatManager sharedChatInstance] sendAudioMediaItemWithParam:dictParam andFileData:data andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                NSLog(@"json <>>>>>>>>>>>>>>>>%@",json);
                NSDictionary *dictResponse = (NSDictionary *)json;
                if (dictResponse[@"success"] != nil) {
                    BOOL success = [dictResponse[@"success"] boolValue];
                    if (success == true) {
                        self->currentMessage.msgStatus = @"Sent".capitalizedString;
                        [self finishSendingMessageAnimated:YES];
                        [self updateChatThreadHistory];
                    }else{
                        [self.view endEditing:true];
                        [_message removeLastObject];
                        [self.collectionView reloadData];
                        [self.view makeToast:dictResponse[@"msg"]];
                    }
                }
                
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
        
        if (self.dictUserDetails[App_User_ID] != nil && self.dictUserDetails[App_User_ID] != [NSNull null]) {
            NSMutableDictionary * dictParam = [NSMutableDictionary new];
            [dictParam setObject:userId forKey:SendereRTCUserId];
            [dictParam setObject:self.strThreadId forKey:ThreadID];
            [[eRTCChatManager sharedChatInstance] sendVideoMediaItemWithParam:dictParam andFileData:data andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                
                NSDictionary *dictResponse = (NSDictionary *)json;
                if (dictResponse[@"success"] != nil) {
                    BOOL success = [dictResponse[@"success"] boolValue];
                    if (success == true) {
                        self->currentMessage.msgStatus = @"Sent".capitalizedString;
                        [self finishSendingMessageAnimated:YES];
                        [self updateChatThreadHistory];
                    }else{
                        [self.view endEditing:true];
                        [_message removeLastObject];
                        [self.collectionView reloadData];
                        [self.view makeToast:dictResponse[@"msg"]];
                    }
                }
                
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
        __block BOOL apiSuccess = true;
        if (self.dictUserDetails[App_User_ID] != nil && self.dictUserDetails[App_User_ID] != [NSNull null]) {
            NSMutableDictionary * dictParam = [NSMutableDictionary new];
            [dictParam setObject:userId forKey:SendereRTCUserId];
            //  [dictParam setObject:@"audio" forKey:@"msgType"];
            [dictParam setObject:self.strThreadId forKey:ThreadID];
            //        NSDictionary *myDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"Test123", @"abc", nil];
            //        NSData *data1 = [NSJSONSerialization dataWithJSONObject:myDictionary options:NSJSONWritingPrettyPrinted error:nil];
            //        NSString *jsonString = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
            //        [dictParam setObject:jsonString forKey:customData];
            //      [[eRTCChatManager sharedChatInstance] sendMediaFileItemWithParam:dictParam andFileData:data andFileExtension:fileExtension];
            [[eRTCChatManager sharedChatInstance] sendMediaFileItemWithParam:dictParam andFileData:data andFileExtension:fileExtension andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                self->currentMessage.msgStatus = @"Sent".capitalizedString;
                [self finishSendingMessageAnimated:YES];
                [self updateChatThreadHistory];
                
            } andFailure:^(NSError * _Nonnull error) {
                NSLog(@"Failed to send File");
                [_message removeLastObject];
                NSString *errMsg = [NSString stringWithFormat:@"%@", error.localizedDescription];
                
                [self performSelector:@selector(showAlert:) withObject:errMsg afterDelay:0.3];
                apiSuccess = false;
            }];
            if (apiSuccess == true) {
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
}

-(void)sendGIFMediaItemWithURL:(NSString*)gifURL {
    if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil && [gifURL length] > 0) {
        NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
        if (self.dictUserDetails[App_User_ID] != nil && self.dictUserDetails[App_User_ID] != [NSNull null]) {
            NSMutableDictionary * dictParam = [NSMutableDictionary new];
            [dictParam setObject:userId forKey:SendereRTCUserId];
            [dictParam setObject:gifURL forKey:GifyFileName];
            [dictParam setObject:self.strThreadId forKey:ThreadID];
            [dictParam setObject:self.dictUserDetails[User_eRTCUserId] forKey:User_eRTCUserId];
            JSQGIFMediaItem *photoItem = [[JSQGIFMediaItem alloc] init];
            JSQMessage *photoMessage = [JSQMessage messageWithSenderId:self.senderId
                                                           displayName:self.senderDisplayName
                                                                 media:photoItem];
            photoMessage.msgStatus =@"sending";
            NSDictionary *dictConfig = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
            NSUInteger index;
            if ([dictConfig[@"gifyChat"] boolValue] == false) {
                
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
                //[_message removeLastObject];
                NSString *errMsg = [NSString stringWithFormat:@"%@", error.localizedDescription];
                [self performSelector:@selector(showAlert:) withObject:errMsg afterDelay:0.3];
            }];
        }
    }
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
        // [bottemView removeFromSuperview];
        [reportView removeFromSuperview];
    });
}

-(IBAction)btnUndu:(id)sender
{
    NSLog(@"Ok button was tapped: dismiss the view controller.");
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

- (void)didReceiveMsgNotification:(NSNotification *) notification
{
    NSDictionary * dictMessage = [notification userInfo];
    if ([dictMessage isKindOfClass:[NSDictionary class]]){
        if (self.strThreadId!= nil && dictMessage[ThreadID] != [NSNull null]) {
            NSString *strReplyStatus = @"";
            if (![Helper stringIsNilOrEmpty:[dictMessage valueForKeyPath:@"replyThreadFeatureData.replyMsgConfig"]]){
                strReplyStatus = [NSString stringWithFormat:@"%@", [dictMessage valueForKeyPath:@"replyThreadFeatureData.replyMsgConfig"]];
            }
            
            if  ([Helper stringIsNilOrEmpty:dictMessage[ReplyThreadFeatureData]] || [strReplyStatus  isEqual: @"1"]) {
                [self updateChatThreadHistory];
                NSString*strCurrentMsgThreadID = [NSString stringWithFormat:@"%@",[dictMessage valueForKeyPath:@"thread.threadId"]];
                if ([self.strThreadId isEqualToString:strCurrentMsgThreadID]){
                    NSString*strSendereRTCUserId = [dictMessage valueForKeyPath:@"sender.eRTCUserId"];
                    NSString*strSenderappUserId = [dictMessage valueForKeyPath:@"sender.appUserId"];
                    if ([dictMessage[@"msgType"]isEqualToString:@"text"]) {
                        
                        [self receiveMessageWithSenderId:strSendereRTCUserId andDisplayName:strSenderappUserId andtextMessage:dictMessage[@"message"] msgType:dictMessage[@"msgType"] andDictionary:dictMessage];
                    } else if ([dictMessage[@"msgType"]isEqualToString:@"gify"]) {
                        NSString *filePath = @"";
                        if (![Helper stringIsNilOrEmpty:dictMessage[LocalFilePath]] && [dictMessage[LocalFilePath] length] > 0) {
                            // if ([[NSFileManager defaultManager] fileExistsA.mp3tPath:filePath]) {
                            filePath = dictMessage[LocalFilePath];
                            // }
                        } else {
                            filePath = dictMessage[GifyFileName];
                        }
                        [self receiveMessageWithSenderId:strSendereRTCUserId andDisplayName:strSenderappUserId andtextMessage:filePath msgType:dictMessage[@"msgType"] andDictionary:dictMessage];
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
                            [self receiveMessageWithSenderId:strSendereRTCUserId andDisplayName:strSenderappUserId andtextMessage:dictMessage[LocalFilePath] msgType:dictMessage[@"msgType"] andDictionary:dictMessage];
                        } else {
                            [self receiveMessageWithSenderId:strSendereRTCUserId andDisplayName:strSenderappUserId andtextMessage:dictMessage[FilePath] msgType:dictMessage[@"msgType"] andDictionary:dictMessage];
                        }
                        // [self loadPhotoMediaMessage:dictMessage];
                    }
                    // [[eRTCChatManager sharedChatInstance] updateMessageWithReadStatus:dictMessage];
                }
            }else{
                [self updateChatThreadHistory];
                [self.collectionView reloadData];
                [[eRTCChatManager sharedChatInstance] updateMessageWithReadStatus:dictMessage];
            }
        }
    }
    if([dictMessage valueForKey:MsgStatusEvent]!= nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"msgUniqueId == %@", [dictMessage valueForKey:@"msgUniqueId"]];
        NSArray *aryFilter = [self->_chatHistory filteredArrayUsingPredicate:predicate];
        if (aryFilter.count > 0){
            NSMutableDictionary *dict = [[aryFilter objectAtIndex:0] mutableCopy];
            NSUInteger index = [self->_chatHistory indexOfObject:dict];
            if (index != NSNotFound){
                [dict setValue:[dictMessage valueForKey:@"msgStatusEvent"] forKey:@"msgStatusEvent"];
                [self->_chatHistory replaceObjectAtIndex:index withObject:dict.copy];
            }else{
                NSLog(@"Index Not found");
            }
        }else{
            NSLog(@"MSG Not found");
        }
        [self.collectionView reloadData];
    }
}

- (void)didReceiveTypingStatusNotification:(NSNotification *) notification{
    NSDictionary *dictTypingData = notification.userInfo;
    if ([dictTypingData isKindOfClass:[NSDictionary class]]){
        if (self.strThreadId!= nil && dictTypingData[ThreadID] != [NSNull null]) {
            if ([self.strThreadId isEqualToString:dictTypingData[ThreadID]]){
                if ([[dictTypingData valueForKey:@"typingStatusEvent"]isEqualToString:@"on"]) {
                    statusLabel.hidden = FALSE;
                } else {
                    statusLabel.hidden = TRUE;
                }
                
            }
        }
    }
}

-(void)didReceiveMsgStatus:(NSNotification *) notification{
    
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
-(void)refreshChatData{
    [self performSelector:@selector(getChatHistory) withObject:nil afterDelay:0.2];
}

-(void)refreshReactionData:(NSNotification *) notification{
    
    NSLog(@"refreshReactionDataInTime");
    
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
        
        if (self.dictUserDetails[App_User_ID] != nil && self.dictUserDetails[App_User_ID] != [NSNull null]) {
            
            NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
            
            [dictParam setValue:self.strThreadId forKey:ThreadID];
            
            [dictParam setValue:userId forKey:SendereRTCUserId];
            //[dictParam setValue:_message forKey:Message];
            [dictParam setValue:dictlocation forKey:@"location"];
            [dictParam setObject:self.dictUserDetails[User_eRTCUserId] forKey:User_eRTCUserId];
           // [dictParam setObject:self.dictUserDetails[User_eRTCUserId] forKey:User_eRTCUserId];
            //            NSDictionary *myDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"Test123", @"abc", nil];
            //            NSData *data1 = [NSJSONSerialization dataWithJSONObject:myDictionary options:NSJSONWritingPrettyPrinted error:nil];
            //            NSString *jsonString = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
            //            [dictParam setObject:jsonString forKey:customData];
            
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
                    BOOL success = [dictResponse[@"success"] boolValue];
                    if (success) {
                        if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                            
                            CLLocation *ferryBuildingInSF = [[CLLocation alloc] initWithLatitude:[self->userLat doubleValue] longitude:[self->userLong doubleValue] ];
                            JSQLocationMediaItem *locationItem = [[JSQLocationMediaItem alloc] init];
                            [locationItem setLocation:ferryBuildingInSF withCompletionHandler:completion];
                            
                            JSQMessage *locationMessage = [JSQMessage messageWithSenderId:self.senderId
                                                                              displayName:self.senderDisplayName
                                                                                    media:locationItem];
                            
                            locationMessage.msgStatus = @"Sent".capitalizedString;
                            [self.message addObject:locationMessage];
                            [self updateChatThreadHistory];
                            
                        }
                    }else{
                    [self.view endEditing:true];
                    [_message removeLastObject];
                    [self.collectionView reloadData];
                    [self.view makeToast:dictResponse[@"msg"]];
                    }
                }
                if (dictResponse[@"msg"] != nil) {
                    NSString *message = (NSString *)dictResponse[@"msg"];
                    if ([message length]>0) {
                        // [Helper showAlertOnController:@"eRTC" withMessage:message onController:self];
                    }
                }
                
            } andFailure:^(NSError * _Nonnull error) {
                
                NSString *errMsg = [NSString stringWithFormat:@"%@", error.localizedDescription];
                [self performSelector:@selector(showAlert:) withObject:errMsg afterDelay:0.3];            }];
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
    
    
    if ((Name == NULL || [Name isEqualToString:@""]) && (contact.organizationName != NULL && ![contact.organizationName isEqualToString:@""])){
        Name = contact.organizationName;
    }
    
    
    
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
    //        NSMutableDictionary*dictEmail = [[NSMutableDictionary alloc]init];
    //        [dictEmail setValue:emailtype forKey:@"type"];
    //        [dictEmail setValue:ContactEmail forKey:@"email"];
    [dictContact setValue:contactnumber forKey:Key_Number];
    //        NSArray*email = [NSArray arrayWithObjects: dictEmail,nil];
    //        [dictContact setValue:email forKey:Key_Email];
    JSQMessage *contactmessage = [[JSQMessage alloc] initWithSenderId:self.senderId
                                                    senderDisplayName:self.senderDisplayName
                                                                 date:[NSDate date]
                                                                 text:[NSString stringWithFormat:@"%@",[Helper getContactNameString:dictContact]]]; //  \n%@ ,phoneMobile
    contactmessage.msgStatus =@"sending...";
    [_message addObject:contactmessage];
    [self sendContactNumber:dictContact];
    
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
 [dictphone setValue:phoneNumbertype forKey:@"type"];
 [dictphone setValue:phoneMobile forKey:@"number"];
 NSArray*contactnumber = [NSArray arrayWithObjects:dictphone,nil];
 //        NSMutableDictionary*dictEmail = [[NSMutableDictionary alloc]init];
 //        [dictEmail setValue:emailtype forKey:@"type"];
 //        [dictEmail setValue:ContactEmail forKey:@"email"];
 [dictContact setValue:contactnumber forKey:Key_Number];
 //        NSArray*email = [NSArray arrayWithObjects: dictEmail,nil];
 //        [dictContact setValue:email forKey:Key_Email];
 JSQMessage *contactmessage = [[JSQMessage alloc] initWithSenderId:self.senderId
 senderDisplayName:self.senderDisplayName
 date:[NSDate date]
 text:[NSString stringWithFormat:@"%@ \n%@",phoneMobile,Name]];
 contactmessage.msgStatus =@"sending...";
 
 
 
 
 NSLog(@"%@ dictContact",dictContact);
 
 
 [_message addObject:contactmessage];
 [self sendContactNumber:dictContact];
 
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
        if (self.dictUserDetails[App_User_ID] != nil && self.dictUserDetails[App_User_ID] != [NSNull null]) {
            // Turn off the location manager to save power.
            NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
            [dictParam setValue:self.strThreadId forKey:ThreadID];
            [dictParam setValue:userId forKey:SendereRTCUserId];
            [dictParam setValue:contact forKey:@"contact"];
            [dictParam setObject:self.dictUserDetails[User_eRTCUserId] forKey:User_eRTCUserId];
            
            [[eRTCChatManager sharedChatInstance] sendContactMessageWithParam:dictParam andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                NSDictionary *dictResponse = (NSDictionary *)json;
                
                if (dictResponse[@"success"] != nil) {
                    BOOL success = [dictResponse[@"success"] boolValue];
                    if (success == true) {
                        NSTimeInterval delayInSeconds = 2.0;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            self->currentMessage.msgStatus = @"Sent".capitalizedString;
                            [self finishSendingMessageAnimated:YES];
                            [self updateChatThreadHistory];
                        });
                    }else{
                        [self.view endEditing:true];
                        [_message removeLastObject];
                        [self.collectionView reloadData];
                        [self.view makeToast:dictResponse[@"msg"]];
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


-(void)showAlert:(NSString *)strMessage{
    [Helper showAlertOnController:@"eRTC" withMessage:strMessage onController:self];
}
#pragma mark - custom actions

-(void)pushToReplyThreadVC:(UIButton *)sender{
    NSInteger selectedInedx = sender.tag;
    NSDictionary * dictMessage = [NSDictionary new];
    if (_chatHistory.count > selectedInedx) {
        dictMessage = [_chatHistory objectAtIndex:selectedInedx];
    }
    [self openThreadView:dictMessage];
}
-(void)openThreadView:(NSDictionary*) dictMessage {
    //    NSDictionary *config = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
    //     if ([config[@"replyThreadChat"] boolValue]){
    ThreadChatViewController *_vcProfile = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"ThreadChatViewController"];
    _vcProfile.dictUserDetails = self.dictUserDetails;
    _vcProfile.dictThreadMsgDetails = dictMessage;
    [self.navigationController pushViewController:_vcProfile animated:YES];
    //     }else {
    //         NSString *msg = @"Thread chat not available. Please contact your administrator.";
    //     }
}
- (void)handleLongPressAction:(NSIndexPath *) indexPath {
    NSDictionary *config = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
    [self.inputToolbar.contentView.textView resignFirstResponder];
    NSString * strFavourite = @"Add to favorites";
    NSDictionary * dictMessage = [NSDictionary new];
    if (_chatHistory.count > indexPath.row) {
        dictMessage = [_chatHistory objectAtIndex:indexPath.row];
        // [self sendEditedTextMessage:editingMessage.copy];
        self.longPressMessage = [dictMessage valueForKey:@"message"];
        if (![Helper objectIsNilOrEmpty:dictMessage andKey:IsFavourite]) {
            if ([dictMessage[IsFavourite] intValue]) {
                strFavourite = @"Remove From Favourites";
            }
        }
    }
    
    NSString *strComparId = dictMessage[SendereRTCUserId];
    NSString *strThreadTitle = @"Start a thread";
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
//    if ([config[@"e2eChat"] boolValue]){
//    }else{
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
    
    [self.view endEditing:YES];
    selectedChatIndexPath = indexPath;
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
    [chatReactions setMessageType: dictMessage[MsgType]];
    [self presentPanModal:chatReactions];
    return;
    
    //    UIAlertController * view =  [UIAlertController
    //                                 alertControllerWithTitle:@""
    //                                 message:@""
    //                                 preferredStyle:UIAlertControllerStyleActionSheet];
    //    UIAlertAction* copy = [UIAlertAction
    //                           actionWithTitle:@"Copy"
    //                           style:UIAlertActionStyleDefault
    //                           handler:^(UIAlertAction * action)
    //                           {
    //        [self copyMessageWithIndexPath:indexPath];
    //    }];
    //
    //    UIAlertAction* favourite = [UIAlertAction
    //                                actionWithTitle:strFavourite
    //                                style:UIAlertActionStyleDefault
    //                                handler:^(UIAlertAction * action)
    //                                {
    //        [self isMarkFavouriteWithIndexPath:indexPath];
    //    }];
    //    NSString *strThreadTitle = @"Start a thread";
    //    /*if (![Helper stringIsNilOrEmpty:[dictMessage valueForKey:@"replyMsgConfig"]] && ![Helper stringIsNilOrEmpty:[dictMessage valueForKey:@"replyMsgConfig"]]){
    //        if ([dictMessage valueForKey:@"replyMsgConfig"] != nil && [dictMessage valueForKey:@"replyMsgConfig"] != [NSNull null] )
    //        {
    //            BOOL isReplyAvailble = [[dictMessage valueForKey:@"replyMsgConfig"] boolValue];
    //            if (isReplyAvailble)
    //            {
    //                strThreadTitle =   @"View thread";
    //            }
    //        }
    //    }*/
    //    if (![Helper stringIsNilOrEmpty:[dictMessage valueForKey:@"replyMsgCount"]] && ![Helper stringIsNilOrEmpty:[dictMessage valueForKey:@"replyMsgCount"]]){
    //        if ([dictMessage valueForKey:@"replyMsgCount"] != nil && [dictMessage valueForKey:@"replyMsgCount"] != [NSNull null] )
    //        {
    //            NSInteger isReplyAvailble = [[dictMessage valueForKey:@"replyMsgCount"] integerValue];
    //            if (isReplyAvailble > 0)
    //            {
    //                strThreadTitle =   @"View thread";
    //            }
    //        }
    //    }
    
    //    UIAlertAction* startThread = [UIAlertAction
    //                                  actionWithTitle:strThreadTitle
    //                                  style:UIAlertActionStyleDefault
    //                                  handler:^(UIAlertAction * action)
    //                                  {
    //        ThreadChatViewController *_vcProfile = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"ThreadChatViewController"];
    //        _vcProfile.dictUserDetails = self.dictUserDetails;
    //        _vcProfile.dictThreadMsgDetails = dictMessage;
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
    //    [copy setValue:[[UIImage imageNamed:@"copythread"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    //    [copy setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
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
    //   // [favourite setValue:[[UIImage imageNamed:@"unFav"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    //    [favourite setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
    //
    //    [startThread setValue:[[UIImage imageNamed:@"startThread"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    //    [startThread setValue:kCAAlignmentLeft forKey:@"titleTextAlignment"];
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

-(void)showTypingHeader:(BOOL)isShow{
    /*  NSString * strUserName;
     if (self.dictUserDetails[User_Name] != nil) {
     strUserName = self.dictUserDetails[User_Name];
     }
     if (isShow) {
     self.lblHeader.text = [NSString stringWithFormat:@"%@ \n typing...",strUserName];
     }
     else{
     self.lblHeader.text = [NSString stringWithFormat:@"%@",strUserName];
     
     }*/
}
//XXXXX
NSArray<NSArray<NSLayoutConstraint*>*> *editMessageViewconstrainsts;
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
            }
            //           NSDictionary *config = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
            //            if ([config[@"replyThreadChat"] boolValue] == true){
            ThreadChatViewController *_vcProfile = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"ThreadChatViewController"];
            _vcProfile.dictUserDetails = self.dictUserDetails;
            _vcProfile.dictThreadMsgDetails = dictMessage;
            [self.navigationController pushViewController:_vcProfile animated:YES];
            //            }else {
            //                NSString *msg = @"Thread chat not available. Please contact your administrator.";
            //                [Helper showAlertOnController:@"eRTC" withMessage:msg onController:self];
            //            }
            break;
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
            forwardToVc.isGroup = false;
            forwardToVc.dictUserDetails = [self.dictUserDetails mutableCopy];
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
        }case Follow: {
            NSDictionary * dictMessage = [NSDictionary new];
            if (_chatHistory.count > selectedChatIndexPath.row) {
                dictMessage = [_chatHistory objectAtIndex:selectedChatIndexPath.row];
            }
            [self followUnFollowMsg:true dict:dictMessage];
            break;
        }case Report: {
            //ReportsMessageViewController * _vcMessage = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"ReportsMessageViewController"];
            // _vcMessage.dictMessage = _chatHistory[selectedChatIndexPath.row];
            // [self.navigationController pushViewController:_vcMessage animated:YES];
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
    //    NSDictionary *myDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"Test123", @"abc", nil];
    //    NSData *data1 = [NSJSONSerialization dataWithJSONObject:myDictionary options:NSJSONWritingPrettyPrinted error:nil];
    //    NSString *jsonString = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
    //    [dictDeleteMessage setObject:jsonString forKey:customData];
    
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

-(JSQMessage*) getMediaItemFrom:(NSMutableDictionary*) dict indexPath:(NSIndexPath *)path {
    
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
        double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
        NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
        NSString *strMessage = @"";
        if ([dict[@"replyMsgConfig"] boolValue]){
            NSString *parentMsg = dict[Parent_Msg];
            if ([parentMsg length] > 35) {
                NSRange range = [parentMsg rangeOfComposedCharacterSequencesForRange:(NSRange){0, 35}];
                parentMsg = [parentMsg substringWithRange:range];
                parentMsg = [parentMsg stringByAppendingString:@"…"];
            }
            strMessage = [NSString stringWithFormat:@"Replied to a thread:%@\n%@",parentMsg,dict[Message]];
        }else if (![dict[IsDeletedMSG] boolValue]  && [dict[IsEdited] boolValue]){
            strMessage = [NSString stringWithFormat:@"%@%@",dict[Message],EditedString];
        }else if (![dict[IsDeletedMSG] boolValue] && [dict[IsForwarded] boolValue]){
            strMessage = [NSString stringWithFormat:@"%@\n%@",ForwardedString, dict[Message]];
        }else {
            strMessage = dict[Message];
        }
        id sendereRTCUserId = dict[@"sendereRTCUserId"];
        __block NSString *userName = self.senderDisplayName;
        if (sendereRTCUserId != NULL){
            [_arrAllUsers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj[@"userId"] != NULL && [sendereRTCUserId isEqual:obj] && obj[@"name"]){
                    userName = obj[@"name"];
                }
            }];
            
            NSURL *first = [Helper getFirstUrlIfExistInMessage:strMessage];
            double timeStamp = [[dict valueForKey:@"createdAt"]doubleValue];
            NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
            if (first){
                //                JSQLinkPreviewMediaItem *item = [[JSQLinkPreviewMediaItem alloc] initWithURL:first details:dict completionHandler:^(NSDictionary * _Nonnull details, NSError * _Nullable error) {
                //
                //                }];
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
        NSLog(@"msgdate>>>>>>>>>>>>%@>>>>>>timeStamp",msgdate,timeStamp);
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
                                                                  text:[NSString stringWithFormat:@"%@",strContactPersonName]]; // \n%@ dictNumber[Number]
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


-(void)updateMessageCellAtIndexPath:(NSIndexPath*)path message:(NSDictionary*)details{
    [[eRTCCoreDataManager sharedInstance] getUserChatHistoryWithThreadID:self.strThreadId andCompletionHandler:^(id ary, NSError *err) {
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

- (void)recentChatReactionDelegate:(int)tagId selectedIndexPath:(NSIndexPath *)indexPath emojiCode:(NSString *)message {
    if (tagId == 106) {
        EmojisViewController *emojisVC = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"EmojisViewController"];
        emojisVC.delegate = self;
        emojisVC.selectedIndexPath = indexPath;
        [self presentPanModal:emojisVC];
    } else {
        NSInteger path = indexPath.row;
        NSMutableArray *arrdata = nil;
        arrdata = self.message;
        NSMutableDictionary * dictMessage = [NSMutableDictionary new];
        if (_chatHistory.count > indexPath.row) {
            dictMessage = [[_chatHistory objectAtIndex:path] mutableCopy];
        }
        
        [[eRTCChatManager sharedChatInstance] sendTextReactionWithParam:[NSString stringWithFormat:@"%@", [dictMessage valueForKey:@"msgUniqueId"]] andEmojiCode:message andEmojiAction:@"set" andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            
            
            if([json isKindOfClass:[NSDictionary class]]) {
                if (![Helper stringIsNilOrEmpty:json[@"success"]]) {
                    self.isScrollToBottom = NO;
                    NSString *strSuccess = [NSString stringWithFormat:@"%@", json[@"success"]];
                    if ([strSuccess intValue] == 0) {
                        if (![Helper stringIsNilOrEmpty:json[Key_Message]]) {
                            [Helper showAlertOnController:@"eRTC" withMessage:json[Key_Message] onController:self];
                        }
                    }
                    // [dictMessage setValue:@true forKey:@"Is_reaction"];
                    [self updateMessageCellAtIndexPath:indexPath message:dictMessage];
                }
            }
        } andFailure:^(NSError * _Nonnull error) {
            NSLog(@"Error -->%@", error);
            NSString *errMsg = [NSString stringWithFormat:@"%@", error.localizedDescription];
            [self performSelector:@selector(showAlert:) withObject:errMsg afterDelay:0.3];
            // [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
        }];
        
        
    }
}

- (void)sendMesage:(NSString *)message selectedindexPath:(NSIndexPath *)indexpath {
    
    NSMutableArray *arrdata = nil;
    arrdata = self.message;
    
    NSMutableDictionary * dictMessage = [NSMutableDictionary new];
    if (_chatHistory.count > indexpath.row) {
        dictMessage = [_chatHistory objectAtIndex:indexpath.row];
        
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
                [self updateMessageCellAtIndexPath:indexpath message:dictMessage];
            }
        }
    } andFailure:^(NSError * _Nonnull error) {
        NSLog(@"Error -->%@", error);
        NSString *errMsg = [NSString stringWithFormat:@"%@", error.localizedDescription];
        [self performSelector:@selector(showAlert:) withObject:errMsg afterDelay:0.3];
        
    }];
}

#pragma mark - ButtonUndo
-(void)btnUndoChatMessage:(NSIndexPath *)indexPath {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
        NSMutableDictionary * dictMessage = [NSMutableDictionary new];
        dictMessage = [_chatHistory objectAtIndex:indexPath.row];
        NSString *chatReportId = dictMessage[Chat_ReportId];
        
        [[eRTCChatManager sharedChatInstance] undoChatReport:@{@"chatReportId": chatReportId} andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            [KVNProgress dismiss];
            NSDictionary *dictResponse = (NSDictionary *)json;
            if (dictResponse[@"success"] != nil) {
                BOOL success = (BOOL)dictResponse[@"success"];
                if (success) {
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
    
    NSMutableArray *arrdata = nil;
    arrdata = self.message;
    NSMutableDictionary * dictMessage = [NSMutableDictionary new];
    if (_chatHistory.count > indexPath.row) {
        dictMessage = [_chatHistory objectAtIndex:indexPath.row];
    }
    NSDictionary *myDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"Test123", @"abc", nil];
    NSData *data1 = [NSJSONSerialization dataWithJSONObject:myDictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
    NSString *emojiCode = [[string componentsSeparatedByString:@" "] objectAtIndex:0];
    
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
    if (reactedByMe) {
        
        [[eRTCChatManager sharedChatInstance] sendTextReactionWithParam:[NSString stringWithFormat:@"%@", [dictMessage valueForKey:@"msgUniqueId"]] andEmojiCode:emojiCode andEmojiAction:@"clear" andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            
            [self updateMessageCellAtIndexPath:indexPath message:dictMessage];
        }andFailure:^(NSError * _Nonnull error) {
            NSLog(@"Error -->%@", error);
            NSString *errMsg = [NSString stringWithFormat:@"%@", error.localizedDescription];
            [self performSelector:@selector(showAlert:) withObject:errMsg afterDelay:0.3];
            // [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
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

- (void)logOutUser{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:IsLoggedIn];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[UserModel sharedInstance]logOutUser];
    [[AppDelegate sharedAppDelegate] willChangeLoginAsRootOfApplication];
}

-(IBAction)btnMoreOptions:(id)sender{
    if([_dictUserDetails[@"blockedStatus"] isEqualToString:@"blocked"]) {
        blockUnblockUser = @"unblock";
    }else{
        blockUnblockUser = @"block";
    }
    
    UIAlertController *activitySheet = [UIAlertController alertControllerWithTitle:nil
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *editChannelInfo = [UIAlertAction actionWithTitle:NSLocalizedString(@"Preferences", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self pushToPreferencesVC];
    }];
    
    UIAlertAction *manageNotification = [UIAlertAction actionWithTitle:NSLocalizedString([self->blockUnblockUser.capitalizedString stringByAppendingString:@" user"], nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([self->blockUnblockUser.capitalizedString isEqualToString:@"Block"]){
            [self blockUserStatus:true];
        }else if ([self->blockUnblockUser.capitalizedString isEqualToString:@"Unblock"]){
            [self blockUserStatus:false];
        }
    }];
    UIAlertAction *clearChat = [UIAlertAction actionWithTitle:NSLocalizedString(@"Clear chat history", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [Helper showAlert:Clear_Chat_History message:msgClearChatHistory btnYes:@"Clear" btnNo:@"Cancel" inViewController:self completedWithBtnStr:^(NSString* btnString) {
            if ([btnString isEqualToString:@"Clear"]) {
                [self clearChatHistory];
            }
        }];
        
    }];
    UIAlertAction *deleteChannel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Mute conversation", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [activitySheet addAction:manageNotification];
    // [activitySheet addAction:editChannelInfo];
    if (_chatHistory.count > 0) {
        [activitySheet addAction:clearChat];
    }
    //[activitySheet addAction:deleteChannel];
    UIAlertAction *leaveChannel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete conversation", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [Helper showAlert:Delete_conversation message:msg_Delete_conversation btnYes:@"Delete" btnNo:@"Cancel" inViewController:self completedWithBtnStr:^(NSString* btnString) {
            if ([btnString isEqualToString:@"Delete"]) {
                
            }
        }];
    }];
    //[activitySheet addAction:leaveChannel];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [activitySheet addAction:cancel];
    [self presentViewController:activitySheet animated:YES completion:nil];
}


-(void)clearChatHistory {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
        NSDictionary*dictMessage = _chatHistory[0];
        NSString *threadId = dictMessage[ThreadID];
        [[eRTCChatManager sharedChatInstance] clearChatHistoryBy:threadId andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            [KVNProgress dismiss];
            [self.view makeToast:ChatMsgClearSuccess];
            [self.navigationController popToRootViewControllerAnimated:NO];
        }andFailure:^(NSError * _Nonnull error) {
            
        }];
    } else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}

- (void)pushToPreferencesVC {
    PreferencesVC *_vcChangePwd = [[Helper mainStoryBoard] instantiateViewControllerWithIdentifier:@"PreferencesVC"];
    [self.navigationController pushViewController:_vcChangePwd animated:YES];
}

-(void)showDisappearing:(BOOL *)isDisappering {
    if (isDisappering) {
        NSTimeInterval delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self->bottemView = [[UIView alloc] initWithFrame:CGRectMake(16, -90, self.collectionView.bounds.size.width-32, 80)];
            UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(48, 5, self.collectionView.bounds.size.width-70, 60)];
            UIImageView *imageNowifi = [[UIImageView alloc] initWithFrame:CGRectMake(16, 20, 24, 24)];
            self->bottemView.layer.cornerRadius = 10;
            [self->bottemView setBackgroundColor:[UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1]];
            lblTitle.textColor = [UIColor colorWithRed:113/255.0 green:134/255.0 blue:156/255.0 alpha:1];//rgba(113, 134, 156, 1)
            lblTitle.text = DissapearingMsg;
            [imageNowifi setImage:[UIImage imageNamed:@"DisappearingIcon"]];
            [lblTitle setFont:[UIFont fontWithName:@"SFProDisplay-Regular" size:14.0]];
            lblTitle.numberOfLines = 0;
            lblTitle.textAlignment = NSTextAlignmentLeft;
            [self->bottemView addSubview:lblTitle];
            [self->bottemView addSubview:imageNowifi];
            [self.inputToolbar addSubview:self->bottemView];
            NSTimeInterval delayInSec = 5.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSec * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self->bottemView removeFromSuperview];
            });
            //[self.navigationController.view addSubview:self->bottemView];
        });
    }else{
        [bottemView removeFromSuperview];
    }
}

-(void)selectedUndoButton:(UITableViewCell *)cell {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        // [KVNProgress show];
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        NSMutableDictionary * dictMessage = [NSMutableDictionary new];
        dictMessage = [_chatHistory objectAtIndex:indexPath.row];
        NSString *chatReportId = dictMessage[Chat_ReportId];
        
        [[eRTCChatManager sharedChatInstance] undoChatReport:@{@"chatReportId": chatReportId} andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            //[KVNProgress dismiss];
            NSDictionary *dictResponse = (NSDictionary *)json;
            if (dictResponse[@"success"] != nil) {
                BOOL success = (BOOL)dictResponse[@"success"];
                NSString *msg = dictResponse[@"msg"];
                [self.view makeToast:msg];
                if (success) {
                    [self getChatHistory];
                }
            }
        }andFailure:^(NSError * _Nonnull error) {
            [KVNProgress dismiss];
            [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
        }];
    }else{
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}

//https://socket-qa.ripbullertc.com/V1/tenants/61fb98a992337a45158882ac/622af3b92c3642905507260b/chatReports/622ee2b32c364290550b14da

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
   // [self.inputToolbar.contentView.rightBarButtonItem setHidden:YES];
    
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
   // [self.inputToolbar.contentView.rightBarButtonItem setHidden:YES];
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

-(void)blockUserStatus:(BOOL)isBlockUser {
    NSMutableDictionary *copy = _dictUserDetails.mutableCopy;
    NSString *strBlockMsg = @"";
    if (isBlockUser){
        blockUnblockUser = @"block";
        copy[BlockedStatus] = @"blocked";
        strBlockMsg = Block_MsgBlocked;
        
    }else{
        copy[BlockedStatus] = @"unblocked";
        blockUnblockUser = @"unblock";
        strBlockMsg = Block_Msg;
    }
    
    [Helper showAlert:[self->blockUnblockUser.capitalizedString stringByAppendingString:@" User?"] message:Block_Msg btnYes:blockUnblockUser.capitalizedString btnNo:@"Cancel" inViewController:self completedWithBtnStr:^(NSString* btnString) {
        if ([btnString.capitalizedString isEqualToString:self->blockUnblockUser.capitalizedString]) {
            [KVNProgress show];
            NSString*strAppUserID  =   self.dictUserDetails[App_User_ID];
            NSMutableDictionary*dict = [[NSMutableDictionary alloc]init];
            [dict setValue:strAppUserID forKey:App_User_ID];
            [dict setValue:self->blockUnblockUser forKey:@"blockUnblock"];
            [[eRTCAppUsers sharedInstance] ContactblockUnblock:dict andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                [KVNProgress dismiss];
                NSMutableDictionary *_dic = self->_dictUserDetails.mutableCopy;
                NSDictionary *dictResponse = (NSDictionary *)json;
                if (dictResponse[@"success"] != nil) {
                    BOOL success = (BOOL)dictResponse[@"success"];
                    if (success) {
                        if ([self->blockUnblockUser isEqualToString:@"block"]){
                            _dic[BlockedStatus] = @"blocked";
                            self->_dictUserDetails = _dic;
                            [self showBlockUI];
                            self->blockUnblockUser = @"unblock";
                        }else if ([self->blockUnblockUser isEqualToString:@"unblock"]){
                            _dic[BlockedStatus] = @"unblocked";
                            self->_dictUserDetails = _dic;
                            self->blockUnblockUser = @"block";
                            [self unblockUI];
                        }
                    }
                }
            } andFailure:^(NSError * _Nonnull error) {
                [KVNProgress dismiss];
                NSString *errMsg = [NSString stringWithFormat:@"%@", error.localizedDescription];
                [self performSelector:@selector(showAlert:) withObject:errMsg afterDelay:0.3];
            }] ;
        }
    }];
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

-(void)showUserBlock:(BOOL *)blockUnBlock {
    if (blockUnBlock) {
        NSTimeInterval delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self->bottemView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-70, self.view.bounds.size.width, 70)];
            UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 70)];
            [self->bottemView setBackgroundColor:UIColor.redColor];
            lblTitle.textColor = UIColor.whiteColor;
            lblTitle.text = @"You have blocked this user";
            lblTitle.textAlignment = NSTextAlignmentCenter;
            [lblTitle setFont:[UIFont fontWithName:@"SFProDisplay-Semibold" size:18.0]];
            lblTitle.numberOfLines = 0;
            [self->bottemView addSubview:lblTitle];
            [self.view addSubview:self->bottemView];
        });
    }else{
        [bottemView removeFromSuperview];
    }
}

/*
 NSMutableAttributedString *stringMessage = [[NSMutableAttributedString alloc] initWithString:message];
 NSError *error = nil;
 NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<@+[a-zA-Z0-9._ @-]+>|<@channel>|<@here>" options:0 error:&error];
 NSArray *matchData = [regex matchesInString:message options:0 range:NSMakeRange(0, message.length)];
  NSString *mentionString = [stringMessage.mutableString stringByReplacingOccurrencesOfString:@"<" withString:@" "];
  NSString *strMention = [mentionString stringByReplacingOccurrencesOfString:@">" withString:@" "];
  stringMessage = [[NSMutableAttributedString alloc] initWithString:strMention];
 for (NSTextCheckingResult *match in matchData) {
 NSRange wordRange = [match rangeAtIndex:0];
 NSString *name = [message substringWithRange:wordRange];
 NSArray *list = [name componentsSeparatedByString:@" "];
 NSMutableSet *set = [[NSMutableSet alloc] initWithObjects:[name stringByReplacingOccurrencesOfString:@"@" withString:@""], nil];
 for(NSString *item in set)
 {
     if ([name isKindOfClass:[NSString class]]){
         wordRange.length = item.length;
         [stringMessage addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:wordRange];
     }
 }
}
 return stringMessage;
 */


@end
