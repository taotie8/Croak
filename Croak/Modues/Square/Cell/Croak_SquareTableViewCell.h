//
//  Croak_SquareTableViewCell.h
//  Croak
//
//  Created by JIAO on 2026/7/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Croak_SquareTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *croak_avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *croak_nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *croak_postImageView;
@property (weak, nonatomic) IBOutlet UILabel *croak_contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_likeCountLabel;

- (void)croak_configureWithName:(NSString *)name
                           time:(NSString *)time
                        content:(NSString *)content
                      imageName:(NSString *)imageName
                     avatarName:(NSString *)avatarName
                      likeCount:(NSString *)likeCount;

@end

NS_ASSUME_NONNULL_END
