//
//  chatRecentTabVc.m
//  eRTCApp
//
//  Created by apple on 23/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "chatRecentTabVc.h"
#import "SearchChannelViewController.h"
#import "AnnouncementDetailVC.h"
#import "ChannelSearchViewController.h"
#import "SearchHistoryViewController.h"


@interface chatRecentTabVc () {
ChannelSearchViewController *_vcSearchChannel;
BOOL                                       _isSegmentType;
}
@end

@implementation chatRecentTabVc

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateSelected];
    [self selectedIndex:true];
    _isSegmentType = true;
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didchatReportSuccess:)
                                                 name:DidopenAnnounceMentpopup
                                               object:nil];
    
    [[NSUserDefaults standardUserDefaults]setValue:@"NO" forKey:RestorationAvailability];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   
    self.title = @"Messages";
    self.navigationItem.title = @"Messages";
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
    } else {
        // Fallback on earlier versions
    }
}

- (IBAction)btnSgSigment:(UISegmentedControl *)sender {
    if (_sgSigment.selectedSegmentIndex == 0) {
        [self selectedIndex:true];
        _isSegmentType = true;
    }else if (_sgSigment.selectedSegmentIndex == 1) {
        [self selectedIndex:false];
        _isSegmentType = false;
    }
    
}

- (IBAction)btnCreateGroup:(UIBarButtonItem *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *nvcNewGroup = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"NewGroupNavigationViewController"];
    [nvcNewGroup setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:nvcNewGroup animated:YES completion:nil];
}


-(void)selectedIndex:(BOOL)isShowContainer {
    if (isShowContainer) {
        self.vwContainerChannel.hidden = true;
        self.vwContainerSingle.hidden = false;
    }else{
        self.vwContainerChannel.hidden = false;
        self.vwContainerSingle.hidden = true;
    }
}

- (IBAction)btnSearchChannelMessages:(id)sender {
    if (_isSegmentType) {
      SearchHistoryViewController *sVC = [[SearchHistoryViewController alloc] init];
      sVC.hidesBottomBarWhenPushed = TRUE;
      [self.navigationController pushViewController:sVC animated:true];
    }else{
    SearchChannelViewController * viewController =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SearchChannelViewController"];
    [self.navigationController pushViewController:viewController animated:true];
    
    }
}

-(void)didchatReportSuccess:(NSNotification *) notification{
        AnnouncementDetailVC * viewController =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AnnouncementDetailVC"];
        [viewController setModalPresentationStyle:UIModalPresentationFullScreen];
        viewController.dictData = notification.object;
        [self presentViewController:viewController animated:NO completion:nil];

}

- (IBAction)btnMore:(id)sender {
//    AnnouncementVC * viewController =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AnnouncementVC"];
//    [viewController setModalPresentationStyle:UIModalPresentationFullScreen];
//    [viewController setModalPresentationStyle:UIModalPresentationPopover];
//    [self presentViewController:viewController animated:NO completion:nil];
}


@end
