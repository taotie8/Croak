
#import "Croak_MessageChatVC.h"
#import "Croak_API.h"
#import "Croak_AppDataStore.h"
#import "Croak_MessageChatCell.h"
#import "Croak_MessageImageCell.h"
#import "Croak_UserSession.h"
#import "Croak_VideoCallsVC.h"
#import <PhotosUI/PhotosUI.h>
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"

static NSString * const CroakMessageChatCellIdentifier = @"Croak_MessageChatCell";
static NSString * const CroakMessageImageCellIdentifier = @"Croak_MessageImageCell";
static NSString * const CroakMessageTypeText = @"text";
static NSString * const CroakMessageTypeImage = @"image";
static NSString * const CroakMessageLocalTypeKey = @"croakLocalType";
static NSString * const CroakMessageLocalImageNameKey = @"croakLocalImageName";

@interface Croak_MessageChatVC () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, PHPickerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *croak_nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *croak_avatarImageView;
@property (weak, nonatomic) IBOutlet UIView *croak_inputContentView;
@property (weak, nonatomic) IBOutlet UITextField *croak_inputTextField;
@property (weak, nonatomic) IBOutlet UITableView *croak_tableView;
@property (nonatomic, strong) NSMutableArray<NSDictionary<NSString *, id> *> *croak_messages;
@property (nonatomic, assign) BOOL croak_isSendingMessage;
@property (nonatomic, assign) UIEdgeInsets croak_originalTableContentInset;
@property (nonatomic, assign) UIEdgeInsets croak_originalTableScrollIndicatorInsets;

@end

@implementation Croak_MessageChatVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;

    NSString *name = self.croak_name.length > 0 ? self.croak_name : @"Ava";
    NSString *avatarName = self.croak_avatarName.length > 0 ? self.croak_avatarName : @"croak_avatar";
    self.croak_nameLabel.text = name;
    [self croak_setAvatarWithName:avatarName];
    self.croak_avatarImageView.layer.cornerRadius = 16.0;
    self.croak_avatarImageView.layer.masksToBounds = YES;

    self.croak_inputContentView.layer.cornerRadius = 8.0;
    self.croak_inputContentView.layer.masksToBounds = YES;
    self.croak_inputTextField.delegate = self;
    self.croak_inputTextField.returnKeyType = UIReturnKeySend;

    self.croak_messages = [[self croak_displayMessagesWithAvatarName:avatarName] mutableCopy];
    if (self.croak_messages.count == 0) {
        self.croak_messages = [NSMutableArray array];
    }

    [self.croak_tableView registerNib:[UINib nibWithNibName:CroakMessageChatCellIdentifier bundle:nil]
                forCellReuseIdentifier:CroakMessageChatCellIdentifier];
    [self.croak_tableView registerNib:[UINib nibWithNibName:CroakMessageImageCellIdentifier bundle:nil]
                forCellReuseIdentifier:CroakMessageImageCellIdentifier];
    self.croak_tableView.delegate = self;
    self.croak_tableView.dataSource = self;
    self.croak_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.croak_tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.croak_originalTableContentInset = self.croak_tableView.contentInset;
    self.croak_originalTableScrollIndicatorInsets = self.croak_tableView.verticalScrollIndicatorInsets;

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(croak_dismissKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.croak_tableView addGestureRecognizer:tapGesture];

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(croak_keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(croak_keyboardWillHide:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self croak_scrollToBottomAnimated:NO];
    });
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (IBAction)croak_backAction:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)croak_callAction:(id)sender {
    Croak_VideoCallsVC *calls = [Croak_VideoCallsVC new];
    calls.croak_name = self.croak_name;
    calls.croak_avatarName = self.croak_avatarName;
    calls.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:calls animated:true completion:nil];
    [self.view endEditing:YES];
}

