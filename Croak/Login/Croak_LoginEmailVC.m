
#import "Croak_LoginEmailVC.h"

@interface Croak_LoginEmailVC ()
 
@end

@implementation Croak_LoginEmailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (IBAction)croak_backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
