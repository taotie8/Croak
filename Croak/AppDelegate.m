
#import "AppDelegate.h"
#import "QChatNewsController.h"
#import "SVProgressHUD.h"
#import "MTStoreController.h"
#import "ONSNewsSession.h"
#import "PFriendsSearchCell.h"


static NSString * const CroakRemoteNotificationDeviceTokenKey = @"CroakRemoteNotificationDeviceToken";

@interface AppDelegate ()


@property(nonatomic, copy)NSArray *  titleElapsedIdentifier_arr;
@property(nonatomic, copy)NSString *  diamondsQueryStr;
@property(nonatomic, assign)NSInteger  indicatorMark;
@property(nonatomic, assign)double  preview_margin;


@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
      volatile  char delegate_gnNOld[] = {74,77,(char)-67,(char)-119,115,(char)-18};
    char* delegate_gnN = (char*)delegate_gnNOld;
      NSInteger completef = sizeof(delegate_gnN) / sizeof(delegate_gnN[0]);
      delegate_gnN[3] += completef / (MAX(delegate_gnN[2], 1));

   self.titleElapsedIdentifier_arr = [NSArray arrayWithObjects:@(401), @(677), @(964), nil];

   self.diamondsQueryStr = [NSString stringWithUTF8String:(char []){99,109,121,107,0}];

   self.indicatorMark = 92;

   self.preview_margin = 27.0;

   self.loading_sum = 91;

   self.indexIndex = 95;

   self.has_Screen = YES;

    
    [SVProgressHUD setMaximumDismissTimeInterval:1.5];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    NSString *posts = ONSNewsSession.croak_currentAccount;
    if (posts.length > 0 &&
        [ONSNewsSession croak_hasCompletedRequiredProfileForAccount:posts]) {
        self.window.rootViewController = [[MTStoreController alloc] init];
    } else {
        if (posts.length > 0) {
            [ONSNewsSession croak_clearSession];
        }
        self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[QChatNewsController alloc] init]];
    }
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
       NSArray * messages6 = [NSArray arrayWithObjects:@(1), nil];
   do {
      if (4758183 == messages6.count) {
         break;
      }
   } while ((4758183 == messages6.count) && ((messages6.count % (MAX(6, messages6.count))) == 3 && 3 == (messages6.count % 3)));

    
}

@end
