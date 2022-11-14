//  ForwardToViewController.m
//  eRTCApp


#import "ForwardToViewController.h"
#import "SingleChatViewController.h"
#import "GroupChatViewController.h"
#import "ThreadChatViewController.h"
#import "ThreadChatGroupViewController.h"
#import <Toast/Toast.h>

@interface ForwardToViewController () {
    NSArray *_arySectionIndexTitle;
    NSMutableDictionary *_dictParticipantsContacts;
    NSMutableDictionary *_dictParticipantsGroups;
    NSMutableArray *arraySelectedParticipants;
    BOOL isContacts;
    UIBarButtonItem *forwardButton;
}

@end

@implementation ForwardToViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncContactDB:) name:ContactDBUpdatedNotification object:nil];
    if (@available(iOS 13.0, *)) {
        self.segmentControl.selectedSegmentTintColor = [UIColor whiteColor];
        NSDictionary *selectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                            [UIColor systemBlueColor], NSForegroundColorAttributeName,
                                            nil];
        [self.segmentControl setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];
        NSDictionary *unselectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                              [UIColor whiteColor], NSForegroundColorAttributeName,
                                              nil];
        [self.segmentControl setTitleTextAttributes:unselectedAttributes forState:UIControlStateNormal];
    } else {
        self.segmentControl.backgroundColor = [UIColor whiteColor];
        NSDictionary *selectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                            [UIColor whiteColor], NSForegroundColorAttributeName,
                                            nil];
        [self.segmentControl setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];
        NSDictionary *unselectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                              [UIColor systemBlueColor], NSForegroundColorAttributeName,
                                              nil];
        [self.segmentControl setTitleTextAttributes:unselectedAttributes forState: UIControlStateNormal];
    }
    isContacts = true;
    self.tableView.estimatedRowHeight = 50;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self callAPIForGetGroupList];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setUpUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)setUpUI {
    self.arraySelectedParticipantsContacts = [NSMutableArray new];
    self.arraySelectedParticipantsGroups = [NSMutableArray new];
//    [self.btnContacts setTitleColor:[UIColor colorWithRed:0.443f green:0.525f blue:0.612f alpha:1.0] forState:UIControlStateNormal];
//    [self.btnGroups setTitleColor:[UIColor colorWithRed:0.443f green:0.525f blue:0.612f alpha:0.5] forState:UIControlStateNormal];
//    [self.btnContacts setSelected:YES];
//    [self.btnGroups setSelected:NO];
//    self.navigationController.navigationBar.topItem.title = @"";
    self.navigationItem.title = @"Forward";
    
    [self rightBarButtonItem];
    [self performSelector:@selector(callAPIForGetChatUserList) withObject:nil afterDelay:0.5];
    [self setupTableView];
}

- (void)rightBarButtonItem {
//    UIBarButtonItem *forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forwardIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(btnForwardClicked:)];
    forwardButton = [[UIBarButtonItem alloc] initWithTitle:@"Forward" style:UIBarButtonItemStylePlain target:self action:@selector(btnForwardClicked:)];
    self.navigationItem.rightBarButtonItem = forwardButton;
    
    [forwardButton setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor systemBlueColor], NSFontAttributeName:[UIFont fontWithName:@"SFProDisplay-Medium" size:17]} forState:UIControlStateNormal];
    [forwardButton setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor grayColor], NSFontAttributeName:[UIFont fontWithName:@"SFProDisplay-Medium" size:17]} forState:UIControlStateDisabled];
    [forwardButton setEnabled:FALSE];
}
-(void) updateUI{
    NSUInteger totalCount = self.arraySelectedParticipantsGroups.count + self.arraySelectedParticipantsContacts.count;
    if (forwardButton && totalCount > 0){
        [forwardButton setEnabled:TRUE];
    }else {
        [forwardButton setEnabled:FALSE];
    }
}
- (void)backToTheChatScreen:(NSMutableArray *)arrDataParticipants {
    if (_isGallery) {
        [self.navigationController popViewControllerAnimated:true];
    }else{
    NSArray *vcs = [[self.navigationController.viewControllers reverseObjectEnumerator] allObjects];
    for (UIViewController *obj in vcs) {
        BOOL isChatScreen = ([obj isKindOfClass:ThreadChatViewController.class] || [obj isKindOfClass:ThreadChatGroupViewController.class] || [obj isKindOfClass:SingleChatViewController.class] || [obj isKindOfClass:GroupChatViewController.class]);
        if (isChatScreen) {
            [self.navigationController popToViewController:obj animated:TRUE];
            [obj.view makeToast:@"Message forwarded" duration:1 position:CSToastPositionCenter];
            if ([obj isKindOfClass:JSQMessagesViewController.class]){
                JSQMessagesViewController *jsqVC = (JSQMessagesViewController*)obj;
                NSString *senderID = jsqVC.senderId;
                
                for (NSDictionary*details in arrDataParticipants) {
                    if (details[@"sendereRTCUserId"] != NULL && [obj isKindOfClass:SingleChatViewController.class] && [senderID isEqualToString:details[@"sendereRTCUserId"]]){
                        SingleChatViewController *sch = (SingleChatViewController*)obj;
                        [sch refreshChatData];
                        break;
                    }else if (details[@"threadId"] != NULL && [obj isKindOfClass:GroupChatViewController.class]) {
                        GroupChatViewController *sch = (GroupChatViewController*)obj;
                        if (sch.strThreadId != NULL && [sch.strThreadId isEqualToString:details[@"threadId"]]){
                            [sch refreshChatData];
                            break;
                        }
                        
                    }
                }
            }
            break;
        }
    }
        
    }
}

