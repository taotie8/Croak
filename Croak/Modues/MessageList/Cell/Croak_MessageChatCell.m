//
//  Croak_MessageChatCell.m
//  Croak
//
//  Created by JIAO on 2026/7/29.
//

#import "Croak_MessageChatCell.h"

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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)croak_configureWithMessage:(NSString *)message avatarName:(NSString *)avatarName {
    self.croak_messageLabel.text = message;
    self.croak_avatarImageView.image = [UIImage imageNamed:avatarName];
}

@end
