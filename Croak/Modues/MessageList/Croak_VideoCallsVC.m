#import "Croak_VideoCallsVC.h"
#import <AVFoundation/AVFoundation.h>
#import "Croak_API.h"
#import "UIImageView+WebCache.h"

@interface Croak_VideoCallsVC ()

@property (weak, nonatomic) IBOutlet UIImageView *croak_backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *croak_avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *croak_nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_statusLabel;
@property (nonatomic, strong) UIView *croak_localPreviewView;
@property (nonatomic, strong) UILabel *croak_cameraTipLabel;
@property (nonatomic, strong) NSTimer *croak_callTimer;
@property (nonatomic, assign) NSInteger croak_elapsedSeconds;
@property (nonatomic, strong) AVCaptureSession *croak_captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *croak_previewLayer;
@property (nonatomic, strong) dispatch_queue_t croak_captureQueue;

@end

@implementation Croak_VideoCallsVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.croak_captureQueue = dispatch_queue_create("com.croak.video-call.capture", DISPATCH_QUEUE_SERIAL);
    [self croak_configureExistingView];
    [self croak_addLocalPreviewIfNeeded];
    [self croak_requestPermissionsAndStart];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.croak_previewLayer.frame = self.croak_localPreviewView.bounds;
}

- (void)dealloc {
    [self croak_stopCall];
}

- (void)croak_configureExistingView {
    self.view.backgroundColor = UIColor.blackColor;
    self.croak_backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.croak_backgroundImageView.clipsToBounds = YES;
    self.croak_avatarImageView.layer.cornerRadius = 36.0;
    self.croak_avatarImageView.layer.masksToBounds = YES;

    NSString *name = [self croak_trimmedString:self.croak_name];
    self.croak_nameLabel.text = name.length > 0 ? name : @"Friend";
    self.croak_statusLabel.text = @"Connecting...";

    [self croak_setImageView:self.croak_backgroundImageView
                   imageName:self.croak_avatarName
             placeholderName:@"croak_avatar"];
    [self croak_setImageView:self.croak_avatarImageView
                   imageName:self.croak_avatarName
             placeholderName:@"croak_avatar"];
}

- (void)croak_addLocalPreviewIfNeeded {
    if (self.croak_localPreviewView) {
        return;
    }

    self.croak_localPreviewView = [[UIView alloc] init];
    self.croak_localPreviewView.translatesAutoresizingMaskIntoConstraints = NO;
    self.croak_localPreviewView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.45];
    self.croak_localPreviewView.layer.cornerRadius = 14.0;
    self.croak_localPreviewView.layer.masksToBounds = YES;
    self.croak_localPreviewView.layer.borderWidth = 1.0;
    self.croak_localPreviewView.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.35].CGColor;
    [self.view addSubview:self.croak_localPreviewView];

    self.croak_cameraTipLabel = [[UILabel alloc] init];
    self.croak_cameraTipLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.croak_cameraTipLabel.text = @"Camera Off";
    self.croak_cameraTipLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    self.croak_cameraTipLabel.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightMedium];
    self.croak_cameraTipLabel.textAlignment = NSTextAlignmentCenter;
    self.croak_cameraTipLabel.hidden = YES;
    [self.croak_localPreviewView addSubview:self.croak_cameraTipLabel];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.croak_localPreviewView.topAnchor constraintEqualToAnchor:safeArea.topAnchor constant:16.0],
        [self.croak_localPreviewView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16.0],
        [self.croak_localPreviewView.widthAnchor constraintEqualToConstant:104.0],
        [self.croak_localPreviewView.heightAnchor constraintEqualToConstant:148.0],

        [self.croak_cameraTipLabel.centerXAnchor constraintEqualToAnchor:self.croak_localPreviewView.centerXAnchor],
        [self.croak_cameraTipLabel.centerYAnchor constraintEqualToAnchor:self.croak_localPreviewView.centerYAnchor],
        [self.croak_cameraTipLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.croak_localPreviewView.leadingAnchor constant:8.0],
        [self.croak_cameraTipLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.croak_localPreviewView.trailingAnchor constant:-8.0],
    ]];
}

