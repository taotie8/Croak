
#import "Croak_EditPersonVC.h"
#import <PhotosUI/PhotosUI.h>
#import "Croak_TabBarController.h"
#import "Croak_AppDataStore.h"
#import "Croak_API.h"
#import "Croak_UserSession.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"

@interface Croak_EditPersonVC () <UITextFieldDelegate, UIGestureRecognizerDelegate, PHPickerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *croak_name_textfiled;
@property (weak, nonatomic) IBOutlet UILabel *croak_years_label;
@property (weak, nonatomic) IBOutlet UIImageView *croak_user_imageView;
@property (nonatomic, strong, nullable) NSDate *croak_selectedBirthday;
@property (nonatomic, copy) NSString *croak_avatarName;
@property (nonatomic, assign) BOOL croak_isSaving;
@property (nonatomic, assign) BOOL croak_didSelectAvatar;

@end
//
@implementation Croak_EditPersonVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    self.croak_user_imageView.layer.cornerRadius = 36.0;
    self.croak_user_imageView.layer.masksToBounds = YES;
    self.croak_name_textfiled.delegate = self;
    self.croak_name_textfiled.returnKeyType = UIReturnKeyDone;
    [self croak_configureKeyboardDismissal];
    [self croak_fillUserProfile];
}

- (IBAction)croak_backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)croak_selectYearsAction:(id)sender {
    [self.view endEditing:YES];
    [self croak_showBirthdayPickerFromSender:sender];
}

- (IBAction)croak_selectUserHeaderImageView:(id)sender {
    PHPickerConfiguration *configuration = [[PHPickerConfiguration alloc] init];
    configuration.filter = PHPickerFilter.imagesFilter;
    configuration.selectionLimit = 1;

    PHPickerViewController *picker = [[PHPickerViewController alloc] initWithConfiguration:configuration];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)croak_saveAction:(id)sender {
    if (self.croak_isSaving) {
        return;
    }

    [self.view endEditing:YES];
    NSString *displayName = [self croak_trimmedString:self.croak_name_textfiled.text];
    if (displayName.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"Please enter nickname."];
        return;
    }
    if (!self.croak_selectedBirthday) {
        [SVProgressHUD showErrorWithStatus:@"Please select your birthday."];
        return;
    }
    if (![self croak_isBirthdayAllowed:self.croak_selectedBirthday]) {
        [SVProgressHUD showErrorWithStatus:@"You must be 18 years old or above to continue."];
        return;
    }

    self.croak_isSaving = YES;
    [SVProgressHUD showWithStatus:@"Saving..."];
    [[Croak_AppDataStore sharedStore] croak_updateCurrentUserWithDisplayName:displayName
                                                                    birthday:self.croak_selectedBirthday
                                                                  completion:^(NSDictionary<NSString *,id> *userInfo, NSError *error) {
        self.croak_isSaving = NO;
        [SVProgressHUD dismiss];
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        self.croak_userInfo = userInfo;
        [Croak_UserSession croak_setCompletedRequiredProfile:YES
                                                   forAccount:Croak_UserSession.croak_currentAccount];
        NSString *successMessage = self.croak_didSelectAvatar ? @"Profile updated successfully. Avatar is under review!" : @"Saved.";
        [SVProgressHUD showSuccessWithStatus:successMessage];
        if (self.croak_returnToPreviousPageAfterSave) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }

        [self croak_showMainInterface];
    }];
}

- (void)croak_configureKeyboardDismissal {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(croak_dismissKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)croak_dismissKeyboard {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.croak_name_textfiled]) {
        return NO;
    }
    return YES;
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

            [self.croak_user_imageView sd_cancelCurrentImageLoad];
            self.croak_user_imageView.image = (UIImage *)object;
            self.croak_didSelectAvatar = YES;
        });
    }];
}

