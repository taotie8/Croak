
#import "Croak_FriendsListVC.h"
#import "Croak_API.h"
#import "Croak_AppDataStore.h"
#import "Croak_FriendsListCell.h"
#import "Croak_SearchUserVC.h"
#import "Croak_RequestFriendsVC.h"
#import "Croak_FriendsCenterVC.h"
#import "Croak_UserSession.h"
#import "SVProgressHUD.h"
#import <UserNotifications/UserNotifications.h>
#import "UIImageView+WebCache.h"

static NSString * const CroakFriendsListCellIdentifier = @"Croak_FriendsListCell";
static NSString * const CroakFriendsListCellNibName = @"Croak_FriendsListCell";
static CGFloat const CroakEmptyStateImageLength = 154.0;

@interface Croak_FriendsListVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *croak_headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *croak_avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *croak_nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_welcomeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *croak_bannerImageView;
@property (weak, nonatomic) IBOutlet UILabel *croak_titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *croak_tableView;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *croak_friends;

@end

@implementation Croak_FriendsListVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.croak_welcomeLabel.text = @"Welcome to Croak";
    self.croak_titleLabel.text = @"Friend List";
    self.croak_friends = @[];
    [self croak_updateHeader];

    self.croak_avatarImageView.layer.cornerRadius = 20.0;
    self.croak_avatarImageView.layer.masksToBounds = YES;
    self.croak_bannerImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *turnTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(croak_turnAction:)];
    [self.croak_bannerImageView addGestureRecognizer:turnTapGesture];

    [self.croak_tableView registerNib:[UINib nibWithNibName:CroakFriendsListCellNibName bundle:[NSBundle mainBundle]]
                forCellReuseIdentifier:CroakFriendsListCellIdentifier];
    self.croak_tableView.delegate = self;
    self.croak_tableView.dataSource = self;
    self.croak_tableView.rowHeight = 64;
    self.croak_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self croak_updateEmptyState];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self croak_updateHeader];
    [self croak_loadFriends];
}

- (IBAction)croak_requestAction:(id)sender {
    Croak_RequestFriendsVC *requestFriendsVC = [[Croak_RequestFriendsVC alloc] init];
    requestFriendsVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:requestFriendsVC animated:YES];
}

- (IBAction)croak_searchAction:(id)sender {
    [self.navigationController pushViewController:[Croak_SearchUserVC new] animated:YES];
}

- (void)croak_turnAction:(id)sender {
    [self croak_prepareAndOpenNotificationSettings];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.croak_friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Croak_FriendsListCell *cell = [tableView dequeueReusableCellWithIdentifier:CroakFriendsListCellIdentifier];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:CroakFriendsListCellNibName owner:nil options:nil].firstObject;
    }
    NSDictionary<NSString *, id> *friendInfo = self.croak_friends[indexPath.row];
    [cell croak_configureWithName:[self croak_displayNameFromUserInfo:friendInfo]
                       avatarName:[self croak_avatarNameFromUserInfo:friendInfo]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.croak_friends.count) {
        return;
    }

    Croak_FriendsCenterVC *friendsCenterVC = [[Croak_FriendsCenterVC alloc] init];
    friendsCenterVC.croak_userInfo = self.croak_friends[indexPath.row];
    friendsCenterVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:friendsCenterVC animated:YES];
}

- (void)croak_updateHeader {
    NSString *account = [self croak_trimmedString:Croak_UserSession.croak_currentAccount];
    NSDictionary<NSString *, id> *userInfo = [[Croak_AppDataStore sharedStore] croak_currentUserInfo] ?: @{};
    NSString *name = [[Croak_AppDataStore sharedStore] croak_currentDisplayName];
    if (name.length == 0 || [name isEqualToString:@"Unknown"]) {
        name = [self croak_displayNameFromUserInfo:userInfo];
    }
    if (name.length == 0 || [name isEqualToString:@"Unknown"]) {
        name = account;
    }

    self.croak_nameLabel.text = name.length > 0 ? [NSString stringWithFormat:@"HI~ %@", name] : @"HI~";
    NSString *avatarName = [[Croak_AppDataStore sharedStore] croak_currentAvatarName];
    if (avatarName.length == 0) {
        avatarName = [self croak_avatarNameFromUserInfo:userInfo];
    }
    [self croak_setHeaderAvatarWithName:avatarName];
}

