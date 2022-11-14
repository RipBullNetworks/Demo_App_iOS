//
//  ReportsViewController.m
//  eRTCApp
//
//  Created by apple on 09/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "ReportsViewController.h"
#import "tblReportCell.h"
#import "MediaModerationVc.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import "FileManager.h"
#import "MediaDownloadOperation.h"
#import "ThumbnailDownloader.h"
#import "AudioVC.h"

@interface ReportsViewController () {
    NSMutableArray *_messageHistory;
    BOOL                                       _isSelectedModeOn;
    NSOperationQueue *queue;
    NSString *imgBaseurl;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *sgSigment;

@end

@implementation ReportsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *dictConfig = [[eRTCChatManager sharedChatInstance] getFeatureConfigs];
    if ([dictConfig isKindOfClass:[NSDictionary class]]){
        if  (![Helper stringIsNilOrEmpty:dictConfig[ChatServerBaseurl]]) {
            imgBaseurl = [dictConfig[ChatServerBaseurl] stringByAppendingString:BaseUrlVersion];
        }
    }
 
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Reports";
    if (@available(iOS 11.0, *)) {
    self.navigationController.navigationBar.prefersLargeTitles = NO;
    } else {
       
    }
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateSelected];
    
    [self callGetModerationListApi];
    
    _isSelectedModeOn = true;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDeleteChatMsgNotification:)
                                                 name:DidDeleteChatMessageNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getIgnoreReportedMessage:)
                                                 name:DidGetChatReportedIdUpdated
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"";
}

- (IBAction)sgSigment:(id)sender {
    if (_sgSigment.selectedSegmentIndex == 0) {
        _isSelectedModeOn = true;
        self.tblMessagesList.reloadData;
    }else if (_sgSigment.selectedSegmentIndex == 1) {
        _isSelectedModeOn = false;
        self.tblMessagesList.reloadData;
    }
    
}

- (IBAction)btnImage:(UIButton *)sender {
    NSDictionary *dictMsg = self.arrMediaList[sender.tag];
    NSDictionary *dictChat = dictMsg[@"chat"];
    NSString *msgType = dictChat[MsgType];
    NSDictionary *dictMedia = dictChat[@"media"];
    NSString *imageURL = [NSString stringWithFormat:@"%@",dictMedia[FilePath]];
    NSString *strUrl = [imgBaseurl stringByAppendingString:imageURL];
    NSURL *url = [[NSURL alloc] initWithString:strUrl];
    
    if ([msgType isEqualToString:GifyFileName] || [msgType isEqualToString:Image]) {
        MediaModerationVc * viewController =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MediaModerationVc"];
        viewController.dictMedia = self.arrMediaList[sender.tag];
        [self.navigationController pushViewController:viewController animated:true];
    }else if ([msgType isEqualToString:Key_video]){
        AVPlayer *player = [AVPlayer playerWithURL:url];
        AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
        [self presentViewController:controller animated:YES completion:nil];
        controller.player = player;
        [player play];
    }else if ([msgType isEqualToString:AudioFileName]) {
        AudioVC * viewController =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AudioVC"];
        [viewController setModalPresentationStyle:UIModalPresentationFullScreen];
        viewController.strUrl = strUrl;
        [self presentViewController:viewController animated:NO completion:nil];
    }
}

-(void)isSelected:(BOOL *)isSelectedIndex {
  
}

- (void)getIgnoreReportedMessage:(NSNotification *) notification{
    NSDictionary *userInfo = notification.userInfo;
    NSLog(@"userInfo>>>>>>%@",userInfo);
    [self performSelector:@selector(callGetModerationListApi) withObject:nil afterDelay:0.2];
}


