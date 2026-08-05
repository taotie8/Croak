
#import "Croak_SearchUserVC.h"
#import "Croak_AppDataStore.h"
#import "Croak_SearchUserCell.h"
#import "Croak_UserSession.h"
#import "SVProgressHUD.h"

static NSString * const CroakSearchUserCellIdentifier = @"Croak_SearchUserCell";
static NSString * const CroakSearchUserCellNibName = @"Croak_SearchUserCell";
static CGFloat const CroakEmptyStateImageLength = 154.0;

@interface Croak_SearchUserVC () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *croak_titleLabel;
@property (weak, nonatomic) IBOutlet UIView *croak_searchContentView;
@property (weak, nonatomic) IBOutlet UITextField *croak_searchTextField;
@property (weak, nonatomic) IBOutlet UITableView *croak_tableView;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *croak_users;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *croak_filterUsers;
@property (nonatomic, assign) BOOL croak_isLoadingUsers;

@end

@implementation Croak_SearchUserVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    self.croak_titleLabel.text = @"Add Friend";

    self.croak_searchContentView.layer.cornerRadius = 8.0;
    self.croak_searchContentView.layer.masksToBounds = YES;
    self.croak_searchTextField.delegate = self;
    [self.croak_searchTextField addTarget:self
                                   action:@selector(croak_searchTextDidChange:)
                         forControlEvents:UIControlEventEditingChanged];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(croak_dismissKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];

    self.croak_users = @[];
    self.croak_filterUsers = self.croak_users;

    [self.croak_tableView registerNib:[UINib nibWithNibName:CroakSearchUserCellNibName bundle:[NSBundle mainBundle]]
                forCellReuseIdentifier:CroakSearchUserCellIdentifier];
    self.croak_tableView.delegate = self;
    self.croak_tableView.dataSource = self;
    self.croak_tableView.rowHeight = 68.0;
    self.croak_tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.croak_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self croak_reloadTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self croak_loadUsers];
}

- (IBAction)croak_backAction:(id)sender {
    [self.view endEditing:YES];
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)croak_searchAction:(id)sender {
    [self.view endEditing:YES];
    [self croak_filterWithKeyword:self.croak_searchTextField.text];
}

- (void)croak_searchTextDidChange:(UITextField *)textField {
    [self croak_filterWithKeyword:textField.text];
}

