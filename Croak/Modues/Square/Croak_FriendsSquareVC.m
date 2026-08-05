
#import "Croak_FriendsSquareVC.h"
#import "Croak_AppDataStore.h"
#import "Croak_SquareTableViewCell.h"
#import "Croak_SquareDetailsVC.h"
#import "Croak_PostSquareVC.h"
#import "Croak_FriendsCenterVC.h"
#import "Croak_UserSession.h"
#import "Croak_ViewController.h"
#import "Croak_ReportDetailsVC.h"
#import "Croak_ReportView.h"
#import "SVProgressHUD.h"

static NSString * const CroakSquareTableViewCellIdentifier = @"Croak_SquareTableViewCell";
static CGFloat const CroakEmptyStateImageLength = 154.0;

@interface Croak_FriendsSquareVC ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *croak_headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *croak_titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_dayLabel;
@property (weak, nonatomic) IBOutlet UITableView *croak_tableView;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *croak_posts;
@property (nonatomic, assign) BOOL croak_hasLoadedPosts;

@end

@implementation Croak_FriendsSquareVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.croak_posts = @[];
    [self croak_updateDateHeaderWithPostItem:nil];
    [self.croak_tableView registerNib:[UINib nibWithNibName:CroakSquareTableViewCellIdentifier bundle:nil]
                forCellReuseIdentifier:CroakSquareTableViewCellIdentifier];
    self.croak_tableView.delegate = self;
    self.croak_tableView.dataSource = self;
    self.croak_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self croak_updateEmptyState];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.croak_hasLoadedPosts) {
        [self croak_loadFriendPosts];
    }
}

- (IBAction)croak_postAction:(id)sender {
    Croak_PostSquareVC *vc = [Croak_PostSquareVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.croak_posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Croak_SquareTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CroakSquareTableViewCellIdentifier
                                                                       forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary<NSString *, id> *postItem = self.croak_posts[indexPath.row];
    NSDictionary<NSString *, id> *postInfo = [postItem[@"post"] isKindOfClass:NSDictionary.class] ? postItem[@"post"] : @{};
    NSDictionary<NSString *, id> *userInfo = [postItem[@"user"] isKindOfClass:NSDictionary.class] ? postItem[@"user"] : @{};
    NSString *currentUserId = [self croak_currentUserId];
    [cell croak_configureWithName:[self croak_displayNameFromUserInfo:userInfo]
                              time:[self croak_timeTextFromPostInfo:postInfo]
                           content:[self croak_contentFromPostInfo:postInfo]
                        imageName:[self croak_imageNameFromPostInfo:postInfo]
                       avatarName:[self croak_avatarNameFromUserInfo:userInfo]
                         likeCount:[self croak_likedUserNamesFromPostInfo:postInfo]
                              liked:[self croak_postInfo:postInfo likedByUserId:currentUserId]];
    __weak typeof(self) weakSelf = self;
    cell.croak_loveActionHandler = ^(Croak_SquareTableViewCell *selectedCell) {
        [weakSelf croak_toggleLikeForCell:selectedCell];
    };
    cell.croak_avatarActionHandler = ^(Croak_SquareTableViewCell *selectedCell) {
        [weakSelf croak_showFriendsCenterForCell:selectedCell];
    };
    cell.croak_moreActionHandler = ^(Croak_SquareTableViewCell *selectedCell) {
        [weakSelf croak_showMoreForCell:selectedCell];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Croak_SquareDetailsVC *vc = [Croak_SquareDetailsVC new];
    vc.croak_postItem = self.croak_posts[indexPath.row];
    __weak typeof(self) weakSelf = self;
    vc.croak_postUpdateHandler = ^(NSDictionary<NSString *,id> *postInfo) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) {
            return;
        }

        [self croak_updatePostAtIndex:indexPath.row postInfo:postInfo];
        if (indexPath.row < self.croak_posts.count) {
            [self.croak_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    };
    vc.croak_postDeleteHandler = ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || indexPath.row >= self.croak_posts.count) {
            return;
        }

        NSMutableArray<NSDictionary<NSString *, id> *> *posts = [self.croak_posts mutableCopy];
        [posts removeObjectAtIndex:(NSUInteger)indexPath.row];
        self.croak_posts = posts;
        [self croak_updateDateHeaderWithPostItem:self.croak_posts.firstObject];
        [self croak_reloadTableView];
    };
    vc.croak_userBlockHandler = ^(NSString *userId) {
        __strong typeof(weakSelf) self = weakSelf;
        [self croak_removePostsForUserId:userId];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)croak_showFriendsCenterForCell:(Croak_SquareTableViewCell *)cell {
    NSIndexPath *indexPath = [self.croak_tableView indexPathForCell:cell];
    if (!indexPath || indexPath.row >= self.croak_posts.count) {
        return;
    }

    NSDictionary<NSString *, id> *postItem = self.croak_posts[indexPath.row];
    NSDictionary<NSString *, id> *userInfo = [postItem[@"user"] isKindOfClass:NSDictionary.class] ? postItem[@"user"] : @{};
    [self croak_showFriendsCenterWithUserInfo:userInfo];
}

- (void)croak_showFriendsCenterWithUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    Croak_FriendsCenterVC *friendsCenterVC = [[Croak_FriendsCenterVC alloc] init];
    friendsCenterVC.croak_userInfo = userInfo;
    friendsCenterVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:friendsCenterVC animated:YES];
}

