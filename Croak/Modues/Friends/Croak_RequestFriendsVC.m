
#import "Croak_RequestFriendsVC.h"
#import "Croak_AppDataStore.h"
#import "Croak_RequestFriendsCell.h"
#import "Croak_UserSession.h"
#import "SVProgressHUD.h"

static NSString * const CroakRequestFriendsCellIdentifier = @"Croak_RequestFriendsCell";
static NSString * const CroakRequestFriendsCellNibName = @"Croak_RequestFriendsCell";

@interface Croak_RequestFriendsVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *croak_titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *croak_tableView;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *croak_requests;
@property (nonatomic, assign) BOOL croak_isLoadingRequests;

@end

@implementation Croak_RequestFriendsVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    self.croak_titleLabel.text = @"Add Friend";
    self.croak_requests = @[];

    [self.croak_tableView registerNib:[UINib nibWithNibName:CroakRequestFriendsCellNibName bundle:[NSBundle mainBundle]]
                forCellReuseIdentifier:CroakRequestFriendsCellIdentifier];
    self.croak_tableView.delegate = self;
    self.croak_tableView.dataSource = self;
    self.croak_tableView.rowHeight = 68.0;
    self.croak_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.croak_tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self croak_loadRequests];
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

    NSDictionary<NSString *, id> *requestInfo = self.croak_requests[indexPath.row];
    [cell croak_configureWithName:[self croak_displayNameFromUserInfo:requestInfo]
                       avatarName:[self croak_avatarNameFromUserInfo:requestInfo]];

    __weak typeof(self) weakSelf = self;
    cell.croak_addFriendHandler = ^{
        [weakSelf croak_addFriendWithUserInfo:requestInfo];
    };
    return cell;
}

- (void)croak_loadRequests {
    if (self.croak_isLoadingRequests) {
        return;
    }

    NSString *account = [self croak_trimmedString:Croak_UserSession.croak_currentAccount];
    self.croak_isLoadingRequests = YES;
    [SVProgressHUD showWithStatus:@"Loading..."];
    [[Croak_AppDataStore sharedStore] croak_fetchFollowBackRequestsForAccount:account
                                                                   completion:^(NSArray<NSDictionary<NSString *,id> *> *users, NSError *error) {
        self.croak_isLoadingRequests = NO;
        [SVProgressHUD dismiss];
        if (error) {
            self.croak_requests = @[];
            [self.croak_tableView reloadData];
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        self.croak_requests = users ?: @[];
        [self.croak_tableView reloadData];
    }];
}

- (void)croak_addFriendWithUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *account = [self croak_trimmedString:Croak_UserSession.croak_currentAccount];
    [SVProgressHUD showWithStatus:@"Adding..."];
    [[Croak_AppDataStore sharedStore] croak_followUser:userInfo
                                               account:account
                                            completion:^(NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        [self croak_removeRequestUserInfo:userInfo];
        [SVProgressHUD showSuccessWithStatus:@"Added."];
    }];
}

- (void)croak_removeRequestUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *targetUserId = [self croak_userIdFromUserInfo:userInfo];
    if (targetUserId.length == 0) {
        [self croak_loadRequests];
        return;
    }

    NSMutableArray<NSDictionary<NSString *, id> *> *requests = [self.croak_requests mutableCopy];
    NSUInteger index = [requests indexOfObjectPassingTest:^BOOL(NSDictionary<NSString *,id> *candidate, NSUInteger idx, BOOL *stop) {
        BOOL matched = [[self croak_userIdFromUserInfo:candidate] isEqualToString:targetUserId];
        if (matched) {
            *stop = YES;
        }
        return matched;
    }];
    if (index != NSNotFound) {
        [requests removeObjectAtIndex:index];
        self.croak_requests = requests;
        [self.croak_tableView reloadData];
    } else {
        [self croak_loadRequests];
    }
}

- (NSString *)croak_displayNameFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *name = [self croak_trimmedString:userInfo[@"kjvmvsaz"]];
    if (name.length == 0) {
        name = [self croak_trimmedString:userInfo[@"kewgxwk"]];
    }
    return name.length > 0 ? name : @"Unknown";
}

- (NSString *)croak_avatarNameFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *avatarName = [self croak_rawImageNameFromValue:userInfo[@"fsuv"]];
    return avatarName.length > 0 ? avatarName : @"croak_avatar";
}

- (NSString *)croak_userIdFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    return [[self croak_trimmedString:userInfo[@"iif"]] lowercaseString];
}

- (NSString *)croak_rawImageNameFromValue:(id)value {
    NSString *rawName = @"";
    if ([value isKindOfClass:NSString.class]) {
        rawName = (NSString *)value;
    } else if ([value isKindOfClass:NSNumber.class]) {
        rawName = [(NSNumber *)value stringValue];
    }

    if ([[rawName stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] length] == 0) {
        return @"";
    }
    return rawName;
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

@end
