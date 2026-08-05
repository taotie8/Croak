//
//  Croak_SquareCommentCell.h
//  Croak
//
//  Created by JIAO on 2026/7/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Croak_SquareCommentCell : UITableViewCell

- (void)croak_configureWithName:(NSString *)name
                         content:(NSString *)content
                            time:(NSString *)time
                      avatarName:(NSString *)avatarName;

@end

NS_ASSUME_NONNULL_END