- (void)forwardMessage:(NSMutableArray *)arrDataParticipants {
    [KVNProgress show];
    
//    NSDictionary *myDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"Test123", @"abc", nil];
//    NSData *data1 = [NSJSONSerialization dataWithJSONObject:myDictionary options:NSJSONWritingPrettyPrinted error:nil];
//    NSString *jsonString = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
//    [arrDataParticipants setValue:jsonString forKey:customData];
      //[dictParam setObject:self.dictUserDetails[User_eRTCUserId] forKey:User_eRTCUserId];
    
    
    [[eRTCChatManager sharedChatInstance] ForwardMultiMessageWithParam:arrDataParticipants andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        [KVNProgress dismiss];
        NSDictionary *dictResponse = (NSDictionary *)json;
        if (dictResponse[@"success"] != nil) {
            BOOL success = (BOOL)dictResponse[@"success"];
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([[[[AppDelegate sharedAppDelegate] window] rootViewController] isKindOfClass:[eRTCTabBarViewController class]]) {
                        eRTCTabBarViewController *controller = [[[AppDelegate sharedAppDelegate] window] rootViewController];
                        controller.selectedIndex = 0;
                        [self backToTheChatScreen:arrDataParticipants];
                    }
                });
            }
        }
    } andFailure:^(NSError * _Nonnull error) {
        [KVNProgress dismiss];
        NSLog(@"error--> %@",error);
        [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
    }];
}

- (void)btnForwardClicked:(id)sender {
    
    BOOL enableSend = NO;
    if (self.arraySelectedParticipantsContacts.count > 0) {
        enableSend = YES;
    }
    if (self.arraySelectedParticipantsGroups.count > 0) {
        enableSend = YES;
    }
    if (enableSend) {
        if ([self.dictMessageDetails[@"msgType"] isEqualToString:@"text"]) {
            if (self.dictMessageDetails[@"message"] != nil && self.dictMessageDetails[@"message"] != [NSNull null]) {
                if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil) {
                    NSMutableArray *arrDataContacts = [NSMutableArray new];
                    NSMutableArray *arrDataGroups = [NSMutableArray new];
                    NSMutableArray *arrDataParticipants = [NSMutableArray new];
                    arrDataGroups = [self createDataSourceForwardChat:self.arraySelectedParticipantsGroups messageType:@"text"];
                    arrDataContacts = [self createDataSourceForwardChat:self.arraySelectedParticipantsContacts messageType:@"text"];
                    if (arrDataContacts.count > 0) {
                        [arrDataParticipants addObjectsFromArray:arrDataContacts];
                    }
                    if (arrDataGroups.count > 0) {
                        [arrDataParticipants addObjectsFromArray:arrDataGroups];
                    }
                    
                    [self forwardMessage:arrDataParticipants];
                }
            }
        }
        else if ([self.dictMessageDetails[@"msgType"] isEqualToString:@"image"]) {
            if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil) {
                NSMutableArray *arrDataContacts = [NSMutableArray new];
                NSMutableArray *arrDataGroups = [NSMutableArray new];
                NSMutableArray *arrDataParticipants = [NSMutableArray new];
                arrDataGroups = [self createDataSourceForwardChat:self.arraySelectedParticipantsGroups messageType:@"image"];
                arrDataContacts = [self createDataSourceForwardChat:self.arraySelectedParticipantsContacts messageType:@"image"];
                if (arrDataContacts.count > 0) {
                    [arrDataParticipants addObjectsFromArray:arrDataContacts];
                }
                if (arrDataGroups.count > 0) {
                    [arrDataParticipants addObjectsFromArray:arrDataGroups];
                }
                [self forwardMessage:arrDataParticipants];
            }
        }
        else if ([self.dictMessageDetails[@"msgType"] isEqualToString:@"contact"]) {
            if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil) {
                NSMutableArray *arrDataContacts = [NSMutableArray new];
                NSMutableArray *arrDataGroups = [NSMutableArray new];
                NSMutableArray *arrDataParticipants = [NSMutableArray new];
                arrDataGroups = [self createDataSourceForwardChat:self.arraySelectedParticipantsGroups messageType:@"contact"];
                arrDataContacts = [self createDataSourceForwardChat:self.arraySelectedParticipantsContacts messageType:@"contact"];
                if (arrDataContacts.count > 0) {
                    [arrDataParticipants addObjectsFromArray:arrDataContacts];
                }
                if (arrDataGroups.count > 0) {
                    [arrDataParticipants addObjectsFromArray:arrDataGroups];
                }
                [self forwardMessage:arrDataParticipants];
            }
        }
        else if ([self.dictMessageDetails[@"msgType"] isEqualToString:@"location"]){
               if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil) {
                   NSMutableArray *arrDataContacts = [NSMutableArray new];
                   NSMutableArray *arrDataGroups = [NSMutableArray new];
                   NSMutableArray *arrDataParticipants = [NSMutableArray new];
                   arrDataGroups = [self createDataSourceForwardChat:self.arraySelectedParticipantsGroups messageType:@"location"];
                   arrDataContacts = [self createDataSourceForwardChat:self.arraySelectedParticipantsContacts messageType:@"location"];
                   if (arrDataContacts.count > 0) {
                       [arrDataParticipants addObjectsFromArray:arrDataContacts];
                   }
                   if (arrDataGroups.count > 0) {
                       [arrDataParticipants addObjectsFromArray:arrDataGroups];
                   }
                   [self forwardMessage:arrDataParticipants];
               }
           }
        else if ([self.dictMessageDetails[@"msgType"] isEqualToString:@"gify"]) {
                if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil) {
                    NSMutableArray *arrDataContacts = [NSMutableArray new];
                    NSMutableArray *arrDataGroups = [NSMutableArray new];
                    NSMutableArray *arrDataParticipants = [NSMutableArray new];
                    arrDataGroups = [self createDataSourceForwardChat:self.arraySelectedParticipantsGroups messageType:@"gify"];
                    arrDataContacts = [self createDataSourceForwardChat:self.arraySelectedParticipantsContacts messageType:@"gify"];

                    if (arrDataContacts.count > 0) {
                        [arrDataParticipants addObjectsFromArray:arrDataContacts];
                    }
                    if (arrDataGroups.count > 0) {
                        [arrDataParticipants addObjectsFromArray:arrDataGroups];
                    }
                    [self forwardMessage:arrDataParticipants];
                }
            }
        else if ([self.dictMessageDetails[@"msgType"] isEqualToString:@"video"]){
            if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil) {
                NSMutableArray *arrDataContacts = [NSMutableArray new];
                NSMutableArray *arrDataGroups = [NSMutableArray new];
                NSMutableArray *arrDataParticipants = [NSMutableArray new];
                arrDataGroups = [self createDataSourceForwardChat:self.arraySelectedParticipantsGroups messageType:@"video"];
                arrDataContacts = [self createDataSourceForwardChat:self.arraySelectedParticipantsContacts messageType:@"video"];
                
                if (arrDataContacts.count > 0) {
                    [arrDataParticipants addObjectsFromArray:arrDataContacts];
                }
                if (arrDataGroups.count > 0) {
                    [arrDataParticipants addObjectsFromArray:arrDataGroups];
                }
                [self forwardMessage:arrDataParticipants];
            }
        }
        else if ([self.dictMessageDetails[@"msgType"] isEqualToString:@"audio"]){
            if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId] != nil) {
                NSMutableArray *arrDataContacts = [NSMutableArray new];
                NSMutableArray *arrDataGroups = [NSMutableArray new];
                NSMutableArray *arrDataParticipants = [NSMutableArray new];
                arrDataGroups = [self createDataSourceForwardChat:self.arraySelectedParticipantsGroups messageType:@"audio"];
                arrDataContacts = [self createDataSourceForwardChat:self.arraySelectedParticipantsContacts messageType:@"audio"];
                
                if (arrDataContacts.count > 0) {
                    [arrDataParticipants addObjectsFromArray:arrDataContacts];
                }
                if (arrDataGroups.count > 0) {
                    [arrDataParticipants addObjectsFromArray:arrDataGroups];
                }
                [self forwardMessage:arrDataParticipants];
            }
        }
    } else {
        [Helper showAlertOnController:@"eRTC" withMessage:@"Please select atleast one recipient" onController:self];
    }
}

