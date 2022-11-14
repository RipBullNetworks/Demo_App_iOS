//
//  AnnouncementDetailVC.m
//  eRTCApp
//
//  Created by apple on 19/05/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "AnnouncementDetailVC.h"

@interface AnnouncementDetailVC () {
NSMutableArray *_arrAnnounceMent;
}

@end

@implementation AnnouncementDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSDictionary*dictDataInfo;
    _arrAnnounceMent = _dictData[@"announcement"];
    for (int i = 0; i < [_arrAnnounceMent count]; i++)
    {
        dictDataInfo = _arrAnnounceMent[i];
    }
    
    if (dictDataInfo[Details] != nil && dictDataInfo[Details] != [NSNull null]) {
    _txtView.text = dictDataInfo[Details];
}
NSDictionary *dictName = dictDataInfo[@"group"];
if (dictName[@"name"] != nil && dictName[@"name"] != [NSNull null]) {
_lblTitle.text = dictName[@"name"];
}else{
    _lblTitle.text = @"All Users";
}
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didchatReportSuccess:)
                                                 name:DidopenAnnounceMentpopup
                                               object:nil];
}

- (void)viewWillLayoutSubviews {
    
  }

- (IBAction)btnDismiss:(id)sender {
    [_arrAnnounceMent removeObjectAtIndex:_arrAnnounceMent.count-1];
    if (_arrAnnounceMent.count > 0) {
        NSDictionary*dictDataInfo;
        for (int i = 0; i < [_arrAnnounceMent count]; i++)
        {
            dictDataInfo = _arrAnnounceMent[i];
        }
        NSTimeInterval delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self->_lblTitle.text = @"";
            self->_txtView.text = @"";
            
            if (dictDataInfo[Details] != nil && dictDataInfo[Details] != [NSNull null]) {
                self->_txtView.text = dictDataInfo[Details];
        }
            NSDictionary *dictName = dictDataInfo[@"group"];
        if (dictName[@"name"] != nil && dictName[@"name"] != [NSNull null]) {
            self->_lblTitle.text = dictName[@"name"];
        }else{
            self->_lblTitle.text = @"All Users";
        }
        
      });
        
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:DidRefreshAnnouncementpopup object:nil userInfo:nil];
        [self dismissViewControllerAnimated:true completion:nil];
    }
    
    
    
    
    
       
}

-(void)didchatReportSuccess:(NSNotification *) notification{
    NSDictionary *dictData = notification.object;
    NSDictionary*dictDataInfo;
    _arrAnnounceMent = dictData[@"announcement"];
    for (int i = 0; i < [_arrAnnounceMent count]; i++)
    {
        dictDataInfo = _arrAnnounceMent[i];
    }
    NSTimeInterval delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self->_lblTitle.text = @"";
        self->_txtView.text = @"";
        
        if (dictDataInfo[Details] != nil && dictDataInfo[Details] != [NSNull null]) {
            self->_txtView.text = dictDataInfo[Details];
    }
        NSDictionary *dictName = dictDataInfo[@"group"];
    if (dictName[@"name"] != nil && dictName[@"name"] != [NSNull null]) {
        self->_lblTitle.text = dictName[@"name"];
    }else{
        self->_lblTitle.text = @"All Users";
    }
    
  });
}



@end
