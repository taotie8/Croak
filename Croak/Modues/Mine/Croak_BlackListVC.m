

#import "Croak_BlackListVC.h"
#import "Croak_AppDataStore.h"
#import "Croak_BlackListCell.h"
#import "Croak_UserSession.h"
#import "SVProgressHUD.h"

static NSString * const CroakBlackListCellIdentifier = @"Croak_BlackListCell";
static CGFloat const CroakEmptyStateImageLength = 154.0;

@interface Croak_BlackListVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *croak_tableView;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *croak_users;

@end

@implementation Croak_BlackListVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.croak_users = @[];
    [self croak_findTableViewInView:self.view];
    self.croak_tableView.delegate = self;
    self.croak_tableView.dataSource = self;
    self.croak_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.croak_tableView registerNib:[UINib nibWithNibName:CroakBlackListCellIdentifier bundle:nil]
                forCellReuseIdentifier:CroakBlackListCellIdentifier];
    [self croak_updateEmptyState];
    [self croak_loadBlockedUsers];
}

- (IBAction)croak_backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.croak_users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Croak_BlackListCell *cell = [tableView dequeueReusableCellWithIdentifier:CroakBlackListCellIdentifier
                                                                 forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary<NSString *, id> *userInfo = self.croak_users[indexPath.row];
    [cell croak_configureWithUserInfo:userInfo];
    __weak typeof(self) weakSelf = self;
    cell.croak_unblockActionHandler = ^(Croak_BlackListCell *selectedCell) {
        [weakSelf croak_unblockUserForCell:selectedCell];
    };
    return cell;
}

- (void)croak_loadBlockedUsers {
    NSString *account = [self croak_trimmedString:Croak_UserSession.croak_currentAccount];
    if (account.length == 0) {
        self.croak_users = @[];
        [self croak_reloadTableView];
        [SVProgressHUD showErrorWithStatus:@"Please log in first."];
        return;
    }

    if ([Croak_AppDataStore sharedStore].croak_isLoaded) {
        [self croak_updateBlockedUsersForAccount:account];
        return;
    }

    [SVProgressHUD show];
    [[Croak_AppDataStore sharedStore] croak_fetchAllDataWithCompletion:^(NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }
        [self croak_updateBlockedUsersForAccount:account];
    }];
}

- (void)croak_updateBlockedUsersForAccount:(NSString *)account {
    self.croak_users = [[Croak_AppDataStore sharedStore] croak_blockedUsersForAccount:account];
    [self croak_reloadTableView];
}

- (void)croak_unblockUserForCell:(Croak_BlackListCell *)cell {
    NSIndexPath *indexPath = [self.croak_tableView indexPathForCell:cell];
    if (!indexPath || indexPath.row >= self.croak_users.count) {
        return;
    }

    NSString *account = [self croak_trimmedString:Croak_UserSession.croak_currentAccount];
    NSDictionary<NSString *, id> *userInfo = self.croak_users[indexPath.row];
    NSString *userId = [self croak_userIdFromUserInfo:userInfo];
    [[Croak_AppDataStore sharedStore] croak_unblockUserId:userId
                                                  account:account
                                               completion:^(NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        NSMutableArray<NSDictionary<NSString *, id> *> *users = [self.croak_users mutableCopy];
        [users removeObjectAtIndex:(NSUInteger)indexPath.row];
        self.croak_users = users;
        [self croak_reloadTableView];
        [SVProgressHUD showSuccessWithStatus:@"Unblocked."];
    }];
}

- (void)croak_reloadTableView {
    [self.croak_tableView reloadData];
    [self croak_updateEmptyState];
}

- (void)croak_updateEmptyState {
    self.croak_tableView.backgroundView = self.croak_users.count > 0 ? nil : [self croak_emptyBackgroundView];
}

- (UIView *)croak_emptyBackgroundView {
    UIView *containerView = [[UIView alloc] initWithFrame:self.croak_tableView.bounds];
    containerView.backgroundColor = [UIColor clearColor];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Nothing_yet"]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:imageView];

    [NSLayoutConstraint activateConstraints:@[
        [imageView.centerXAnchor constraintEqualToAnchor:containerView.centerXAnchor],
        [imageView.centerYAnchor constraintEqualToAnchor:containerView.centerYAnchor constant:-40.0],
        [imageView.widthAnchor constraintEqualToConstant:CroakEmptyStateImageLength],
        [imageView.heightAnchor constraintEqualToConstant:CroakEmptyStateImageLength]
    ]];
    return containerView;
}

- (void)croak_findTableViewInView:(UIView *)view {
    if ([view isKindOfClass:UITableView.class]) {
        self.croak_tableView = (UITableView *)view;
        return;
    }

    for (UIView *subview in view.subviews) {
        [self croak_findTableViewInView:subview];
        if (self.croak_tableView) {
            return;
        }
    }
}

- (NSString *)croak_userIdFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *userId = [self croak_normalizedString:userInfo[@"iif"]];
    if (userId.length == 0) {
        userId = [self croak_normalizedString:userInfo[@"id"]];
    }
    return userId;
}

- (NSString *)croak_trimmedString:(id)value {
    if ([value isKindOfClass:NSString.class]) {
        return [value stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    }
    if ([value isKindOfClass:NSNumber.class]) {
        return [[value stringValue] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    }
    return @"";
}

- (NSString *)croak_normalizedString:(id)value {
    return [[self croak_trimmedString:value] lowercaseString];
}

@end
