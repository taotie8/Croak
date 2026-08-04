
#import "AppDelegate.h"
#import "Croak_ViewController.h"
#import "SVProgressHUD.h"
#import "Croak_TabBarController.h"
#import "Croak_UserSession.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [SVProgressHUD setMaximumDismissTimeInterval:1.5];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    if (Croak_UserSession.croak_currentAccount.length > 0) {
        self.window.rootViewController = [[Croak_TabBarController alloc] init];
    } else {
        self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[Croak_ViewController alloc] init]];
    }
    [self.window makeKeyAndVisible];
    return YES;
}

@end