- (NSMutableArray *)createDataSourceForwardChat:(NSArray *)forwardUserData messageType:(NSString *)strType {
    NSMutableArray *arrData = [NSMutableArray new];
    if ([strType isEqualToString:@"text"]) {
        for (NSMutableDictionary *dictData in forwardUserData) {
            NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
            NSString *groupOrUserId = @"";
            NSInteger isThreadIdPresent = 0;
                if (dictData[@"threadId"] != nil && dictData[@"threadId"] != [NSNull null]) {
                    groupOrUserId = dictData[@"threadId"];
                    isThreadIdPresent = 1;
                } else  {
                    groupOrUserId = dictData[App_User_ID];
                }
//            }
            
            if (groupOrUserId != nil && groupOrUserId != [NSNull null] && ![groupOrUserId isEqualToString:@""]) {
                NSMutableDictionary * dictParam = [NSMutableDictionary new];
                [dictParam setObject:userId forKey:SendereRTCUserId];
                [dictParam setObject:self.dictMessageDetails[@"message"] forKey:Message];
                if (dictData[User_eRTCUserId] != nil && dictData[User_eRTCUserId] != [NSNull null]) {
                    [dictParam setObject:dictData[User_eRTCUserId] forKey:User_eRTCUserId];
                }
                
                [dictParam setObject:@"text" forKey:MsgType];
                [dictParam setObject:self.dictMessageDetails[MsgUniqueId] forKey:@"originalMsgUniqueId"];
                if(isThreadIdPresent) {
                    [dictParam setObject:groupOrUserId forKey:@"threadId"];
                } else {
                    [dictParam setObject:groupOrUserId forKey:@"recipientAppUserId"];
                }
                [arrData addObject:dictParam];
            }
        }
    }
    else if ([strType isEqualToString:@"image"]) {
        for (NSMutableDictionary *dictData in forwardUserData) {
            NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
            NSString *groupOrUserId = @"";
            NSInteger isThreadIdPresent = 0;
//            if (self.isGroup) {
//                groupOrUserId = self.dictUserDetails[Group_GroupId];
//                isThreadIdPresent = 1;
//            } else {
                if (dictData[@"threadId"] != nil && dictData[@"threadId"] != [NSNull null]) {
                    groupOrUserId = dictData[@"threadId"];
                    isThreadIdPresent = 1;
                } else  {
                    groupOrUserId = dictData[App_User_ID];
                }
//            }
            if (groupOrUserId != nil && groupOrUserId != [NSNull null] && ![groupOrUserId isEqualToString:@""]) {
                NSMutableDictionary * dictParam = [NSMutableDictionary new];
                [dictParam setObject:userId forKey:SendereRTCUserId];
                NSDictionary *dictMedia = [NSDictionary dictionaryWithDictionary:self.dictMessageDetails[@"media"]];
                [dictParam setObject:dictMedia forKey:@"media"];
                NSString *type = [NSString stringWithFormat:@"%@",self.dictMessageDetails[@"msgType"]];
                [dictParam setObject:type forKey:MsgType];
                [dictParam setObject:self.dictMessageDetails[MsgUniqueId] forKey:@"originalMsgUniqueId"];
                if(isThreadIdPresent) {
                    [dictParam setObject:groupOrUserId forKey:@"threadId"];
                } else {
                    [dictParam setObject:groupOrUserId forKey:@"recipientAppUserId"];
                }
                [dictParam setObject:self.dictMessageDetails[LocalFilePath] forKey:LocalFilePath];
                [dictParam setObject:self.dictMessageDetails[@"mediaFileName"] forKey:@"mediaFileName"];
                [arrData addObject:dictParam];
            }
        }
    }
    else if ([strType isEqualToString:@"contact"]) {
        for (NSMutableDictionary *dictData in forwardUserData) {
            NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
            NSString *groupOrUserId = @"";
            NSInteger isThreadIdPresent = 0;
//            if (self.isGroup) {
//                groupOrUserId = self.dictUserDetails[Group_GroupId];
//                isThreadIdPresent = 1;
//            } else {
                if (dictData[@"threadId"] != nil && dictData[@"threadId"] != [NSNull null]) {
                    groupOrUserId = dictData[@"threadId"];
                    isThreadIdPresent = 1;
                } else  {
                    groupOrUserId = dictData[App_User_ID];
                }
//            }
            if (groupOrUserId != nil && groupOrUserId != [NSNull null] && ![groupOrUserId isEqualToString:@""]) {
                NSMutableDictionary * dictParam = [NSMutableDictionary new];
                [dictParam setObject:userId forKey:SendereRTCUserId];
                NSDictionary *dictContact = [NSDictionary dictionaryWithDictionary:self.dictMessageDetails[@"contact"]];
                [dictParam setObject:dictContact forKey:@"contact"];
                if (dictData[User_eRTCUserId] != nil && dictData[User_eRTCUserId] != [NSNull null]) {
                    [dictParam setObject:dictData[User_eRTCUserId] forKey:User_eRTCUserId];
                }
                NSString *type = [NSString stringWithFormat:@"%@",self.dictMessageDetails[@"msgType"]];
                [dictParam setObject:type forKey:MsgType];
                [dictParam setObject:self.dictMessageDetails[MsgUniqueId] forKey:@"originalMsgUniqueId"];
                if(isThreadIdPresent) {
                    [dictParam setObject:groupOrUserId forKey:@"threadId"];
                } else {
                    [dictParam setObject:groupOrUserId forKey:@"recipientAppUserId"];
                }
//                    [dictParam setObject:self.dictMessageDetails[LocalFilePath] forKey:LocalFilePath];
//                    [dictParam setObject:self.dictMessageDetails[@"mediaFileName"] forKey:@"mediaFileName"];
                [arrData addObject:dictParam];
            }
        }
    }
    else if ([strType isEqualToString:@"gify"]) {
            for (NSMutableDictionary *dictData in forwardUserData) {
                NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
                NSString *groupOrUserId = @"";
                NSInteger isThreadIdPresent = 0;
    //            if (self.isGroup) {
    //                groupOrUserId = self.dictUserDetails[Group_GroupId];
    //                isThreadIdPresent = 1;
    //            } else {
                    if (dictData[@"threadId"] != nil && dictData[@"threadId"] != [NSNull null]) {
                        groupOrUserId = dictData[@"threadId"];
                        isThreadIdPresent = 1;
                    } else  {
                        groupOrUserId = dictData[App_User_ID];
                    }
    //            }
                if (groupOrUserId != nil && groupOrUserId != [NSNull null] && ![groupOrUserId isEqualToString:@""]) {
                    NSMutableDictionary * dictParam = [NSMutableDictionary new];
                    [dictParam setObject:userId forKey:SendereRTCUserId];
                    NSString *gifStr = self.dictMessageDetails[@"gify"];
                    [dictParam setObject:gifStr forKey:@"gify"];
                    if (dictData[User_eRTCUserId] != nil && dictData[User_eRTCUserId] != [NSNull null]) {
                        [dictParam setObject:dictData[User_eRTCUserId] forKey:User_eRTCUserId];
                    }
                    NSString *type = [NSString stringWithFormat:@"%@",self.dictMessageDetails[@"msgType"]];
                    [dictParam setObject:type forKey:MsgType];
                    [dictParam setObject:self.dictMessageDetails[MsgUniqueId] forKey:@"originalMsgUniqueId"];
                    if(isThreadIdPresent) {
                        [dictParam setObject:groupOrUserId forKey:@"threadId"];
                    } else {
                        [dictParam setObject:groupOrUserId forKey:@"recipientAppUserId"];
                    }
                    [dictParam setObject:self.dictMessageDetails[LocalFilePath] forKey:LocalFilePath];
                    [dictParam setObject:self.dictMessageDetails[@"mediaFileName"] forKey:@"mediaFileName"];
                    [arrData addObject:dictParam];
                }
            }
        }
    else if ([strType isEqualToString:@"location"]) {
            for (NSMutableDictionary *dictData in forwardUserData) {
                NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
                NSString *groupOrUserId = @"";
                NSInteger isThreadIdPresent = 0;
    //            if (self.isGroup) {
    //                groupOrUserId = self.dictUserDetails[Group_GroupId];
    //                isThreadIdPresent = 1;
    //            } else {
                    if (dictData[@"threadId"] != nil && dictData[@"threadId"] != [NSNull null]) {
                        groupOrUserId = dictData[@"threadId"];
                        isThreadIdPresent = 1;
                    } else  {
                        groupOrUserId = dictData[App_User_ID];
                    }
    //            }
                if (groupOrUserId != nil && groupOrUserId != [NSNull null] && ![groupOrUserId isEqualToString:@""]) {
                    NSMutableDictionary * dictParam = [NSMutableDictionary new];
                    [dictParam setObject:userId forKey:SendereRTCUserId];
                    NSDictionary *dictLocation = [NSDictionary dictionaryWithDictionary:self.dictMessageDetails[@"location"]];
                    [dictParam setObject:dictLocation forKey:@"location"];
                    if (dictData[User_eRTCUserId] != nil && dictData[User_eRTCUserId] != [NSNull null]) {
                        [dictParam setObject:dictData[User_eRTCUserId] forKey:User_eRTCUserId];
                    }
                    NSString *type = [NSString stringWithFormat:@"%@",self.dictMessageDetails[@"msgType"]];
                    [dictParam setObject:type forKey:MsgType];
                    [dictParam setObject:self.dictMessageDetails[MsgUniqueId] forKey:@"originalMsgUniqueId"];
                    if(isThreadIdPresent) {
                        [dictParam setObject:groupOrUserId forKey:@"threadId"];
                    } else {
                        [dictParam setObject:groupOrUserId forKey:@"recipientAppUserId"];
                    }
                       [dictParam setObject:self.dictMessageDetails[LocalFilePath] forKey:LocalFilePath];
    //                    [dictParam setObject:self.dictMessageDetails[@"mediaFileName"] forKey:@"mediaFileName"];
                    [arrData addObject:dictParam];
                }
            }
        }
    else if ([strType isEqualToString:@"video"]) {
            for (NSMutableDictionary *dictData in forwardUserData) {
                NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
                NSString *groupOrUserId = @"";
                NSInteger isThreadIdPresent = 0;
    //            if (self.isGroup) {
    //                groupOrUserId = self.dictUserDetails[Group_GroupId];
    //                isThreadIdPresent = 1;
    //            } else {
                    if (dictData[@"threadId"] != nil && dictData[@"threadId"] != [NSNull null]) {
                        groupOrUserId = dictData[@"threadId"];
                        isThreadIdPresent = 1;
                    } else  {
                        groupOrUserId = dictData[App_User_ID];
                    }
    //            }
                if (groupOrUserId != nil && groupOrUserId != [NSNull null] && ![groupOrUserId isEqualToString:@""]) {
                    NSMutableDictionary * dictParam = [NSMutableDictionary new];
                    [dictParam setObject:userId forKey:SendereRTCUserId];
                    NSDictionary *dictMedia = [NSDictionary dictionaryWithDictionary:self.dictMessageDetails[@"media"]];
                    [dictParam setObject:dictMedia forKey:@"media"];
                    NSString *type = [NSString stringWithFormat:@"%@",self.dictMessageDetails[@"msgType"]];
                    [dictParam setObject:type forKey:MsgType];
                    [dictParam setObject:self.dictMessageDetails[MsgUniqueId] forKey:@"originalMsgUniqueId"];
                    if(isThreadIdPresent) {
                        [dictParam setObject:groupOrUserId forKey:@"threadId"];
                    } else {
                        [dictParam setObject:groupOrUserId forKey:@"recipientAppUserId"];
                    }
                    [dictParam setObject:self.dictMessageDetails[LocalFilePath] forKey:LocalFilePath];
                    [dictParam setObject:self.dictMessageDetails[@"mediaFileName"] forKey:@"mediaFileName"];
                    [arrData addObject:dictParam];
                }
            }
        }
    else if ([strType isEqualToString:@"audio"]) {
            for (NSMutableDictionary *dictData in forwardUserData) {
                NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
                NSString *groupOrUserId = @"";
                NSInteger isThreadIdPresent = 0;
    //            if (self.isGroup) {
    //                groupOrUserId = self.dictUserDetails[Group_GroupId];
    //                isThreadIdPresent = 1;
    //            } else {
                    if (dictData[@"threadId"] != nil && dictData[@"threadId"] != [NSNull null]) {
                        groupOrUserId = dictData[@"threadId"];
                        isThreadIdPresent = 1;
                    } else  {
                        groupOrUserId = dictData[App_User_ID];
                    }
    //            }
                if (groupOrUserId != nil && groupOrUserId != [NSNull null] && ![groupOrUserId isEqualToString:@""]) {
                    NSMutableDictionary * dictParam = [NSMutableDictionary new];
                    [dictParam setObject:userId forKey:SendereRTCUserId];
                    NSDictionary *dictMedia = [NSDictionary dictionaryWithDictionary:self.dictMessageDetails[@"media"]];
                    [dictParam setObject:dictMedia forKey:@"media"];
                    NSString *type = [NSString stringWithFormat:@"%@",self.dictMessageDetails[@"msgType"]];
                    [dictParam setObject:type forKey:MsgType];
                    [dictParam setObject:self.dictMessageDetails[MsgUniqueId] forKey:@"originalMsgUniqueId"];
                    if(isThreadIdPresent) {
                        [dictParam setObject:groupOrUserId forKey:@"threadId"];
                    } else {
                        [dictParam setObject:groupOrUserId forKey:@"recipientAppUserId"];
                    }
                    [dictParam setObject:self.dictMessageDetails[LocalFilePath] forKey:LocalFilePath];
                    [dictParam setObject:self.dictMessageDetails[@"mediaFileName"] forKey:@"mediaFileName"];
                    [arrData addObject:dictParam];
                }
            }
        }
    return arrData;
}

