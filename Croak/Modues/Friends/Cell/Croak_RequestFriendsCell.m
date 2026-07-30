
#import "Croak_RequestFriendsCell.h"

@implementation Croak_RequestFriendsCell

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

- (IBAction)croak_addFriendAction:(id)sender {
    
}

- (void)croak_configureWithName:(NSString *)name avatarName:(NSString *)avatarName {
    self.croak_nameLabel.text = name;
    self.croak_avatarImageView.image = [UIImage imageNamed:avatarName];
}

@end
