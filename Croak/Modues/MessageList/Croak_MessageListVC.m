
#import "Croak_MessageListVC.h"
#import "Croak_MessageListViewCell.h"
#import "Croak_MessageChatVC.h"
#import "Croak_SearchVC.h"

static NSString * const CroakMessageListCellIdentifier = @"Croak_MessageListViewCell";

@interface Croak_MessageListVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *croak_avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *croak_nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *croak_searchButton;
@property (weak, nonatomic) IBOutlet UIButton *croak_turnButton;
@property (weak, nonatomic) IBOutlet UITableView *croak_tableView;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSString *> *> *croak_messages;

@end

@implementation Croak_MessageListVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.croak_nameLabel.text = @"Croak";
    self.croak_avatarImageView.image = [UIImage imageNamed:@"croak_avatar"];
    self.croak_avatarImageView.layer.cornerRadius = 20.0;
    self.croak_avatarImageView.layer.masksToBounds = YES;

    self.croak_messages = @[
        @{@"name": @"Ava", @"time": @"09:30", @"message": @"Check-in done today. Nice!"},
        @{@"name": @"Mia", @"time": @"Yesterday", @"message": @"Welcome to Croak."},
        @{@"name": @"Leo", @"time": @"Mon", @"message": @"Tap to open the chat."}
    ];

    [self.croak_tableView registerNib:[UINib nibWithNibName:CroakMessageListCellIdentifier bundle:nil]
                forCellReuseIdentifier:CroakMessageListCellIdentifier];
    self.croak_tableView.delegate = self;
    self.croak_tableView.dataSource = self;
    self.croak_tableView.rowHeight = 64.0;
    self.croak_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (IBAction)croak_searchAction:(id)sender {
    Croak_SearchVC *searchVC = [[Croak_SearchVC alloc] init];
    searchVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchVC animated:YES];
}

- (IBAction)croak_turnAction:(id)sender {
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.croak_messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Croak_MessageListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CroakMessageListCellIdentifier
                                                                       forIndexPath:indexPath];
    NSDictionary<NSString *, NSString *> *message = self.croak_messages[indexPath.row];
    [cell croak_configureWithName:message[@"name"]
                             time:message[@"time"]
                          message:message[@"message"]
                       avatarName:@"croak_avatar"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary<NSString *, NSString *> *message = self.croak_messages[indexPath.row];
    Croak_MessageChatVC *chatVC = [[Croak_MessageChatVC alloc] init];
    chatVC.croak_name = message[@"name"];
    chatVC.croak_avatarName = @"croak_avatar";
    chatVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
}

@end