- (IBAction)btnContactsClicked:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
//        [self.btnContacts setTitleColor:[UIColor colorWithRed:0.443f green:0.525f blue:0.612f alpha:1.0] forState:UIControlStateNormal];
//        [self.btnGroups setTitleColor:[UIColor colorWithRed:0.443f green:0.525f blue:0.612f alpha:0.5] forState:UIControlStateNormal];
//        [self.btnContacts setSelected:YES];
//        [self.btnGroups setSelected:NO];
        [self.tableView reloadData];
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)btnGroupsClicked:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
//        [self.btnContacts setTitleColor:[UIColor colorWithRed:0.443f green:0.525f blue:0.612f alpha:0.5] forState:UIControlStateNormal];
//        [self.btnGroups setTitleColor:[UIColor colorWithRed:0.443f green:0.525f blue:0.612f alpha:1.0] forState:UIControlStateNormal];
//        [self.btnContacts setSelected:NO];
//        [self.btnGroups setSelected:YES];
        [self.tableView reloadData];
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - @API Call
- (void)callAPIForGetChatUserList {
    [[eRTCCoreDataManager sharedInstance] fetchChatUserListWithCompletionHandler:^(id ary, NSError *err) {
        //        [self refreshTableDataForContactsWith:ary];
        [self reloadTableWithParticipantsContacts:ary];
    }];
}

