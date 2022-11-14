//
//  tblReportCell.h
//  eRTCApp
//
//  Created by apple on 09/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface tblReportCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *vwContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;
@property (weak, nonatomic) IBOutlet UIButton *btnResolve;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblUserCreatedDate;
@property (weak, nonatomic) IBOutlet UILabel *lblAdminMsg;
@property (weak, nonatomic) IBOutlet UILabel *lblReportedName;
@property (weak, nonatomic) IBOutlet UILabel *lblReportedMsg;
@property (weak, nonatomic) IBOutlet UILabel *lblReportedDate;
@property (weak, nonatomic) IBOutlet UIImageView *imgMedia;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hgtContactView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hgtAudioView;
@property (weak, nonatomic) IBOutlet UIView *viewContact;

@property (weak, nonatomic) IBOutlet UIView *viewAudio;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hgtImageView;
@property (weak, nonatomic) IBOutlet UIView *viewLocation;
@property (weak, nonatomic) IBOutlet UIButton *btnLocation;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hgtViewLocation;
@property (weak, nonatomic) IBOutlet UIView *viewImage;

@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;
@property (weak, nonatomic) IBOutlet UIButton *btnImage;
@property (weak, nonatomic) IBOutlet UILabel *lblCategory;
@property (weak, nonatomic) IBOutlet MKMapView *mapKitView;
@property (weak, nonatomic) IBOutlet UILabel *lblChannelName;
@property (weak, nonatomic) IBOutlet UILabel *lblContactUserName;
@property (weak, nonatomic) IBOutlet UIImageView *imgContactUser;
@property (weak, nonatomic) IBOutlet UIButton *btnAudio;
@property (weak, nonatomic) IBOutlet UIButton *btnContact;
@property (weak, nonatomic) IBOutlet UIImageView *imgPlay;

@end

NS_ASSUME_NONNULL_END
