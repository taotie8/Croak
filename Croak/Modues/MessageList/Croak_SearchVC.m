//
//  Croak_SearchVC.m
//  Croak
//
//  Created by JIAO on 2026/7/29.
//

#import "Croak_SearchVC.h"
#import "Croak_AppDataStore.h"
#import "Croak_SearchViewCell.h"
#import "Croak_MessageChatVC.h"
#import "Croak_UserSession.h"
#import "SVProgressHUD.h"

static NSString * const CroakSearchCellIdentifier = @"Croak_SearchViewCell";

@interface Croak_SearchVC () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *croak_titleLabel;
@property (weak, nonatomic) IBOutlet UIView *croak_searchContentView;
@property (weak, nonatomic) IBOutlet UITextField *croak_searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *croak_searchButton;
@property (weak, nonatomic) IBOutlet UITableView *croak_tableView;
@property (weak, nonatomic) IBOutlet UIImageView *croak_emptyImageView;
@property (weak, nonatomic) IBOutlet UILabel *croak_resultTitleLabel;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *croak_chatSessions;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *croak_filterChatSessions;
@property (nonatomic, assign) BOOL croak_isLoadingChatSessions;

@end

@implementation Croak_SearchVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    self.croak_titleLabel.text = @"Search";
//    self.croak_resultTitleLabel.hidden = YES;
    self.croak_searchContentView.layer.cornerRadius = 8.0;
    self.croak_searchContentView.layer.masksToBounds = YES;
    self.croak_searchTextField.delegate = self;
    [self.croak_searchTextField addTarget:self
                                   action:@selector(croak_searchTextDidChange:)
                         forControlEvents:UIControlEventEditingChanged];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(croak_dismissKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];

    self.croak_chatSessions = @[];
    self.croak_filterChatSessions = @[];

    [self.croak_tableView registerNib:[UINib nibWithNibName:CroakSearchCellIdentifier bundle:nil]
                forCellReuseIdentifier:CroakSearchCellIdentifier];
    self.croak_tableView.delegate = self;
    self.croak_tableView.dataSource = self;
    self.croak_tableView.rowHeight = 68.0;
    self.croak_tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.croak_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self croak_reloadSearchResult];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self croak_loadChatSessions];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.croak_searchTextField becomeFirstResponder];
}

- (IBAction)croak_backAction:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
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
        self.croak_filterChatSessions = @[];
        [self croak_reloadSearchResult];
        return;
    }

    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary<NSString *, id> *chatItem, NSDictionary *bindings) {
        NSDictionary<NSString *, id> *userInfo = [chatItem[@"user"] isKindOfClass:NSDictionary.class] ? chatItem[@"user"] : @{};
        NSString *name = [self croak_displayNameFromUserInfo:userInfo];
        return [name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound;
    }];
    self.croak_filterChatSessions = [self.croak_chatSessions filteredArrayUsingPredicate:predicate];
    [self croak_reloadSearchResult];
}

- (void)croak_reloadSearchResult {
    BOOL hasSearchText = [self.croak_searchTextField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].length > 0;
    BOOL hasResult = self.croak_filterChatSessions.count > 0;
    self.croak_tableView.hidden = !hasResult;
    self.croak_emptyImageView.hidden = !hasSearchText || hasResult;
    [self.croak_tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.croak_filterChatSessions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Croak_SearchViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CroakSearchCellIdentifier
                                                                       forIndexPath:indexPath];
    NSDictionary<NSString *, id> *chatItem = self.croak_filterChatSessions[indexPath.row];
    NSDictionary<NSString *, id> *userInfo = [chatItem[@"user"] isKindOfClass:NSDictionary.class] ? chatItem[@"user"] : @{};
    [cell croak_configureWithName:[self croak_displayNameFromUserInfo:userInfo]
                             time:@""
                          message:[self croak_trimmedString:chatItem[@"lastMessage"]]
                       avatarName:[self croak_avatarNameFromUserInfo:userInfo]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.croak_filterChatSessions.count) {
        return;
    }

    NSDictionary<NSString *, id> *chatItem = self.croak_filterChatSessions[indexPath.row];
    NSDictionary<NSString *, id> *userInfo = [chatItem[@"user"] isKindOfClass:NSDictionary.class] ? chatItem[@"user"] : @{};
    Croak_MessageChatVC *chatVC = [[Croak_MessageChatVC alloc] init];
    chatVC.croak_name = [self croak_displayNameFromUserInfo:userInfo];
    chatVC.croak_avatarName = [self croak_avatarNameFromUserInfo:userInfo];
    chatVC.croak_sessionId = [self croak_sessionIdFromChatItem:chatItem];
    chatVC.croak_currentUserId = [[Croak_AppDataStore sharedStore] croak_currentUserId];
    chatVC.croak_currentAvatarName = [[Croak_AppDataStore sharedStore] croak_currentAvatarName];
    chatVC.croak_chatMessages = [chatItem[@"messages"] isKindOfClass:NSArray.class] ? chatItem[@"messages"] : @[];
    chatVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (void)croak_loadChatSessions {
    if (self.croak_isLoadingChatSessions) {
        return;
    }

    NSString *account = [self croak_trimmedString:Croak_UserSession.croak_currentAccount];
    if (account.length == 0) {
        self.croak_chatSessions = @[];
        [self croak_filterWithKeyword:self.croak_searchTextField.text];
        return;
    }

    if ([Croak_AppDataStore sharedStore].croak_isLoaded) {
        self.croak_chatSessions = [[Croak_AppDataStore sharedStore] croak_chatSessionsForAccount:account] ?: @[];
        [self croak_filterWithKeyword:self.croak_searchTextField.text];
        return;
    }

    self.croak_isLoadingChatSessions = YES;
    [[Croak_AppDataStore sharedStore] croak_fetchChatSessionsForAccount:account
                                                             completion:^(NSArray<NSDictionary<NSString *,id> *> *users, NSError *error) {
        self.croak_isLoadingChatSessions = NO;
        if (error) {
            self.croak_chatSessions = @[];
            [self croak_filterWithKeyword:self.croak_searchTextField.text];
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        self.croak_chatSessions = users ?: @[];
        [self croak_filterWithKeyword:self.croak_searchTextField.text];
    }];
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

- (NSString *)croak_sessionIdFromChatItem:(NSDictionary<NSString *, id> *)chatItem {
    NSDictionary<NSString *, id> *sessionInfo = [chatItem[@"session"] isKindOfClass:NSDictionary.class] ? chatItem[@"session"] : @{};
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
    if ([touch.view isDescendantOfView:self.croak_searchContentView]) {
        return NO;
    }
    return YES;
}

- (void)croak_dismissKeyboard {
    [self.view endEditing:YES];
}

@end