//- (void)callAPIForGetContactsUserList {
//    [[eRTCCoreDataManager sharedInstance] fetchChatUserListWithCompletionHandler:^(id ary, NSError *err) {
//        [self refreshTableDataForContactsWith:ary];
//    }];
//}

//- (void)refreshTableDataForContactsWith:(NSArray *) ary {
//    NSString *strAppUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
//
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"appUserId != %@",strAppUserId];
//    NSArray *filteredArr = [ary filteredArrayUsingPredicate:predicate];
//
//    if (filteredArr.count >0) {
//        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
//        NSArray *sortedArray=[filteredArr sortedArrayUsingDescriptors:@[sort]];
//        if (sortedArray.count > 0) {
//            [self.tableView reloadData];
//        }
//    }
//}

-(void) reloadTableWithParticipantsContacts:(NSArray *)all_participants {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"blockedStatus == %@", @"unblocked"];
    NSArray *participants = [all_participants filteredArrayUsingPredicate:predicate];
    _dictParticipantsContacts = [NSMutableDictionary new];
    for (NSString *strSection in _arySectionIndexTitle) {
        NSMutableArray *sections = [NSMutableArray new];
        if (_dictParticipantsContacts[strSection] != nil) {
            sections = (NSMutableArray *)_dictParticipantsContacts[strSection];
        }
        
        for (NSDictionary *participant in participants) {
            if(participant[Key_Name] != nil) {
                NSString *name = participant[Key_Name];
                if (name.length>0) {
                    NSString *firstCharecter = [[name substringToIndex:1] uppercaseString];
                    if ([[strSection uppercaseString] isEqualToString:firstCharecter]) {
                        [sections addObject:participant];
                    }
                }
            }
        }
        if ([sections count]>0) {
            _dictParticipantsContacts[strSection] = sections;
        }
    }
    [self.tableView reloadData];
}

