
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString * const CroakPrivacyPolicyURLString;
FOUNDATION_EXPORT NSString * const CroakUserAgreementURLString;

@interface Croak_AgreementLinks : NSObject

+ (void)croak_openPrivacyPolicyFromViewController:(UIViewController *)viewController;
+ (void)croak_openUserAgreementFromViewController:(UIViewController *)viewController;
+ (void)croak_openURLString:(NSString *)URLString fromViewController:(UIViewController *)viewController;

@end
