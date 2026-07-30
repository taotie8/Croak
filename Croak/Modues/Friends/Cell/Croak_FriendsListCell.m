//
//  Croak_FriendsListCell.m
//  Croak
//
//  Created by JIAO on 2026/7/30.
//

#import "Croak_FriendsListCell.h"

@implementation Croak_FriendsListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = UIColor.clearColor;
    self.contentView.backgroundColor = UIColor.clearColor;
    self.croak_avatarImageView.layer.cornerRadius = 24.0;
    self.croak_avatarImageView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)croak_configureWithName:(NSString *)name avatarName:(NSString *)avatarName {
    self.croak_nameLabel.text = name;
    self.croak_avatarImageView.image = [UIImage imageNamed:avatarName];
}

@end
