
#import "AppDelegate.h"
#import "Croak_ViewController.h"
#import "SVProgressHUD.h"
#import "Croak_TabBarController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [SVProgressHUD setMaximumDismissTimeInterval:1.5];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
<<<<<<< HEAD
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[Croak_ViewController alloc] init]];
=======
    self.window.rootViewController = [Croak_TabBarController new];//[[UINavigationController alloc] initWithRootViewController:[[Croak_ViewController alloc] init]];
>>>>>>> 6cdc69dfae03157684f1b27d2fdecd58bb3d2ffe
    [self.window makeKeyAndVisible];
    return YES;
}

@end
