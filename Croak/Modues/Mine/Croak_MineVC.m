
#import "Croak_MineVC.h"
#import "Croak_SettingVC.h"
#import "Croak_DiamondsVC.h"
#import "Croak_SquareTableViewCell.h"

static NSString * const CroakMineSquareCellIdentifier = @"Croak_SquareTableViewCell";
static NSString * const CroakMineSquareCellNibName = @"Croak_SquareTableViewCell";

@interface Croak_MineVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *croak_headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *croak_avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *croak_nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_userIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_diamondsLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_squareTitleLabel;
@property (weak, nonatomic) IBOutlet UITableView *croak_tableView;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSString *> *> *croak_posts;

@end

@implementation Croak_MineVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    self.croak_headerImageView.image = [UIImage imageNamed:@"croak_photo"];
    self.croak_avatarImageView.image = [UIImage imageNamed:@"croak_avatar"];
    self.croak_avatarImageView.layer.cornerRadius = 36.0;
    self.croak_avatarImageView.layer.masksToBounds = YES;

    self.croak_nameLabel.text = @"Xi_yin";
    self.croak_ageLabel.text = @"23";
    self.croak_userIdLabel.text = @"ID: 1234567";
    self.croak_diamondsLabel.text = @"1000";
    self.croak_squareTitleLabel.text = @"Friends Square";

    self.croak_posts = @[
        @{@"name": @"Xi_yin", @"time": @"Today", @"content": @"Check-in done today. Nice!", @"image": @"croak_photo", @"avatar": @"croak_avatar", @"likes": @"128"},
        @{@"name": @"Xi_yin", @"time": @"Yesterday", @"content": @"Welcome to Croak.", @"image": @"croak_photo", @"avatar": @"croak_avatar", @"likes": @"96"}
    ];

    [self.croak_tableView registerNib:[UINib nibWithNibName:CroakMineSquareCellNibName bundle:[NSBundle mainBundle]]
                forCellReuseIdentifier:CroakMineSquareCellIdentifier];
    self.croak_tableView.delegate = self;
    self.croak_tableView.dataSource = self;
    self.croak_tableView.rowHeight = 381.0;
    self.croak_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.croak_tableView reloadData];
}

- (IBAction)croak_editAction:(id)sender {
    [self.navigationController pushViewController:[Croak_SettingVC new] animated:YES];
}

- (IBAction)croak_settingAction:(id)sender {
    [self.navigationController pushViewController:[Croak_SettingVC new] animated:YES];
}

- (IBAction)croak_diamondsAction:(id)sender {
    Croak_DiamondsVC *diamondsVC = [[Croak_DiamondsVC alloc] init];
    diamondsVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:diamondsVC animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.croak_posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Croak_SquareTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CroakMineSquareCellIdentifier];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:CroakMineSquareCellNibName owner:nil options:nil].firstObject;
    }

    NSDictionary<NSString *, NSString *> *postInfo = self.croak_posts[indexPath.row];
    [cell croak_configureWithName:postInfo[@"name"]
                             time:postInfo[@"time"]
                          content:postInfo[@"content"]
                        imageName:postInfo[@"image"]
                       avatarName:postInfo[@"avatar"]
                        likeCount:postInfo[@"likes"]];
    return cell;
}


@end
