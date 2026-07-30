//
//  Croak_FriendsListCell.h
//  Croak
//
//  Created by JIAO on 2026/7/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Croak_FriendsListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *croak_avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *croak_nameLabel;

- (void)croak_configureWithName:(NSString *)name avatarName:(NSString *)avatarName;

@end

NS_ASSUME_NONNULL_END
