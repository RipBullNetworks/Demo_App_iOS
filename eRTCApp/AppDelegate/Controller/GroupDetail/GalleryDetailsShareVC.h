//
//  GroupDetailsVC.h
//  eRTCApp
//
//  Created by apple on 16/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GalleryDetailsShareVC : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imgGroupProfile;
@property (weak, nonatomic) IBOutlet UIView *subViewSocialMediaPopUP;
@property (nonatomic, strong) NSDictionary *dictGalleryInfo;
@property (strong, nonatomic) NSDictionary *dictUserDetails;
@property (nonatomic, retain) UIDocumentInteractionController *documentController;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property(nonatomic, strong) NSMutableDictionary *dictforward;
@property(nonatomic, strong) NSString *strImage;
@property(nonatomic, strong) NSString *name;

@end

NS_ASSUME_NONNULL_END
