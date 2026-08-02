
#import "Croak_AgreementLinks.h"
#import "SVProgressHUD.h"

NSString * const CroakPrivacyPolicyURLString = @"https://croak.app/privacy-policy";
NSString * const CroakUserAgreementURLString = @"https://croak.app/user-agreement";

@implementation Croak_AgreementLinks

+ (void)croak_openPrivacyPolicyFromViewController:(UIViewController *)viewController {
    [self croak_openURLString:CroakPrivacyPolicyURLString fromViewController:viewController];
}

+ (void)croak_openUserAgreementFromViewController:(UIViewController *)viewController {
    [self croak_openURLString:CroakUserAgreementURLString fromViewController:viewController];
}

+ (void)croak_openURLString:(NSString *)URLString fromViewController:(UIViewController *)viewController {
    NSString *trimmedURLString = [URLString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSURLComponents *components = [NSURLComponents componentsWithString:trimmedURLString];

    if (trimmedURLString.length == 0 ||
        components.scheme.length == 0 ||
        components.host.length == 0 ||
        ![components.scheme.lowercaseString hasPrefix:@"http"]) {
        [SVProgressHUD showErrorWithStatus:@"Link unavailable."];
        return;
    }

    NSURL *URL = components.URL;
    if (!URL) {
        [SVProgressHUD showErrorWithStatus:@"Link unavailable."];
        return;
    }

    UIApplication *application = [UIApplication sharedApplication];
    if (![application canOpenURL:URL]) {
        [SVProgressHUD showErrorWithStatus:@"Cannot open this link."];
        return;
    }

    [application openURL:URL options:@{} completionHandler:^(BOOL success) {
        if (!success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:@"Cannot open this link."];
            });
        }
    }];
}

@end