- (void)croak_filterWithKeyword:(NSString *)keyword {
    NSString *searchText = [keyword stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (searchText.length == 0) {
        self.croak_filterUsers = @[];
        [self croak_reloadTableView];
        return;
    }

    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary<NSString *, id> *userInfo, NSDictionary *bindings) {
        return [[self croak_displayNameFromUserInfo:userInfo] rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ||
               [[self croak_accountFromUserInfo:userInfo] rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ||
               [[self croak_userIdFromUserInfo:userInfo] rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound;
    }];
    self.croak_filterUsers = [self.croak_users filteredArrayUsingPredicate:predicate];
    [self croak_reloadTableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.croak_filterUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Croak_SearchUserCell *cell = [tableView dequeueReusableCellWithIdentifier:CroakSearchUserCellIdentifier];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:CroakSearchUserCellNibName owner:nil options:nil].firstObject;
    }

    NSDictionary<NSString *, id> *userInfo = self.croak_filterUsers[indexPath.row];
    NSString *account = [self croak_trimmedString:Croak_UserSession.croak_currentAccount];
    BOOL isFriend = [[Croak_AppDataStore sharedStore] croak_userInfo:userInfo isFriendForAccount:account];
    BOOL isRequested = !isFriend && [[Croak_AppDataStore sharedStore] croak_userInfo:userInfo isFollowingForAccount:account];
    BOOL buttonEnabled = !isFriend && !isRequested;
    NSString *buttonText = isFriend ? @"Friends" : (isRequested ? @"Requested" : @"+ Add Friend");

    [cell croak_configureWithName:[self croak_displayNameFromUserInfo:userInfo]
                              age:[self croak_ageTextFromUserInfo:userInfo]
                           userId:[self croak_accountFromUserInfo:userInfo]
                       avatarName:[self croak_avatarNameFromUserInfo:userInfo]
                       buttonText:buttonText
                    buttonEnabled:buttonEnabled];

    __weak typeof(self) weakSelf = self;
    cell.croak_addFriendHandler = buttonEnabled ? ^{
        [weakSelf croak_requestFriendWithUserInfo:userInfo];
    } : nil;
    return cell;
}

- (void)croak_loadUsers {
    if (self.croak_isLoadingUsers) {
        return;
    }

    NSString *account = [self croak_trimmedString:Croak_UserSession.croak_currentAccount];
    self.croak_isLoadingUsers = YES;
    [SVProgressHUD showWithStatus:@"Loading..."];
    [[Croak_AppDataStore sharedStore] croak_fetchSearchUsersForAccount:account
                                                            completion:^(NSArray<NSDictionary<NSString *,id> *> *users, NSError *error) {
        self.croak_isLoadingUsers = NO;
        [SVProgressHUD dismiss];
        if (error) {
            self.croak_users = @[];
            self.croak_filterUsers = @[];
            [self croak_reloadTableView];
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        self.croak_users = users ?: @[];
        [self croak_filterWithKeyword:self.croak_searchTextField.text];
    }];
}

- (void)croak_requestFriendWithUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *account = [self croak_trimmedString:Croak_UserSession.croak_currentAccount];
    [SVProgressHUD showWithStatus:@"Sending..."];
    [[Croak_AppDataStore sharedStore] croak_followUser:userInfo
                                               account:account
                                            completion:^(NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        [self croak_reloadTableView];
        [SVProgressHUD showSuccessWithStatus:@"Request sent."];
    }];
}

- (void)croak_reloadTableView {
    [self.croak_tableView reloadData];
    [self croak_updateEmptyState];
}

- (void)croak_updateEmptyState {
    self.croak_tableView.backgroundView = self.croak_filterUsers.count > 0 ? nil : [self croak_emptyBackgroundView];
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

- (NSString *)croak_accountFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *account = [self croak_trimmedString:userInfo[@"kewgxwk"]];
    if (account.length == 0) {
        account = [self croak_userIdFromUserInfo:userInfo];
    }
    return account;
}

- (NSString *)croak_userIdFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    return [[self croak_trimmedString:userInfo[@"iif"]] lowercaseString];
}

- (NSString *)croak_avatarNameFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *avatarName = [self croak_rawImageNameFromValue:userInfo[@"fsuv"]];
    return avatarName.length > 0 ? avatarName : @"croak_avatar";
}

- (NSString *)croak_ageTextFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSDate *birthday = [self croak_birthDateFromUserInfo:userInfo];
    if (!birthday) {
        return @"";
    }

    NSDateComponents *components = [NSCalendar.currentCalendar components:NSCalendarUnitYear
                                                                 fromDate:birthday
                                                                   toDate:NSDate.date
                                                                  options:0];
    return components.year >= 0 ? [NSString stringWithFormat:@"%ld", (long)components.year] : @"";
}

- (NSDate *)croak_birthDateFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *birthdayText = [self croak_trimmedString:userInfo[@"fzlucn"]];
    if (birthdayText.length == 0) {
        birthdayText = [self croak_trimmedString:userInfo[@"birthday"]];
    }
    if (birthdayText.length == 0) {
        return nil;
    }

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    for (NSString *format in @[@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", @"yyyy-MM-dd'T'HH:mm:ss'Z'", @"yyyy-MM-dd"]) {
        formatter.dateFormat = format;
        NSDate *date = [formatter dateFromString:birthdayText];
        if (date) {
            return date;
        }
    }
    return nil;
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self croak_searchAction:textField];
    return YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.croak_searchTextField]) {
        return NO;
    }
    return YES;
}

- (void)croak_dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


@end
