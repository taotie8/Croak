
#import "Croak_RequestFriendsVC.h"
#import "Croak_RequestFriendsCell.h"

static NSString * const CroakRequestFriendsCellIdentifier = @"Croak_RequestFriendsCell";
static NSString * const CroakRequestFriendsCellNibName = @"Croak_RequestFriendsCell";

@interface Croak_RequestFriendsVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *croak_titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *croak_tableView;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSString *> *> *croak_requests;

@end

@implementation Croak_RequestFriendsVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    self.croak_titleLabel.text = @"Add Friend";

    self.croak_requests = @[
        @{@"name": @"Ava", @"avatar": @"croak_avatar"},
        @{@"name": @"Mia", @"avatar": @"croak_avatar"},
        @{@"name": @"Leo", @"avatar": @"croak_avatar"},
        @{@"name": @"Noah", @"avatar": @"croak_avatar"}
    ];

    [self.croak_tableView registerNib:[UINib nibWithNibName:CroakRequestFriendsCellNibName bundle:[NSBundle mainBundle]]
                forCellReuseIdentifier:CroakRequestFriendsCellIdentifier];
    self.croak_tableView.delegate = self;
    self.croak_tableView.dataSource = self;
    self.croak_tableView.rowHeight = 68.0;
    self.croak_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.croak_tableView reloadData];
}

- (IBAction)croak_backAction:(id)sender {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.croak_requests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Croak_RequestFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:CroakRequestFriendsCellIdentifier];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:CroakRequestFriendsCellNibName owner:nil options:nil].firstObject;
    }

    NSDictionary<NSString *, NSString *> *requestInfo = self.croak_requests[indexPath.row];
    [cell croak_configureWithName:requestInfo[@"name"] avatarName:requestInfo[@"avatar"]];
    return cell;
}


@end
