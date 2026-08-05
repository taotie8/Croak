//
//  Croak_SquareCommentCell.m
//  Croak
//
//  Created by JIAO on 2026/7/30.
//

#import "Croak_SquareCommentCell.h"
#import "Croak_API.h"
#import "UIImageView+WebCache.h"

@interface Croak_SquareCommentCell ()

@property (weak, nonatomic) IBOutlet UIImageView *croak_avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *croak_nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_timeLabel;

@end

@implementation Croak_SquareCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.croak_avatarImageView.layer.cornerRadius = 18.0;
    self.croak_avatarImageView.layer.masksToBounds = YES;
    self.croak_contentLabel.numberOfLines = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)croak_configureWithName:(NSString *)name
                         content:(NSString *)content
                            time:(NSString *)time
                      avatarName:(NSString *)avatarName {
    self.croak_nameLabel.text = name.length > 0 ? name : @"Unknown";
    self.croak_contentLabel.text = content ?: @"";
    self.croak_timeLabel.text = time ?: @"";
    [self croak_setAvatarWithName:avatarName];
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
    return [[rawName stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] length] > 0 ? rawName : @"";
}

@end
