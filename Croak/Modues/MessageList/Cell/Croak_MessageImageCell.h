//
//  Croak_MessageImageCell.h
//  Croak
//
//  Created by JIAO on 2026/7/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Croak_MessageImageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *croak_avatarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *croak_contentImageView;

- (void)croak_configureWithImageName:(NSString *)imageName avatarName:(NSString *)avatarName;

@end

NS_ASSUME_NONNULL_END
