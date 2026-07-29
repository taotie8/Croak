
#import "Croak_ViewController.h"
#import "Croak_LoginEmailVC.h"
<<<<<<< HEAD
#import "Croak_EditPersonVC.h"

=======
#import "SVProgressHUD.h"
>>>>>>> 6cdc69dfae03157684f1b27d2fdecd58bb3d2ffe
@interface Croak_ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *croak_select_button;

@end

@implementation Croak_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
<<<<<<< HEAD
    self.view.backgroundColor = UIColor.whiteColor;
}

- (IBAction)croak_loginWithSingupAction:(UIButton *)sender {
    if (sender.tag == 1) {
        [self.navigationController pushViewController:[Croak_LoginEmailVC new] animated:YES];
    }
    else {
        [self.navigationController pushViewController:[Croak_EditPersonVC new] animated:YES];
    }
=======
    [self.croak_select_button setSelected:false];
    [self.croak_select_button setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
>>>>>>> 6cdc69dfae03157684f1b27d2fdecd58bb3d2ffe
}

- (IBAction)croak_loginWithSignupAction:(UIButton *)sender {
    if (self.croak_select_button.selected == NO) {
        [SVProgressHUD showErrorWithStatus:@"Please first review and check the agreement before proceeding."];
        return;
    }
    
    if (sender.tag == 1) {
        Croak_LoginEmailVC *login_vc = [Croak_LoginEmailVC new];
        login_vc.croak_login = YES;
        [self.navigationController pushViewController:login_vc animated:true];
    }
    else {
        [self.navigationController pushViewController:[Croak_LoginEmailVC new] animated:true];
    }
}

- (IBAction)croak_selectPrivacyWithUserAndPolicyAction:(UIButton *)sender {
    if (sender.tag == 3) {
        self.croak_select_button.selected = !self.croak_select_button.selected;
        if (self.croak_select_button.isSelected == false) {
            [self.croak_select_button setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        }else {
            [self.croak_select_button setImage:[UIImage imageNamed:@"croak_select"] forState:UIControlStateNormal];
        }
    }
    else if (sender.tag == 4) {
        
    }
    else {
        
    }
}


@end