#pragma mark :- TableViewDelegate&DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _tblMessagesList.bounds.size.width, _tblMessagesList.bounds.size.height)];
    noDataLabel.textColor        = [UIColor blueColor];
    noDataLabel.textAlignment    = NSTextAlignmentCenter;
    if (_isSelectedModeOn) {
        if (self.arrModerationList.count > 0) {
            noDataLabel.text             = @"";
            self.tblMessagesList.backgroundView = noDataLabel;
            return self.arrModerationList.count;
        }else{
            noDataLabel.text             = @"Record not found";
            self.tblMessagesList.backgroundView = noDataLabel;
            self.tblMessagesList.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
    }else{
        if (self.arrMediaList.count > 0) {
            noDataLabel.text             = @"";
            self.tblMessagesList.backgroundView = noDataLabel;
            return self.arrMediaList.count;
        }else{
            noDataLabel.text             = @"Record not found";
            self.tblMessagesList.backgroundView = noDataLabel;
            self.tblMessagesList.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tblReportCell *cell = [tableView dequeueReusableCellWithIdentifier:MyReportsCellIdentifier forIndexPath:indexPath];
    NSMutableDictionary*dictMsg = [[NSMutableDictionary alloc]init];
    NSMutableDictionary*dictChat = [[NSMutableDictionary alloc]init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (_isSelectedModeOn) {
        dictMsg = self.arrModerationList[indexPath.row];
        dictChat = dictMsg[Chat];
        cell.viewContact.hidden = true;
        cell.viewImage.hidden = true;
        cell.viewLocation.hidden = true;
        cell.viewAudio.hidden = true;
        if (dictChat[Message] != nil && dictChat[Message] != [NSNull null]) {
        cell.lblReportedMsg.text = [dictChat valueForKey:Message];
        }
    }else{
        cell.lblReportedMsg.text = @"";
        NSString *url = NULL;
        NSString *filename;
        cell.btnImage.hidden = false;
        dictMsg = self.arrMediaList[indexPath.row];
        dictChat = dictMsg[Chat];
        NSString *msgType = dictChat[MsgType];
        NSDictionary *dictMedia = dictChat[typeMedia];
        BOOL isVideo = [msgType isEqualToString:Key_video];
        if ([msgType isEqualToString:GifyFileName]) {
            cell.viewContact.hidden = true;
            cell.viewImage.hidden = NO;
            cell.imgPlay.hidden = true;
            cell.viewLocation.hidden = true;
            cell.viewAudio.hidden = true;
            NSString *imageURL = dictChat[GifyFileName];
            [cell.imgMedia sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
        }else if ([msgType isEqualToString:Image]) {
            cell.imgPlay.hidden = true;
            cell.viewContact.hidden = true;
            cell.viewImage.hidden = NO;
            cell.viewLocation.hidden = true;
            cell.viewAudio.hidden = true;
            url = [NSString stringWithFormat:@"%@",dictMedia[@"path"]];
            NSString *fullurl = [NSString stringWithFormat:@"%@%@", imageBaseUrl, url];
            [cell.imgMedia sd_setImageWithURL:[NSURL URLWithString:fullurl]];
        }else if ([msgType isEqualToString:AudioFileName]) {
            cell.viewContact.hidden = true;
            cell.viewImage.hidden = true;
            cell.viewLocation.hidden = true;
            cell.viewAudio.hidden = NO;
            [cell.imgMedia setImage:[UIImage imageNamed:@"audioIcon"]];
        }else if ([msgType isEqualToString:@"location"]) {
            cell.viewContact.hidden = true;
            cell.viewImage.hidden = true;
            cell.viewLocation.hidden = NO;
            cell.viewAudio.hidden = true;
            [cell.imgMedia setImage:[UIImage imageNamed:@"audioIcon"]];
        }else if ([msgType isEqualToString:ContactType]) {
            cell.viewContact.hidden = NO;
            cell.viewImage.hidden = true;
            cell.viewLocation.hidden = true;
            cell.viewAudio.hidden = true;
        }else if ([msgType isEqualToString:Key_video]) {
            cell.viewContact.hidden = true;
            cell.viewImage.hidden = NO;
            cell.imgPlay.hidden = NO;
            cell.viewLocation.hidden = true;
            cell.viewAudio.hidden = true;
            url = [NSString stringWithFormat:@"%@",dictMedia[@"path"]];
            filename = dictMedia[@"name"];
            NSString *fullurl = [NSString stringWithFormat:@"%@%@", imgBaseurl, url];
            
            NSURL *_url = [NSURL URLWithString:fullurl];
            if (![FileManager isFileAlreadySaved:filename]) {
                MediaDownloadOperation *op = [[MediaDownloadOperation alloc] initWith:_url];
                op = [[ThumbnailDownloader alloc] initWith:_url];
                op.completionBlock = ^{
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        [FileManager saveFile:filename withData:op.data];
                        [cell.imgMedia setImage: [UIImage imageWithData:op.data]];
                    });
                };
                [queue addOperation:op];
            }else{
                NSString *localFile = [FileManager getFileURL:filename];
                NSData *_data = [NSData dataWithContentsOfFile:[NSURL URLWithString:localFile].path];
                [cell.imgMedia setImage: [UIImage imageWithData: _data]];
            }
        }
    }
    
    
    //GetReportedUser
    if (dictMsg[Category] != nil && dictMsg[Category] != [NSNull null]) {
        cell.lblCategory.text = [dictMsg valueForKey:Category];
    }
    
    //Get CreatedAt Date
    if (dictChat[CreatedAt] != nil && dictChat[CreatedAt] != [NSNull null]) {
        double timeStamp = [[dictChat valueForKey:CreatedAt]doubleValue];
        NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
        [dateFormatter setDateFormat:@"EEE MMM dd yyyy HH:mm:ss"];
        NSString  *finalate = [dateFormatter stringFromDate:msgdate];
        cell.lblReportedDate.text = finalate;
    }
    
   
    
    
    //Get contact Message
    if (dictChat[ContactType] != nil && dictChat[ContactType] != [NSNull null]) {
        NSDictionary *dictContact = dictChat[ContactType];
        if (dictContact[User_Name] != nil && dictContact[User_Name] != [NSNull null]) {
            cell.lblContactUserName.text = [dictContact valueForKey:User_Name];
        }
    }
    
    
    
    //Get Location Lat Long and Show the Location on Map
    if (dictChat[LocationType] != nil && dictChat[LocationType] != [NSNull null]) {
        //location
        NSDictionary *dictLocation = dictChat[LocationType];
        if (![Helper stringIsNilOrEmpty:dictLocation[Latitude]] && ![Helper stringIsNilOrEmpty:dictLocation[Longitude]]) {
            cell.mapKitView.delegate = self;
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([dictLocation[Latitude] doubleValue], [dictLocation[Longitude] doubleValue]);
            MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.1);
            MKCoordinateRegion region = {coord, span};
            [cell.mapKitView setRegion:region];
        }
    }
    
    //Get Reported name
    if (dictChat[Chat_Sender] != nil && dictChat[Chat_Sender] != [NSNull null]) {
        NSDictionary *dictSender = dictChat[Chat_Sender];
        if (dictSender[User_Name] != nil && dictSender[User_Name] != [NSNull null]) {
            cell.lblUserName.text = [dictSender valueForKey:User_Name];
        }
    }
    
    //Get Reported Reason
    if (dictMsg[Reason] != nil && dictMsg[Reason] != [NSNull null]) {
        // cell.lblAdminMsg.text = [dictMsg valueForKey:Reason];
        NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@ %@ ",[dictMsg valueForKey:Category],@"Additional Message from Reporter: ",[dictMsg valueForKey:Reason]]];
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"SFProDisplay-Bold" size:15]}
                                  range:NSMakeRange(0, [NSString stringWithFormat:@"%@ %@",[dictMsg valueForKey:Category],@"Additional Message from Reporter: "].length)];
        cell.lblAdminMsg.attributedText = attributedString;//[NSString stringWithFormat:@"%@ %@ %@ ",[dictMsg valueForKey:Category],@"Additional Message from Reporter:- ",[dictMsg valueForKey:Reason]];
    }
    
    //Get Reported user name
    if (dictMsg[ReporterERTCUser] != nil && dictMsg[ReporterERTCUser] != [NSNull null]) {
        NSDictionary *dictReported = dictMsg[ReporterERTCUser];
        if (dictReported[User_Name] != nil && dictReported[User_Name] != [NSNull null]) {
            cell.lblReportedName.text = [dictReported valueForKey:User_Name];
        }
    }
    
    //Get Admin Status
    if (dictMsg[TenantAdminStatus] != nil && dictMsg[TenantAdminStatus] != [NSNull null]) {
        NSDictionary *dictAdminStatus = dictMsg[TenantAdminStatus];
        if (dictAdminStatus[CreatedAt] != nil && dictAdminStatus[CreatedAt] != [NSNull null]) {
            double timeStampReported = [[dictAdminStatus valueForKey:CreatedAt]doubleValue];
            NSDate *msgdateReported = [NSDate dateWithTimeIntervalSince1970:timeStampReported / 1000];
            [dateFormatter setDateFormat:@"EEE MMM dd yyyy HH:mm:ss"];
            NSString  *finadateReported = [dateFormatter stringFromDate:msgdateReported];
            cell.lblUserCreatedDate.text = finadateReported;
        }
    }
    
    NSString* userImage = [[UserModel sharedInstance] getUserDetailsUsingKey:User_ProfilePic_Thumb];
    [cell.imgProfile sd_setImageWithURL:userImage placeholderImage:[UIImage imageNamed:@"DefaultUserIcon"]];
    cell.btnDelete.tag = indexPath.row;
    cell.btnResolve.tag = indexPath.row;
    cell.btnImage.tag = indexPath.row;
    cell.btnAudio.tag = indexPath.row;
    cell.btnContact.tag = indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(void)callGetModerationListApi {
    if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
        [KVNProgress show];
        NSMutableDictionary*dictParam = [[NSMutableDictionary alloc]init];
        NSArray *aryCategory = @[@"abuse",@"spam",@"other",@"inappropriate"];
        NSArray *aryStatus = @"new";
        NSArray *aryMsgType = @[@"gif", @"image", @"audio", @"video", @"file", @"location", @"contact", @"gify"];
        //[dictParam setValue:aryCategory forKey:Category];
        [dictParam setValue:@"new" forKey:@"status"];
        [dictParam setValue:_dictGroupInfo[ThreadID] forKey:ThreadID];
        [dictParam setValue:@"10000000" forKey:Limit];
        [dictParam setValue:@1 forKey:Skip];
        // NSString *userId = [[UserModel sharedInstance] getUserDetailsUsingKey:User_eRTCUserId];
        [[eRTCChatManager sharedChatInstance] getChatReports:dictParam andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
            
            [KVNProgress dismiss];
            NSDictionary *dictResponse = (NSDictionary *)json;
            NSLog(@"json >>>>>>>>>>%@",json);
            if (dictResponse[@"success"] != nil) {
                BOOL success = (BOOL)dictResponse[@"success"];
                if (success) {
                    if ([dictResponse[@"result"] isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *dictResult = (NSDictionary *)json;
                        dictResult = (NSDictionary *)dictResponse[@"result"];
                        NSArray *arr = dictResult[@"chatReports"];
                        self.arrModerationList = [[NSMutableArray alloc] init];
                        self.arrMediaList = [[NSMutableArray alloc] init];
                        for (NSDictionary *obj in arr)
                        {
                            NSDictionary *dictChat = obj[@"chat"];
                            NSString *type = dictChat[@"msgType"];
                            if ([type isEqualToString:@"text"]) {
                                [self.arrModerationList addObject:obj];
                                if ([self.arrModerationList count]>0){
                                    [self->_tblMessagesList reloadData];
                                }
                            }else{
                                [self.arrMediaList addObject:obj];
                                if ([self.arrMediaList count]>0){
                                    [self->_tblMessagesList reloadData];
                                }
                            }
                        }
                        [self->_tblMessagesList reloadData];
                    }
                }
            }
        }andFailure:^(NSError * _Nonnull error) {
            [KVNProgress dismiss];
            [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
        }];
    } else {
        [KVNProgress dismiss];
        [Helper showAlertOnController:@"eRTC" withMessage:NO_Network onController:self];
    }
}

