
#import "DraftsControllerVC.h"
#import "DraftsTableCell.h"

@interface DraftsControllerVC ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation DraftsControllerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Drafts";
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
    } else {
        // Fallback on earlier versions
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Drafts";
    self.navigationController.navigationBar.topItem.title = @"";
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DraftsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:DraftsTblCell];

    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
