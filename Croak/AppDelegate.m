
#import "AppDelegate.h"
#import "Croak_ViewController.h"
#import "SVProgressHUD.h"
#import "Croak_TabBarController.h"
#import "Croak_UserSession.h"

static NSString * const CroakRemoteNotificationDeviceTokenKey = @"CroakRemoteNotificationDeviceToken";

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [SVProgressHUD setMaximumDismissTimeInterval:1.5];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    NSString *currentAccount = Croak_UserSession.croak_currentAccount;
    if (currentAccount.length > 0 &&
        [Croak_UserSession croak_hasCompletedRequiredProfileForAccount:currentAccount]) {
        self.window.rootViewController = [[Croak_TabBarController alloc] init];
    } else {
        if (currentAccount.length > 0) {
            [Croak_UserSession croak_clearSession];
        }
        self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[Croak_ViewController alloc] init]];
    }
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
}

@end
