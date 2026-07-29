//
//  Croak_SearchViewCell.m
//  Croak
//
//  Created by JIAO on 2026/7/29.
//

#import "Croak_SearchViewCell.h"

@implementation Croak_SearchViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.croak_avatarImageView.layer.cornerRadius = 24.0;
    self.croak_avatarImageView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)croak_configureWithName:(NSString *)name
                           time:(NSString *)time
                        message:(NSString *)message
                     avatarName:(NSString *)avatarName {
    self.croak_nameLabel.text = name;
    self.croak_avatarImageView.image = [UIImage imageNamed:avatarName];
}

@end
