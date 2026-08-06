
#import "Croak_SquareDetailsCell.h"
#import "Croak_API.h"
#import "UIImageView+WebCache.h"

@implementation Croak_SquareDetailsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = UIColor.clearColor;
    self.contentView.backgroundColor = UIColor.clearColor;
    self.croak_avatarImageView.layer.cornerRadius = 20.0;
    self.croak_avatarImageView.layer.masksToBounds = YES;
    self.croak_avatarImageView.userInteractionEnabled = YES;
    self.croak_postImageView.layer.cornerRadius = 20.0;
    self.croak_postImageView.layer.masksToBounds = YES;
    self.croak_likeNamesLabel.numberOfLines = 1;
    self.croak_likeNamesLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.croak_likeNamesLabel.adjustsFontSizeToFitWidth = YES;
    self.croak_likeNamesLabel.minimumScaleFactor = 0.75;

    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(croak_avatarAction:)];
    [self.croak_avatarImageView addGestureRecognizer:avatarTap];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (IBAction)croak_loveAction:(UIButton *)sender {
    if (self.croak_loveActionHandler) {
        self.croak_loveActionHandler(self);
    } else {
        sender.selected = !sender.selected;
    }
}

- (void)croak_avatarAction:(UITapGestureRecognizer *)gesture {
    if (self.croak_avatarActionHandler) {
        self.croak_avatarActionHandler(self);
    }
}

- (void)croak_configureWithName:(NSString *)name
                        content:(NSString *)content
                      imageName:(NSString *)imageName
                     avatarName:(NSString *)avatarName
                      likeNames:(NSString *)likeNames
                           liked:(BOOL)liked {
    self.croak_nameLabel.text = name;
    self.croak_contentLabel.text = content;
    self.croak_likeNamesLabel.text = likeNames;
    self.croak_loveButton.selected = liked;
    self.croak_loveButton.enabled = YES;
    [self croak_setImageView:self.croak_avatarImageView
                    imageName:avatarName
                  placeholder:@"croak_avatar"];
    [self croak_setImageView:self.croak_postImageView
                    imageName:imageName
                  placeholder:@"croak_photo"];
}

- (void)croak_setImageView:(UIImageView *)imageView
                 imageName:(NSString *)imageName
               placeholder:(NSString *)placeholderName {
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

    UIImage *dataImage = [self croak_imageFromDataURI:imageName];
    if (dataImage) {
        return dataImage;
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
    if ([rawName hasPrefix:@"data:image"]) {
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
    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    if (!imageData.length) {
        return nil;
    }
    return [UIImage imageWithData:imageData];
}

@end