- (void)croak_loadFriends {
    NSString *account = [self croak_trimmedString:Croak_UserSession.croak_currentAccount];
#if DEBUG
    NSLog(@"\n[Croak Friends Page]\ncurrentAccount: %@", account.length > 0 ? account : @"<empty>");
#endif
    if (account.length == 0) {
        self.croak_friends = @[];
        [self croak_reloadTableView];
        return;
    }

    [[Croak_AppDataStore sharedStore] croak_fetchFriendsForAccount:account
                                                        completion:^(NSArray<NSDictionary<NSString *,id> *> *users, NSError *error) {
        if (error) {
            self.croak_friends = @[];
            [self croak_reloadTableView];
#if DEBUG
            NSLog(@"\n[Croak Friends Page]\nloadError: %@", error.localizedDescription);
#endif
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        self.croak_friends = users ?: @[];
        [self croak_updateHeader];
#if DEBUG
        NSLog(@"\n[Croak Friends Page]\nresultCount: %lu\nresult: %@",
              (unsigned long)self.croak_friends.count,
              self.croak_friends);
#endif
        [self croak_reloadTableView];
    }];
}

- (void)croak_reloadTableView {
    [self.croak_tableView reloadData];
    [self croak_updateEmptyState];
}

- (void)croak_prepareAndOpenNotificationSettings {
    UNUserNotificationCenter *notificationCenter = UNUserNotificationCenter.currentNotificationCenter;
    [notificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
        if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
            UNAuthorizationOptions options = UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound;
            [notificationCenter requestAuthorizationWithOptions:options
                                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!error && granted) {
                        [UIApplication.sharedApplication registerForRemoteNotifications];
                    }
                    [self croak_openNotificationSettingsURL];
                });
            }];
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self croak_openNotificationSettingsURL];
        });
    }];
}

- (void)croak_openNotificationSettingsURL {
    NSURL *notificationSettingsURL = [NSURL URLWithString:UIApplicationOpenNotificationSettingsURLString];
    if (!notificationSettingsURL) {
        [SVProgressHUD showErrorWithStatus:@"Notification settings cannot be opened."];
        return;
    }

    [UIApplication.sharedApplication openURL:notificationSettingsURL
                                     options:@{}
                           completionHandler:^(BOOL success) {
        if (!success) {
            [SVProgressHUD showErrorWithStatus:@"Notification settings cannot be opened."];
        }
    }];
}

- (void)croak_updateEmptyState {
    self.croak_tableView.backgroundView = self.croak_friends.count > 0 ? nil : [self croak_emptyBackgroundView];
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
    if (name.length > 0) {
        return name;
    }

    name = [self croak_trimmedString:userInfo[@"nickname"]];
    if (name.length > 0) {
        return name;
    }

    name = [self croak_trimmedString:userInfo[@"name"]];
    if (name.length > 0) {
        return name;
    }

    NSString *account = [self croak_trimmedString:userInfo[@"kewgxwk"]];
    return account.length > 0 ? account : @"Unknown";
}

- (NSString *)croak_avatarNameFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *avatarName = [self croak_rawImageNameFromValue:userInfo[@"fsuv"]];
    if (avatarName.length == 0) {
        avatarName = [self croak_rawImageNameFromValue:userInfo[@"avatar"]];
    }
    return avatarName.length > 0 ? avatarName : @"croak_avatar";
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

- (void)croak_setHeaderAvatarWithName:(NSString *)avatarName {
    UIImage *placeholderImage = [UIImage imageNamed:@"croak_avatar"];
    UIImage *localImage = [self croak_localImageWithName:avatarName];
    if (localImage) {
        [self.croak_avatarImageView sd_cancelCurrentImageLoad];
        self.croak_avatarImageView.image = localImage;
        return;
    }

    NSURL *avatarURL = [self croak_remoteAvatarURLWithName:avatarName];
    if (avatarURL) {
        [self.croak_avatarImageView sd_setImageWithURL:avatarURL placeholderImage:placeholderImage];
    } else {
        [self.croak_avatarImageView sd_cancelCurrentImageLoad];
        self.croak_avatarImageView.image = placeholderImage;
    }
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

- (NSURL *)croak_remoteAvatarURLWithName:(NSString *)imageName {
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
