//
//  CannedResponsesVC.m
//  eRTCApp
//
//  Created by apple on 14/04/21.
//  Copyright © 2021 Ripbull Network. All rights reserved.
//

#import "CannedResponsesVC.h"
#import "EditTblCell.h"

@interface CannedResponsesVC ()<UITableViewDelegate,UITableViewDataSource> {
    UIBarButtonItem *AddBarButtonItem;
}
@property (weak, nonatomic) IBOutlet UITableView *tblCannedList;

@end

@implementation CannedResponsesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Canned Responses";
    AddBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(clickAddButton:)];
    self.navigationItem.rightBarButtonItem=AddBarButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"";
}


-(IBAction)clickAddButton:(id)sender{
    UIAlertController *activitySheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(nil, nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *clearChat = [UIAlertAction actionWithTitle:NSLocalizedString(@"Edit", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
       [activitySheet addAction:clearChat];
            UIAlertAction *delete = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                
        }];
        [activitySheet addAction:delete];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [activitySheet addAction:cancel];
    
    [self presentViewController:activitySheet animated:YES completion:nil];
}


#pragma mark - UITableView Delegates and DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EditTblCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditTblCell" forIndexPath:indexPath];
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
}



@end
