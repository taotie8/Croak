
#import "Croak_SettingVC.h"
#import "Croak_BlackListVC.h"

@interface Croak_SettingVC ()

@property (weak, nonatomic) IBOutlet UILabel *croak_titleLabel;

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
    
}

- (IBAction)croak_userAgreementAction:(id)sender {
    
}

- (IBAction)croak_logoutAction:(id)sender {
    
}

- (IBAction)croak_deleteAccountAction:(id)sender {
    
}


@end