- (void)croak_requestPermissionsAndStart {
    [self croak_configureAudioSession];

    __weak typeof(self) weakSelf = self;
    [self croak_requestCameraPermissionWithCompletion:^(BOOL cameraGranted) {
        [weakSelf croak_requestMicrophonePermissionWithCompletion:^(BOOL microphoneGranted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) self = weakSelf;
                if (!self) {
                    return;
                }

                if (!cameraGranted) {
                    self.croak_statusLabel.text = @"Connecting...";
                    self.croak_cameraTipLabel.hidden = NO;
                } else {
                    self.croak_statusLabel.text = @"Connecting...";
                    [self croak_startCameraSessionWithMicrophone:microphoneGranted];
                }
                [self croak_startTimerIfNeeded];
            });
        }];
    }];
}

- (void)croak_requestCameraPermissionWithCompletion:(void (^)(BOOL granted))completion {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusAuthorized) {
        completion(YES);
        return;
    }
    if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:completion];
        return;
    }
    completion(NO);
}

- (void)croak_requestMicrophonePermissionWithCompletion:(void (^)(BOOL granted))completion {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (status == AVAuthorizationStatusAuthorized) {
        completion(YES);
        return;
    }
    if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:completion];
        return;
    }
    completion(NO);
}

- (void)croak_configureAudioSession {
    AVAudioSession *audioSession = AVAudioSession.sharedInstance;
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                  withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionAllowBluetoothHFP
                        error:nil];
    [audioSession setActive:YES error:nil];
}

- (void)croak_startCameraSessionWithMicrophone:(BOOL)microphoneGranted {
    if (self.croak_captureSession) {
        return;
    }

    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetHigh;

    BOOL hasVideoInput = NO;
    AVCaptureDevice *videoDevice = [self croak_videoDeviceWithPosition:AVCaptureDevicePositionFront];
    AVCaptureDeviceInput *videoInput = videoDevice ? [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil] : nil;
    if (videoInput && [session canAddInput:videoInput]) {
        [session addInput:videoInput];
        hasVideoInput = YES;
    }

    if (microphoneGranted) {
        AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        AVCaptureDeviceInput *audioInput = audioDevice ? [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil] : nil;
        if (audioInput && [session canAddInput:audioInput]) {
            [session addInput:audioInput];
        }
    }

    if (!hasVideoInput) {
        self.croak_statusLabel.text = @"Connecting...";
        self.croak_cameraTipLabel.hidden = NO;
        return;
    }

    self.croak_captureSession = session;
    self.croak_previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    self.croak_previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.croak_previewLayer.frame = self.croak_localPreviewView.bounds;
    [self.croak_localPreviewView.layer insertSublayer:self.croak_previewLayer atIndex:0];

    dispatch_async(self.croak_captureQueue, ^{
        [session startRunning];
    });
}

- (AVCaptureDevice *)croak_videoDeviceWithPosition:(AVCaptureDevicePosition)position {
    AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera]
                                                                                                                mediaType:AVMediaTypeVideo
                                                                                                                 position:position];
    AVCaptureDevice *device = discoverySession.devices.firstObject;
    return device ?: [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

- (void)croak_startTimerIfNeeded {
    if (self.croak_callTimer) {
        return;
    }

    self.croak_elapsedSeconds = 0;
    self.croak_callTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                            target:self
                                                          selector:@selector(croak_callTimerDidTick)
                                                          userInfo:nil
                                                           repeats:YES];
}

- (void)croak_callTimerDidTick {
    self.croak_elapsedSeconds += 1;
    self.croak_statusLabel.text = @"Connecting...";
}

- (IBAction)croak_callEndAction:(id)sender {
    [self croak_stopCall];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)croak_stopCall {
    [self.croak_callTimer invalidate];
    self.croak_callTimer = nil;

    AVCaptureSession *session = self.croak_captureSession;
    self.croak_captureSession = nil;
    if (session) {
        dispatch_async(self.croak_captureQueue ?: dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            if (session.isRunning) {
                [session stopRunning];
            }
        });
    }

    [AVAudioSession.sharedInstance setActive:NO
                                 withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                       error:nil];
}

- (void)croak_setImageView:(UIImageView *)imageView
                 imageName:(NSString *)imageName
           placeholderName:(NSString *)placeholderName {
    UIImage *placeholderImage = [UIImage imageNamed:placeholderName];
    UIImage *localImage = [self croak_localImageWithName:imageName];
    if (localImage) {
        [imageView sd_cancelCurrentImageLoad];
        imageView.image = localImage;
        return;
    }

    NSURL *imageURL = [self croak_remoteImageURLWithName:imageName];
    if (imageURL) {
        [imageView sd_setImageWithURL:imageURL placeholderImage:placeholderImage];
    } else {
        [imageView sd_cancelCurrentImageLoad];
        imageView.image = placeholderImage;
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
