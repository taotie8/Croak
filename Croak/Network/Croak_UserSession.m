#import "Croak_UserSession.h"

static NSString * const CroakUserSessionAccessTokenKey = @"CroakUserSessionAccessTokenKey";
static NSString * const CroakUserSessionCurrentAccountKey = @"CroakUserSessionCurrentAccountKey";
static NSString * const CroakUserSessionCompletedProfilePrefix = @"CroakUserSessionCompletedProfile.";

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
    return self.croak_currentAccount.length > 0;
}

+ (void)croak_clearSession {
    self.croak_accessToken = nil;
    self.croak_currentAccount = nil;
}

+ (NSString *)croak_currentAccount {
    return [NSUserDefaults.standardUserDefaults stringForKey:CroakUserSessionCurrentAccountKey];
}

+ (void)setCroak_currentAccount:(NSString *)croak_currentAccount {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    if (croak_currentAccount.length > 0) {
        [defaults setObject:croak_currentAccount forKey:CroakUserSessionCurrentAccountKey];
    } else {
        [defaults removeObjectForKey:CroakUserSessionCurrentAccountKey];
    }
    [defaults synchronize];
}

+ (BOOL)croak_hasCompletedRequiredProfileForAccount:(NSString *)account {
    NSString *profileKey = [self croak_completedProfileKeyForAccount:account];
    if (profileKey.length == 0) {
        return NO;
    }
    return [NSUserDefaults.standardUserDefaults boolForKey:profileKey];
}

+ (void)croak_setCompletedRequiredProfile:(BOOL)completed forAccount:(NSString *)account {
    NSString *profileKey = [self croak_completedProfileKeyForAccount:account];
    if (profileKey.length == 0) {
        return;
    }

    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    if (completed) {
        [defaults setBool:YES forKey:profileKey];
    } else {
        [defaults removeObjectForKey:profileKey];
    }
    [defaults synchronize];
}

+ (NSString *)croak_completedProfileKeyForAccount:(NSString *)account {
    NSString *trimmedAccount = [account isKindOfClass:NSString.class] ? [account stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] : @"";
    if (trimmedAccount.length == 0) {
        return @"";
    }
    return [CroakUserSessionCompletedProfilePrefix stringByAppendingString:[trimmedAccount lowercaseString]];
}

@end
