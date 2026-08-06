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
@property (weak, nonatomic) IBOutlet UIButton *croak_loveButton;
@property (weak, nonatomic) IBOutlet UIButton *croak_moreButton;
@property (nonatomic, copy, nullable) void (^croak_loveActionHandler)(Croak_SquareTableViewCell *cell);
@property (nonatomic, copy, nullable) void (^croak_avatarActionHandler)(Croak_SquareTableViewCell *cell);
@property (nonatomic, copy, nullable) void (^croak_moreActionHandler)(Croak_SquareTableViewCell *cell);

- (void)croak_configureWithName:(NSString *)name
                           time:(NSString *)time
                        content:(NSString *)content
                      imageName:(NSString *)imageName
                     avatarName:(NSString *)avatarName
                      likeCount:(NSString *)likeCount;

- (void)croak_configureWithName:(NSString *)name
                           time:(NSString *)time
                        content:(NSString *)content
                      imageName:(NSString *)imageName
                     avatarName:(NSString *)avatarName
                      likeCount:(NSString *)likeCount
                           liked:(BOOL)liked;

@end

NS_ASSUME_NONNULL_END
