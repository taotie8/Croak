
#import "Croak_MineVC.h"
#import "Croak_SettingVC.h"
#import "Croak_DiamondsVC.h"
#import "Croak_EditPersonVC.h"
#import "Croak_AppDataStore.h"
#import "Croak_API.h"
#import "Croak_ReportDetailsVC.h"
#import "Croak_ReportView.h"
#import "Croak_SquareDetailsVC.h"
#import "Croak_SquareTableViewCell.h"
#import "Croak_UserSession.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"

static NSString * const CroakMineSquareCellIdentifier = @"Croak_SquareTableViewCell";
static NSString * const CroakMineSquareCellNibName = @"Croak_SquareTableViewCell";
static CGFloat const CroakEmptyStateImageLength = 154.0;

@interface Croak_MineVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *croak_headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *croak_avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *croak_nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_userIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_diamondsLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_squareTitleLabel;
@property (weak, nonatomic) IBOutlet UITableView *croak_tableView;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *croak_posts;
@property (nonatomic, assign) BOOL croak_isLoadingData;

@end

@implementation Croak_MineVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    self.croak_avatarImageView.layer.cornerRadius = 36.0;
    self.croak_avatarImageView.layer.masksToBounds = YES;

    self.croak_posts = @[];
    self.croak_nameLabel.text = @"";
    self.croak_ageLabel.text = @"";
    self.croak_userIdLabel.text = @"";
    self.croak_diamondsLabel.text = @"0";
    self.croak_squareTitleLabel.text = @"My Posts";
    [self croak_setProfileImageWithName:@""];

    [self.croak_tableView registerNib:[UINib nibWithNibName:CroakMineSquareCellNibName bundle:[NSBundle mainBundle]]
                forCellReuseIdentifier:CroakMineSquareCellIdentifier];
    self.croak_tableView.delegate = self;
    self.croak_tableView.dataSource = self;
    self.croak_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self croak_reloadTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self croak_loadMineDataIfNeeded];
}

- (IBAction)croak_editAction:(id)sender {
    Croak_EditPersonVC *editPersonVC = [[Croak_EditPersonVC alloc] init];
    editPersonVC.croak_userInfo = [[Croak_AppDataStore sharedStore] croak_currentUserInfo];
    editPersonVC.croak_returnToPreviousPageAfterSave = YES;
    [self.navigationController pushViewController:editPersonVC animated:YES];
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
    [cell.croak_moreButton setHidden:YES];
    NSDictionary<NSString *, id> *postItem = self.croak_posts[indexPath.row];
    NSDictionary<NSString *, id> *postInfo = [postItem[@"post"] isKindOfClass:NSDictionary.class] ? postItem[@"post"] : @{};
    NSDictionary<NSString *, id> *userInfo = [postItem[@"user"] isKindOfClass:NSDictionary.class] ? postItem[@"user"] : @{};
    NSString *currentUserId = [[Croak_AppDataStore sharedStore] croak_currentUserId];

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
        [self croak_updatePostAtIndex:indexPath.row postInfo:postInfo];
        if (indexPath.row < self.croak_posts.count) {
            [self.croak_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
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
        [self croak_reloadTableView];
    };
    [self.navigationController pushViewController:detailsVC animated:YES];
}

- (void)croak_loadMineDataIfNeeded {
    if ([Croak_AppDataStore sharedStore].croak_isLoaded) {
        [self croak_updateMineData];
        return;
    }
    if (self.croak_isLoadingData) {
        return;
    }

    self.croak_isLoadingData = YES;
    [SVProgressHUD showWithStatus:@"Loading..."];
    [[Croak_AppDataStore sharedStore] croak_fetchAllDataWithCompletion:^(NSError *error) {
        self.croak_isLoadingData = NO;
        [SVProgressHUD dismiss];
        if (error) {
            self.croak_posts = @[];
            [self croak_reloadTableView];
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        [self croak_updateMineData];
    }];
}

- (void)croak_updateMineData {
    NSDictionary<NSString *, id> *userInfo = [[Croak_AppDataStore sharedStore] croak_currentUserInfo];
    if (![userInfo isKindOfClass:NSDictionary.class]) {
        NSString *account = [self croak_trimmedString:Croak_UserSession.croak_currentAccount];
        self.croak_nameLabel.text = account.length > 0 ? account : @"";
        self.croak_ageLabel.text = @"";
        self.croak_userIdLabel.text = @"";
        self.croak_diamondsLabel.text = @"0";
        self.croak_posts = @[];
        [self croak_setProfileImageWithName:@""];
        [self croak_reloadTableView];
        return;
    }

    self.croak_nameLabel.text = [self croak_displayNameFromUserInfo:userInfo];
    self.croak_ageLabel.text = [self croak_ageTextFromUserInfo:userInfo];
    NSString *shortUserId = [self croak_shortIdFromUserInfo:userInfo];
    self.croak_userIdLabel.text = shortUserId.length > 0 ? [NSString stringWithFormat:@"ID:%@", shortUserId] : @"";
    self.croak_diamondsLabel.text = [self croak_diamondsTextFromUserInfo:userInfo];
    [self croak_setProfileImageWithName:[self croak_avatarNameFromUserInfo:userInfo]];
    [self croak_updateMyPostsWithUserInfo:userInfo];
}

- (void)croak_updateMyPostsWithUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *currentUserId = [self croak_userIdFromUserInfo:userInfo];
    NSMutableArray<NSDictionary<NSString *, id> *> *posts = [NSMutableArray array];
    for (NSDictionary<NSString *, id> *postInfo in [self croak_allPosts]) {
        if (![[self croak_userIdFromPostInfo:postInfo] isEqualToString:currentUserId]) {
            continue;
        }
        [posts addObject:@{@"post": postInfo, @"user": userInfo}];
    }

    [posts sortUsingComparator:^NSComparisonResult(NSDictionary<NSString *, id> *firstObject,
                                                   NSDictionary<NSString *, id> *secondObject) {
        NSString *firstDate = [self croak_createdAtFromPostInfo:firstObject[@"post"]];
        NSString *secondDate = [self croak_createdAtFromPostInfo:secondObject[@"post"]];
        return [secondDate compare:firstDate];
    }];

    self.croak_posts = posts;
    [self croak_reloadTableView];
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
            [self croak_openReportDetails];
        } else if (action == CroakReportViewActionBlock) {
            [SVProgressHUD showErrorWithStatus:@"You cannot block yourself."];
        } else if (action == CroakReportViewActionDelete) {
            [self croak_confirmDeletePostItem:postItem indexPath:indexPath];
        }
    };
    [reportView croak_showInView:self.view.window ?: self.view];
}

