
#import "Croak_SquareDetailsVC.h"
#import "Croak_AppDataStore.h"
#import "Croak_SquareDetailsCell.h"
#import "Croak_SquareCommentCell.h"
#import "Croak_FriendsCenterVC.h"
#import "Croak_UserSession.h"
#import "Croak_ViewController.h"
#import "Croak_ReportDetailsVC.h"
#import "Croak_ReportView.h"
#import "SVProgressHUD.h"

static NSString * const CroakSquareDetailsCellIdentifier = @"Croak_SquareDetailsCell";
static NSString * const CroakSquareCommentCellIdentifier = @"Croak_SquareCommentCell";

@interface Croak_SquareDetailsVC () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *croak_tableView;
@property (weak, nonatomic) IBOutlet UIView *croak_inputBarView;
@property (weak, nonatomic) IBOutlet UIView *croak_inputContentView;
@property (weak, nonatomic) IBOutlet UITextField *croak_commentTextField;
@property (nonatomic, assign) UIEdgeInsets croak_originalTableContentInset;
@property (nonatomic, assign) UIEdgeInsets croak_originalTableScrollIndicatorInsets;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *croak_comments;
@property (nonatomic, assign) BOOL croak_isSubmittingComment;

@end

@implementation Croak_SquareDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.croak_comments = @[];
    [self.croak_tableView registerNib:[UINib nibWithNibName:CroakSquareDetailsCellIdentifier bundle:nil]
                forCellReuseIdentifier:CroakSquareDetailsCellIdentifier];
    [self.croak_tableView registerNib:[UINib nibWithNibName:CroakSquareCommentCellIdentifier bundle:nil]
                forCellReuseIdentifier:CroakSquareCommentCellIdentifier];
    self.croak_tableView.delegate = self;
    self.croak_tableView.dataSource = self;
    self.croak_tableView.estimatedRowHeight = 594.0;
    self.croak_tableView.rowHeight = UITableViewAutomaticDimension;
    self.croak_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.croak_tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.croak_originalTableContentInset = self.croak_tableView.contentInset;
    self.croak_originalTableScrollIndicatorInsets = self.croak_tableView.scrollIndicatorInsets;

    self.croak_inputContentView.layer.masksToBounds = YES;
    self.croak_commentTextField.delegate = self;
    self.croak_commentTextField.returnKeyType = UIReturnKeySend;

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(croak_dismissKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(croak_keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(croak_keyboardWillHide:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
    [self croak_reloadComments];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (IBAction)croak_backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)croak_moreAction:(id)sender {
    [self croak_showMoreOptions];
}

- (IBAction)croak_sendAction:(id)sender {
    [self croak_submitCommentAndDismissKeyboard];
}

- (void)croak_keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect convertedKeyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
    CGFloat overlapHeight = MAX(0.0, CGRectGetMaxY(self.view.bounds) - CGRectGetMinY(convertedKeyboardFrame));
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = (UIViewAnimationOptions)([userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16);

    UIEdgeInsets contentInset = self.croak_originalTableContentInset;
    contentInset.bottom += overlapHeight;
    UIEdgeInsets indicatorInsets = self.croak_originalTableScrollIndicatorInsets;
    indicatorInsets.bottom += overlapHeight;

    [UIView animateWithDuration:duration
                          delay:0
                        options:options
                     animations:^{
        self.croak_inputBarView.transform = CGAffineTransformMakeTranslation(0, -overlapHeight);
        self.croak_tableView.contentInset = contentInset;
        self.croak_tableView.scrollIndicatorInsets = indicatorInsets;
    } completion:nil];
}

- (void)croak_keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = (UIViewAnimationOptions)([userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16);

    [UIView animateWithDuration:duration
                          delay:0
                        options:options
                     animations:^{
        self.croak_inputBarView.transform = CGAffineTransformIdentity;
        self.croak_tableView.contentInset = self.croak_originalTableContentInset;
        self.croak_tableView.scrollIndicatorInsets = self.croak_originalTableScrollIndicatorInsets;
    } completion:nil];
}

- (void)croak_dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)croak_submitCommentAndDismissKeyboard {
    NSString *comment = [self.croak_commentTextField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (comment.length == 0 || self.croak_isSubmittingComment) {
        return;
    }

    NSString *account = [self croak_currentAccountForAction];
    if (account.length == 0) {
        return;
    }

    self.croak_isSubmittingComment = YES;
    [SVProgressHUD show];
    [[Croak_AppDataStore sharedStore] croak_saveComment:comment
                                                forPost:[self croak_postInfo]
                                                account:account
                                             completion:^(NSDictionary<NSString *,id> *commentInfo,
                                                          NSDictionary<NSString *,id> *postInfo,
                                                          NSError *error) {
        self.croak_isSubmittingComment = NO;
        [SVProgressHUD dismiss];
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        self.croak_commentTextField.text = @"";
        [self croak_dismissKeyboard];
        if (postInfo) {
            [self croak_updatePostInfo:postInfo];
            if (self.croak_postUpdateHandler) {
                self.croak_postUpdateHandler(postInfo);
            }
        }
        [self croak_reloadCommentsAndScrollToLatest:YES];
        [SVProgressHUD showSuccessWithStatus:@"Comment posted."];
    }];
    [self croak_dismissKeyboard];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self croak_submitCommentAndDismissKeyboard];
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.croak_inputBarView]) {
        return NO;
    }
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return self.croak_comments.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 ? 594.0 : 84.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        Croak_SquareDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:CroakSquareDetailsCellIdentifier
                                                                         forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        NSDictionary<NSString *, id> *postInfo = [self croak_postInfo];
        NSDictionary<NSString *, id> *userInfo = [self croak_userInfo];
        [cell croak_configureWithName:[self croak_displayNameFromUserInfo:userInfo]
                               content:[self croak_contentFromPostInfo:postInfo]
                             imageName:[self croak_imageNameFromPostInfo:postInfo]
                            avatarName:[self croak_avatarNameFromUserInfo:userInfo]
                             likeNames:[self croak_likedUserNamesFromPostInfo:postInfo]
                                  liked:[self croak_postInfo:postInfo likedByUserId:[self croak_currentUserId]]];
        __weak typeof(self) weakSelf = self;
        cell.croak_loveActionHandler = ^(Croak_SquareDetailsCell *selectedCell) {
            [weakSelf croak_toggleLikeForCell:selectedCell];
        };
        cell.croak_avatarActionHandler = ^(Croak_SquareDetailsCell *selectedCell) {
            [weakSelf croak_showFriendsCenter];
        };
        return cell;
    }
    else {
        Croak_SquareCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CroakSquareCommentCellIdentifier
                                                                         forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        NSDictionary<NSString *, id> *commentInfo = self.croak_comments[indexPath.row];
        [cell croak_configureWithName:[self croak_commentAuthorNameFromCommentInfo:commentInfo]
                               content:[self croak_commentContentFromCommentInfo:commentInfo]
                                  time:[self croak_timeTextFromDateString:[self croak_commentCreatedAtFromCommentInfo:commentInfo]]
                            avatarName:[self croak_commentAvatarNameFromCommentInfo:commentInfo]];
        return cell;
    }
    
}

