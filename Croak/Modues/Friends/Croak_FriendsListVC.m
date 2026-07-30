
#import "Croak_FriendsListVC.h"
#import "Croak_FriendsListCell.h"
#import "Croak_SearchUserVC.h"
#import "Croak_RequestFriendsVC.h"

static NSString * const CroakFriendsListCellIdentifier = @"Croak_FriendsListCell";
static NSString * const CroakFriendsListCellNibName = @"Croak_FriendsListCell";

@interface Croak_FriendsListVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *croak_headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *croak_avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *croak_nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_welcomeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *croak_bannerImageView;
@property (weak, nonatomic) IBOutlet UILabel *croak_titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *croak_tableView;
@property (nonatomic, strong) NSArray<NSString *> *croak_friends;

@end

@implementation Croak_FriendsListVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.croak_nameLabel.text = @"HI~ Xi_yin";
    self.croak_welcomeLabel.text = @"Welcome to Croak";
    self.croak_titleLabel.text = @"Friend List";

    self.croak_avatarImageView.layer.cornerRadius = 20.0;
    self.croak_avatarImageView.layer.masksToBounds = YES;

    self.croak_friends = @[@"Ava", @"Mia", @"Leo", @"Noah"];
    [self.croak_tableView registerNib:[UINib nibWithNibName:CroakFriendsListCellNibName bundle:[NSBundle mainBundle]]
                forCellReuseIdentifier:CroakFriendsListCellIdentifier];
    self.croak_tableView.delegate = self;
    self.croak_tableView.dataSource = self;
    self.croak_tableView.rowHeight = 64;
    self.croak_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (IBAction)croak_requestAction:(id)sender {
    Croak_RequestFriendsVC *requestFriendsVC = [[Croak_RequestFriendsVC alloc] init];
    requestFriendsVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:requestFriendsVC animated:YES];
}

- (IBAction)croak_searchAction:(id)sender {
    [self.navigationController pushViewController:[Croak_SearchUserVC new] animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.croak_friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Croak_FriendsListCell *cell = [tableView dequeueReusableCellWithIdentifier:CroakFriendsListCellIdentifier];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:CroakFriendsListCellNibName owner:nil options:nil].firstObject;
    }
    [cell croak_configureWithName:self.croak_friends[indexPath.row] avatarName:@"croak_avatar"];
    return cell;
}

@end
