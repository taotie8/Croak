
#import "Croak_FriendsCenterVC.h"
#import "Croak_API.h"
#import "Croak_AppDataStore.h"
#import "Croak_SquareDetailsVC.h"
#import "Croak_SquareTableViewCell.h"
#import "Croak_UserSession.h"
#import "Croak_VideoCallsVC.h"
#import "Croak_ReportDetailsVC.h"
#import "Croak_ReportView.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"

static NSString * const CroakFriendsCenterPostCellIdentifier = @"Croak_SquareTableViewCell";

@interface Croak_FriendsCenterVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *croak_tableView;
@property (weak, nonatomic) IBOutlet UIImageView *croak_backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *croak_headerView;
@property (weak, nonatomic) IBOutlet UILabel *croak_name_label;
@property (weak, nonatomic) IBOutlet UILabel *croak_age_label;
@property (weak, nonatomic) IBOutlet UILabel *croak_id_label;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *croak_posts;

@end

@implementation Croak_FriendsCenterVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.croak_posts = @[];
    self.croak_headerView.layer.cornerRadius = 36.0;
    self.croak_headerView.layer.masksToBounds = YES;
    self.croak_tableView.delegate = self;
    self.croak_tableView.dataSource = self;
    self.croak_tableView.backgroundColor = [UIColor whiteColor];
    self.croak_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.croak_tableView registerNib:[UINib nibWithNibName:CroakFriendsCenterPostCellIdentifier bundle:nil]
                forCellReuseIdentifier:CroakFriendsCenterPostCellIdentifier];

    [self croak_configureUserInfo];
    [self croak_loadUserPosts];
}

- (IBAction)croak_navBackWithCallAndMoreAction:(UIButton *)sender {
    if (sender.tag == 1) {
        [self.navigationController popViewControllerAnimated:true];
    }
    else if (sender.tag == 2) {
        Croak_VideoCallsVC *calls = [[Croak_VideoCallsVC alloc] init];
        calls.croak_name = [self croak_displayNameFromUserInfo:self.croak_userInfo];
        calls.croak_avatarName = [self croak_avatarNameFromUserInfo:self.croak_userInfo];
        calls.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:calls animated:YES completion:nil];
    }
    else {
        [self croak_showMoreOptionsForUser];
    }
}


- (IBAction)croak_gotoChatAction:(id)sender {
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.croak_posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Croak_SquareTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CroakFriendsCenterPostCellIdentifier
                                                                       forIndexPath:indexPath];
    cell.backgroundColor = UIColor.clearColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    NSDictionary<NSString *, id> *postItem = self.croak_posts[indexPath.row];
    NSDictionary<NSString *, id> *postInfo = [postItem[@"post"] isKindOfClass:NSDictionary.class] ? postItem[@"post"] : @{};
    NSDictionary<NSString *, id> *userInfo = [postItem[@"user"] isKindOfClass:NSDictionary.class] ? postItem[@"user"] : self.croak_userInfo ?: @{};
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
    cell.croak_avatarActionHandler = nil;
    cell.croak_moreActionHandler = ^(Croak_SquareTableViewCell *selectedCell) {
        [weakSelf croak_showMoreForCell:selectedCell];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.croak_posts.count) {
        return;
    }

    Croak_SquareDetailsVC *detailsVC = [[Croak_SquareDetailsVC alloc] init];
    detailsVC.croak_postItem = self.croak_posts[indexPath.row];
    __weak typeof(self) weakSelf = self;
    detailsVC.croak_postUpdateHandler = ^(NSDictionary<NSString *,id> *postInfo) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) {
            return;
        }

        [self croak_updatePostAtIndex:indexPath.row postInfo:postInfo];
        if (indexPath.row < self.croak_posts.count) {
            [self.croak_tableView reloadRowsAtIndexPaths:@[indexPath]
                                         withRowAnimation:UITableViewRowAnimationNone];
        }
    };
    detailsVC.croak_postDeleteHandler = ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || indexPath.row >= self.croak_posts.count) {
            return;
        }

        NSMutableArray<NSDictionary<NSString *, id> *> *posts = [self.croak_posts mutableCopy];
        [posts removeObjectAtIndex:(NSUInteger)indexPath.row];
        self.croak_posts = posts;
        [self.croak_tableView reloadData];
    };
    detailsVC.croak_userBlockHandler = ^(NSString *userId) {
        __strong typeof(weakSelf) self = weakSelf;
        [self croak_removePostsForUserId:userId];
    };
    [self.navigationController pushViewController:detailsVC animated:YES];
}