- (IBAction)btnResolveReport:(UIButton *)sender {
    [Helper showAlert:Allow_message message:Allow_Reported_conversation btnYes:@"Allow" btnNo:@"Cancel" inViewController:self completedWithBtnStr:^(NSString* btnString) {
        if ([btnString isEqualToString:@"Allow"]) {
            if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
                [KVNProgress show];
                NSMutableDictionary * dictMessage = [NSMutableDictionary new];
                if (self->_isSelectedModeOn) {
                    dictMessage = [self->_arrModerationList objectAtIndex:sender.tag];
                }else{
                    dictMessage = [self->_arrMediaList objectAtIndex:sender.tag];
                }
                NSMutableDictionary * dictUndoChatReport = [NSMutableDictionary new];
                [dictUndoChatReport setValue:dictMessage[Chat_ReportId] forKey:@"chatReportId"];
                [dictUndoChatReport setValue:ReportedIgnored forKey:ChatReportAction];
                [[eRTCChatManager sharedChatInstance] chatReportMessageIgnored:dictUndoChatReport andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                    [KVNProgress dismiss];
                    NSDictionary *dictResponse = (NSDictionary *)json;
                    if (dictResponse[@"success"] != nil) {
                        BOOL success = (BOOL)dictResponse[@"success"];
                        if (success == true) {
                            [self performSelector:@selector(callGetModerationListApi) withObject:nil afterDelay:0.2];
                            [[NSNotificationCenter defaultCenter] postNotificationName:DeleteModerationMessage object:nil userInfo:nil];
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
    }];
}

- (IBAction)btnDeleteMsg:(UIButton *)sender {
    [Helper showAlert:Delete_message message:msg_Reported_conversation btnYes:@"Delete" btnNo:@"Cancel" inViewController:self completedWithBtnStr:^(NSString* btnString) {
        if ([btnString isEqualToString:@"Delete"]) {
            if ([[AppDelegate sharedAppDelegate] isNetworkReachable]) {
                [KVNProgress show];
                NSMutableDictionary * dictMessage = [NSMutableDictionary new];
                if (self->_isSelectedModeOn) {
                    dictMessage = [self->_arrModerationList objectAtIndex:sender.tag];
                }else{
                    dictMessage = [_arrMediaList objectAtIndex:sender.tag];
                }
                NSMutableDictionary * dictUndoChatReport = [NSMutableDictionary new];
                [dictUndoChatReport setValue:dictMessage[Chat_ReportId] forKey:@"chatReportId"];
                [dictUndoChatReport setValue:ReportConsidered forKey:ChatReportAction];
                [[eRTCChatManager sharedChatInstance] chatReportMessageIgnored:dictUndoChatReport andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
                    [KVNProgress dismiss];
                    NSDictionary *dictResponse = (NSDictionary *)json;
                    if (dictResponse[@"success"] != nil) {
                        BOOL success = (BOOL)dictResponse[@"success"];
                        if (success == true) {
                            [self performSelector:@selector(callGetModerationListApi) withObject:nil afterDelay:0.2];
                            [[NSNotificationCenter defaultCenter] postNotificationName:DeleteModerationMessage object:nil userInfo:nil];
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
    }];
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
        [self performSelector:@selector(callGetModerationListApi) withObject:nil afterDelay:0.2];
    }
}

- (void)deleteMessage:(NSString *)type dictMessage:(NSDictionary *)dict {
    NSDictionary * dictMessage = [NSDictionary new];
    dictMessage = dict[@"chat"];
    NSMutableDictionary * dictDeleteChat = [NSMutableDictionary new];
    NSMutableDictionary * dictDeleteMessage = [NSMutableDictionary new];
    NSString * messageUniqueID = @"";
    [dictDeleteChat setValue:messageUniqueID forKey:@"msgUniqueId"];
    NSArray *arrData = [NSArray arrayWithObject:dictDeleteChat];
    [dictDeleteMessage setValue:arrData forKey:@"chats"];
    [dictDeleteMessage setValue:dictMessage[ThreadID] forKey:@"threadId"];
    [dictDeleteMessage setValue:dictMessage[MsgUniqueId] forKey:@"msgUniqueId"];
    [dictDeleteMessage setValue:type forKey:@"deleteType"];
    [dictDeleteMessage setValue:[Helper getEpochTime] forKey:@"msgCorrelationId"];
    [[eRTCChatManager sharedChatInstance] DeleteMessageWithParam:dictDeleteMessage andCompletion:^(id  _Nonnull json, NSString * _Nonnull errMsg) {
        
    } andFailure:^(NSError * _Nonnull error) {
        [Helper showAlertOnController:@"eRTC" withMessage:error.localizedDescription onController:self];
        
    }];
}

- (IBAction)btnAudio:(UIButton *)sender {
    NSDictionary *dictMsg = self.arrMediaList[sender.tag];
    NSDictionary *dictChat = dictMsg[@"chat"];
    NSString *msgType = dictChat[MsgType];
    NSDictionary *dictMedia = dictChat[@"media"];
    NSString *imageURL = [NSString stringWithFormat:@"%@",dictMedia[FilePath]];
    NSString *strUrl = [imgBaseurl stringByAppendingString:imageURL];
    NSURL *url = [[NSURL alloc] initWithString:strUrl];
    if ([msgType isEqualToString:AudioFileName]) {
        AudioVC * viewController =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AudioVC"];
        [viewController setModalPresentationStyle:UIModalPresentationFullScreen];
        viewController.strUrl = strUrl;
        [self presentViewController:viewController animated:NO completion:nil];
    }
    
}

- (IBAction)btnContact:(UIButton *)sender {
    
    
}


- (IBAction)btnTapOnLocation:(id)sender {
    
    
}

@end