- (IBAction)croak_sendAction:(id)sender {
    NSString *message = [self.croak_inputTextField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (message.length == 0) {
        return;
    }
    if (self.croak_isSendingMessage) {
        return;
    }
    if ([self croak_trimmedString:self.croak_sessionId].length == 0) {
        [SVProgressHUD showErrorWithStatus:@"Chat session does not exist."];
        return;
    }

    NSString *avatarName = self.croak_avatarName.length > 0 ? self.croak_avatarName : @"croak_avatar";
    self.croak_isSendingMessage = YES;
    [[Croak_AppDataStore sharedStore] croak_saveLocalChatMessage:message
                                                       sessionId:self.croak_sessionId
                                                    senderUserId:self.croak_currentUserId
                                                       completion:^(NSDictionary<NSString *,id> *messageInfo, NSError *error) {
        self.croak_isSendingMessage = NO;
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        NSMutableDictionary<NSString *, id> *displayMessage = [[self croak_displayMessageFromMessageInfo:messageInfo
                                                                                               avatarName:avatarName] mutableCopy];
        if (displayMessage.count > 0) {
            displayMessage[@"outgoing"] = @(YES);
            displayMessage[@"avatar"] = [self croak_currentAvatarNameForDisplay];
            [self.croak_messages addObject:displayMessage];
        } else {
            [self.croak_messages addObject:@{@"type": CroakMessageTypeText,
                                             @"message": message,
                                             @"avatar": [self croak_currentAvatarNameForDisplay],
                                             @"outgoing": @(YES)}];
        }
        self.croak_inputTextField.text = @"";
        [self croak_reloadAndScrollToBottom];
    }];
}

- (IBAction)croak_voiceAction:(id)sender {
    [self.view endEditing:YES];
    [SVProgressHUD showInfoWithStatus:@"Voice messages are not available."];
}

- (IBAction)croak_pictureAction:(id)sender {
    [self.view endEditing:YES];
    if (self.croak_isSendingMessage) {
        return;
    }
    if ([self croak_trimmedString:self.croak_sessionId].length == 0) {
        [SVProgressHUD showErrorWithStatus:@"Chat session does not exist."];
        return;
    }
    if ([self croak_normalizedCurrentUserId].length == 0) {
        [SVProgressHUD showErrorWithStatus:@"Please log in first."];
        return;
    }

    PHPickerConfiguration *configuration = [[PHPickerConfiguration alloc] init];
    configuration.filter = PHPickerFilter.imagesFilter;
    configuration.selectionLimit = 1;

    PHPickerViewController *picker = [[PHPickerViewController alloc] initWithConfiguration:configuration];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)croak_reloadAndScrollToBottom {
    [self.croak_tableView reloadData];
    [self croak_scrollToBottomAnimated:YES];
}

- (void)croak_scrollToBottomAnimated:(BOOL)animated {
    if (self.croak_messages.count == 0) {
        return;
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.croak_messages.count - 1 inSection:0];
    [self.croak_tableView scrollToRowAtIndexPath:indexPath
                                atScrollPosition:UITableViewScrollPositionBottom
                                        animated:animated];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.croak_messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary<NSString *, id> *messageInfo = self.croak_messages[indexPath.row];
    NSString *type = messageInfo[@"type"];

    if ([type isEqualToString:CroakMessageTypeImage]) {
        Croak_MessageImageCell *cell = [tableView dequeueReusableCellWithIdentifier:CroakMessageImageCellIdentifier
                                                                       forIndexPath:indexPath];
        [cell croak_configureWithImageName:messageInfo[@"image"] avatarName:messageInfo[@"avatar"]];
        return cell;
    }

    Croak_MessageChatCell *cell = [tableView dequeueReusableCellWithIdentifier:CroakMessageChatCellIdentifier
                                                                  forIndexPath:indexPath];
    [cell croak_configureWithMessage:[self croak_trimmedString:messageInfo[@"message"]]
                           avatarName:[self croak_rawImageNameFromValue:messageInfo[@"avatar"]]
                             outgoing:[self croak_boolFromValue:messageInfo[@"outgoing"]]];
    return cell;
}

- (NSArray<NSDictionary<NSString *, id> *> *)croak_displayMessagesWithAvatarName:(NSString *)avatarName {
    if (![self.croak_chatMessages isKindOfClass:NSArray.class] || self.croak_chatMessages.count == 0) {
        return @[];
    }

    NSMutableArray<NSDictionary<NSString *, id> *> *messages = [NSMutableArray array];
    for (NSDictionary<NSString *, id> *messageInfo in self.croak_chatMessages) {
        NSDictionary<NSString *, id> *displayMessage = [self croak_displayMessageFromMessageInfo:messageInfo
                                                                                       avatarName:avatarName];
        if (displayMessage.count > 0) {
            [messages addObject:displayMessage];
        }
    }
    return messages;
}

- (NSDictionary<NSString *, id> *)croak_displayMessageFromMessageInfo:(NSDictionary<NSString *, id> *)messageInfo
                                                             avatarName:(NSString *)avatarName {
    if (![messageInfo isKindOfClass:NSDictionary.class]) {
        return @{};
    }

    NSString *senderUserId = [self croak_normalizedString:messageInfo[@"jhrrdwm"]];
    NSString *currentUserId = [self croak_normalizedCurrentUserId];
    BOOL outgoing = senderUserId.length > 0 && [senderUserId isEqualToString:currentUserId];
    NSString *messageAvatarName = outgoing ? [self croak_currentAvatarNameForDisplay] : avatarName;

    NSString *imageName = [self croak_messageImageNameFromMessageInfo:messageInfo];
    NSString *messageType = [self croak_trimmedString:messageInfo[CroakMessageLocalTypeKey]];
    if (imageName.length > 0 || [messageType isEqualToString:CroakMessageTypeImage]) {
        NSString *imagePath = [self croak_localChatImagePathWithName:imageName];
        if (imagePath.length == 0) {
            return @{};
        }
        return @{@"type": CroakMessageTypeImage,
                 @"image": imagePath,
                 @"avatar": messageAvatarName.length > 0 ? messageAvatarName : @"croak_avatar",
                 @"outgoing": @(outgoing)};
    }

    NSString *content = [self croak_messageContentFromMessageInfo:messageInfo];
    if (content.length == 0) {
        return @{};
    }
    return @{@"type": CroakMessageTypeText,
             @"message": content,
             @"avatar": messageAvatarName.length > 0 ? messageAvatarName : @"croak_avatar",
             @"outgoing": @(outgoing)};
}

- (NSString *)croak_messageContentFromMessageInfo:(NSDictionary<NSString *, id> *)messageInfo {
    NSString *content = [self croak_trimmedString:messageInfo[@"syuvoah"]];
    if (content.length == 0) {
        content = [self croak_trimmedString:messageInfo[@"content"]];
    }
    return content;
}

- (NSString *)croak_messageImageNameFromMessageInfo:(NSDictionary<NSString *, id> *)messageInfo {
    NSString *imageName = [self croak_rawImageNameFromValue:messageInfo[CroakMessageLocalImageNameKey]];
    if (imageName.length == 0) {
        imageName = [self croak_rawImageNameFromValue:messageInfo[@"image"]];
    }
    if (imageName.length == 0) {
        imageName = [self croak_rawImageNameFromValue:messageInfo[@"imageName"]];
    }
    if (imageName.length == 0 && [messageInfo[@"images"] isKindOfClass:NSArray.class]) {
        imageName = [self croak_rawImageNameFromValue:[(NSArray *)messageInfo[@"images"] firstObject]];
    }
    return imageName;
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

    self.croak_isSendingMessage = YES;
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
                self.croak_isSendingMessage = NO;
                [SVProgressHUD showErrorWithStatus:error.localizedDescription ?: @"Image does not exist."];
                return;
            }

            [self croak_savePickedImageMessage:(UIImage *)object];
        });
    }];
}