- (void)croak_showMoreOptionsForUser {
    Croak_ReportView *reportView = [Croak_ReportView croak_reportView];
    __weak typeof(self) weakSelf = self;
    reportView.croak_actionHandler = ^(CroakReportViewAction action) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) {
            return;
        }

        if (action == CroakReportViewActionReport) {
            [self croak_openReportDetailsForUser];
        } else if (action == CroakReportViewActionBlock) {
            [self croak_blockUser:self.croak_userInfo removingPosts:YES];
        } else if (action == CroakReportViewActionDelete) {
            [SVProgressHUD showErrorWithStatus:@"Delete is only available for posts."];
        }
    };

    UIView *targetView = self.view.window ?: self.view;
    [reportView croak_showInView:targetView];
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
            NSDictionary<NSString *, id> *userInfo = [postItem[@"user"] isKindOfClass:NSDictionary.class] ? postItem[@"user"] : self.croak_userInfo ?: @{};
            [self croak_blockUser:userInfo removingPosts:YES];
        } else if (action == CroakReportViewActionDelete) {
            [self croak_confirmDeletePostItem:postItem indexPath:indexPath];
        }
    };

    UIView *targetView = self.view.window ?: self.view;
    [reportView croak_showInView:targetView];
}

- (void)croak_openReportDetailsForUser {
    Croak_ReportDetailsVC *reportDetailsVC = [[Croak_ReportDetailsVC alloc] init];
    reportDetailsVC.croak_reportTitle = @"Report";
    [self.navigationController pushViewController:reportDetailsVC animated:YES];
}

- (void)croak_blockUser:(NSDictionary<NSString *, id> *)userInfo removingPosts:(BOOL)removingPosts {
    NSString *account = [self croak_trimmedString:Croak_UserSession.croak_currentAccount];
    if (account.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"Please log in first."];
        return;
    }

    NSString *blockedUserId = [self croak_userIdFromUserInfo:userInfo];
    [[Croak_AppDataStore sharedStore] croak_blockUser:userInfo
                                              account:account
                                           completion:^(NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        if (removingPosts) {
            [self croak_removePostsForUserId:blockedUserId];
        }
        [SVProgressHUD showSuccessWithStatus:@"Blocked."];
    }];
}

- (void)croak_removePostsForUserId:(NSString *)userId {
    NSString *targetUserId = [self croak_normalizedString:userId];
    if (targetUserId.length == 0) {
        return;
    }

    NSMutableArray<NSDictionary<NSString *, id> *> *posts = [NSMutableArray array];
    for (NSDictionary<NSString *, id> *postItem in self.croak_posts) {
        NSDictionary<NSString *, id> *userInfo = [postItem[@"user"] isKindOfClass:NSDictionary.class] ? postItem[@"user"] : self.croak_userInfo ?: @{};
        if ([[self croak_userIdFromUserInfo:userInfo] isEqualToString:targetUserId]) {
            continue;
        }
        [posts addObject:postItem];
    }
    self.croak_posts = posts;
    [self.croak_tableView reloadData];
}

- (void)croak_openReportDetailsForPostItem:(NSDictionary<NSString *, id> *)postItem {
    Croak_ReportDetailsVC *reportDetailsVC = [[Croak_ReportDetailsVC alloc] init];
    reportDetailsVC.croak_reportTitle = @"Report";
    [self.navigationController pushViewController:reportDetailsVC animated:YES];
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
    NSString *account = [self croak_trimmedString:Croak_UserSession.croak_currentAccount];
    if (account.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"Please log in first."];
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
            [self.croak_tableView reloadData];
        }
        [SVProgressHUD showSuccessWithStatus:@"Deleted."];
    }];
}

