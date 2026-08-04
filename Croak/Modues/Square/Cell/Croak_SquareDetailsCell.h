//
//  Croak_SquareDetailsCell.h
//  Croak
//
//  Created by JIAO on 2026/7/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Croak_SquareDetailsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *croak_avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *croak_nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *croak_postImageView;
@property (weak, nonatomic) IBOutlet UIButton *croak_loveButton;
@property (weak, nonatomic) IBOutlet UILabel *croak_likeNamesLabel;
@property (nonatomic, copy, nullable) void (^croak_loveActionHandler)(Croak_SquareDetailsCell *cell);
@property (nonatomic, copy, nullable) void (^croak_avatarActionHandler)(Croak_SquareDetailsCell *cell);

- (void)croak_configureWithName:(NSString *)name
                        content:(NSString *)content
                      imageName:(NSString *)imageName
                     avatarName:(NSString *)avatarName
                      likeNames:(NSString *)likeNames
                           liked:(BOOL)liked;

@end

NS_ASSUME_NONNULL_END
