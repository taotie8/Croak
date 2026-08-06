
#import "Croak_SettingVC.h"
#import "Croak_BlackListVC.h"
#import "Croak_AgreementLinks.h"
#import "Croak_AppDataStore.h"
#import "Croak_UserSession.h"
#import "Croak_ViewController.h"
#import "SVProgressHUD.h"

@interface Croak_SettingVC ()

@property (weak, nonatomic) IBOutlet UILabel *croak_titleLabel;
@property (strong, nonatomic) IBOutlet UIView *croak_deleteView;
@property (weak, nonatomic) IBOutlet UIView *croak_deleteContentView;
@property (strong, nonatomic) UIView *croak_logoutView;
@property (strong, nonatomic) UIView *croak_logoutContentView;
@property (strong, nonatomic) NSLayoutConstraint *croak_logoutContentWidthConstraint;

@end

@implementation Croak_SettingVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.969 alpha:1.0];
    self.croak_titleLabel.text = @"Setting";
}

- (IBAction)croak_backAction:(id)sender {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)croak_blacklistAction:(id)sender {
    [self.navigationController pushViewController:[Croak_BlackListVC new] animated:YES];
}

- (IBAction)croak_privacyPolicyAction:(id)sender {
    [Croak_AgreementLinks croak_openPrivacyPolicyFromViewController:self];
}

- (IBAction)croak_userAgreementAction:(id)sender {
    [Croak_AgreementLinks croak_openUserAgreementFromViewController:self];
}

- (IBAction)croak_logoutAction:(id)sender {
    [self croak_showLogoutView];
}

- (IBAction)croak_deleteAccountAction:(id)sender {
    [self croak_showDeleteView];
}

- (void)croak_setupLogoutViewIfNeeded {
    if (self.croak_logoutView) {
        return;
    }

    UIView *logoutView = [[UIView alloc] initWithFrame:CGRectZero];
    logoutView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    logoutView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 26.0;
    contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    contentView.layer.shadowOpacity = 0.12;
    contentView.layer.shadowOffset = CGSizeMake(0, 10);
    contentView.layer.shadowRadius = 24.0;
    [logoutView addSubview:contentView];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = @"Log out";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor colorWithRed:0.082 green:0.090 blue:0.153 alpha:1.0];
    [contentView addSubview:titleLabel];

    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    messageLabel.text = @"Are you sure you want to log out?";
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.numberOfLines = 0;
    messageLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    messageLabel.textColor = [UIColor colorWithRed:0.600 green:0.600 blue:0.600 alpha:1.0];
    [contentView addSubview:messageLabel];

    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    cancelButton.backgroundColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.969 alpha:1.0];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    cancelButton.layer.cornerRadius = 22.0;
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor colorWithRed:0.082 green:0.090 blue:0.153 alpha:1.0] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(croak_cancelLogoutViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:cancelButton];

    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.translatesAutoresizingMaskIntoConstraints = NO;
    confirmButton.backgroundColor = [UIColor blackColor];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    confirmButton.layer.cornerRadius = 22.0;
    [confirmButton setTitle:@"Log out" forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor colorWithRed:0.910 green:0.525 blue:0.239 alpha:1.0] forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(croak_confirmLogoutViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:confirmButton];

    self.croak_logoutContentWidthConstraint = [contentView.widthAnchor constraintEqualToConstant:313.0];
    [NSLayoutConstraint activateConstraints:@[
        [contentView.centerXAnchor constraintEqualToAnchor:logoutView.centerXAnchor],
        [contentView.centerYAnchor constraintEqualToAnchor:logoutView.centerYAnchor],
        self.croak_logoutContentWidthConstraint,

        [titleLabel.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:30.0],
        [titleLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:24.0],
        [titleLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-24.0],

        [messageLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:14.0],
        [messageLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:32.0],
        [messageLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-32.0],

        [cancelButton.topAnchor constraintEqualToAnchor:messageLabel.bottomAnchor constant:28.0],
        [cancelButton.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:24.0],
        [cancelButton.heightAnchor constraintEqualToConstant:44.0],

        [confirmButton.topAnchor constraintEqualToAnchor:cancelButton.topAnchor],
        [confirmButton.leadingAnchor constraintEqualToAnchor:cancelButton.trailingAnchor constant:12.0],
        [confirmButton.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-24.0],
        [confirmButton.widthAnchor constraintEqualToAnchor:cancelButton.widthAnchor],
        [confirmButton.heightAnchor constraintEqualToAnchor:cancelButton.heightAnchor],

        [contentView.bottomAnchor constraintEqualToAnchor:cancelButton.bottomAnchor constant:24.0],
    ]];

    self.croak_logoutView = logoutView;
    self.croak_logoutContentView = contentView;
}

