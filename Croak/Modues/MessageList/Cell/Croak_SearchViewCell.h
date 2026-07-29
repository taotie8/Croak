//
//  Croak_SearchViewCell.h
//  Croak
//
//  Created by JIAO on 2026/7/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Croak_SearchViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *croak_avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *croak_nameLabel;

- (void)croak_configureWithName:(NSString *)name
                           time:(NSString *)time
                        message:(NSString *)message
                     avatarName:(NSString *)avatarName;

@end

NS_ASSUME_NONNULL_END