- (void)croak_openReportDetails {
    Croak_ReportDetailsVC *reportDetailsVC = [[Croak_ReportDetailsVC alloc] init];
    reportDetailsVC.croak_reportTitle = @"Report";
    reportDetailsVC.hidesBottomBarWhenPushed = YES;
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
    [SVProgressHUD showWithStatus:@"Deleting..."];
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

- (void)croak_reloadTableView {
    [self.croak_tableView reloadData];
    [self croak_updateEmptyState];
}

- (void)croak_updateEmptyState {
    if (self.croak_posts.count > 0) {
        self.croak_tableView.backgroundView = nil;
        return;
    }

    self.croak_tableView.backgroundView = [self croak_emptyBackgroundView];
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

- (NSString *)croak_displayNameFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *name = [self croak_trimmedString:userInfo[@"kjvmvsaz"]];
    if (name.length == 0) {
        name = [self croak_trimmedString:userInfo[@"kewgxwk"]];
    }
    return name.length > 0 ? name : @"Unknown";
}

- (NSString *)croak_shortIdFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *userId = [self croak_userIdFromUserInfo:userInfo];
    if (userId.length > 8) {
        return [userId substringToIndex:8];
    }
    return userId;
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

    NSDate *birthday = [self croak_dateFromISOString:[self croak_trimmedString:userInfo[@"fzlucn"]]];
    if (!birthday) {
        return @"";
    }

    NSDateComponents *components = [NSCalendar.currentCalendar components:NSCalendarUnitYear
                                                                 fromDate:birthday
                                                                   toDate:NSDate.date
                                                                  options:0];
    return [NSString stringWithFormat:@"%ld", (long)MAX(0, components.year)];
}

- (NSString *)croak_diamondsTextFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *diamonds = [self croak_trimmedString:userInfo[@"yin"]];
    return diamonds.length > 0 ? diamonds : @"0";
}

- (NSString *)croak_avatarNameFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *avatarName = [self croak_rawImageNameFromValue:userInfo[@"fsuv"]];
    if (avatarName.length == 0) {
        avatarName = [self croak_rawImageNameFromValue:userInfo[@"avatar"]];
    }
    return avatarName;
}

- (void)croak_setProfileImageWithName:(NSString *)imageName {
    UIImage *placeholderImage = [UIImage imageNamed:@"croak_avatar"];
    UIImage *localImage = [self croak_localImageWithName:imageName];
    if (localImage) {
        [self.croak_avatarImageView sd_cancelCurrentImageLoad];
        self.croak_avatarImageView.image = localImage;
        [self.croak_headerImageView sd_cancelCurrentImageLoad];
        self.croak_headerImageView.image = localImage;
        return;
    }

    NSURL *imageURL = [self croak_remoteImageURLWithName:imageName];
    if (imageURL) {
        [self.croak_avatarImageView sd_setImageWithURL:imageURL placeholderImage:placeholderImage];
        [self.croak_headerImageView sd_setImageWithURL:imageURL placeholderImage:placeholderImage];
    } else {
        [self.croak_avatarImageView sd_cancelCurrentImageLoad];
        self.croak_avatarImageView.image = placeholderImage;
        [self.croak_headerImageView sd_cancelCurrentImageLoad];
        self.croak_headerImageView.image = [UIImage imageNamed:@"croak_photo"] ?: placeholderImage;
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

- (NSDate *)croak_dateFromISOString:(NSString *)dateString {
    if (dateString.length == 0) {
        return nil;
    }

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    for (NSString *format in @[@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", @"yyyy-MM-dd'T'HH:mm:ss'Z'", @"yyyy-MM-dd"]) {
        formatter.dateFormat = format;
        NSDate *date = [formatter dateFromString:dateString];
        if (date) {
            return date;
        }
    }
    return nil;
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