-(void) reloadTableWithParticipantsGroups:(NSArray *)participants {
    _dictParticipantsGroups = [NSMutableDictionary new];
    for (NSString *strSection in _arySectionIndexTitle) {
        NSMutableArray *sections = [NSMutableArray new];
        if (_dictParticipantsGroups[strSection] != nil) {
            sections = (NSMutableArray *)_dictParticipantsGroups[strSection];
        }
        
        for (NSDictionary *participant in participants) {
            if(participant[Key_Name] != nil) {
                NSString *name = participant[Key_Name];
                if (name.length>0) {
                    NSString *firstCharecter = [[name substringToIndex:1] uppercaseString];
                    if ([[strSection uppercaseString] isEqualToString:firstCharecter]) {
                        [sections addObject:participant];
                    }
                }
            }
        }
        if ([sections count]>0) {
            _dictParticipantsGroups[strSection] = sections;
        }
    }
    [self.tableView reloadData];
}

- (void)intializeSectionIndex {
    _arySectionIndexTitle = @[@"1", @"2", @"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",@"#", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
}

- (void)setupTableView {
    [self intializeSectionIndex];
    [self.tableView registerNib:[UINib nibWithNibName:@"ForwardToTableViewCell" bundle:nil] forCellReuseIdentifier:@"ForwardToTableViewCell"];
    [self.tableView reloadData];
}

-(NSArray *)tableRowsWithSection:(NSInteger )section andParticipants:(NSDictionary *)dictParticipants {
    
    if (_arySectionIndexTitle.count>section) {
        if (dictParticipants[_arySectionIndexTitle[section]]!= nil) {
            return (NSArray *)dictParticipants[_arySectionIndexTitle[section]];
        }
    }
    return [NSArray new];
}

//- (void)syncContactDB:(NSNotification *) notification
//{
//    // [notification name] should always be @"TestNotification"
//    // unless you use this method for observation of other notifications
//    // as well.
//
//    //    if ([notification userInfo])
//    [self callAPIForGetContactsUserList];
//}

#pragma mark - @API Call

- (void)loadUserGroupsFromAPI:(NSMutableDictionary *)dict {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
        if ([[UserModel sharedInstance] getUserDetailsUsingKey:User_ID] != nil) {
            [[eRTCChatManager sharedChatInstance] getuserGroups:dict andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                [KVNProgress dismiss];
                //                NSLog(@"GroupListViewController ->  callAPIForGetGroupList -> %@ %@",json, errMsg);
                NSDictionary *dictResponse = (NSDictionary *)json;
                if (dictResponse[@"success"] != nil) {
                    BOOL success = (BOOL)dictResponse[@"success"];
                    if (success) {
                        if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *result = (NSDictionary *)dictResponse[@"result"];
                            NSArray *groups = (NSArray *)result[@"groups"];
                            [self reloadTableWithParticipantsGroups:groups];
                            //                            NSLog(@"GroupListViewController ->  callAPIForGetGroupList -> %@",result);
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
                [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
            }];
        }
    }else {
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}

- (void)callAPIForGetGroupList {
    NSMutableDictionary*dict = [[NSMutableDictionary alloc]init];
    [eRTCCoreDataManager fetchGroupRecordWithCompletionHandler:^(id ary, NSError *err) {
        NSString*strUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
        NSMutableArray *aryGroups = [NSMutableArray new];
        for (NSDictionary *groups in ary) {
            NSArray *arr = groups[Group_Participants];
            for (NSDictionary *participants in arr) {
                if (participants[App_User_ID] != nil && participants[App_User_ID] != [NSNull null]) {
                    NSString *strappUserId = participants[App_User_ID];
                    if ([strappUserId isEqualToString:strUserId]) {
                        [aryGroups addObject:groups];
                    }
                }
            }
         }
        if ([aryGroups isKindOfClass:NSArray.class] && [aryGroups count] > 0){
            if (self->_arySectionIndexTitle == NULL){
                [self intializeSectionIndex];
            }
            [self reloadTableWithParticipantsGroups:aryGroups];
        }else {
            [self loadUserGroupsFromAPI:dict];
        }
    }];
}

#pragma mark - UITableView Delegates and DataSource
#pragma mark Table Delegate and DataSource
//- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    return _arySectionIndexTitle;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _arySectionIndexTitle.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_dictParticipantsContacts[_arySectionIndexTitle[section]]!= nil) {
        NSArray *ary = _dictParticipantsContacts[_arySectionIndexTitle[section]];
        if (ary.count>0) {
            return (NSString *)_arySectionIndexTitle[section];
        }
    }
    return @"";
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (isContacts) {
        NSArray *ary = [self tableRowsWithSection:section andParticipants:_dictParticipantsContacts];
        if (ary.count>0) {
            return 36;
        }
    } else  {
        NSArray *ary = [self tableRowsWithSection:section andParticipants:_dictParticipantsGroups];
        if (ary.count>0) {
            return 36;
        }
    }
    return 0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *ary;
    if (isContacts) {
        ary = [self tableRowsWithSection:section andParticipants:_dictParticipantsContacts];
    } else {
        ary = [self tableRowsWithSection:section andParticipants:_dictParticipantsGroups];
    }
    if (ary.count>0) {
        UIView *view = [UIView new];
        [view setFrame:CGRectMake(0, 0, tableView.bounds.size.width, 36)];
        [view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        
        UILabel *lbl = [UILabel new];
        [lbl setBackgroundColor:[UIColor clearColor]];
        [lbl setTextColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
        [lbl setFont:[UIFont fontWithName:@"SFProDisplay-Medium" size:17]];
        [lbl setText:(NSString *)_arySectionIndexTitle[section]];
        [lbl setFrame:CGRectMake(16, 0, view.bounds.size.width-32, 36)];
        [view addSubview:lbl];
        return view;
    }
    return [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *ary;
    if (isContacts) {
        NSArray *arrContacts = [self tableRowsWithSection:section andParticipants:_dictParticipantsContacts];
        NSString *strAppUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"appUserId != %@",strAppUserId];
        ary = [arrContacts filteredArrayUsingPredicate:predicate];
    } else {
        ary = [self tableRowsWithSection:section andParticipants:_dictParticipantsGroups];
    }
    if (ary.count>0) {
        return ary.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ForwardToTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ForwardToTableViewCell" forIndexPath:indexPath];
    NSArray *ary;
    if (isContacts) {
        NSArray *arrContacts = [self tableRowsWithSection:indexPath.section andParticipants:_dictParticipantsContacts];
        NSString *strAppUserId = [[UserModel sharedInstance] getUserDetailsUsingKey:App_User_ID];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"appUserId != %@",strAppUserId];
        ary = [arrContacts filteredArrayUsingPredicate:predicate];
    } else {
        ary = [self tableRowsWithSection:indexPath.section andParticipants:_dictParticipantsGroups];
    }
    if (ary.count > indexPath.row) {
        NSDictionary * dict = [ary objectAtIndex:indexPath.row];
        [
         cell updateUIWithData:dict
         isContacts:isContacts
         status:[
                 self checkAvailabilityInSelectedArrayForDict:dict
                 isContacts:isContacts
                 ]
         ];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ForwardToTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    NSArray *ary;
    if (isContacts) {
        ary = [self tableRowsWithSection:indexPath.section andParticipants:_dictParticipantsContacts];
    } else {
        ary = [self tableRowsWithSection:indexPath.section andParticipants:_dictParticipantsGroups];
    }
    unsigned long int contactCount = [self.arraySelectedParticipantsContacts count];
    unsigned long int groupCount = [self.arraySelectedParticipantsGroups count];
    
    if ((contactCount + groupCount) == 10) {
        [Helper showAlertOnController:@"eRTC" withMessage:@"Message can be forwarded to 10 recepients only." onController:self];
        return;
    }
    if (ary.count > indexPath.row) {
        NSDictionary * dict = [ary objectAtIndex:indexPath.row];
        
        if (cell != nil) {
            if (cell.btnCheck.isSelected) {
                [cell updateButtonStatus:NO isContacts:isContacts];
                [self addRemovedParticipantsForContacts:isContacts add:NO userDict:dict];
            } else {
                [cell updateButtonStatus:YES isContacts:isContacts];
                [self addRemovedParticipantsForContacts:isContacts add:YES userDict:dict];
            }
            [self.tableView reloadData];
        }
    }
    [self updateUI];
}

- (void)addRemovedParticipantsForContacts:(BOOL)isContacts add:(BOOL)isAdd userDict:(NSDictionary *)dictData {
    
    if (dictData != nil && dictData != [NSNull null]) {
        if (isContacts) {
            if (isAdd) {
                if (![self checkAvailabilityInSelectedArrayForDict:dictData isContacts:isContacts]) {
                    // Does Not Exist, Please Add
//                    [self.arraySelectedParticipantsContacts removeAllObjects];
                    [self.arraySelectedParticipantsContacts addObject:dictData];
                }
            } else {
                if ([self checkAvailabilityInSelectedArrayForDict:dictData isContacts:isContacts]) {
                    // Exist, Please Remove
                    [self.arraySelectedParticipantsContacts removeObject:dictData];
                }
            }
        } else {
            if (isAdd) {
                if (![self checkAvailabilityInSelectedArrayForDict:dictData isContacts:isContacts]) {
                    // Does Not Exist, Please Add
//                    [self.arraySelectedParticipantsGroups removeAllObjects];
                    [self.arraySelectedParticipantsGroups addObject:dictData];
                }
            } else {
                if ([self checkAvailabilityInSelectedArrayForDict:dictData isContacts:isContacts]) {
                    // Exist, Please Remove
                    [self.arraySelectedParticipantsGroups removeObject:dictData];
                }
            }
        }
    }
}

- (BOOL)checkAvailabilityInSelectedArrayForDict:(NSDictionary *)dictData isContacts:(BOOL)isContacts {
    if (dictData != nil && dictData != [NSNull null]) {
        if (isContacts) {
            if (self.arraySelectedParticipantsContacts.count > 0) {
                NSString *userId = [dictData valueForKey:@"userId"];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@",userId];
                NSArray *filteredArr = [self.arraySelectedParticipantsContacts filteredArrayUsingPredicate:predicate];
                
                if (filteredArr.count >0) {
                    return YES;
                }
            }
        } else {
            if (self.arraySelectedParticipantsGroups.count > 0) {
                NSString *groupId = [dictData valueForKey:@"groupId"];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupId == %@",groupId];
                NSArray *filteredArr = [self.arraySelectedParticipantsGroups filteredArrayUsingPredicate:predicate];
                
                if (filteredArr.count >0) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (IBAction)segmentControlChanged:(id)sender {
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    if (segment.selectedSegmentIndex == 0) {
        isContacts = YES;
    } else if (segment.selectedSegmentIndex == 1) {
        isContacts = NO;
        [self showNoResultsLabel];
    }
    [self.tableView reloadData];
}

-(void)showNoResultsLabel {
    NSUInteger count = 0;
    for (NSArray*list in _dictParticipantsGroups.allValues) {
        if ([list isKindOfClass:NSArray.class]){
            count += list.count;
        }
    }
    if (count == 0){
        UILabel *noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
        noDataLabel.text = @"No Groups Available";
        noDataLabel.font = [UIFont fontWithName:@"SFProDisplay-Semibold" size:18];
        noDataLabel.textAlignment = NSTextAlignmentCenter;
        noDataLabel.textColor = [UIColor darkGrayColor];
        noDataLabel.backgroundColor = [UIColor whiteColor];
        
        self.tableView.backgroundView = noDataLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
}
@end
