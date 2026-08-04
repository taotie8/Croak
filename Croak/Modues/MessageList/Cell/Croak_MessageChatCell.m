//
//  Croak_MessageChatCell.m
//  Croak
//
//  Created by JIAO on 2026/7/29.
//

#import "Croak_MessageChatCell.h"
#import "Croak_API.h"
#import "UIImageView+WebCache.h"

@implementation Croak_MessageChatCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = UIColor.clearColor;
    self.contentView.backgroundColor = UIColor.clearColor;

    self.croak_avatarImageView.layer.cornerRadius = 20.0;
    self.croak_avatarImageView.layer.masksToBounds = YES;

    self.croak_bubbleImageView.backgroundColor = [UIColor colorWithRed:0.835 green:0.969 blue:0.345 alpha:1.0];
    self.croak_bubbleImageView.layer.cornerRadius = 14.0;
    self.croak_bubbleImageView.layer.masksToBounds = YES;

    self.croak_messageLabel.numberOfLines = 1;
    self.croak_messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)croak_configureWithMessage:(NSString *)message avatarName:(NSString *)avatarName {
    [self croak_configureWithMessage:message avatarName:avatarName outgoing:NO];
}

- (void)croak_configureWithMessage:(NSString *)message
                         avatarName:(NSString *)avatarName
                           outgoing:(BOOL)outgoing {
    self.croak_messageLabel.text = message;
    self.croak_bubbleImageView.backgroundColor = outgoing ? [UIColor colorWithRed:0.835 green:0.969 blue:0.345 alpha:1.0] : [UIColor colorWithRed:0.947 green:0.947 blue:0.960 alpha:1.0];
    self.croak_messageLabel.textColor = [UIColor colorWithRed:0.082 green:0.090 blue:0.153 alpha:1.0];
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

@end