- (void)croak_configureUserInfo {
    self.croak_name_label.text = [self croak_displayNameFromUserInfo:self.croak_userInfo];
    self.croak_id_label.text = [NSString stringWithFormat:@"ID:%@", [self croak_shortIdFromUserInfo:self.croak_userInfo]];
    self.croak_age_label.text = [self croak_ageTextFromUserInfo:self.croak_userInfo];
    [self croak_setAvatarWithName:[self croak_avatarNameFromUserInfo:self.croak_userInfo]];
}

- (void)croak_loadUserPosts {
    if ([Croak_AppDataStore sharedStore].croak_isLoaded) {
        [self croak_updateUserPosts];
        return;
    }

    [SVProgressHUD show];
    [[Croak_AppDataStore sharedStore] croak_fetchAllDataWithCompletion:^(NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            self.croak_posts = @[];
            [self.croak_tableView reloadData];
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        [self croak_updateUserPosts];
    }];
}

- (void)croak_updateUserPosts {
    NSString *targetUserId = [self croak_userIdFromUserInfo:self.croak_userInfo];
    NSMutableArray<NSDictionary<NSString *, id> *> *posts = [NSMutableArray array];
    for (NSDictionary<NSString *, id> *postInfo in [self croak_allPosts]) {
        if (![[self croak_userIdFromPostInfo:postInfo] isEqualToString:targetUserId]) {
            continue;
        }
        [posts addObject:@{@"post": postInfo, @"user": self.croak_userInfo ?: @{}}];
    }

    [posts sortUsingComparator:^NSComparisonResult(NSDictionary<NSString *, id> *firstObject,
                                                   NSDictionary<NSString *, id> *secondObject) {
        NSString *firstDate = [self croak_createdAtFromPostInfo:firstObject[@"post"]];
        NSString *secondDate = [self croak_createdAtFromPostInfo:secondObject[@"post"]];
        return [secondDate compare:firstDate];
    }];

    self.croak_posts = posts;
    [self.croak_tableView reloadData];

#if DEBUG
    NSLog(@"\n[Croak Friends Center]\nuserId: %@\npostsCount: %lu\nposts: %@",
          targetUserId,
          (unsigned long)posts.count,
          posts);
#endif
}

- (void)croak_toggleLikeForCell:(Croak_SquareTableViewCell *)cell {
    NSIndexPath *indexPath = [self.croak_tableView indexPathForCell:cell];
    if (!indexPath || indexPath.row >= self.croak_posts.count) {
        return;
    }

    NSString *account = [self croak_trimmedString:Croak_UserSession.croak_currentAccount];
    if (account.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"Please log in first."];
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

- (NSString *)croak_displayNameFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *name = [self croak_trimmedString:userInfo[@"kjvmvsaz"]];
    if (name.length == 0) {
        name = [self croak_trimmedString:userInfo[@"nickname"]];
    }
    if (name.length == 0) {
        name = [self croak_trimmedString:userInfo[@"name"]];
    }
    if (name.length == 0) {
        name = [self croak_trimmedString:userInfo[@"kewgxwk"]];
    }
    if (name.length == 0) {
        name = [self croak_trimmedString:userInfo[@"email"]];
    }
    return name.length > 0 ? name : @"Unknown";
}

- (NSString *)croak_shortIdFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *userId = [self croak_userIdFromUserInfo:userInfo];
    if (userId.length > 8) {
        return [userId substringToIndex:8];
    }
    return userId.length > 0 ? userId : @"";
}

- (NSString *)croak_userIdFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *userId = [self croak_normalizedString:userInfo[@"iif"]];
    if (userId.length == 0) {
        userId = [self croak_normalizedString:userInfo[@"id"]];
    }
    return userId;
}

- (NSString *)croak_ageTextFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *age = [self croak_trimmedString:userInfo[@"age"]];
    if (age.length > 0) {
        return age;
    }

    NSString *birthday = [self croak_trimmedString:userInfo[@"fzlucn"]];
    if (birthday.length == 0) {
        birthday = [self croak_trimmedString:userInfo[@"birthday"]];
    }

    NSDate *birthdayDate = [self croak_dateFromISOString:birthday];
    if (!birthdayDate) {
        return @"";
    }

    NSDateComponents *components = [NSCalendar.currentCalendar components:NSCalendarUnitYear
                                                                 fromDate:birthdayDate
                                                                   toDate:NSDate.date
                                                                  options:0];
    return [NSString stringWithFormat:@"%ld", (long)MAX(0, components.year)];
}