- (void)croak_showMoreForCell:(Croak_SquareTableViewCell *)cell {
    NSIndexPath *indexPath = [self.croak_tableView indexPathForCell:cell];
    if (!indexPath || indexPath.row >= self.croak_posts.count) {
        return;
    }

    [self croak_showMoreForPostItem:self.croak_posts[indexPath.row] indexPath:indexPath];
}

- (void)croak_showMoreForPostItem:(NSDictionary<NSString *, id> *)postItem
                         indexPath:(NSIndexPath *)indexPath {
    Croak_ReportView *reportView = [Croak_ReportView croak_reportView];
    __weak typeof(self) weakSelf = self;
    reportView.croak_actionHandler = ^(CroakReportViewAction action) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) {
            return;
        }

        if (action == CroakReportViewActionReport) {
            [self croak_openReportDetailsForPostItem:postItem];
        } else if (action == CroakReportViewActionBlock) {
            [self croak_blockUserFromPostItem:postItem];
        } else if (action == CroakReportViewActionDelete) {
            [self croak_confirmDeletePostItem:postItem indexPath:indexPath];
        }
    };

    UIView *targetView = self.view.window ?: self.view;
    [reportView croak_showInView:targetView];
}

- (void)croak_openReportDetailsForPostItem:(NSDictionary<NSString *, id> *)postItem {
    Croak_ReportDetailsVC *reportDetailsVC = [[Croak_ReportDetailsVC alloc] init];
    reportDetailsVC.croak_reportTitle = @"Report";
    reportDetailsVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:reportDetailsVC animated:YES];
}

- (void)croak_blockUserFromPostItem:(NSDictionary<NSString *, id> *)postItem {
    NSString *account = [self croak_currentAccountForAction];
    if (account.length == 0) {
        return;
    }

    NSDictionary<NSString *, id> *userInfo = [postItem[@"user"] isKindOfClass:NSDictionary.class] ? postItem[@"user"] : @{};
    NSString *blockedUserId = [self croak_userIdFromUserInfo:userInfo];
    [[Croak_AppDataStore sharedStore] croak_blockUser:userInfo
                                              account:account
                                           completion:^(NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        if (blockedUserId.length > 0) {
            [self croak_removePostsForUserId:blockedUserId];
        }
        [SVProgressHUD showSuccessWithStatus:@"Blocked."];
    }];
}

