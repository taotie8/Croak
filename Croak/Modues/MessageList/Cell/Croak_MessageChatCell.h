//
//  Croak_MessageChatCell.h
//  Croak
//
//  Created by JIAO on 2026/7/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Croak_MessageChatCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *croak_avatarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *croak_bubbleImageView;
@property (weak, nonatomic) IBOutlet UILabel *croak_messageLabel;

- (void)croak_configureWithMessage:(NSString *)message avatarName:(NSString *)avatarName;

@end

NS_ASSUME_NONNULL_END
