
#import "Croak_ViewController.h"
#import "Croak_LoginEmailVC.h"
@interface Croak_ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *croak_select_button;

@end

@implementation Croak_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.croak_select_button setSelected:false];
    [self.croak_select_button setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
}

- (IBAction)croak_loginWithSignupAction:(UIButton *)sender {
    if (sender.tag == 1) {
        [self.navigationController pushViewController:[Croak_LoginEmailVC new] animated:true];
    }
    else {
        
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
