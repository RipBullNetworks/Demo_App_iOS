//
//  ShowGIFViewController.m
//  eRTCApp
//
//  Created by jayant patidar on 23/11/20.
//  Copyright © 2020 Ripbull Network. All rights reserved.
//

#import "ShowGIFViewController.h"
#import "YFGIFImageView.h"

@interface ShowGIFViewController (){
    Callback didCancelCallback;
    Callback didSelectCallback;
    NSURL *url;
}
@property (strong, nonatomic) IBOutlet YFGIFImageView *imageView;
@property (strong, nonatomic) IBOutlet  UIActivityIndicatorView *activityView;
@end

@implementation ShowGIFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (url){
        [self.activityView startAnimating];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:self->url];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_imageView setGifData:data];
                [self->_imageView startGIF];
                [self->_activityView stopAnimating];
            });
        });
    }
}
- (instancetype)initWithURL: (NSURL*)_url didSelect: (void (^)(void)) didSelect  didCancel: (void (^)(void)) didCancel
{
    self = [super init];
    if (self) {
        url = _url;
        didCancelCallback = didCancel;
        didSelectCallback = didSelect;
    }
    return self;
}

-(IBAction)chooseClick:(id)sender{
    if (didSelectCallback){
        didSelectCallback();
    }
}

-(IBAction)cancelClick:(id)sender{
    if (didCancelCallback){
        didCancelCallback();
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
