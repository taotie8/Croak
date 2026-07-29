
#import "Croak_MessageImageCell.h"

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
    self.croak_contentImageView.image = [UIImage imageNamed:imageName];
    self.croak_avatarImageView.image = [UIImage imageNamed:avatarName];
}

@end
