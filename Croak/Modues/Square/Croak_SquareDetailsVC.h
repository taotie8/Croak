//
//  Croak_SquareDetailsVC.h
//  Croak
//
//  Created by JIAO on 2026/7/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Croak_SquareDetailsVC : UIViewController

@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *croak_postItem;
@property (nonatomic, copy, nullable) void (^croak_postUpdateHandler)(NSDictionary<NSString *, id> *postInfo);
@property (nonatomic, copy, nullable) void (^croak_postDeleteHandler)(void);
@property (nonatomic, copy, nullable) void (^croak_userBlockHandler)(NSString *userId);

@end

NS_ASSUME_NONNULL_END
