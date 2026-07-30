
#import "Croak_SquareTableViewCell.h"

@implementation Croak_SquareTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = UIColor.clearColor;
    self.contentView.backgroundColor = UIColor.clearColor;
    self.croak_avatarImageView.layer.cornerRadius = 24.0;
    self.croak_avatarImageView.layer.masksToBounds = YES;
    self.croak_postImageView.layer.cornerRadius = 16.0;
    self.croak_postImageView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (IBAction)croak_moreAction:(id)sender {
    
}

- (IBAction)croak_loveAction:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (void)croak_configureWithName:(NSString *)name
                           time:(NSString *)time
                        content:(NSString *)content
                      imageName:(NSString *)imageName
                     avatarName:(NSString *)avatarName
                      likeCount:(NSString *)likeCount {
    self.croak_nameLabel.text = name;
    self.croak_timeLabel.text = time;
    self.croak_contentLabel.text = content;
    self.croak_likeCountLabel.text = likeCount;
    self.croak_avatarImageView.image = [UIImage imageNamed:avatarName];
    self.croak_postImageView.image = [UIImage imageNamed:imageName];
}

@end
