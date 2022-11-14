//
//  JiraBotCollectionCell.m
//  eRTCApp
//
//  Created by apple on 05/08/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "JiraBotCollectionCell.h"
#import "GoogleDriveCell.h"
#import "ImageVideoCell.h"
#import "JiraDriveCell.h"
#import "EmptyCollectionCell.h"



@interface JiraBotCollectionCell ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,JiraReportedDelegate>{ //
    
}
@end

@implementation JiraBotCollectionCell

- (void)awakeFromNib {
    [_cvJirabotCollectionView registerNib:[UINib nibWithNibName:@"GoogleDriveCell" bundle:nil] forCellWithReuseIdentifier:@"GoogleDriveCell"];
    [_cvJirabotCollectionView registerNib:[UINib nibWithNibName:@"JiraDriveCell" bundle:nil] forCellWithReuseIdentifier:@"JiraDriveCell"];
    [_cvJirabotCollectionView registerNib:[UINib nibWithNibName:@"EmptyCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"EmptyCollectionCell"];
    [super awakeFromNib];
    // Initialization code
     _cvJirabotCollectionView.delegate = self;
    _cvJirabotCollectionView.dataSource = self;
}



#pragma mark :- CollectionViewDelegate&Datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_arrayDataSource.count > 0) {
        return _arrayDataSource.count;
    }else{
        return 1;
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_arrayDataSource.count > 0)  {
    NSMutableDictionary*dictJira = [[NSMutableDictionary alloc]init];
    dictJira = _arrayDataSource[indexPath.row];
        //GetSourceJira
        if (dictJira[SourceJira] != nil && dictJira[SourceJira] != [NSNull null]) {
            NSDictionary *dictSource = dictJira[SourceJira];
            if ([dictSource[JiraRaw] isEqualToString:jiraBot_cloud]) {
            JiraDriveCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JiraDriveCell" forIndexPath:indexPath];
                if (dictJira[JiraStatus] != nil && dictJira[JiraStatus] != [NSNull null]) {
                    NSDictionary *dictSource = dictJira[JiraStatus];
                    NSString *status = dictSource[JiraRaw];
                    cell.lblStatus.text = status.capitalizedString;
                    cell.lblStatus.layer.borderWidth = 1;
                    cell.lblStatus.layer.cornerRadius = 5;
                    if ([dictSource[JiraRaw] isEqualToString:@"done"]) {
                        cell.lblStatus.layer.borderColor = [self colorWithHexString:@"33D24E"].CGColor;
                        cell.lblStatus.textColor = [self colorWithHexString:@"33D24E"];
                    }else{
                        cell.lblStatus.layer.borderColor = [self colorWithHexString:@"71869C"].CGColor;
                        cell.lblStatus.textColor = [self colorWithHexString:@"71869C"];
                    }
                }
                
                //Set Jiratitle
                if (dictJira[Jiratitle] != nil && dictJira[Jiratitle] != [NSNull null]) {
                    NSDictionary *dicttitle = dictJira[Jiratitle];
                    cell.lblSprint.text = dicttitle[JiraRaw];
                }
                
                //Set slug
                if (dictJira[JiraSlug] != nil && dictJira[JiraSlug] != [NSNull null]) {
                    NSDictionary *dictSlug = dictJira[JiraSlug];
                    cell.lblEback.text = dictSlug[JiraRaw];
                }
                
                //Set type
                if (dictJira[JiraType] != nil && dictJira[JiraType] != [NSNull null]) {
                    NSDictionary *dictType = dictJira[JiraType];
                    NSString *type = dictType[JiraRaw];
                    cell.lblType.text = type.capitalizedString;
                    cell.lblType.layer.borderWidth = 1;
                    cell.lblType.layer.cornerRadius = 5;
                    cell.lblType.layer.borderColor = [self colorWithHexString:@"71869C"].CGColor;
                }

                
                //Set JiraAssigned_to
                if (dictJira[JiraAssigned_to] != nil && dictJira[JiraAssigned_to] != [NSNull null]) {
                    NSDictionary *dictSlug = dictJira[JiraAssigned_to];
                    if (dictSlug[JiraRaw] != nil && dictSlug[JiraRaw] != [NSNull null]) {
                        cell.lblAssigned.text = [@"Assigned to " stringByAppendingString:dictSlug[JiraRaw]];
                    }else{
                        cell.lblAssigned.text = @"Assigned";
                    }
                }
                //Get Jiraupdated_at
                if (dictJira[Jiraupdated_at] != nil && dictJira[Jiraupdated_at] != [NSNull null]) {
                    NSDictionary *dictUpdated = dictJira[Jiraupdated_at];
                   // NSString *dateString = dictUpdated[JiraRaw];
                    double timeStamp = [[dictUpdated valueForKey:JiraRaw]doubleValue];
                    NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:timeStamp];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm a"];
                    NSString  *finalate = [dateFormatter stringFromDate:msgdate];
                    cell.lblLastUpdate.text = finalate;
                }
                
                //Set JiraCreated_by
                if (dictJira[JiraCreated_by] != nil && dictJira[JiraCreated_by] != [NSNull null]) {
                    NSDictionary *dictCreated = dictJira[JiraCreated_by];
                    cell.lblCreadedBy.text = [@"Created by " stringByAppendingString:dictCreated[JiraRaw]];
                }
                
                //NSString *strUrl = [imageBaseUrl stringByAppendingString:imageURL];
                
                cell.delegate = self;
            return cell;
            }
        }
  //  GoogleDriveCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GoogleDriveCell" forIndexPath:indexPath];
  //  return cell;
    }else{
        EmptyCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EmptyCollectionCell" forIndexPath:indexPath];
        return cell;
    }
   
    
   // }
    return [UICollectionViewCell new];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_arrayDataSource.count > 0)  {
    return CGSizeMake((_cvJirabotCollectionView.frame.size.width-64), 280);
    }else{
    return CGSizeMake((_cvJirabotCollectionView.frame.size.width-16), 280);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath  {
  
}

-(void)selectedItcTickets:(JiraDriveCell *)cell {
    NSIndexPath *indexPath = [self.cvJirabotCollectionView indexPathForCell:cell];
    NSMutableDictionary*dictJira = [[NSMutableDictionary alloc]init];
    dictJira = _arrayDataSource[indexPath.row];
    if (dictJira[@"url"] != nil && dictJira[@"url"] != [NSNull null]) {
        NSDictionary *dictUrl = dictJira[@"url"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: dictUrl[JiraRaw]]];
    }
}



-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];

    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];

    if ([cString length] != 6) return  [UIColor grayColor];

    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];

    range.location = 2;
    NSString *gString = [cString substringWithRange:range];

    range.location = 4;
    NSString *bString = [cString substringWithRange:range];

    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

@end