- (void)croak_confirmDeletePostItem:(NSDictionary<NSString *, id> *)postItem
                           indexPath:(NSIndexPath *)indexPath {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete post?"
                                                                   message:@"This action cannot be undone."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [weakSelf croak_deletePostItem:postItem indexPath:indexPath];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)croak_deletePostItem:(NSDictionary<NSString *, id> *)postItem
                   indexPath:(NSIndexPath *)indexPath {
    NSString *account = [self croak_currentAccountForAction];
    if (account.length == 0) {
        return;
    }

    NSDictionary<NSString *, id> *postInfo = [postItem[@"post"] isKindOfClass:NSDictionary.class] ? postItem[@"post"] : @{};
    [SVProgressHUD show];
    [[Croak_AppDataStore sharedStore] croak_deletePost:postInfo
                                               account:account
                                            completion:^(NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        if (indexPath.row < self.croak_posts.count) {
            NSMutableArray<NSDictionary<NSString *, id> *> *posts = [self.croak_posts mutableCopy];
            [posts removeObjectAtIndex:(NSUInteger)indexPath.row];
            self.croak_posts = posts;
            [self croak_updateDateHeaderWithPostItem:self.croak_posts.firstObject];
            [self croak_reloadTableView];
        }
        [SVProgressHUD showSuccessWithStatus:@"Deleted."];
    }];
}

- (void)croak_toggleLikeForCell:(Croak_SquareTableViewCell *)cell {
    NSIndexPath *indexPath = [self.croak_tableView indexPathForCell:cell];
    if (!indexPath || indexPath.row >= self.croak_posts.count) {
        return;
    }

    NSString *account = [self croak_currentAccountForAction];
    if (account.length == 0) {
        return;
    }

    NSDictionary<NSString *, id> *postItem = self.croak_posts[indexPath.row];
    NSDictionary<NSString *, id> *postInfo = [postItem[@"post"] isKindOfClass:NSDictionary.class] ? postItem[@"post"] : @{};
    cell.croak_loveButton.enabled = NO;
    [[Croak_AppDataStore sharedStore] croak_toggleLikeForPost:postInfo
                                                      account:account
                                                   completion:^(NSDictionary<NSString *,id> *updatedPostInfo, BOOL liked, NSError *error) {
        Croak_SquareTableViewCell *visibleCell = [self.croak_tableView cellForRowAtIndexPath:indexPath];
        Croak_SquareTableViewCell *targetCell = visibleCell ?: cell;
        targetCell.croak_loveButton.enabled = YES;
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        NSDictionary<NSString *, id> *displayPostInfo = updatedPostInfo ?: postInfo;
        [self croak_updatePostAtIndex:indexPath.row postInfo:displayPostInfo];
        NSString *likeNames = [self croak_likedUserNamesFromPostInfo:displayPostInfo];
        if (liked && likeNames.length == 0) {
            likeNames = [[Croak_AppDataStore sharedStore] croak_displayNameForAccount:account];
        }
        targetCell.croak_loveButton.selected = liked;
        targetCell.croak_likeCountLabel.text = likeNames;
#if DEBUG
        NSLog(@"\n[Croak Like UI]\naccount: %@\nliked: %@\nlabel: %@",
              account,
              liked ? @"YES" : @"NO",
              likeNames);
#endif
    }];
}

- (void)croak_updatePostAtIndex:(NSInteger)index postInfo:(NSDictionary<NSString *, id> *)postInfo {
    if (index < 0 || index >= self.croak_posts.count || ![postInfo isKindOfClass:NSDictionary.class]) {
        return;
    }

    NSDictionary<NSString *, id> *oldPostItem = self.croak_posts[(NSUInteger)index];
    NSMutableDictionary<NSString *, id> *newPostItem = [oldPostItem isKindOfClass:NSDictionary.class] ? [oldPostItem mutableCopy] : [NSMutableDictionary dictionary];
    newPostItem[@"post"] = postInfo;

    NSMutableArray<NSDictionary<NSString *, id> *> *posts = [self.croak_posts mutableCopy];
    posts[(NSUInteger)index] = newPostItem;
    self.croak_posts = posts;
}

- (void)croak_reloadTableView {
    [self.croak_tableView reloadData];
    [self croak_updateEmptyState];
}

