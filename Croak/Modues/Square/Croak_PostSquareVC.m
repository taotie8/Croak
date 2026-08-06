
#import "Croak_PostSquareVC.h"
#import "Croak_API.h"
#import "Croak_AppDataStore.h"
#import "Croak_DiamondsVC.h"
#import "Croak_UserSession.h"
#import <PhotosUI/PhotosUI.h>
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"

static NSInteger const CroakPostSquareCost = 49;

@interface Croak_PostSquareVC () <UITextViewDelegate, UIGestureRecognizerDelegate, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *croak_titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *croak_avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *croak_nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_placeholderLabel;
@property (weak, nonatomic) IBOutlet UITextView *croak_contentTextView;
@property (weak, nonatomic) IBOutlet UIView *croak_imageContentView;
@property (weak, nonatomic) IBOutlet UIImageView *croak_postImageView;
@property (strong, nonatomic) IBOutlet UIView *croak_successView;
@property (weak, nonatomic) IBOutlet UIView *croak_successContentView;
@property (strong, nonatomic) IBOutlet UIView *croak_insufficientCoinsView;
@property (weak, nonatomic) IBOutlet UIView *croak_insufficientCoinsContentView;
@property (nonatomic, weak) UIButton *croak_postButton;
@property (nonatomic, weak) UIButton *croak_addImageButton;
@property (nonatomic, strong, nullable) UIImage *croak_selectedPostImage;
@property (nonatomic, assign) BOOL croak_isPosting;
@property (nonatomic, assign) BOOL croak_viewVisible;

@end

@implementation Croak_PostSquareVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.croak_contentTextView.delegate = self;
    self.croak_titleLabel.text = @"Post";
    self.croak_avatarImageView.layer.masksToBounds = YES;
    self.croak_imageContentView.layer.masksToBounds = YES;
    self.croak_postImageView.layer.masksToBounds = YES;

    [self croak_configureButtonsInView:self.view];
    [self croak_configureKeyboardDismissal];
    [self croak_configureKeyboardAccessory];
    [self croak_configureCurrentUserInfo];
    [self croak_updateSelectedImage:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.croak_viewVisible = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.croak_viewVisible = NO;
}

- (IBAction)croak_backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)croak_addImageAction:(id)sender {
    [self.view endEditing:YES];
    if (self.croak_isPosting) {
        return;
    }

    if (@available(iOS 14.0, *)) {
        PHPickerConfiguration *configuration = [[PHPickerConfiguration alloc] init];
        configuration.filter = PHPickerFilter.imagesFilter;
        configuration.selectionLimit = 1;

        PHPickerViewController *picker = [[PHPickerViewController alloc] initWithConfiguration:configuration];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
        return;
    }

    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [SVProgressHUD showErrorWithStatus:@"Image does not exist."];
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)croak_postAction:(UIButton *)sender {
    [self.view endEditing:YES];
    if (self.croak_isPosting) {
        return;
    }

    NSString *content = [self.croak_contentTextView.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (content.length == 0 && !self.croak_selectedPostImage) {
        [SVProgressHUD showErrorWithStatus:@"Please enter content or choose an image."];
        return;
    }

    NSString *account = [self croak_trimmedString:Croak_UserSession.croak_currentAccount];
    if (account.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"Please log in first."];
        return;
    }

    NSString *imageName = [self croak_encodedSelectedPostImageIfNeeded];
    if (self.croak_selectedPostImage && imageName.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"Image does not exist."];
        return;
    }

    self.croak_postButton = sender ?: self.croak_postButton;
    self.croak_isPosting = YES;
    self.croak_postButton.enabled = NO;
    self.croak_addImageButton.enabled = NO;
    [SVProgressHUD showWithStatus:@"Publishing..."];

#if DEBUG
    NSLog(@"\n[Croak Post]\naccount: %@\ncontent: %@\nhasImage: %@",
          [self croak_trimmedString:Croak_UserSession.croak_currentAccount],
          content,
          self.croak_selectedPostImage ? @"YES" : @"NO");
#endif

    [[Croak_AppDataStore sharedStore] croak_publishPostWithContent:content
                                                          imageName:imageName
                                                            account:account
                                                               cost:CroakPostSquareCost
                                                         completion:^(NSDictionary<NSString *,id> *postInfo, NSError *error) {
        [SVProgressHUD dismiss];
        self.croak_isPosting = NO;
        self.croak_postButton.enabled = YES;
        self.croak_addImageButton.enabled = YES;
        if (error) {
            if ([[self croak_trimmedString:error.localizedDescription] isEqualToString:@"Not enough diamonds."]) {
                [self croak_showInsufficientCoinsView];
            } else {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }
            return;
        }
        if (!self.croak_viewVisible) {
            return;
        }
        [self croak_showSuccessView];
    }];
}

- (IBAction)croak_cancelSuccessViewAction:(id)sender {
    [self croak_hideSuccessView];
}

