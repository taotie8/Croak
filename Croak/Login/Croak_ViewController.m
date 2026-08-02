
#import "Croak_ViewController.h"
#import "Croak_LoginEmailVC.h"
#import "Croak_AgreementLinks.h"
#import "SVProgressHUD.h"

@interface Croak_ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *croak_select_button;

@end

@implementation Croak_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self.croak_select_button setSelected:NO];
    [self.croak_select_button setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
}

- (IBAction)croak_loginWithSignupAction:(UIButton *)sender {
    if (self.croak_select_button.selected == NO) {
        [SVProgressHUD showErrorWithStatus:@"Please first review and check the agreement before proceeding."];
        return;
    }
    
    if (sender.tag == 1) {
        Croak_LoginEmailVC *login_vc = [Croak_LoginEmailVC new];
        login_vc.croak_login = YES;
        [self.navigationController pushViewController:login_vc animated:YES];
    }
    else {
        [self.navigationController pushViewController:[Croak_LoginEmailVC new] animated:YES];
    }
}

- (IBAction)croak_selectPrivacyWithUserAndPolicyAction:(UIButton *)sender {
    if (sender.tag == 3) {
        self.croak_select_button.selected = !self.croak_select_button.selected;
        if (self.croak_select_button.isSelected == NO) {
            [self.croak_select_button setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        } else {
            [self.croak_select_button setImage:[UIImage imageNamed:@"croak_select"] forState:UIControlStateNormal];
        }
    }
    else if (sender.tag == 4) {
        [Croak_AgreementLinks croak_openUserAgreementFromViewController:self];
    }
    else {
        [Croak_AgreementLinks croak_openPrivacyPolicyFromViewController:self];
    }
}


@end
