
#import "AppDelegate.h"
#import "Croak_ViewController.h"
#import "SVProgressHUD.h"
#import "Croak_TabBarController.h"
#import "Croak_UserSession.h"
#import <UserNotifications/UserNotifications.h>

static NSString * const CroakRemoteNotificationDeviceTokenKey = @"CroakRemoteNotificationDeviceToken";

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [SVProgressHUD setMaximumDismissTimeInterval:1.5];
    [self croak_registerForRemoteNotifications];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    if (Croak_UserSession.croak_currentAccount.length > 0) {
        self.window.rootViewController = [[Croak_TabBarController alloc] init];
    } else {
        self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[Croak_ViewController alloc] init]];
    }
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)croak_registerForRemoteNotifications {
    UNUserNotificationCenter *notificationCenter = UNUserNotificationCenter.currentNotificationCenter;
    notificationCenter.delegate = self;
    UNAuthorizationOptions options = UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound;
    [notificationCenter requestAuthorizationWithOptions:options
                                      completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (error) {
#if DEBUG
            NSLog(@"\n[Croak Remote Notification]\nauthorizationError: %@", error.localizedDescription);
#endif
            return;
        }

        if (!granted) {
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication.sharedApplication registerForRemoteNotifications];
        });
    }];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    const unsigned char *deviceTokenBytes = deviceToken.bytes;
    NSMutableString *deviceTokenString = [NSMutableString stringWithCapacity:deviceToken.length * 2];
    for (NSUInteger index = 0; index < deviceToken.length; index++) {
        [deviceTokenString appendFormat:@"%02x", deviceTokenBytes[index]];
    }

    [NSUserDefaults.standardUserDefaults setObject:deviceTokenString
                                            forKey:CroakRemoteNotificationDeviceTokenKey];
#if DEBUG
    NSLog(@"\n[Croak Remote Notification]\ndeviceToken: %@", deviceTokenString);
#endif
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
#if DEBUG
    NSLog(@"\n[Croak Remote Notification]\nregisterError: %@", error.localizedDescription);
#endif
}

@end