- (void)croak_savePickedImageMessage:(UIImage *)image {
    NSString *imageName = [self croak_saveImageToLocalDirectory:image];
    if (imageName.length == 0) {
        self.croak_isSendingMessage = NO;
        [SVProgressHUD showErrorWithStatus:@"Failed to save image."];
        return;
    }

    NSString *avatarName = self.croak_avatarName.length > 0 ? self.croak_avatarName : @"croak_avatar";
    self.croak_isSendingMessage = YES;
    [[Croak_AppDataStore sharedStore] croak_saveLocalChatImageName:imageName
                                                         sessionId:self.croak_sessionId
                                                      senderUserId:self.croak_currentUserId
                                                        completion:^(NSDictionary<NSString *,id> *messageInfo, NSError *error) {
        self.croak_isSendingMessage = NO;
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        NSMutableDictionary<NSString *, id> *displayMessage = [[self croak_displayMessageFromMessageInfo:messageInfo
                                                                                               avatarName:avatarName] mutableCopy];
        if (displayMessage.count > 0) {
            displayMessage[@"outgoing"] = @(YES);
            displayMessage[@"avatar"] = [self croak_currentAvatarNameForDisplay];
            [self.croak_messages addObject:displayMessage];
        }
        [self croak_reloadAndScrollToBottom];
    }];
}

- (NSString *)croak_saveImageToLocalDirectory:(UIImage *)image {
    if (![image isKindOfClass:UIImage.class]) {
        return @"";
    }

    NSURL *directoryURL = [self croak_localChatImageDirectoryURL];
    NSError *directoryError = nil;
    [NSFileManager.defaultManager createDirectoryAtURL:directoryURL
                           withIntermediateDirectories:YES
                                            attributes:nil
                                                 error:&directoryError];
    if (directoryError) {
        return @"";
    }

    NSString *imageName = [NSString stringWithFormat:@"%@.jpg", NSUUID.UUID.UUIDString];
    NSURL *imageURL = [directoryURL URLByAppendingPathComponent:imageName];
    NSData *imageData = UIImageJPEGRepresentation([self croak_normalizedImage:image], 0.82);
    if (imageData.length == 0) {
        imageData = UIImagePNGRepresentation([self croak_normalizedImage:image]);
    }
    if (imageData.length == 0) {
        return @"";
    }

    NSError *writeError = nil;
    BOOL saved = [imageData writeToURL:imageURL options:NSDataWritingAtomic error:&writeError];
    return saved && !writeError ? imageName : @"";
}

