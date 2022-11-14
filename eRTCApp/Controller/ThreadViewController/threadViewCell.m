//
//  threadViewCell.m
//  eRTCApp
//
//  Created by apple on 22/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "threadViewCell.h"
#import "ThreadeXpandableCell.h"
#import "ThreadMessageImageCell.h"

@interface threadViewCell ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hgtConstanttableview;
@property (weak, nonatomic) IBOutlet UIButton *btnReplay;

@end

@implementation threadViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName:@"ThreadeXpandableCell" bundle:nil] forCellReuseIdentifier:@"ThreadeXpandableCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ThreadMessageImageCell" bundle:nil] forCellReuseIdentifier:@"ThreadMessageImageCell"];
    self.imgUser.layer.cornerRadius = self.imgUser.frame.size.height/2;
    self.imgUser.clipsToBounds = true;
    
    _viewThread.layer.borderWidth = 1;
    _viewThread.layer.borderColor = [UIColor colorWithRed:0.86 green:0.91 blue:0.91 alpha:1.0].CGColor;
    
    _btnReplay.layer.borderWidth = 1;
    _btnReplay.layer.borderColor = [UIColor colorWithRed:0.86 green:0.91 blue:0.91 alpha:1.0].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.hgtConstanttableview.constant = 80*2;
    return  2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  // ThreadeXpandableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ThreadeXpandableCell"];
    ThreadMessageImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ThreadMessageImageCell"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (IBAction)btnMoreInfo:(UIButton *)sender {
    [self.delegate selectedIndex:self];
}



@end
