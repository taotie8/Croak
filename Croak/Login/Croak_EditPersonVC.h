//
//  Croak_EditPersonVC.h
//  Croak
//
//  Created by Mac on 2026/7/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Croak_EditPersonVC : UIViewController

@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *croak_userInfo;
@property (nonatomic, assign) BOOL croak_returnToPreviousPageAfterSave;

@end

NS_ASSUME_NONNULL_END