- (void)croak_showMainInterface {
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

- (void)croak_fillUserProfile {
    NSDictionary<NSString *, id> *userInfo = self.croak_userInfo ?: [[Croak_AppDataStore sharedStore] croak_currentUserInfo];
    if (![userInfo isKindOfClass:NSDictionary.class]) {
        [self croak_loadCurrentUserProfile];
        return;
    }

    self.croak_userInfo = userInfo;
    self.croak_name_textfiled.text = [self croak_displayNameFromUserInfo:userInfo];
    self.croak_selectedBirthday = [self croak_birthdayFromUserInfo:userInfo];
    self.croak_years_label.text = [self croak_displayBirthdayTextFromDate:self.croak_selectedBirthday];
    self.croak_avatarName = [self croak_avatarNameFromUserInfo:userInfo];
    [self croak_setAvatarImageWithName:self.croak_avatarName];
}

- (void)croak_loadCurrentUserProfile {
    [[Croak_AppDataStore sharedStore] croak_fetchAllDataWithCompletion:^(NSError *error) {
        if (error) {
            [self croak_setAvatarImageWithName:@""];
            return;
        }
        self.croak_userInfo = [[Croak_AppDataStore sharedStore] croak_currentUserInfo];
        [self croak_fillUserProfile];
    }];
}

- (void)croak_showBirthdayPickerFromSender:(id)sender {
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    datePicker.maximumDate = [self croak_latestAllowedBirthdayDate];
    datePicker.minimumDate = [self croak_earliestAllowedBirthdayDate];
    datePicker.date = self.croak_selectedBirthday ?: datePicker.maximumDate;
    if ([datePicker.date compare:datePicker.maximumDate] == NSOrderedDescending) {
        datePicker.date = datePicker.maximumDate;
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select birthday\n\n\n\n\n\n\n\n"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    datePicker.translatesAutoresizingMaskIntoConstraints = NO;
    [alert.view addSubview:datePicker];
    [NSLayoutConstraint activateConstraints:@[
        [datePicker.leadingAnchor constraintEqualToAnchor:alert.view.leadingAnchor constant:8.0],
        [datePicker.trailingAnchor constraintEqualToAnchor:alert.view.trailingAnchor constant:-8.0],
        [datePicker.topAnchor constraintEqualToAnchor:alert.view.topAnchor constant:46.0],
        [datePicker.heightAnchor constraintEqualToConstant:190.0]
    ]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.croak_selectedBirthday = datePicker.date;
        self.croak_years_label.text = [self croak_displayBirthdayTextFromDate:datePicker.date];
    }]];

    UIPopoverPresentationController *popover = alert.popoverPresentationController;
    if (popover && [sender isKindOfClass:UIView.class]) {
        popover.sourceView = sender;
        popover.sourceRect = [(UIView *)sender bounds];
    }
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSString *)croak_displayNameFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *name = [self croak_trimmedString:userInfo[@"kjvmvsaz"]];
    if (name.length == 0) {
        name = [self croak_trimmedString:userInfo[@"nickname"]];
    }
    if (name.length == 0) {
        name = [self croak_trimmedString:userInfo[@"kewgxwk"]];
    }
    return name;
}

- (NSDate *)croak_birthdayFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *birthdayText = [self croak_trimmedString:userInfo[@"fzlucn"]];
    if (birthdayText.length == 0) {
        birthdayText = [self croak_trimmedString:userInfo[@"birthday"]];
    }
    return [self croak_dateFromISOString:birthdayText];
}

- (NSString *)croak_avatarNameFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *avatarName = [self croak_rawImageNameFromValue:userInfo[@"fsuv"]];
    if (avatarName.length == 0) {
        avatarName = [self croak_rawImageNameFromValue:userInfo[@"avatar"]];
    }
    return avatarName;
}

- (void)croak_setAvatarImageWithName:(NSString *)imageName {
    UIImage *placeholderImage = [UIImage imageNamed:@"croak_avatar"];
    UIImage *localImage = [self croak_localImageWithName:imageName];
    if (localImage) {
        [self.croak_user_imageView sd_cancelCurrentImageLoad];
        self.croak_user_imageView.image = localImage;
        return;
    }

    NSURL *imageURL = [self croak_remoteImageURLWithName:imageName];
    if (imageURL) {
        [self.croak_user_imageView sd_setImageWithURL:imageURL placeholderImage:placeholderImage];
    } else {
        [self.croak_user_imageView sd_cancelCurrentImageLoad];
        self.croak_user_imageView.image = placeholderImage;
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
    NSString *rawName = [self croak_rawImageNameFromValue:imageName];
    if (rawName.length == 0) {
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

- (NSDate *)croak_dateFromISOString:(NSString *)dateString {
    if (dateString.length == 0) {
        return nil;
    }

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    for (NSString *format in @[@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", @"yyyy-MM-dd'T'HH:mm:ss'Z'", @"yyyy-MM-dd"]) {
        formatter.dateFormat = format;
        NSDate *date = [formatter dateFromString:dateString];
        if (date) {
            return date;
        }
    }
    return nil;
}

- (NSString *)croak_displayBirthdayTextFromDate:(NSDate *)date {
    if (!date) {
        return @"";
    }

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"yyyy-MM-dd";
    return [formatter stringFromDate:date];
}

- (NSDate *)croak_latestAllowedBirthdayDate {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = -18;
    return [NSCalendar.currentCalendar dateByAddingComponents:components toDate:NSDate.date options:0] ?: NSDate.date;
}

- (BOOL)croak_isBirthdayAllowed:(NSDate *)birthday {
    if (!birthday) {
        return NO;
    }
    return [birthday compare:[self croak_latestAllowedBirthdayDate]] != NSOrderedDescending;
}

- (NSDate *)croak_earliestAllowedBirthdayDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"yyyy-MM-dd";
    return [formatter dateFromString:@"1900-01-01"] ?: NSDate.distantPast;
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

@end
