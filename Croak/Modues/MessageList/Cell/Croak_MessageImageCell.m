
#import "Croak_MessageImageCell.h"
#import "Croak_API.h"
#import "UIImageView+WebCache.h"

@implementation Croak_MessageImageCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = UIColor.clearColor;
    self.contentView.backgroundColor = UIColor.clearColor;

    self.croak_avatarImageView.layer.cornerRadius = 20.0;
    self.croak_avatarImageView.layer.masksToBounds = YES;

    self.croak_contentImageView.layer.cornerRadius = 12.0;
    self.croak_contentImageView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)croak_configureWithImageName:(NSString *)imageName avatarName:(NSString *)avatarName {
    [self croak_setImageView:self.croak_contentImageView
                   imageName:imageName
             placeholderName:@"croak_photo"];
    [self croak_setImageView:self.croak_avatarImageView
                   imageName:avatarName
             placeholderName:@"croak_avatar"];
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

    UIImage *fileImage = [UIImage imageWithContentsOfFile:imageName];
    if (fileImage) {
        return fileImage;
    }

    UIImage *assetImage = [UIImage imageNamed:imageName];
    if (assetImage) {
        return assetImage;
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
    if ([[rawName stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] length] == 0 ||
        [rawName hasPrefix:@"/"]) {
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

@end
