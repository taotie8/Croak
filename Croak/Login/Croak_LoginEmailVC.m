
#import "Croak_LoginEmailVC.h"
#import "Croak_EditPersonVC.h"

@interface Croak_LoginEmailVC ()
<<<<<<< HEAD
 
=======

@property (weak, nonatomic) IBOutlet UILabel *croak_title_label;
@property (weak, nonatomic) IBOutlet UITextField *croak_email_textfiled;
@property (weak, nonatomic) IBOutlet UITextField *croak_password_textfiled;
@property (weak, nonatomic) IBOutlet UIButton *croak_button;
>>>>>>> 6cdc69dfae03157684f1b27d2fdecd58bb3d2ffe
@end

@implementation Croak_LoginEmailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:true];
    
    if (self.croak_login == YES) {
        self.croak_title_label.text = @"Login";
    }else {
        self.croak_title_label.text = @"Sign up";
    }
}

- (IBAction)corak_backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)croak_loginSignupAction:(id)sender {
    [self.navigationController pushViewController:[Croak_EditPersonVC new] animated:YES];
    
}

<<<<<<< HEAD
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (IBAction)croak_backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
=======
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
>>>>>>> 6cdc69dfae03157684f1b27d2fdecd58bb3d2ffe
}

@end
