#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Croak_UserSession : NSObject

@property (class, nonatomic, copy, nullable) NSString *croak_accessToken;
@property (class, nonatomic, copy, nullable) NSString *croak_currentAccount;

+ (BOOL)croak_isLoggedIn;
+ (void)croak_clearSession;
+ (BOOL)croak_hasCompletedRequiredProfileForAccount:(nullable NSString *)account;
+ (void)croak_setCompletedRequiredProfile:(BOOL)completed forAccount:(nullable NSString *)account;

@end

NS_ASSUME_NONNULL_END