- (void)croak_updateEmptyState {
    self.croak_tableView.backgroundView = self.croak_posts.count > 0 ? nil : [self croak_emptyBackgroundView];
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

- (void)croak_removePostsForUserId:(NSString *)userId {
    NSString *targetUserId = [self croak_normalizedString:userId];
    if (targetUserId.length == 0) {
        return;
    }

    NSMutableArray<NSDictionary<NSString *, id> *> *posts = [NSMutableArray array];
    for (NSDictionary<NSString *, id> *postItem in self.croak_posts) {
        NSDictionary<NSString *, id> *userInfo = [postItem[@"user"] isKindOfClass:NSDictionary.class] ? postItem[@"user"] : @{};
        if ([[self croak_userIdFromUserInfo:userInfo] isEqualToString:targetUserId]) {
            continue;
        }
        [posts addObject:postItem];
    }
    self.croak_posts = posts;
    [self croak_updateDateHeaderWithPostItem:self.croak_posts.firstObject];
    [self croak_reloadTableView];
}

- (void)croak_loadFriendPosts {
    NSString *account = [self croak_trimmedString:Croak_UserSession.croak_currentAccount];
    if (account.length == 0) {
        self.croak_posts = @[];
        [self croak_reloadTableView];
        return;
    }

    self.croak_hasLoadedPosts = YES;
    [SVProgressHUD show];
    [[Croak_AppDataStore sharedStore] croak_fetchFriendPostsForAccount:account
                                                             completion:^(NSArray<NSDictionary<NSString *,id> *> *users, NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            self.croak_hasLoadedPosts = NO;
            self.croak_posts = @[];
            [self croak_reloadTableView];
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        self.croak_posts = users ?: @[];
        [self croak_updateDateHeaderWithPostItem:self.croak_posts.firstObject];
        [self croak_reloadTableView];
    }];
}

- (NSString *)croak_currentAccountForAction {
    NSString *account = [self croak_trimmedString:Croak_UserSession.croak_currentAccount];
    if (account.length > 0) {
        return account;
    }

#if DEBUG
    NSLog(@"\n[Croak Session]\ncurrentAccount is empty when tapping like.");
#endif
    [Croak_UserSession croak_clearSession];
    [SVProgressHUD showErrorWithStatus:@"Please log in first."];
    [self croak_showLoginInterface];
    return @"";
}

- (void)croak_showLoginInterface {
    UIWindow *window = self.view.window ?: UIApplication.sharedApplication.delegate.window;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[Croak_ViewController alloc] init]];
    window.rootViewController = navigationController;
    [window makeKeyAndVisible];

    [UIView transitionWithView:window
                      duration:0.25
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:nil
                    completion:nil];
}

- (NSString *)croak_displayNameFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *name = [self croak_trimmedString:userInfo[@"kjvmvsaz"]];
    if (name.length == 0) {
        name = [self croak_trimmedString:userInfo[@"nickname"]];
    }
    if (name.length == 0) {
        name = [self croak_trimmedString:userInfo[@"kewgxwk"]];
    }
    return name.length > 0 ? name : @"Unknown";
}

- (NSString *)croak_avatarNameFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *avatarName = [self croak_rawImageNameFromValue:userInfo[@"fsuv"]];
    if (avatarName.length == 0) {
        avatarName = [self croak_rawImageNameFromValue:userInfo[@"avatar"]];
    }
    return avatarName;
}

- (NSString *)croak_contentFromPostInfo:(NSDictionary<NSString *, id> *)postInfo {
    NSString *content = [self croak_trimmedString:postInfo[@"hctnqmww"]];
    if (content.length == 0) {
        content = [self croak_trimmedString:postInfo[@"content"]];
    }
    return content;
}

