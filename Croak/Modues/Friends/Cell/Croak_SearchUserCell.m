
#import "Croak_SearchUserCell.h"

@implementation Croak_SearchUserCell

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

- (void)croak_configureWithName:(NSString *)name
                            age:(NSString *)age
                         userId:(NSString *)userId
                     avatarName:(NSString *)avatarName {
    self.croak_nameLabel.text = name;
    self.croak_ageLabel.text = age;
    self.croak_userIdLabel.text = userId;
    self.croak_avatarImageView.image = [UIImage imageNamed:avatarName];
}

@end