- (void)croak_showLogoutView {
    [self croak_setupLogoutViewIfNeeded];

    self.croak_logoutView.frame = self.view.bounds;
    self.croak_logoutContentWidthConstraint.constant = MIN(CGRectGetWidth(self.view.bounds) - 48.0, 313.0);

    if (!self.croak_logoutView.superview) {
        [self.view addSubview:self.croak_logoutView];
    }

    self.croak_logoutView.hidden = NO;
    self.croak_logoutView.alpha = 0.0;
    self.croak_logoutContentView.transform = CGAffineTransformMakeScale(0.82, 0.82);
    [self.croak_logoutView layoutIfNeeded];

    [UIView animateWithDuration:0.28
                          delay:0
         usingSpringWithDamping:0.78
          initialSpringVelocity:0.8
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.croak_logoutView.alpha = 1.0;
        self.croak_logoutContentView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (IBAction)croak_cancelLogoutViewAction:(id)sender {
    [self croak_hideLogoutView];
}

- (IBAction)croak_confirmLogoutViewAction:(id)sender {
    [self croak_hideLogoutView];
    [Croak_UserSession croak_clearSession];
    [self croak_showLoginInterface];
}

- (void)croak_hideLogoutView {
    [UIView animateWithDuration:0.18
                     animations:^{
        self.croak_logoutView.alpha = 0.0;
        self.croak_logoutContentView.transform = CGAffineTransformMakeScale(0.92, 0.92);
    } completion:^(BOOL finished) {
        self.croak_logoutContentView.transform = CGAffineTransformIdentity;
        [self.croak_logoutView removeFromSuperview];
    }];
}

- (IBAction)croak_cancelDeleteViewAction:(id)sender {
    [self croak_hideDeleteView];
}

- (IBAction)croak_confirmDeleteViewAction:(id)sender {
    [self croak_hideDeleteView];

    NSString *account = [self croak_trimmedString:Croak_UserSession.croak_currentAccount];
    if (account.length == 0) {
        [Croak_UserSession croak_clearSession];
        [self croak_showLoginInterface];
        return;
    }

    [SVProgressHUD showWithStatus:@"Deleting account..."];
    [[Croak_AppDataStore sharedStore] croak_deleteAccount:account
                                               completion:^(NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        [Croak_UserSession croak_clearSession];
        [SVProgressHUD showSuccessWithStatus:@"Account deleted."];
        [self croak_showLoginInterface];
    }];
}

- (void)croak_showDeleteView {
    self.croak_deleteView.frame = self.view.bounds;
    self.croak_deleteView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    if (!self.croak_deleteView.superview) {
        [self.view addSubview:self.croak_deleteView];
    }

    self.croak_deleteView.hidden = NO;
    self.croak_deleteView.alpha = 0.0;
    self.croak_deleteContentView.transform = CGAffineTransformMakeScale(0.82, 0.82);
    [self.croak_deleteView layoutIfNeeded];

    [UIView animateWithDuration:0.28
                          delay:0
         usingSpringWithDamping:0.78
          initialSpringVelocity:0.8
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.croak_deleteView.alpha = 1.0;
        self.croak_deleteContentView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)croak_hideDeleteView {
    [UIView animateWithDuration:0.18
                     animations:^{
        self.croak_deleteView.alpha = 0.0;
        self.croak_deleteContentView.transform = CGAffineTransformMakeScale(0.92, 0.92);
    } completion:^(BOOL finished) {
        self.croak_deleteContentView.transform = CGAffineTransformIdentity;
        [self.croak_deleteView removeFromSuperview];
    }];
}

- (void)croak_showLoginInterface {
    [Croak_UserSession croak_clearSession];
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
