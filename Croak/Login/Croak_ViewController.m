
#import "Croak_ViewController.h"
#import "Croak_LoginEmailVC.h"
#import "Croak_EditPersonVC.h"

@interface Croak_ViewController ()

@end

@implementation Croak_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
}

- (IBAction)croak_loginWithSingupAction:(UIButton *)sender {
    if (sender.tag == 1) {
        [self.navigationController pushViewController:[Croak_LoginEmailVC new] animated:YES];
    }
    else {
        [self.navigationController pushViewController:[Croak_EditPersonVC new] animated:YES];
    }
}

@end
