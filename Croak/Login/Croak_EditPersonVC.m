
#import "Croak_EditPersonVC.h"
#import "Croak_TabBarController.h"

@interface Croak_EditPersonVC ()

@property (weak, nonatomic) IBOutlet UITextField *croak_name_textfiled;
@property (weak, nonatomic) IBOutlet UILabel *croak_years_label;
@property (weak, nonatomic) IBOutlet UIImageView *croak_user_imageView;

@end
//
@implementation Croak_EditPersonVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)croak_backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)croak_selectYearsAction:(id)sender {
    
}

- (IBAction)croak_selectUserHeaderImageView:(id)sender {
    
}

- (IBAction)croak_saveAction:(id)sender {
    UIWindow *window = self.view.window;
    if (!window) {
        window = UIApplication.sharedApplication.delegate.window;
    }

    Croak_TabBarController *tabBarController = [[Croak_TabBarController alloc] init];
    window.rootViewController = tabBarController;
    [window makeKeyAndVisible];

    [UIView transitionWithView:window
                      duration:0.25
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:nil
                    completion:nil];
}

@end
