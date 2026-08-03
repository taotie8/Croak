#import "Croak_UserSession.h"

static NSString * const CroakUserSessionAccessTokenKey = @"CroakUserSessionAccessTokenKey";

@implementation Croak_UserSession

+ (NSString *)croak_accessToken {
    return [NSUserDefaults.standardUserDefaults stringForKey:CroakUserSessionAccessTokenKey];
}

+ (void)setCroak_accessToken:(NSString *)croak_accessToken {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    if (croak_accessToken.length > 0) {
        [defaults setObject:croak_accessToken forKey:CroakUserSessionAccessTokenKey];
    } else {
        [defaults removeObjectForKey:CroakUserSessionAccessTokenKey];
    }
    [defaults synchronize];
}

+ (BOOL)croak_isLoggedIn {
    return self.croak_accessToken.length > 0;
}

+ (void)croak_clearSession {
    self.croak_accessToken = nil;
}

@end