- (IBAction)croak_confirmSuccessViewAction:(id)sender {
    [self croak_resetDraft];
    [self croak_hideSuccessViewWithCompletion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (IBAction)croak_cancelInsufficientCoinsViewAction:(id)sender {
    [self croak_hideInsufficientCoinsView];
}

- (IBAction)croak_confirmInsufficientCoinsViewAction:(id)sender {
    [self croak_hideInsufficientCoinsViewWithCompletion:^{
        Croak_DiamondsVC *diamondsVC = [[Croak_DiamondsVC alloc] init];
        diamondsVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:diamondsVC animated:YES];
    }];
}

- (void)textViewDidChange:(UITextView *)textView {
    self.croak_placeholderLabel.hidden = textView.text.length > 0;
}

- (void)croak_dismissKeyboard {
    [self.view endEditing:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.croak_contentTextView]) {
        return NO;
    }
    return YES;
}

- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results API_AVAILABLE(ios(14.0)) {
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

            [self croak_updateSelectedImage:(UIImage *)object];
        });
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *image = [info[UIImagePickerControllerOriginalImage] isKindOfClass:UIImage.class] ? info[UIImagePickerControllerOriginalImage] : nil;
    [picker dismissViewControllerAnimated:YES completion:^{
        if (image) {
            [self croak_updateSelectedImage:image];
        } else {
            [SVProgressHUD showErrorWithStatus:@"Image does not exist."];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)croak_configureButtonsInView:(UIView *)view {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:UIButton.class]) {
            UIButton *button = (UIButton *)subview;
            NSString *title = [button titleForState:UIControlStateNormal];
            if ([title isEqualToString:@"POST"]) {
                self.croak_postButton = button;
            } else if ([subview isDescendantOfView:self.croak_imageContentView]) {
                self.croak_addImageButton = button;
            }
        }
        [self croak_configureButtonsInView:subview];
    }
}

- (void)croak_configureKeyboardDismissal {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(croak_dismissKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)croak_configureKeyboardAccessory {
    CGFloat width = CGRectGetWidth(self.view.bounds) > 0 ? CGRectGetWidth(self.view.bounds) : 320.0;
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, width, 44.0)];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil
                                                                                  action:nil];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                 style:UIBarButtonItemStyleDone
                                                                target:self
                                                                action:@selector(croak_dismissKeyboard)];
    toolbar.items = @[flexibleItem, doneItem];
    self.croak_contentTextView.inputAccessoryView = toolbar;
}

- (void)croak_configureCurrentUserInfo {
    NSString *account = [self croak_trimmedString:Croak_UserSession.croak_currentAccount];
    NSString *displayName = [[Croak_AppDataStore sharedStore] croak_currentDisplayName];
    if (displayName.length == 0) {
        displayName = account;
    }
    self.croak_nameLabel.text = displayName.length > 0 ? displayName : @"Unknown";
    NSString *avatarName = [[Croak_AppDataStore sharedStore] croak_currentAvatarName];
#if DEBUG
    NSLog(@"\n[Croak Post Current User]\naccount: %@\nname: %@\nfsuv: %@",
          account.length > 0 ? account : @"<empty>",
          self.croak_nameLabel.text ?: @"",
          avatarName.length > 0 ? avatarName : @"<empty>");
#endif
    [self croak_setAvatarWithName:avatarName.length > 0 ? avatarName : @"croak_avatar"];
}

- (void)croak_updateSelectedImage:(UIImage *)image {
    self.croak_selectedPostImage = image;
    if (image) {
        self.croak_postImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.croak_postImageView.image = image;
        [self.croak_addImageButton setImage:nil forState:UIControlStateNormal];
    } else {
        self.croak_postImageView.image = nil;
        [self.croak_addImageButton setImage:[UIImage imageNamed:@"croak_add"] forState:UIControlStateNormal];
    }
}

- (void)croak_resetDraft {
    self.croak_contentTextView.text = @"";
    self.croak_placeholderLabel.hidden = NO;
    [self croak_updateSelectedImage:nil];
}

- (void)croak_setAvatarWithName:(NSString *)avatarName {
    UIImage *placeholderImage = [UIImage imageNamed:@"croak_avatar"];
    UIImage *localImage = [self croak_localImageWithName:avatarName];
    if (localImage) {
        [self.croak_avatarImageView sd_cancelCurrentImageLoad];
        self.croak_avatarImageView.image = localImage;
        return;
    }

    NSURL *imageURL = [self croak_remoteImageURLWithName:avatarName];
#if DEBUG
    NSLog(@"\n[Croak Post Avatar]\nrawAvatar: <%@>\nurl: %@",
          avatarName.length > 0 ? avatarName : @"<empty>",
          imageURL.absoluteString ?: @"<nil>");
#endif
    if (imageURL) {
        [self.croak_avatarImageView sd_setImageWithURL:imageURL
                                      placeholderImage:placeholderImage
                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
#if DEBUG
            if (error) {
                NSLog(@"\n[Croak Post Avatar]\nloadError: %@\nurl: %@", error.localizedDescription, imageURL.absoluteString);
            }
#endif
        }];
    } else {
        [self.croak_avatarImageView sd_cancelCurrentImageLoad];
        self.croak_avatarImageView.image = placeholderImage;
    }
}

