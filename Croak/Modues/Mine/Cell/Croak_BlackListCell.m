//
//  Croak_BlackListCell.m
//  Croak
//
//  Created by JIAO on 2026/7/30.
//

#import "Croak_BlackListCell.h"
#import "Croak_API.h"
#import "UIImageView+WebCache.h"

@interface Croak_BlackListCell ()

@property (nonatomic, weak) UIImageView *croak_avatarImageView;
@property (nonatomic, weak) UILabel *croak_nameLabel;
@property (nonatomic, weak) UIButton *croak_unblockButton;

@end

@implementation Croak_BlackListCell

- (void)awakeFromNib {
    [super awakeFromNib];

    [self croak_configureSubviewsInView:self.contentView];
    self.croak_avatarImageView.layer.masksToBounds = YES;
    [self.croak_unblockButton addTarget:self action:@selector(croak_unblockAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)croak_configureWithUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    self.croak_nameLabel.text = [self croak_displayNameFromUserInfo:userInfo];
    [self croak_setAvatarWithName:[self croak_avatarNameFromUserInfo:userInfo]];
}

- (void)croak_unblockAction:(id)sender {
    if (self.croak_unblockActionHandler) {
        self.croak_unblockActionHandler(self);
    }
}

- (void)croak_configureSubviewsInView:(UIView *)view {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:UIImageView.class]) {
            self.croak_avatarImageView = (UIImageView *)subview;
        } else if ([subview isKindOfClass:UILabel.class]) {
            self.croak_nameLabel = (UILabel *)subview;
        } else if ([subview isKindOfClass:UIButton.class]) {
            self.croak_unblockButton = (UIButton *)subview;
        }

        [self croak_configureSubviewsInView:subview];
    }
}

- (NSString *)croak_displayNameFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *name = [self croak_trimmedString:userInfo[@"kjvmvsaz"]];
    if (name.length == 0) {
        name = [self croak_trimmedString:userInfo[@"nickname"]];
    }
    if (name.length == 0) {
        name = [self croak_trimmedString:userInfo[@"kewgxwk"]];
    }
    return name.length > 0 ? name : @"Unknown";
}

- (NSString *)croak_avatarNameFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *avatarName = [self croak_rawImageNameFromValue:userInfo[@"fsuv"]];
    if (avatarName.length == 0) {
        avatarName = [self croak_rawImageNameFromValue:userInfo[@"avatar"]];
    }
    return avatarName;
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
    if (imageURL) {
        [self.croak_avatarImageView sd_setImageWithURL:imageURL placeholderImage:placeholderImage];
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

    if ([imageName hasPrefix:@"http://"] || [imageName hasPrefix:@"https://"]) {
        return [NSURL URLWithString:imageName];
    }
    return [NSURL URLWithString:[CroakAPIAssetBaseURLString stringByAppendingString:imageName]];
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
