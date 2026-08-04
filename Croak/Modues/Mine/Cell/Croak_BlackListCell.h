//
//  Croak_BlackListCell.h
//  Croak
//
//  Created by JIAO on 2026/7/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Croak_BlackListCell : UITableViewCell

@property (nonatomic, copy, nullable) void (^croak_unblockActionHandler)(Croak_BlackListCell *cell);

- (void)croak_configureWithUserInfo:(NSDictionary<NSString *, id> *)userInfo;

@end

NS_ASSUME_NONNULL_END