- (void)croak_reloadComments {
    [self croak_reloadCommentsAndScrollToLatest:NO];
}

- (void)croak_reloadCommentsAndScrollToLatest:(BOOL)scrollToLatest {
    self.croak_comments = [[Croak_AppDataStore sharedStore] croak_commentsForPost:[self croak_postInfo]] ?: @[];
    [self.croak_tableView reloadData];
    if (!scrollToLatest || self.croak_comments.count == 0) {
        return;
    }

    NSIndexPath *lastCommentIndexPath = [NSIndexPath indexPathForRow:(NSInteger)self.croak_comments.count - 1
                                                            inSection:1];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.croak_tableView numberOfSections] <= lastCommentIndexPath.section ||
            [self.croak_tableView numberOfRowsInSection:lastCommentIndexPath.section] <= lastCommentIndexPath.row) {
            return;
        }

        [self.croak_tableView scrollToRowAtIndexPath:lastCommentIndexPath
                                    atScrollPosition:UITableViewScrollPositionBottom
                                            animated:YES];
    });
}

- (void)croak_showFriendsCenter {
    Croak_FriendsCenterVC *friendsCenterVC = [[Croak_FriendsCenterVC alloc] init];
    friendsCenterVC.croak_userInfo = [self croak_userInfo];
    friendsCenterVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:friendsCenterVC animated:YES];
}

- (void)croak_showMoreOptions {
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
            [self croak_blockCurrentPostUser];
        } else if (action == CroakReportViewActionDelete) {
            [self croak_confirmDeletePost];
        }
    };

    UIView *targetView = self.view.window ?: self.view;
    [reportView croak_showInView:targetView];
}

- (void)croak_openReportDetails {
    Croak_ReportDetailsVC *reportDetailsVC = [[Croak_ReportDetailsVC alloc] init];
    reportDetailsVC.croak_reportTitle = @"Report";
    [self.navigationController pushViewController:reportDetailsVC animated:YES];
}

