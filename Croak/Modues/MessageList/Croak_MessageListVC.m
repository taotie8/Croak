
#import "Croak_MessageListVC.h"
#import "Croak_API.h"
#import "Croak_AppDataStore.h"
#import "Croak_MessageListViewCell.h"
#import "Croak_MessageChatVC.h"
#import "Croak_SearchVC.h"
#import "Croak_UserSession.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"

static NSString * const CroakMessageListCellIdentifier = @"Croak_MessageListViewCell";

@interface Croak_MessageListVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *croak_avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *croak_nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *croak_searchButton;
@property (weak, nonatomic) IBOutlet UIButton *croak_turnButton;
@property (weak, nonatomic) IBOutlet UITableView *croak_tableView;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *croak_messages;
@property (nonatomic, assign) BOOL croak_hasLoadedMessages;

@end

@implementation Croak_MessageListVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.croak_avatarImageView.layer.cornerRadius = 20.0;
    self.croak_avatarImageView.layer.masksToBounds = YES;
    [self croak_updateCurrentUserHeader];

    self.croak_messages = @[];

    [self.croak_tableView registerNib:[UINib nibWithNibName:CroakMessageListCellIdentifier bundle:nil]
                forCellReuseIdentifier:CroakMessageListCellIdentifier];
    self.croak_tableView.delegate = self;
    self.croak_tableView.dataSource = self;
    self.croak_tableView.rowHeight = 64.0;
    self.croak_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self croak_loadMessagesIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self croak_updateCurrentUserHeader];
    if (self.croak_hasLoadedMessages) {
        [self croak_reloadMessagesFromCache];
    } else {
        [self croak_loadMessagesIfNeeded];
    }
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
    NSDictionary<NSString *, id> *message = self.croak_messages[indexPath.row];
    NSDictionary<NSString *, id> *userInfo = [message[@"user"] isKindOfClass:NSDictionary.class] ? message[@"user"] : @{};
    [cell croak_configureWithName:[self croak_displayNameFromUserInfo:userInfo]
                             time:[self croak_timeTextFromDateString:[self croak_trimmedString:message[@"lastMessageTime"]]]
                          message:[self croak_trimmedString:message[@"lastMessage"]]
                       avatarName:[self croak_avatarNameFromUserInfo:userInfo]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary<NSString *, id> *message = self.croak_messages[indexPath.row];
    NSDictionary<NSString *, id> *userInfo = [message[@"user"] isKindOfClass:NSDictionary.class] ? message[@"user"] : @{};
    Croak_MessageChatVC *chatVC = [[Croak_MessageChatVC alloc] init];
    chatVC.croak_name = [self croak_displayNameFromUserInfo:userInfo];
    chatVC.croak_avatarName = [self croak_avatarNameFromUserInfo:userInfo];
    chatVC.croak_sessionId = [self croak_sessionIdFromMessageItem:message];
    chatVC.croak_currentUserId = [[Croak_AppDataStore sharedStore] croak_currentUserId];
    chatVC.croak_currentAvatarName = [[Croak_AppDataStore sharedStore] croak_currentAvatarName];
    chatVC.croak_chatMessages = [message[@"messages"] isKindOfClass:NSArray.class] ? message[@"messages"] : @[];
    chatVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (void)croak_reloadMessagesFromCache {
    NSString *account = [self croak_trimmedString:Croak_UserSession.croak_currentAccount];
    if (account.length == 0) {
        self.croak_messages = @[];
    } else {
        self.croak_messages = [[Croak_AppDataStore sharedStore] croak_chatSessionsForAccount:account] ?: @[];
    }
    [self.croak_tableView reloadData];
}

- (void)croak_loadMessagesIfNeeded {
    if (self.croak_hasLoadedMessages) {
        return;
    }

    NSString *account = [self croak_trimmedString:Croak_UserSession.croak_currentAccount];
    if (account.length == 0) {
        self.croak_messages = @[];
        [self.croak_tableView reloadData];
        return;
    }

    self.croak_hasLoadedMessages = YES;
    [SVProgressHUD show];
    [[Croak_AppDataStore sharedStore] croak_fetchChatSessionsForAccount:account
                                                             completion:^(NSArray<NSDictionary<NSString *,id> *> *users, NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            self.croak_hasLoadedMessages = NO;
            self.croak_messages = @[];
            [self.croak_tableView reloadData];
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        self.croak_messages = users ?: @[];
        [self croak_updateCurrentUserHeader];
        [self.croak_tableView reloadData];
    }];
}

- (void)croak_updateCurrentUserHeader {
    NSString *account = [self croak_trimmedString:Croak_UserSession.croak_currentAccount];
    NSDictionary<NSString *, id> *userInfo = [[Croak_AppDataStore sharedStore] croak_currentUserInfo] ?: @{};
    NSString *name = [[Croak_AppDataStore sharedStore] croak_currentDisplayName];
    if (name.length == 0 || [name isEqualToString:@"Unknown"]) {
        name = [self croak_displayNameFromUserInfo:userInfo];
    }
    if (name.length == 0 || [name isEqualToString:@"Unknown"]) {
        name = account.length > 0 ? account : @"Croak";
    }
    self.croak_nameLabel.text = name;
    NSString *avatarName = [[Croak_AppDataStore sharedStore] croak_currentAvatarName];
    if (avatarName.length == 0) {
        avatarName = [self croak_avatarNameFromUserInfo:userInfo];
    }
#if DEBUG
    NSLog(@"\n[Croak Home Header]\naccount: %@\nname: %@\navatarRaw: <%@>",
          account.length > 0 ? account : @"<empty>",
          name.length > 0 ? name : @"<empty>",
          avatarName.length > 0 ? avatarName : @"<empty>");
#endif
    [self croak_setCurrentAvatarWithName:avatarName];
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

- (NSString *)croak_avatarNameFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *avatarName = [self croak_rawImageNameFromValue:userInfo[@"fsuv"]];
    if (avatarName.length == 0) {
        avatarName = [self croak_rawImageNameFromValue:userInfo[@"avatar"]];
    }
    return avatarName.length > 0 ? avatarName : @"croak_avatar";
}

- (NSString *)croak_sessionIdFromMessageItem:(NSDictionary<NSString *, id> *)messageItem {
    NSDictionary<NSString *, id> *sessionInfo = [messageItem[@"session"] isKindOfClass:NSDictionary.class] ? messageItem[@"session"] : @{};
    NSString *sessionId = [self croak_trimmedString:sessionInfo[@"cwkxbxdk"]];
    if (sessionId.length == 0) {
        sessionId = [self croak_trimmedString:sessionInfo[@"id"]];
    }
    return sessionId;
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

- (void)croak_setCurrentAvatarWithName:(NSString *)avatarName {
    UIImage *placeholderImage = [UIImage imageNamed:@"croak_avatar"];
    UIImage *localImage = [self croak_localImageWithName:avatarName];
    if (localImage) {
        [self.croak_avatarImageView sd_cancelCurrentImageLoad];
        self.croak_avatarImageView.image = localImage;
        return;
    }

    NSURL *avatarURL = [self croak_remoteAvatarURLWithName:avatarName];
#if DEBUG
    NSLog(@"\n[Croak Home Header Avatar]\nrawAvatar: <%@>\nurl: %@",
          avatarName.length > 0 ? avatarName : @"<empty>",
          avatarURL.absoluteString ?: @"<nil>");
#endif
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

- (NSString *)croak_timeTextFromDateString:(NSString *)dateString {
    NSDate *date = [self croak_dateFromISOString:dateString];
    if (!date) {
        return @"";
    }

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    if ([NSCalendar.currentCalendar isDateInToday:date]) {
        formatter.dateFormat = @"HH:mm";
    } else {
        formatter.dateFormat = @"MMM d";
    }
    return [formatter stringFromDate:date];
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
