
#import "Streak_ViewController.h"
#import "Croak_API.h"
#import "UIImageView+WebCache.h"

@interface Streak_ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *croak_avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *croak_dayStreakLabel;

@end

@implementation Streak_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.croak_avatarImageView.layer.cornerRadius = 28.5;
    self.croak_avatarImageView.layer.masksToBounds = YES;
    self.croak_dayStreakLabel.text = [self croak_displayDayStreakText];
    [self croak_setAvatarWithName:self.croak_avatarName];
}

- (IBAction)croak_backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)croak_displayDayStreakText {
    NSString *dayText = [self croak_trimmedString:self.croak_dayStreakText];
    return dayText.length > 0 ? dayText : @"1";
}

- (void)croak_setAvatarWithName:(NSString *)avatarName {
    UIImage *placeholderImage = [UIImage imageNamed:@"croak_avatar"];
    NSString *rawName = [self croak_rawImageNameFromValue:avatarName];
    UIImage *localImage = [self croak_localImageWithName:rawName];
    if (localImage) {
        [self.croak_avatarImageView sd_cancelCurrentImageLoad];
        self.croak_avatarImageView.image = localImage;
        return;
    }

    NSURL *avatarURL = [self croak_remoteAvatarURLWithName:rawName];
    if (avatarURL) {
        [self.croak_avatarImageView sd_setImageWithURL:avatarURL placeholderImage:placeholderImage];
    } else {
        [self.croak_avatarImageView sd_cancelCurrentImageLoad];
        self.croak_avatarImageView.image = placeholderImage;
    }
}

- (UIImage *)croak_localImageWithName:(NSString *)imageName {
    NSString *rawName = [self croak_rawImageNameFromValue:imageName];
    if (rawName.length == 0) {
        return nil;
    }

    UIImage *fileImage = [UIImage imageWithContentsOfFile:rawName];
    if (fileImage) {
        return fileImage;
    }

    UIImage *dataImage = [self croak_imageFromDataURI:rawName];
    if (dataImage) {
        return dataImage;
    }

    UIImage *assetImage = [UIImage imageNamed:rawName];
    if (assetImage) {
        return assetImage;
    }

    NSString *nameWithoutExtension = rawName.stringByDeletingPathExtension;
    if (nameWithoutExtension.length > 0 && ![nameWithoutExtension isEqualToString:rawName]) {
        return [UIImage imageNamed:nameWithoutExtension];
    }
    return nil;
}

- (NSURL *)croak_remoteAvatarURLWithName:(NSString *)imageName {
    NSString *rawName = [self croak_rawImageNameFromValue:imageName];
    if (rawName.length == 0 || [rawName hasPrefix:@"/"] || [rawName hasPrefix:@"data:image"]) {
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

- (UIImage *)croak_imageFromDataURI:(NSString *)dataURI {
    if (![dataURI hasPrefix:@"data:image"]) {
        return nil;
    }

    NSRange commaRange = [dataURI rangeOfString:@","];
    if (commaRange.location == NSNotFound || commaRange.location + 1 >= dataURI.length) {
        return nil;
    }

    NSString *base64String = [dataURI substringFromIndex:commaRange.location + 1];
    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (imageData.length == 0) {
        return nil;
    }
    return [UIImage imageWithData:imageData];
}

- (NSString *)croak_rawImageNameFromValue:(id)value {
    NSString *rawName = @"";
    if ([value isKindOfClass:NSString.class]) {
        rawName = (NSString *)value;
    } else if ([value isKindOfClass:NSNumber.class]) {
        rawName = [(NSNumber *)value stringValue];
    }
    return [self croak_trimmedString:rawName];
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
