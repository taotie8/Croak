//
//  Croak_SearchUserCell.h
//  Croak
//
//  Created by JIAO on 2026/7/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Croak_SearchUserCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *croak_avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *croak_nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_userIdLabel;
@property (weak, nonatomic) IBOutlet UIButton *croak_addButton;
@property (nonatomic, copy, nullable) void (^croak_addFriendHandler)(void);

- (void)croak_configureWithName:(NSString *)name
                            age:(NSString *)age
                         userId:(NSString *)userId
                     avatarName:(NSString *)avatarName
                     buttonText:(NSString *)buttonText
                  buttonEnabled:(BOOL)buttonEnabled;

@end

NS_ASSUME_NONNULL_END
