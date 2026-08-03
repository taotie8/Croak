#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Croak_UserSession : NSObject

@property (class, nonatomic, copy, nullable) NSString *croak_accessToken;

+ (BOOL)croak_isLoggedIn;
+ (void)croak_clearSession;

@end

NS_ASSUME_NONNULL_END