- (void)croak_blockCurrentPostUser {
    NSString *account = [self croak_currentAccountForAction];
    if (account.length == 0) {
        return;
    }

    NSDictionary<NSString *, id> *userInfo = [self croak_userInfo];
    NSString *blockedUserId = [self croak_userIdFromUserInfo:userInfo];
    [[Croak_AppDataStore sharedStore] croak_blockUser:userInfo
                                              account:account
                                           completion:^(NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        [SVProgressHUD showSuccessWithStatus:@"Blocked."];
        if (self.croak_userBlockHandler) {
            self.croak_userBlockHandler(blockedUserId);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)croak_confirmDeletePost {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete post?"
                                                                   message:@"This action cannot be undone."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [weakSelf croak_deletePost];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)croak_deletePost {
    NSString *account = [self croak_currentAccountForAction];
    if (account.length == 0) {
        return;
    }

    [SVProgressHUD show];
    [[Croak_AppDataStore sharedStore] croak_deletePost:[self croak_postInfo]
                                               account:account
                                            completion:^(NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        [SVProgressHUD showSuccessWithStatus:@"Deleted."];
        if (self.croak_postDeleteHandler) {
            self.croak_postDeleteHandler();
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)croak_toggleLikeForCell:(Croak_SquareDetailsCell *)cell {
    NSString *account = [self croak_currentAccountForAction];
    if (account.length == 0) {
        return;
    }

    NSDictionary<NSString *, id> *postInfo = [self croak_postInfo];
    cell.croak_loveButton.enabled = NO;
    [[Croak_AppDataStore sharedStore] croak_toggleLikeForPost:postInfo
                                                      account:account
                                                   completion:^(NSDictionary<NSString *,id> *updatedPostInfo, BOOL liked, NSError *error) {
        cell.croak_loveButton.enabled = YES;
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        NSDictionary<NSString *, id> *displayPostInfo = updatedPostInfo ?: postInfo;
        [self croak_updatePostInfo:displayPostInfo];
        NSString *likeNames = [self croak_likedUserNamesFromPostInfo:displayPostInfo];
        if (liked && likeNames.length == 0) {
            likeNames = [[Croak_AppDataStore sharedStore] croak_displayNameForAccount:account];
        }
        cell.croak_loveButton.selected = liked;
        cell.croak_likeNamesLabel.text = likeNames;
#if DEBUG
        NSLog(@"\n[Croak Detail Like UI]\naccount: %@\nliked: %@\nlabel: %@",
              account,
              liked ? @"YES" : @"NO",
              likeNames);
#endif
        if (self.croak_postUpdateHandler) {
            self.croak_postUpdateHandler(displayPostInfo);
        }
    }];
}

- (NSString *)croak_currentAccountForAction {
    NSString *account = [self croak_trimmedString:Croak_UserSession.croak_currentAccount];
    if (account.length > 0) {
        return account;
    }

#if DEBUG
    NSLog(@"\n[Croak Session]\ncurrentAccount is empty when tapping detail like.");
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

- (NSDictionary<NSString *, id> *)croak_postInfo {
    NSDictionary<NSString *, id> *postInfo = self.croak_postItem[@"post"];
    return [postInfo isKindOfClass:NSDictionary.class] ? postInfo : @{};
}

- (NSDictionary<NSString *, id> *)croak_userInfo {
    NSDictionary<NSString *, id> *userInfo = self.croak_postItem[@"user"];
    return [userInfo isKindOfClass:NSDictionary.class] ? userInfo : @{};
}

- (NSString *)croak_userIdFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *userId = [self croak_normalizedString:userInfo[@"iif"]];
    if (userId.length == 0) {
        userId = [self croak_normalizedString:userInfo[@"id"]];
    }
    return userId;
}

- (void)croak_updatePostInfo:(NSDictionary<NSString *, id> *)postInfo {
    NSMutableDictionary<NSString *, id> *postItem = [self.croak_postItem isKindOfClass:NSDictionary.class] ? [self.croak_postItem mutableCopy] : [NSMutableDictionary dictionary];
    postItem[@"post"] = postInfo ?: @{};
    self.croak_postItem = postItem;
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

- (NSDictionary<NSString *, id> *)croak_userInfoForUserId:(NSString *)userId {
    NSString *targetUserId = [self croak_normalizedString:userId];
    if (targetUserId.length == 0) {
        return @{};
    }

    NSArray *users = [Croak_AppDataStore sharedStore].croak_dataLayer[@"hok"];
    if (![users isKindOfClass:NSArray.class]) {
        return @{};
    }

    for (NSDictionary<NSString *, id> *userInfo in users) {
        if (![userInfo isKindOfClass:NSDictionary.class]) {
            continue;
        }

        NSString *candidateUserId = [self croak_normalizedString:userInfo[@"iif"]];
        if (candidateUserId.length == 0) {
            candidateUserId = [self croak_normalizedString:userInfo[@"id"]];
        }
        if ([candidateUserId isEqualToString:targetUserId]) {
            return userInfo;
        }
    }
    return @{};
}

- (NSDictionary<NSString *, id> *)croak_userInfoForCommentInfo:(NSDictionary<NSString *, id> *)commentInfo {
    id embeddedUserInfo = commentInfo[@"user"];
    if ([embeddedUserInfo isKindOfClass:NSDictionary.class]) {
        return embeddedUserInfo;
    }

    NSString *commentUserId = [self croak_commentUserIdFromCommentInfo:commentInfo];
    NSDictionary<NSString *, id> *matchedUserInfo = [self croak_userInfoForUserId:commentUserId];
    if (matchedUserInfo.count > 0) {
        return matchedUserInfo;
    }

    if (commentUserId.length > 0 && [commentUserId isEqualToString:[self croak_currentUserId]]) {
        NSDictionary<NSString *, id> *currentUserInfo = [[Croak_AppDataStore sharedStore] croak_currentUserInfo];
        if ([currentUserInfo isKindOfClass:NSDictionary.class]) {
            return currentUserInfo;
        }
    }
    return @{};
}

- (NSString *)croak_commentAuthorNameFromCommentInfo:(NSDictionary<NSString *, id> *)commentInfo {
    NSDictionary<NSString *, id> *userInfo = [self croak_userInfoForCommentInfo:commentInfo];
    NSString *name = [self croak_trimmedString:userInfo[@"kjvmvsaz"]];
    if (name.length == 0) {
        name = [self croak_trimmedString:userInfo[@"nickname"]];
    }
    if (name.length == 0) {
        name = [self croak_trimmedString:userInfo[@"kewgxwk"]];
    }
    if (name.length == 0) {
        name = [self croak_trimmedString:commentInfo[@"authorName"]];
    }
    if (name.length == 0) {
        name = [self croak_trimmedString:commentInfo[@"nickname"]];
    }
    return name.length > 0 ? name : @"Unknown";
}

- (NSString *)croak_commentAvatarNameFromCommentInfo:(NSDictionary<NSString *, id> *)commentInfo {
    NSDictionary<NSString *, id> *userInfo = [self croak_userInfoForCommentInfo:commentInfo];
    NSString *avatarName = [self croak_avatarNameFromUserInfo:userInfo];
    if (avatarName.length == 0) {
        avatarName = [self croak_rawImageNameFromValue:commentInfo[@"authorAvatar"]];
    }
    if (avatarName.length == 0) {
        avatarName = [self croak_rawImageNameFromValue:commentInfo[@"avatar"]];
    }
    return avatarName;
}

- (NSString *)croak_commentUserIdFromCommentInfo:(NSDictionary<NSString *, id> *)commentInfo {
    NSString *userId = [self croak_normalizedString:commentInfo[@"twcxf"]];
    if (userId.length == 0) {
        userId = [self croak_normalizedString:commentInfo[@"userId"]];
    }
    if (userId.length == 0) {
        userId = [self croak_normalizedString:commentInfo[@"fegg"]];
    }
    return userId;
}

- (NSString *)croak_commentContentFromCommentInfo:(NSDictionary<NSString *, id> *)commentInfo {
    NSString *content = [self croak_trimmedString:commentInfo[@"ycluiw"]];
    if (content.length == 0) {
        content = [self croak_trimmedString:commentInfo[@"content"]];
    }
    if (content.length == 0) {
        content = [self croak_trimmedString:commentInfo[@"hctnqmww"]];
    }
    return content;
}

- (NSString *)croak_commentCreatedAtFromCommentInfo:(NSDictionary<NSString *, id> *)commentInfo {
    NSString *createdAt = [self croak_trimmedString:commentInfo[@"ua"]];
    if (createdAt.length == 0) {
        createdAt = [self croak_trimmedString:commentInfo[@"createdAt"]];
    }
    if (createdAt.length == 0) {
        createdAt = [self croak_trimmedString:commentInfo[@"jumog"]];
    }
    return createdAt;
}

- (NSString *)croak_timeTextFromDateString:(NSString *)dateString {
    NSDate *date = [self croak_dateFromISOString:dateString];
    if (!date) {
        return @"";
    }

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"MMM d";
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

- (NSString *)croak_shortUserId:(NSString *)userId {
    if (userId.length <= 8) {
        return userId;
    }
    return [userId substringToIndex:8];
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