- (NSString *)croak_imageNameFromPostInfo:(NSDictionary<NSString *, id> *)postInfo {
    id images = postInfo[@"yuylv"] ?: postInfo[@"images"];
    if ([images isKindOfClass:NSArray.class]) {
        for (id imageName in (NSArray *)images) {
            NSString *value = [self croak_rawImageNameFromValue:imageName];
            if (value.length > 0) {
                return value;
            }
        }
    }
    return @"";
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

- (NSString *)croak_likedUserNamesFromPostInfo:(NSDictionary<NSString *, id> *)postInfo {
    return [[Croak_AppDataStore sharedStore] croak_likedUserNamesFromPostInfo:postInfo
                                                               currentAccount:Croak_UserSession.croak_currentAccount];
}

- (BOOL)croak_postInfo:(NSDictionary<NSString *, id> *)postInfo likedByUserId:(NSString *)userId {
    if (userId.length == 0) {
        return NO;
    }

    id likedUserIds = postInfo[@"ri"] ?: postInfo[@"likedUserIds"];
    if (![likedUserIds isKindOfClass:NSArray.class]) {
        return NO;
    }

    for (id likedUserId in (NSArray *)likedUserIds) {
        if ([[self croak_normalizedString:likedUserId] isEqualToString:userId]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)croak_currentUserId {
    return [[Croak_AppDataStore sharedStore] croak_currentUserId];
}

- (NSString *)croak_userIdFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *userId = [self croak_normalizedString:userInfo[@"iif"]];
    if (userId.length == 0) {
        userId = [self croak_normalizedString:userInfo[@"id"]];
    }
    return userId;
}

- (NSString *)croak_shortUserId:(NSString *)userId {
    if (userId.length <= 8) {
        return userId;
    }
    return [userId substringToIndex:8];
}

- (NSString *)croak_userNameForUserId:(NSString *)userId {
    if (userId.length == 0) {
        return @"";
    }

    NSArray *users = [Croak_AppDataStore sharedStore].croak_dataLayer[@"hok"];
    if (![users isKindOfClass:NSArray.class]) {
        return @"";
    }

    for (NSDictionary<NSString *, id> *userInfo in users) {
        if (![userInfo isKindOfClass:NSDictionary.class]) {
            continue;
        }

        NSString *candidateUserId = [self croak_normalizedString:userInfo[@"iif"]];
        if (candidateUserId.length == 0) {
            candidateUserId = [self croak_normalizedString:userInfo[@"id"]];
        }
        if (![candidateUserId isEqualToString:userId]) {
            continue;
        }

        NSString *name = [self croak_trimmedString:userInfo[@"kjvmvsaz"]];
        if (name.length == 0) {
            name = [self croak_trimmedString:userInfo[@"nickname"]];
        }
        if (name.length == 0) {
            name = [self croak_trimmedString:userInfo[@"kewgxwk"]];
        }
        return name;
    }
    return @"";
}

- (NSString *)croak_createdAtFromPostInfo:(NSDictionary<NSString *, id> *)postInfo {
    NSString *createdAt = [self croak_trimmedString:postInfo[@"jumog"]];
    if (createdAt.length == 0) {
        createdAt = [self croak_trimmedString:postInfo[@"createdAt"]];
    }
    return createdAt;
}

- (NSString *)croak_timeTextFromPostInfo:(NSDictionary<NSString *, id> *)postInfo {
    NSDate *date = [self croak_dateFromISOString:[self croak_createdAtFromPostInfo:postInfo]];
    if (!date) {
        return @"";
    }

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"MMM d, HH:mm";
    return [formatter stringFromDate:date];
}

- (void)croak_updateDateHeaderWithPostItem:(NSDictionary<NSString *, id> *)postItem {
    NSDate *date = NSDate.date;

    NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
    monthFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    monthFormatter.dateFormat = @"MMMM";
    self.croak_monthLabel.text = [monthFormatter stringFromDate:date];

    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    dayFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    dayFormatter.dateFormat = @"d";
    self.croak_dayLabel.text = [dayFormatter stringFromDate:date];
}

- (NSDate *)croak_dateFromISOString:(NSString *)dateString {
    if (dateString.length == 0) {
        return nil;
    }

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    return [formatter dateFromString:dateString];
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
