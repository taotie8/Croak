
#import "Croak_PostSquareVC.h"

@interface Croak_PostSquareVC () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *croak_titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *croak_avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *croak_nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_placeholderLabel;
@property (weak, nonatomic) IBOutlet UITextView *croak_contentTextView;
@property (weak, nonatomic) IBOutlet UIView *croak_imageContentView;
@property (weak, nonatomic) IBOutlet UIImageView *croak_postImageView;
@property (strong, nonatomic) IBOutlet UIView *croak_successView;
@property (weak, nonatomic) IBOutlet UIView *croak_successContentView;

@end

@implementation Croak_PostSquareVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.croak_contentTextView.delegate = self;
    self.croak_titleLabel.text = @"Post";
}

- (IBAction)croak_backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)croak_addImageAction:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)croak_postAction:(id)sender {
    [self.view endEditing:YES];
    [self croak_showSuccessView];
}

- (IBAction)croak_cancelSuccessViewAction:(id)sender {
    [self croak_hideSuccessView];
}

- (IBAction)croak_confirmSuccessViewAction:(id)sender {
    [self croak_hideSuccessView];
}

- (void)textViewDidChange:(UITextView *)textView {
    self.croak_placeholderLabel.hidden = textView.text.length > 0;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)croak_showSuccessView {
    if (!self.croak_successView.superview) {
        self.croak_successView.frame = self.view.bounds;
        self.croak_successView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.croak_successView];
    }

    self.croak_successView.hidden = NO;
    self.croak_successView.alpha = 0.0;
    self.croak_successContentView.transform = CGAffineTransformMakeScale(0.82, 0.82);
    [self.croak_successView layoutIfNeeded];

    [UIView animateWithDuration:0.28
                          delay:0
         usingSpringWithDamping:0.78
          initialSpringVelocity:0.8
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.croak_successView.alpha = 1.0;
        self.croak_successContentView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)croak_hideSuccessView {
    [UIView animateWithDuration:0.18
                     animations:^{
        self.croak_successView.alpha = 0.0;
        self.croak_successContentView.transform = CGAffineTransformMakeScale(0.92, 0.92);
    } completion:^(BOOL finished) {
        self.croak_successContentView.transform = CGAffineTransformIdentity;
        [self.croak_successView removeFromSuperview];
    }];
}

@end
