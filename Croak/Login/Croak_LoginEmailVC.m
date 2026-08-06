
#import "Croak_LoginEmailVC.h"
#import "Croak_AppDataStore.h"
#import "Croak_UserSession.h"
#import "Croak_EditPersonVC.h"
#import "SVProgressHUD.h"

@interface Croak_LoginEmailVC ()

@property (weak, nonatomic) IBOutlet UILabel *croak_title_label;
@property (weak, nonatomic) IBOutlet UITextField *croak_password_textfiled;
@property (weak, nonatomic) IBOutlet UIButton *croak_button;

@end

@implementation Croak_LoginEmailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    self.croak_email_textfiled.placeholder = @"Account";
    self.croak_password_textfiled.placeholder = @"Password";
    self.croak_password_textfiled.secureTextEntry = YES;
    
    if (self.croak_login) {
        self.croak_title_label.text = @"Login";
    } else {
        self.croak_title_label.text = @"Sign up";
        [self.croak_button setImage:[UIImage imageNamed:@"croak_sig_up"] forState:UIControlStateNormal];
    }

}

- (IBAction)croak_loginSignupAction:(id)sender {
    [self.view endEditing:YES];

    NSString *account = [self.croak_email_textfiled.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    NSString *password = [self.croak_password_textfiled.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];

    if (self.croak_login) {
        [self croak_loginWithAccount:account password:password];
    } else {
        [self croak_registerWithAccount:account password:password];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (IBAction)croak_backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)croak_loginWithAccount:(NSString *)account password:(NSString *)password {
    [SVProgressHUD show];
    [[Croak_AppDataStore sharedStore] croak_loginWithAccount:account
                                                    password:password
                                                  completion:^(NSDictionary<NSString *,id> *userInfo, NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        Croak_UserSession.croak_currentAccount = [self croak_accountFromUserInfo:userInfo fallback:account];
        if (![self croak_userInfoHasBirthday:userInfo]) {
            [Croak_UserSession croak_setCompletedRequiredProfile:NO
                                                       forAccount:Croak_UserSession.croak_currentAccount];
        }
        [SVProgressHUD showSuccessWithStatus:@"Login successful."];
        [self croak_showEditProfileWithUserInfo:userInfo];
    }];
}

- (void)croak_registerWithAccount:(NSString *)account password:(NSString *)password {
    [SVProgressHUD show];
    [[Croak_AppDataStore sharedStore] croak_registerWithAccount:account
                                                       password:password
                                                     completion:^(NSDictionary<NSString *,id> *userInfo, NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        Croak_UserSession.croak_currentAccount = [self croak_accountFromUserInfo:userInfo fallback:account];
        [Croak_UserSession croak_setCompletedRequiredProfile:NO
                                                   forAccount:Croak_UserSession.croak_currentAccount];
        [SVProgressHUD showSuccessWithStatus:@"Registration successful."];
        [self croak_showEditProfileWithUserInfo:userInfo];
    }];
}

- (void)croak_showEditProfileWithUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    Croak_EditPersonVC *editPersonVC = [[Croak_EditPersonVC alloc] init];
    editPersonVC.croak_userInfo = userInfo;
    [self.navigationController pushViewController:editPersonVC animated:YES];
}

- (BOOL)croak_userInfoHasBirthday:(NSDictionary<NSString *, id> *)userInfo {
    NSString *birthdayText = [self croak_trimmedString:userInfo[@"fzlucn"]];
    if (birthdayText.length == 0) {
        birthdayText = [self croak_trimmedString:userInfo[@"birthday"]];
    }
    return birthdayText.length > 0;
}

- (NSString *)croak_accountFromUserInfo:(NSDictionary<NSString *, id> *)userInfo fallback:(NSString *)fallback {
    NSString *account = [self croak_trimmedString:userInfo[@"kewgxwk"]];
    return account.length > 0 ? account : [self croak_trimmedString:fallback];
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