- (UIImage *)croak_normalizedImage:(UIImage *)image {
    if (image.imageOrientation == UIImageOrientationUp) {
        return image;
    }

    UIGraphicsImageRendererFormat *format = UIGraphicsImageRendererFormat.defaultFormat;
    format.scale = image.scale;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:image.size format:format];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [image drawInRect:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    }];
}

- (NSURL *)croak_localChatImageDirectoryURL {
    NSURL *baseURL = [NSFileManager.defaultManager URLsForDirectory:NSApplicationSupportDirectory
                                                          inDomains:NSUserDomainMask].firstObject;
    if (!baseURL) {
        baseURL = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory
                                                       inDomains:NSUserDomainMask].firstObject;
    }
    if (!baseURL) {
        baseURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    }
    return [baseURL URLByAppendingPathComponent:@"CroakChatImages" isDirectory:YES];
}

- (NSString *)croak_localChatImagePathWithName:(NSString *)imageName {
    NSString *rawName = [self croak_rawImageNameFromValue:imageName];
    if (rawName.length == 0) {
        return @"";
    }
    if ([rawName hasPrefix:@"/"] || [rawName hasPrefix:@"http://"] || [rawName hasPrefix:@"https://"]) {
        return rawName;
    }

    NSString *localPath = [[self croak_localChatImageDirectoryURL] URLByAppendingPathComponent:rawName].path;
    if ([NSFileManager.defaultManager fileExistsAtPath:localPath]) {
        return localPath;
    }
    return rawName;
}

- (void)croak_keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect convertedKeyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
    CGFloat overlapHeight = MAX(0.0, CGRectGetMaxY(self.view.bounds) - CGRectGetMinY(convertedKeyboardFrame));
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = (UIViewAnimationOptions)([userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16);
    UIView *inputBarView = self.croak_inputContentView.superview;

    UIEdgeInsets contentInset = self.croak_originalTableContentInset;
    contentInset.bottom += overlapHeight;
    UIEdgeInsets indicatorInsets = self.croak_originalTableScrollIndicatorInsets;
    indicatorInsets.bottom += overlapHeight;

    [UIView animateWithDuration:duration
                          delay:0.0
                        options:options
                     animations:^{
        inputBarView.transform = CGAffineTransformMakeTranslation(0.0, -overlapHeight);
        self.croak_tableView.contentInset = contentInset;
        self.croak_tableView.verticalScrollIndicatorInsets = indicatorInsets;
    } completion:^(BOOL finished) {
        [self croak_scrollToBottomAnimated:YES];
    }];
}

- (void)croak_keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = (UIViewAnimationOptions)([userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16);
    UIView *inputBarView = self.croak_inputContentView.superview;

    [UIView animateWithDuration:duration
                          delay:0.0
                        options:options
                     animations:^{
        inputBarView.transform = CGAffineTransformIdentity;
        self.croak_tableView.contentInset = self.croak_originalTableContentInset;
        self.croak_tableView.verticalScrollIndicatorInsets = self.croak_originalTableScrollIndicatorInsets;
    } completion:nil];
}

- (void)croak_dismissKeyboard {
    [self.view endEditing:YES];
}

- (NSString *)croak_normalizedCurrentUserId {
    return [self croak_normalizedString:self.croak_currentUserId];
}

- (NSString *)croak_currentAvatarNameForDisplay {
    NSString *avatarName = [self croak_rawImageNameFromValue:self.croak_currentAvatarName];
    return avatarName.length > 0 ? avatarName : @"croak_avatar";
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

- (BOOL)croak_boolFromValue:(id)value {
    if ([value isKindOfClass:NSNumber.class]) {
        return [value boolValue];
    }
    if ([value isKindOfClass:NSString.class]) {
        NSString *normalizedValue = [[self croak_trimmedString:value] lowercaseString];
        return [normalizedValue isEqualToString:@"1"] || [normalizedValue isEqualToString:@"true"] || [normalizedValue isEqualToString:@"yes"];
    }
    return NO;
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

- (NSString *)croak_normalizedString:(id)value {
    return [[self croak_trimmedString:value] lowercaseString];
}

- (void)croak_setAvatarWithName:(NSString *)avatarName {
    UIImage *placeholderImage = [UIImage imageNamed:@"croak_avatar"];
    UIImage *localImage = [self croak_localImageWithName:avatarName];
    if (localImage) {
        [self.croak_avatarImageView sd_cancelCurrentImageLoad];
        self.croak_avatarImageView.image = localImage;
        return;
    }

    NSURL *avatarURL = [self croak_remoteAvatarURLWithName:avatarName];
    if (avatarURL) {
        [self.croak_avatarImageView sd_setImageWithURL:avatarURL placeholderImage:placeholderImage];
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

- (NSURL *)croak_remoteAvatarURLWithName:(NSString *)imageName {
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self croak_sendAction:textField];
    return YES;
}

@end
