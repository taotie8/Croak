#import "Croak_ReportDetailsVC.h"
#import <PhotosUI/PhotosUI.h>
#import "SVProgressHUD.h"

@interface Croak_ReportDetailsVC () <UITextViewDelegate, UIGestureRecognizerDelegate, PHPickerViewControllerDelegate>

@property (nonatomic, weak) UITextView *croak_reasonTextView;
@property (nonatomic, weak) UILabel *croak_placeholderLabel;
@property (nonatomic, weak) UIImageView *croak_previewImageView;
@property (nonatomic, weak) UIButton *croak_submitButton;
@property (nonatomic, strong) UILabel *croak_chooseImageLabel;
@property (nonatomic, strong, nullable) UIImage *croak_selectedEvidenceImage;
@property (nonatomic, assign) BOOL croak_isSubmittingReport;
@property (nonatomic, assign) BOOL croak_viewVisible;

@end

@implementation Croak_ReportDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self croak_configureSubviewsInView:self.view];
    [self croak_configureKeyboardDismissal];
    [self croak_configureEvidenceImagePicker];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.croak_viewVisible = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.croak_viewVisible = NO;
}

- (void)croak_configureSubviewsInView:(UIView *)view {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:UIButton.class]) {
            UIButton *button = (UIButton *)subview;
            NSString *title = [button titleForState:UIControlStateNormal];
            if ([title isEqualToString:@"Submit"]) {
                [button addTarget:self action:@selector(croak_submitAction:) forControlEvents:UIControlEventTouchUpInside];
                self.croak_submitButton = button;
            } else if (button.currentImage) {
                [button addTarget:self action:@selector(croak_backAction:) forControlEvents:UIControlEventTouchUpInside];
            }
        } else if ([subview isKindOfClass:UITextView.class]) {
            UITextView *textView = (UITextView *)subview;
            textView.delegate = self;
            textView.inputAccessoryView = [self croak_keyboardAccessoryView];
            self.croak_reasonTextView = textView;
        } else if ([subview isKindOfClass:UILabel.class]) {
            UILabel *label = (UILabel *)subview;
            if ([label.text isEqualToString:@"Search"]) {
                label.text = self.croak_reportTitle.length > 0 ? self.croak_reportTitle : @"Report";
            } else if ([label.text isEqualToString:@"Please enter"]) {
                self.croak_placeholderLabel = label;
            }
        } else if ([subview isKindOfClass:UIImageView.class]) {
            UIImageView *imageView = (UIImageView *)subview;
            self.croak_previewImageView = imageView;
            imageView.layer.masksToBounds = YES;
        }

        [self croak_configureSubviewsInView:subview];
    }
}

- (void)croak_configureKeyboardDismissal {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(croak_dismissKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
}

- (UIToolbar *)croak_keyboardAccessoryView {
    CGFloat width = CGRectGetWidth(self.view.bounds) > 0 ? CGRectGetWidth(self.view.bounds) : 320.0;
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, width, 44.0)];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil
                                                                                  action:nil];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                 style:UIBarButtonItemStyleProminent
                                                                target:self
                                                                action:@selector(croak_dismissKeyboard)];
    toolbar.items = @[flexibleItem, doneItem];
    return toolbar;
}

- (void)croak_dismissKeyboard {
    [self.view endEditing:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.croak_reasonTextView]) {
        return NO;
    }
    return YES;
}

- (void)croak_backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)croak_submitAction:(id)sender {
    if (self.croak_isSubmittingReport) {
        return;
    }

    NSString *reason = [self.croak_reasonTextView.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (reason.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"Please enter a reason."];
        return;
    }

    [self croak_dismissKeyboard];
    self.croak_isSubmittingReport = YES;
    self.croak_submitButton.enabled = NO;
    [SVProgressHUD showWithStatus:@"Submitting report..."];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        self.croak_isSubmittingReport = NO;
        self.croak_submitButton.enabled = YES;
        if (!self.croak_viewVisible) {
            return;
        }
        [self croak_showReportSuccessAlert];
    });
}

- (void)croak_showReportSuccessAlert {
    NSString *message = @"Thanks for helping keep Croak safe. We received your report and will review the details and any evidence you added. If this content or account violates our rules, we will take action as soon as possible.";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report submitted"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)textViewDidChange:(UITextView *)textView {
    self.croak_placeholderLabel.hidden = textView.text.length > 0;
}

- (void)croak_configureEvidenceImagePicker {
    self.croak_previewImageView.userInteractionEnabled = YES;
    self.croak_previewImageView.contentMode = UIViewContentModeCenter;
    self.croak_previewImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.04];
    self.croak_previewImageView.image = [UIImage imageNamed:@"croak_add"];

    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = @"Choose image";
    label.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    label.textColor = [UIColor colorWithWhite:0.45 alpha:1.0];
    label.textAlignment = NSTextAlignmentCenter;
    [self.croak_previewImageView addSubview:label];
    self.croak_chooseImageLabel = label;

    [NSLayoutConstraint activateConstraints:@[
        [label.leadingAnchor constraintEqualToAnchor:self.croak_previewImageView.leadingAnchor constant:8.0],
        [label.trailingAnchor constraintEqualToAnchor:self.croak_previewImageView.trailingAnchor constant:-8.0],
        [label.bottomAnchor constraintEqualToAnchor:self.croak_previewImageView.bottomAnchor constant:-18.0]
    ]];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(croak_chooseImageAction)];
    [self.croak_previewImageView addGestureRecognizer:tapGesture];
}

- (void)croak_chooseImageAction {
    PHPickerConfiguration *configuration = [[PHPickerConfiguration alloc] init];
    configuration.filter = PHPickerFilter.imagesFilter;
    configuration.selectionLimit = 1;

    PHPickerViewController *picker = [[PHPickerViewController alloc] initWithConfiguration:configuration];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results {
    [picker dismissViewControllerAnimated:YES completion:nil];
    PHPickerResult *result = results.firstObject;
    if (!result) {
        return;
    }
    if (![result.itemProvider canLoadObjectOfClass:UIImage.class]) {
        [SVProgressHUD showErrorWithStatus:@"Image does not exist."];
        return;
    }

    [SVProgressHUD show];
    __weak typeof(self) weakSelf = self;
    [result.itemProvider loadObjectOfClass:UIImage.class completionHandler:^(__kindof id<NSItemProviderReading> object, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) {
                return;
            }

            [SVProgressHUD dismiss];
            if (error || ![object isKindOfClass:UIImage.class]) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription ?: @"Image does not exist."];
                return;
            }

            self.croak_selectedEvidenceImage = (UIImage *)object;
            self.croak_previewImageView.contentMode = UIViewContentModeScaleAspectFill;
            self.croak_previewImageView.image = (UIImage *)object;
            self.croak_chooseImageLabel.hidden = YES;
        });
    }];
}

@end