- (NSDate *)croak_dateFromISOString:(NSString *)dateString {
    if (dateString.length == 0) {
        return nil;
    }

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    NSDate *date = [formatter dateFromString:dateString];
    if (date) {
        return date;
    }

    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    return [formatter dateFromString:dateString];
}

- (NSString *)croak_avatarNameFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *avatarName = [self croak_rawImageNameFromValue:userInfo[@"fsuv"]];
    if (avatarName.length == 0) {
        avatarName = [self croak_rawImageNameFromValue:userInfo[@"avatar"]];
    }
    return avatarName;
}

- (void)croak_setAvatarWithName:(NSString *)imageName {
    UIImage *placeholderImage = [UIImage imageNamed:@"croak_avatar"];
    UIImage *localImage = [self croak_localImageWithName:imageName];
    if (localImage) {
        [self.croak_headerView sd_cancelCurrentImageLoad];
        self.croak_headerView.image = localImage;
        [self.croak_backgroundImageView sd_cancelCurrentImageLoad];
        self.croak_backgroundImageView.image = localImage;
        return;
    }

    NSURL *imageURL = [self croak_remoteImageURLWithName:imageName];
    if (imageURL) {
        [self.croak_headerView sd_setImageWithURL:imageURL placeholderImage:placeholderImage];
        [self.croak_backgroundImageView sd_setImageWithURL:imageURL placeholderImage:placeholderImage];
    } else {
        [self.croak_headerView sd_cancelCurrentImageLoad];
        self.croak_headerView.image = placeholderImage;
        [self.croak_backgroundImageView sd_cancelCurrentImageLoad];
        self.croak_backgroundImageView.image = placeholderImage;
    }
}

- (NSArray<NSDictionary<NSString *, id> *> *)croak_allPosts {
    NSDictionary<NSString *, id> *dataLayer = [Croak_AppDataStore sharedStore].croak_dataLayer;
    id posts = dataLayer[@"fcfmx"];
    if (![posts isKindOfClass:NSArray.class]) {
        posts = dataLayer[@"posts"];
    }
    if (![posts isKindOfClass:NSArray.class]) {
        return @[];
    }

    NSMutableArray<NSDictionary<NSString *, id> *> *validPosts = [NSMutableArray array];
    for (id postInfo in (NSArray *)posts) {
        if ([postInfo isKindOfClass:NSDictionary.class]) {
            [validPosts addObject:postInfo];
        }
    }
    return validPosts;
}

- (NSString *)croak_userIdFromPostInfo:(NSDictionary<NSString *, id> *)postInfo {
    NSString *userId = [self croak_normalizedString:postInfo[@"fegg"]];
    if (userId.length == 0) {
        userId = [self croak_normalizedString:postInfo[@"userId"]];
    }
    return userId;
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

- (UIImage *)croak_localImageWithName:(NSString *)imageName {
    if (![imageName isKindOfClass:NSString.class] || imageName.length == 0) {
        return nil;
    }

    UIImage *image = [UIImage imageNamed:imageName];
    if (image) {
        return image;
    }

    NSString *nameWithoutExtension = imageName.stringByDeletingPathExtension;
    if (nameWithoutExtension.length > 0 && ![nameWithoutExtension isEqualToString:imageName]) {
        return [UIImage imageNamed:nameWithoutExtension];
    }
    return nil;
}

- (NSURL *)croak_remoteImageURLWithName:(NSString *)imageName {
    NSString *rawName = [self croak_rawImageNameFromValue:imageName];
    if (rawName.length == 0) {
        return nil;
    }

    if ([rawName hasPrefix:@"http://"] || [rawName hasPrefix:@"https://"]) {
        return [NSURL URLWithString:[rawName stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet] ?: rawName];
    }

    NSString *encodedName = [rawName stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLPathAllowedCharacterSet];
    if (encodedName.length == 0) {
        return nil;
    }
    return [NSURL URLWithString:[CroakAPIAssetBaseURLString stringByAppendingString:encodedName]];
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

- (NSString *)croak_normalizedString:(id)value {
    return [[self croak_trimmedString:value] lowercaseString];
}

@end