- (UIImage *)croak_localImageWithName:(NSString *)imageName {
    if (![imageName isKindOfClass:NSString.class] || imageName.length == 0) {
        return nil;
    }

    UIImage *image = [UIImage imageNamed:imageName];
    if (image) {
        return image;
    }

    NSString *nameWithoutExtension = imageName.stringByDeletingPathExtension;
    if (nameWithoutExtension.length > 0 && ![nameWithoutExtension isEqualToString:imageName]) {
        return [UIImage imageNamed:nameWithoutExtension];
    }
    return nil;
}

- (NSURL *)croak_remoteImageURLWithName:(NSString *)imageName {
    if (![imageName isKindOfClass:NSString.class] || imageName.length == 0) {
        return nil;
    }

    NSString *rawName = imageName;
    if ([[rawName stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] length] == 0) {
        return nil;
    }

    if ([rawName hasPrefix:@"http://"] || [rawName hasPrefix:@"https://"]) {
        return [NSURL URLWithString:[rawName stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet] ?: rawName];
    }

    NSString *encodedName = [rawName stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLPathAllowedCharacterSet];
    if (encodedName.length == 0) {
        return nil;
    }
    return [NSURL URLWithString:[CroakAPIAssetBaseURLString stringByAppendingString:encodedName]];
}

- (NSString *)croak_rawImageNameFromValue:(id)value {
    NSString *rawName = @"";
    if ([value isKindOfClass:NSString.class]) {
        rawName = (NSString *)value;
    } else if ([value isKindOfClass:NSNumber.class]) {
        rawName = [(NSNumber *)value stringValue];
    }

    if ([[rawName stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] length] == 0) {
        return @"";
    }
    return rawName;
}

- (NSString *)croak_trimmedString:(id)value {
    if ([value isKindOfClass:NSString.class]) {
        return [value stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    }
    if ([value isKindOfClass:NSNumber.class]) {
        return [[value stringValue] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    }
    return @"";
}

- (NSString *)croak_encodedSelectedPostImageIfNeeded {
    if (!self.croak_selectedPostImage) {
        return @"";
    }

    UIImage *image = [self croak_scaledImage:self.croak_selectedPostImage maxPixelLength:960.0];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.78);
    if (!imageData.length) {
        return @"";
    }
    return [@"data:image/jpeg;base64," stringByAppendingString:[imageData base64EncodedStringWithOptions:0]];
}

- (UIImage *)croak_scaledImage:(UIImage *)image maxPixelLength:(CGFloat)maxPixelLength {
    if (!image || maxPixelLength <= 0) {
        return image;
    }

    CGSize originalSize = image.size;
    CGFloat longestSide = MAX(originalSize.width, originalSize.height);
    if (longestSide <= maxPixelLength || longestSide <= 0) {
        return image;
    }

    CGFloat scale = maxPixelLength / longestSide;
    CGSize targetSize = CGSizeMake(floor(originalSize.width * scale), floor(originalSize.height * scale));
    if (targetSize.width <= 0 || targetSize.height <= 0) {
        return image;
    }

    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:targetSize];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [image drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    }];
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
    [self croak_hideSuccessViewWithCompletion:nil];
}

- (void)croak_hideSuccessViewWithCompletion:(void (^)(void))completion {
    [UIView animateWithDuration:0.18
                     animations:^{
        self.croak_successView.alpha = 0.0;
        self.croak_successContentView.transform = CGAffineTransformMakeScale(0.92, 0.92);
    } completion:^(BOOL finished) {
        self.croak_successContentView.transform = CGAffineTransformIdentity;
        [self.croak_successView removeFromSuperview];
        if (completion) {
            completion();
        }
    }];
}

- (void)croak_showInsufficientCoinsView {
    if (!self.croak_insufficientCoinsView.superview) {
        self.croak_insufficientCoinsView.frame = self.view.bounds;
        self.croak_insufficientCoinsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.croak_insufficientCoinsView];
    }

    self.croak_insufficientCoinsView.hidden = NO;
    self.croak_insufficientCoinsView.alpha = 0.0;
    self.croak_insufficientCoinsContentView.transform = CGAffineTransformMakeScale(0.82, 0.82);
    [self.croak_insufficientCoinsView layoutIfNeeded];

    [UIView animateWithDuration:0.28
                          delay:0
         usingSpringWithDamping:0.78
          initialSpringVelocity:0.8
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.croak_insufficientCoinsView.alpha = 1.0;
        self.croak_insufficientCoinsContentView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)croak_hideInsufficientCoinsView {
    [self croak_hideInsufficientCoinsViewWithCompletion:nil];
}

- (void)croak_hideInsufficientCoinsViewWithCompletion:(void (^)(void))completion {
    [UIView animateWithDuration:0.18
                     animations:^{
        self.croak_insufficientCoinsView.alpha = 0.0;
        self.croak_insufficientCoinsContentView.transform = CGAffineTransformMakeScale(0.92, 0.92);
    } completion:^(BOOL finished) {
        self.croak_insufficientCoinsContentView.transform = CGAffineTransformIdentity;
        [self.croak_insufficientCoinsView removeFromSuperview];
        if (completion) {
            completion();
        }
    }];
}

@end
