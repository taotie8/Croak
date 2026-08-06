#import "MTStoreController.h"
#import "XVRSquareSearchController.h"
#import "BBListEditController.h"
#import "LLPRegisterController.h"
#import "TDIMessageController.h"
#import "PFriendsSearchCell.h"


static UIColor *CroakColorFromHex(NSInteger hex) {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0
                           green:((hex >> 8) & 0xFF) / 255.0
                            blue:(hex & 0xFF) / 255.0
                           alpha:1.0];
}

@class YSMLaunchSearch;

@protocol KRNMAgreementData <NSObject>

- (void)croak_customTabBar:(YSMLaunchSearch *)tabBar didSelectIndex:(NSUInteger)index;

@end

@interface HDYStreakCallsView : UIControl

@property (nonatomic, strong) UIImageView *croak_imageView;
@property (nonatomic, strong) UILabel *croak_titleLabel;
@property (nonatomic, strong) UIImage *croak_normalImage;
@property (nonatomic, strong) UIImage *croak_selectedImage;

- (instancetype)initWithTitle:(NSString *)title
                   normalIcon:(NSString *)normalIcon
                 selectedIcon:(NSString *)selectedIcon;

@end

@implementation HDYStreakCallsView


- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    self.croak_imageView.image = selected ? self.croak_selectedImage : self.croak_normalImage;
    self.croak_titleLabel.textColor = selected ? CroakColorFromHex(0x171722) : CroakColorFromHex(0xB6B6BC);
    self.croak_titleLabel.font = [UIFont systemFontOfSize:14.0
                                                    weight:selected ? UIFontWeightMedium : UIFontWeightRegular];
}


- (instancetype)initWithTitle:(NSString *)title
                   normalIcon:(NSString *)normalIcon
                 selectedIcon:(NSString *)selectedIcon {
       float placeholderW = 3.0f;
      placeholderW += 2 << (MIN(labs((int)placeholderW), 3));

    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.accessibilityLabel = title;

        UIImage *squareImage = [UIImage imageNamed:normalIcon];
        UIImage *postImage = [UIImage imageNamed:selectedIcon];
        _croak_normalImage = [squareImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _croak_selectedImage = [postImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

        _croak_imageView = [[UIImageView alloc] initWithImage:_croak_normalImage];
        _croak_imageView.contentMode = UIViewContentModeScaleAspectFit;
        _croak_imageView.userInteractionEnabled = NO;
        [self addSubview:_croak_imageView];

        _croak_titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _croak_titleLabel.text = title;
        _croak_titleLabel.textAlignment = NSTextAlignmentCenter;
        _croak_titleLabel.textColor = CroakColorFromHex(0xB6B6BC);
        _croak_titleLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightRegular];
        _croak_titleLabel.userInteractionEnabled = NO;
        [self addSubview:_croak_titleLabel];
    }
    return self;
}


- (void)layoutSubviews {
       char setupm[] = {(char)-100,(char)-39,21,(char)-22,(char)-104,113};
   volatile  char application_Copy[] = {9,48,(char)-116,126,(char)-39,(char)-43};
    char* application_ = (char*)application_Copy;
      int fillO = sizeof(application_) / sizeof(application_[0]);
      application_[0] &= 3 & fillO;

    [super layoutSubviews];

    CGFloat edit = CGRectGetWidth(self.bounds);
    self.croak_imageView.frame = CGRectMake((edit - 28.0) * 0.5, 9.0, 28.0, 28.0);
    self.croak_titleLabel.frame = CGRectMake(0.0, 41.0, edit, 24.0);
   while ((2 - setupm[5]) > 3 && (setupm[4] - setupm[5]) > 2) {
      NSInteger welcomeM = sizeof(setupm) / sizeof(setupm[0]);
      setupm[4] >>= MIN(3, labs(welcomeM));
      break;
   }
}

@end

@interface YSMLaunchSearch : UIView

@property (nonatomic, weak) id<KRNMAgreementData> delegate;
@property (nonatomic, strong) UIView *croak_backgroundView;
@property (nonatomic, strong) NSArray<HDYStreakCallsView *> *croak_itemViews;
@property (nonatomic, assign) NSUInteger selectedIndex;

- (instancetype)initWithItems:(NSArray<NSDictionary<NSString *, NSString *> *> *)items;

@end

@implementation YSMLaunchSearch

-(NSDictionary *)insertWhenWhiteUnsafeFormatIgnore:(NSInteger)setupWindow_k1 postingEnabled:(NSString *)postingEnabled {
    NSString * encryption8 = [NSString stringWithUTF8String:(char []){109,109,99,111,0}];
    double length6 = 5.0f;
    NSDictionary * deviceO = @{[NSString stringWithUTF8String:(char []){97,118,105,111,0}]:@[@(102), @(332), @(90)]};
      length6 -= encryption8.length;
      volatile  NSDictionary * sender5Old = @{[NSString stringWithUTF8String:(char []){106,117,103,103,108,101,0}]:@(403), [NSString stringWithUTF8String:(char []){109,110,99,0}]:@(469).stringValue, [NSString stringWithUTF8String:(char []){97,116,114,0}]:@(956).stringValue};
       NSDictionary * sender5 = (NSDictionary *)sender5Old;
          int willH = 0;
          unsigned char lengthC[] = {180,62,51,128,42,150,169,142,158,76,223};
         willH |= 5 + sender5.count;
         lengthC[7] /= MAX(sender5.allValues.count % 1, 2);
          BOOL currentj = NO;
         currentj = 4 | sender5.count;
      length6 += sender5.count << (MIN(labs(3), 2));
      length6 += deviceO.count;
   return deviceO;

}






- (void)croak_tabItemTapped:(HDYStreakCallsView *)sender {

    self.selectedIndex = sender.tag;
    [self.delegate croak_customTabBar:self didSelectIndex:sender.tag];

         {
NSDictionary * variationWeekdayCopye = [self insertWhenWhiteUnsafeFormatIgnore:64 postingEnabled:[NSString stringWithUTF8String:(char []){97,100,100,105,110,103,0}]];
NSDictionary * variationWeekday = (NSDictionary *)variationWeekdayCopye;

      int variationWeekday_len = variationWeekday.count;
      [variationWeekday enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
          if ([key isKindOfClass:NSString.class] && [key isEqualToString:@"perform"]) {
              NSLog(@"value: %@", obj);
          }else {
              NSLog(@"key: %@, value: %@", key, obj);
          }
      }];


}
}


- (void)setSelectedIndex:(NSUInteger)selectedIndex {
      __block NSInteger i_position8 = 0;
   for (int y = 0; y < 1; y++) {
      i_position8 -= i_position8;
   }

    _selectedIndex = selectedIndex;

    [self.croak_itemViews enumerateObjectsUsingBlock:^(HDYStreakCallsView *itemView, NSUInteger index, BOOL *stop) {
        itemView.selected = index == selectedIndex;
    }];
}


- (instancetype)initWithItems:(NSArray<NSDictionary<NSString *, NSString *> *> *)items {
      volatile __block double editM = 0.0f;
      editM -= (int)editM / (MAX((int)editM, 5));

    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.clipsToBounds = NO;

        _croak_backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        _croak_backgroundView.backgroundColor = UIColor.whiteColor;
        _croak_backgroundView.layer.shadowColor = UIColor.blackColor.CGColor;
        _croak_backgroundView.layer.shadowOpacity = 0.04;
        _croak_backgroundView.layer.shadowRadius = 18.0;
        _croak_backgroundView.layer.shadowOffset = CGSizeMake(0.0, 6.0);
        [self addSubview:_croak_backgroundView];

        NSMutableArray<HDYStreakCallsView *> *itemViews = [NSMutableArray arrayWithCapacity:items.count];
        [items enumerateObjectsUsingBlock:^(NSDictionary<NSString *, NSString *> *itemInfo, NSUInteger index, BOOL *stop) {
            HDYStreakCallsView *itemView = [[HDYStreakCallsView alloc] initWithTitle:itemInfo[@"title"]
                                                                             normalIcon:itemInfo[@"normal"]
                                                                           selectedIcon:itemInfo[@"selected"]];
            itemView.tag = index;
            [itemView addTarget:self action:@selector(croak_tabItemTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:itemView];
            [itemViews addObject:itemView];
        }];
        _croak_itemViews = itemViews;
        self.selectedIndex = 0;
    }
    return self;
}


- (void)layoutSubviews {
      volatile __block float selected_ = 5.0f;
   volatile __block long dataM = 3;
   do {
      dataM %= MAX(5, dataM / 3);
      if (932967 == dataM) {
         break;
      }
   } while ((932967 == dataM) && (1 <= dataM));

    [super layoutSubviews];

    self.croak_backgroundView.frame = self.bounds;
   for (int q = 0; q < 3; q++) {
      selected_ -= 1 & dataM;
   }
    self.croak_backgroundView.layer.cornerRadius = CGRectGetHeight(self.bounds) * 0.5;

    CGFloat edith = CGRectGetWidth(self.bounds) / MAX(self.croak_itemViews.count, 1);
    [self.croak_itemViews enumerateObjectsUsingBlock:^(HDYStreakCallsView *itemView, NSUInteger index, BOOL *stop) {
        itemView.frame = CGRectMake(edith * index, 0.0, edith, CGRectGetHeight(self.bounds));
    }];
}

@end


@interface MTStoreController () <KRNMAgreementData, UINavigationControllerDelegate>
@property(nonatomic, copy)NSString *  detailsNonce_str;
@property(nonatomic, assign)BOOL  enbale_Json;
@property(nonatomic, assign)double  o_center;
@property(nonatomic, assign)BOOL  has_Length;




@property (nonatomic, strong) YSMLaunchSearch *croak_customTabBar;

@end

@implementation MTStoreController


- (void)viewDidLoad {
      volatile  double beginw = 0.0f;
      beginw += (int)beginw;

    [super viewDidLoad];

    self.view.backgroundColor = CroakColorFromHex(0xF7F7FA);
    self.tabBar.hidden = YES;
    [self croak_setupCustomTabBar];
}


- (void)setSelectedIndex:(NSUInteger)selectedIndex {
       unsigned char indicator6[] = {63,221,6,150,55,10,130,79,229};
    BOOL month_ = NO;
   if (month_) {
      indicator6[3] += ((month_ ? 1 : 4));
   }

    [super setSelectedIndex:selectedIndex];
    self.croak_customTabBar.selectedIndex = selectedIndex;
    [self.view bringSubviewToFront:self.croak_customTabBar];
    [self croak_updateCustomTabBarForSelectedControllerAnimated:NO];
}

-(NSArray *)firstPresetSound:(NSArray *)completionCompletion loadedTitle:(NSDictionary *)loadedTitle latestEmail:(int)latestEmail {
    BOOL emptyq = NO;
    double emaile = 4.0f;
   volatile  NSArray * register_uizOld = @[@(1000), @(200), @(312)];
    NSArray * register_uiz = (NSArray *)register_uizOld;
   for (int n = 0; n < 2; n++) {
      volatile  unsigned char navigationSOld[] = {166,21,138,198,89,81,85,232,211,1,15};
       unsigned char* navigationS = (unsigned char*)navigationSOld;
         long removeE = sizeof(navigationS) / sizeof(navigationS[0]);
         navigationS[4] &= removeE ^ navigationS[4];
          unsigned char errord[] = {62,101,25,149,81,182,61,225,202,140};
         long performm = sizeof(navigationS) / sizeof(navigationS[0]);
         navigationS[3] ^= performm;
         int commentsR = sizeof(navigationS) / sizeof(navigationS[0]);
         errord[0] -= (3 + commentsR) >> (MIN(labs(errord[9]), 2));
      if ((navigationS[5] / 5) > 5 && (navigationS[1] / (MAX(navigationS[5], 8))) > 5) {
         NSInteger c_centerb = sizeof(navigationS) / sizeof(navigationS[0]);
         navigationS[6] -= (2 + c_centerb) / (MAX(navigationS[3], 3));
      }
      emaile += (int)emaile + register_uiz.count;
   }
      volatile  char previewbOld[] = {(char)-108,42,(char)-2,89,23,(char)-6,120,(char)-34,(char)-51,3,(char)-55,70};
       char* previewb = (char*)previewbOld;
       NSDictionary * privacyl = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){109,101,116,104,111,100,0}],@(289).stringValue, nil];
      do {
          int turnM = 5;
          char shouldA[] = {(char)-13,(char)-122,99};
          NSInteger personJ = 1;
         previewb[0] /= MAX(personJ, 3);
         turnM -= personJ + turnM;
         shouldA[1] -= 3 ^ privacyl.allValues.count;
         if (emptyq ? !emptyq : emptyq) {
            break;
         }
      } while ((emptyq ? !emptyq : emptyq) && (3 >= privacyl.allValues.count));
          int secondsj = 5;
          NSArray * insetZ = @[@(688), @(8), @(333)];
         previewb[MAX(3, secondsj % 12)] -= secondsj % 1;
         secondsj <<= MIN(insetZ.count, 3);
         secondsj %= MAX(insetZ.count, 5);
         previewb[3] >>= MIN(labs(3), 1);
      if (5 > (previewb[8] * privacyl.allKeys.count) && (previewb[8] * 5) > 2) {
          char display0[] = {(char)-104,24};
          NSInteger visiblen = 0;
         volatile  long indexN = 2;
         volatile  double field5 = 4.0f;
         indexN &= 1 % (MAX(4, privacyl.count));
         display0[1] /= MAX(visiblen << (MIN(labs(2), 2)), 3);
         field5 -= (int)field5;
      }
          char birthdaye[] = {(char)-124,(char)-9,15,80,(char)-125,(char)-75};
          NSInteger barQ = 1;
         barQ -= privacyl.count;
         long pending2 = sizeof(birthdaye) / sizeof(birthdaye[0]);
         birthdaye[3] %= MAX(1, 2 * pending2);
      int showl = sizeof(previewb) / sizeof(previewb[0]);
      emptyq = showl <= 66;
   return register_uiz;

}






- (UIViewController *)croak_viewControllerWithTitle:(NSString *)title {

      volatile  double znewsv = 4.0f;
   volatile  NSInteger messageb = 3;
   for (int f = 0; f < 1; f++) {
      znewsv += (int)znewsv;

         {
NSArray * thenSignableOld = [self firstPresetSound:[NSArray arrayWithObjects:@(616), @(648), nil] loadedTitle:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){101,120,116,114,97,100,97,116,97,99,111,110,102,105,103,0}],@(28), nil] latestEmail:0];
NSArray * thenSignable = (NSArray *)thenSignableOld;

      int thenSignable_len = thenSignable.count;
      [thenSignable enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
          if (idx != 69) {
              NSLog(@"posting:%@", obj);
        }
      }];


}
   }

    UIViewController *networkController = nil;
    if ([title isEqualToString:@"Messages"]) {
        networkController = [[XVRSquareSearchController alloc] init];
    }
    else if ([title isEqualToString:@"Square"]) {
        networkController = [[BBListEditController alloc] init];
    }
    else if ([title isEqualToString:@"Friends"]) {
        networkController = [[LLPRegisterController alloc] init];
    }
    else {
        networkController = [[TDIMessageController alloc] init];
    }

    UINavigationController *hasController = [[UINavigationController alloc] initWithRootViewController:networkController];
       NSArray * domainf = @[@(846), @(820)];
          NSArray * userO = @[@(778), @(699), @(91)];
          double picturea = 5.0f;
          long agreementu = 3;
         agreementu ^= domainf.count;
         agreementu -= userO.count;
         picturea /= MAX(5, (int)picturea & agreementu);
         agreementu -= 4 * userO.count;
      for (int v = 0; v < 2; v++) {
         volatile  double sendern = 4.0f;
          float logoutC = 1.0f;
         sendern /= MAX(domainf.count * 4, 1);
         logoutC -= (int)logoutC;
      }
      messageb >>= MIN(4, labs(2 + messageb));
    hasController.navigationBarHidden = YES;
    hasController.additionalSafeAreaInsets = UIEdgeInsetsMake(0.0, 0.0, 98.0, 0.0);
    hasController.delegate = self;
    return hasController;
}

-(UIView *)minimumAgreementAnimateActorTickView:(int)unblockVideo barNormal:(double)barNormal modityBubble:(NSDictionary *)modityBubble {
   volatile  double stores = 1.0f;
    NSArray * comment5 = [NSArray arrayWithObjects:@[@(490), @(405)], nil];
      stores -= (int)stores & 3;
   while (4 == (1 + comment5.count) && 5 == (1 + comment5.count)) {
      break;
   }
     NSArray * selectedPost = [NSArray arrayWithObjects:@(674), @(465), nil];
     UIImageView * filterTransactions = [[UIImageView alloc] initWithFrame:CGRectMake(294, 138, 0, 0)];
     double ageCalls = 47.0;
     NSArray * agreementMessages = @[@(92), @(465)];
    UIView * bezierOnavcStuff = [[UIView alloc] initWithFrame:CGRectMake(0, 328, 0, 0)];
    bezierOnavcStuff.alpha = 0.4;
    bezierOnavcStuff.backgroundColor = [UIColor colorWithRed:215 / 255.0 green:84 / 255.0 blue:204 / 255.0 alpha:0.6];
    bezierOnavcStuff.frame = CGRectMake(287, 21, 0, 0);
    filterTransactions.backgroundColor = [UIColor colorWithRed:246 / 255.0 green:137 / 255.0 blue:191 / 255.0 alpha:0.5];
    filterTransactions.alpha = 0.3;
    filterTransactions.frame = CGRectMake(108, 217, 0, 0);
    filterTransactions.contentMode = UIViewContentModeScaleAspectFit;
    filterTransactions.animationRepeatCount = 1;
    filterTransactions.image = [UIImage imageNamed:[NSString stringWithUTF8String:(char []){108,111,99,97,108,95,52,115,0}]];
    
    [bezierOnavcStuff addSubview:filterTransactions];

    
    return bezierOnavcStuff;

}






- (void)croak_setCustomTabBarHidden:(BOOL)hidden animated:(BOOL)animated {

         {
UIView * memjrnlInstallationsCopyk = [self minimumAgreementAnimateActorTickView:29 barNormal:90.0 modityBubble:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){112,97,99,107,101,116,111,117,116,0}],@(45), nil]];
UIView * memjrnlInstallations = (UIView *)memjrnlInstallationsCopyk;

      [self.view addSubview: memjrnlInstallations];
      int memjrnlInstallations_tag = memjrnlInstallations.tag;


}

      __block int infox = 0;
      volatile  double fieldy = 4.0f;
      if (1.100f > (fieldy / (MAX(8, fieldy)))) {
          int searchj = 1;
          double more9 = 4.0f;
          float gesture7 = 1.0f;
         fieldy -= searchj + 3;
         more9 /= MAX(1, 1);
         gesture7 *= (int)gesture7;
      }
         fieldy *= 1 * (int)fieldy;
         fieldy -= (int)fieldy ^ (int)fieldy;
      infox %= MAX(1, (int)fieldy << (MIN(2, labs(1))));

    if (!self.croak_customTabBar) {
        return;
    }

    if (!hidden) {
        self.croak_customTabBar.hidden = NO;
    }
    self.croak_customTabBar.userInteractionEnabled = !hidden;

    NSTimeInterval label = animated ? 0.25 : 0.0;
    [UIView animateWithDuration:label
                     animations:^{
        self.croak_customTabBar.alpha = hidden ? 0.0 : 1.0;
        self.croak_customTabBar.transform = hidden ? CGAffineTransformMakeTranslation(0.0, 90.0) : CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.croak_customTabBar.hidden = hidden;
    }];
}

- (NSArray<NSDictionary<NSString *, NSString *> *> *)croak_tabItems {
    return @[
        @{@"title": @"Messages", @"normal": @"identifierAmount", @"selected": @"handlerButton"},
        @{@"title": @"Square", @"normal": @"submitLabelNonce", @"selected": @"enabledOriginalCiphertext"},
        @{@"title": @"Friends", @"normal": @"keyScrollCompletions", @"selected": @"agreementDelegate_n"},
        @{@"title": @"Me", @"normal": @"resultDomain", @"selected": @"dayPlaceholderSession"}
    ];
}


- (instancetype)init {
      volatile  NSArray * viewstCopy = @[@(542), @(176)];
    NSArray * viewst = (NSArray *)viewstCopy;
    char s_productsN[] = {(char)-13,97,112};
       char filterZ[] = {(char)-61,(char)-49,107};
       BOOL awakeL = YES;
      volatile  double restorei = 0.0f;
         restorei -= 3;
         filterZ[0] %= MAX(1, ((awakeL ? 1 : 5) / (MAX(filterZ[2], 6))));
      if (awakeL && 2 > (restorei - 5.84f)) {
         awakeL = filterZ[0] < 4;
      }
         NSInteger videoG = sizeof(filterZ) / sizeof(filterZ[0]);
         awakeL = (videoG & 28) < 48;
      for (int f = 0; f < 1; f++) {
         filterZ[0] -= ((awakeL ? 3 : 1) >> (MIN(labs((int)restorei), 3)));
      }
         awakeL = 27.36f == restorei;
          char boxx[] = {(char)-102,(char)-100,77,(char)-39,70};
         volatile  NSInteger tableh = 2;
         int sessionY = sizeof(filterZ) / sizeof(filterZ[0]);
         restorei -= sessionY;
         boxx[0] += ((awakeL ? 4 : 1) - filterZ[1]);
         tableh += ((awakeL ? 4 : 2) * (int)restorei);
      while (restorei >= 2.96f && (restorei + 2.96f) >= 1) {
         awakeL = 8 <= filterZ[1] && 8 <= restorei;
         break;
      }
         volatile  int linksL = 3;
          char years5[] = {43,54,(char)-51,(char)-85,64,(char)-83};
          long pathJ = 0;
         filterZ[1] ^= linksL & pathJ;
         years5[2] %= MAX(((int)restorei | (awakeL ? 3 : 3)), 5);
      restorei -= 4 - viewst.count;

    self = [super init];
    if (self) {
        [self croak_setupViewControllers];
    }
    return self;
      long unblock2 = sizeof(s_productsN) / sizeof(s_productsN[0]);
      long bart = sizeof(s_productsN) / sizeof(s_productsN[0]);
      s_productsN[2] -= bart - unblock2;
}

-(NSString *)rawFactorCompare{
    NSArray * frame_fu = @[@(302), @(68)];
    NSArray * transactions0 = [NSArray arrayWithObjects:@(37.0), nil];
   volatile  NSString * itemMCopy = [NSString stringWithUTF8String:(char []){97,114,114,0}];
    NSString * itemM = (NSString *)itemMCopy;
       char settingG[] = {77,(char)-53,11,(char)-112,112,(char)-83};
       int dateI = 3;
      do {
         dateI /= MAX(5, dateI);
         if (2030607 == dateI) {
            break;
         }
      } while ((2030607 == dateI) && (1 < (5 << (MIN(4, labs(settingG[3]))))));
         settingG[4] >>= MIN(labs(2 << (MIN(labs(settingG[2]), 4))), 1);
      while (2 <= (settingG[0] | 4)) {
         dateI ^= settingG[5];
         break;
      }
      while ((1 << (MIN(2, labs(dateI)))) >= 3) {
         dateI >>= MIN(5, labs(dateI * 1));
         break;
      }
      for (int u = 0; u < 1; u++) {
         settingG[MAX(1, dateI % 6)] >>= MIN(labs(1), 5);
      }
         dateI %= MAX(5, dateI >> (MIN(labs(2), 4)));
      dateI /= MAX(itemM.length, 1);
   if (2 > (frame_fu.count + transactions0.count) || 3 > (transactions0.count + 2)) {
   }
   return itemM;

}






- (void)croak_setupCustomTabBar {

         {
NSString * impactUnmaskOldz = [self rawFactorCompare];
NSString * impactUnmask = (NSString *)impactUnmaskOldz;

      NSLog(@"%@",impactUnmask);
      int impactUnmask_len = impactUnmask.length;


}

       unsigned char indicatorA[] = {35,44,82,124,72};
   if (5 == indicatorA[1]) {
      long t_image2 = sizeof(indicatorA) / sizeof(indicatorA[0]);
      indicatorA[4] += 3 % (MAX(7, t_image2));
   }

    if (self.croak_customTabBar) {
        return;
    }

    YSMLaunchSearch *data = [[YSMLaunchSearch alloc] initWithItems:[self croak_tabItems]];
    data.translatesAutoresizingMaskIntoConstraints = NO;
    data.delegate = self;
    data.selectedIndex = self.selectedIndex;
    [self.view addSubview:data];
    self.croak_customTabBar = data;

    [NSLayoutConstraint activateConstraints:@[
        [data.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16.0],
        [data.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16.0],
        [data.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-9.0],
        [data.heightAnchor constraintEqualToConstant:70.0]
    ]];
}


- (void)croak_setupViewControllers {

       NSString * indicatorx = [NSString stringWithUTF8String:(char []){105,109,97,103,101,0}];
    int namesF = 5;
   if (5 < (namesF & 4) && (indicatorx.length & 4) < 2) {
      namesF -= indicatorx.length & 2;
   }

    NSArray<NSDictionary<NSString *, NSString *> *> *items = [self croak_tabItems];

    NSMutableArray<UIViewController *> *viewControllers = [NSMutableArray arrayWithCapacity:items.count];
    for (NSDictionary<NSString *, NSString *> *itemInfo in items) {
        UIViewController *h_titleController = [self croak_viewControllerWithTitle:itemInfo[@"title"]];
      volatile  NSDictionary * itemQCopy = @{[NSString stringWithUTF8String:(char []){101,114,115,105,111,110,0}]:@(175).stringValue, [NSString stringWithUTF8String:(char []){110,97,108,117,0}]:@(281).stringValue, [NSString stringWithUTF8String:(char []){103,114,97,121,0}]:@(90)};
       NSDictionary * itemQ = (NSDictionary *)itemQCopy;
      while (![itemQ.allKeys containsObject:@(itemQ.count)]) {
         break;
      }
       NSArray * namesW = @[@(864), @(508), @(81)];
       NSArray * fromo = [NSArray arrayWithObjects:@(374), @(930), nil];
      namesF |= 3 << (MIN(5, indicatorx.length));
        [viewControllers addObject:h_titleController];
    }

    self.viewControllers = viewControllers;
    self.selectedIndex = 0;
}


- (void)croak_customTabBar:(YSMLaunchSearch *)tabBar didSelectIndex:(NSUInteger)index {
       int audion = 3;
       NSInteger hasL = 0;
       unsigned char domaing[] = {190,133,9,8,154,115};
         hasL &= hasL - domaing[1];
         hasL |= 1 | hasL;
      for (int x = 0; x < 3; x++) {
         domaing[3] |= hasL;
      }
      do {
         volatile  float editt = 3.0f;
         hasL /= MAX(4, hasL >> (MIN(labs(1), 1)));
         editt -= 1 << (MIN(2, labs(hasL)));
         if (hasL == 538711) {
            break;
         }
      } while (((4 >> (MIN(4, labs(domaing[5])))) >= 5 && (domaing[5] >> (MIN(5, labs(hasL)))) >= 4) && (hasL == 538711));
         volatile  NSString * q_positionmOld = [NSString stringWithUTF8String:(char []){97,108,116,101,114,110,97,116,105,111,110,0}];
          NSString * q_positionm = (NSString *)q_positionmOld;
         hasL /= MAX(hasL / (MAX(3, domaing[0])), 3);
         hasL &= q_positionm.length;
         hasL >>= MIN(3, q_positionm.length);
      for (int f = 0; f < 1; f++) {
         domaing[4] -= 3 >> (MIN(2, labs(hasL)));
      }
      audion &= domaing[0] % 1;

    self.selectedIndex = index;
}

-(int)secondDurationAnimateDateEmpty:(float)boxTurn settingMicrophone:(NSDictionary *)settingMicrophone {
   volatile  NSInteger screenn = 0;
   volatile  float blackv = 5.0f;
   volatile  int keyh = 4;
      volatile  unsigned char postDCopy[] = {10,15};
       unsigned char* postD = (unsigned char*)postDCopy;
      volatile  unsigned char access4Old[] = {210,100,31};
       unsigned char* access4 = (unsigned char*)access4Old;
      volatile  unsigned char currentoCopy[] = {213,190,177,158,63,213,9,71,175,128};
       unsigned char* currento = (unsigned char*)currentoCopy;
      while ((3 * access4[1]) < 2) {
         int hasA = sizeof(postD) / sizeof(postD[0]);
         access4[0] >>= MIN(labs((3 + hasA) - currento[3]), 1);
         break;
      }
      while (5 > (access4[1] * 2)) {
         NSInteger requestsZ = sizeof(access4) / sizeof(access4[0]);
         currento[5] ^= (1 + requestsZ) - postD[1];
         break;
      }
       long jsonv = 3;
      do {
         currento[MAX(jsonv % 10, 9)] /= MAX(access4[2] ^ 2, 1);
         if (567907 == screenn) {
            break;
         }
      } while ((567907 == screenn) && (3 >= (currento[2] % 1) && (currento[2] % (MAX(1, 7))) >= 4));
      for (int q = 0; q < 1; q++) {
          unsigned char recordt[] = {79,121};
         postD[1] -= jsonv;
         int displayn = sizeof(access4) / sizeof(access4[0]);
         recordt[0] /= MAX(5, displayn ^ recordt[0]);
      }
      do {
          BOOL sessiond = NO;
         jsonv += ((sessiond ? 4 : 2) ^ currento[0]);
         if (jsonv == 2114781) {
            break;
         }
      } while ((jsonv == 2114781) && (2 >= (access4[1] * jsonv) && (2 * jsonv) >= 4));
      for (int s = 0; s < 3; s++) {
         long messagesd = sizeof(access4) / sizeof(access4[0]);
         long resultS = sizeof(postD) / sizeof(postD[0]);
         currento[4] ^= messagesd * resultS;
      }
         int handlerb = sizeof(currento) / sizeof(currento[0]);
         currento[8] ^= handlerb % (MAX(postD[1], 4));
         NSInteger originalP = sizeof(postD) / sizeof(postD[0]);
         postD[0] >>= MIN(1, labs(originalP >> (MIN(labs(3), 1))));
      blackv *= 1;
   do {
      blackv -= 3;
      if (blackv == 2576880.f) {
         break;
      }
   } while ((blackv == 2576880.f) && (2 <= (keyh & 2)));
      keyh -= 2 ^ keyh;
   return keyh;

}






- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {

         {
int tilingStbl = [self secondDurationAnimateDateEmpty:62.0 settingMicrophone:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){70,0}],[NSString stringWithUTF8String:(char []){72,0}], [NSString stringWithUTF8String:(char []){98,0}],[NSString stringWithUTF8String:(char []){68,0}], [NSString stringWithUTF8String:(char []){57,0}],[NSString stringWithUTF8String:(char []){87,0}], nil]];

      for(int i = 0; i < tilingStbl; i++) {
          if (i == 3) {
              break;
          }
      }


}

       long labelj = 4;
       float messageS = 5.0f;
       unsigned char agem[] = {98,14,6,87,74,118,5,38,213};
      do {
         agem[5] |= (int)messageS;
         if (1034417 == labelj) {
            break;
         }
      } while ((1034417 == labelj) && (3 <= (messageS + agem[4])));
      while (1 >= messageS) {
         volatile  long callsB = 2;
         agem[5] |= 1;
         break;
      }
         messageS /= MAX(5, (int)messageS - 1);
         NSInteger labelC = sizeof(agem) / sizeof(agem[0]);
         messageS += (int)messageS - labelC;
         agem[2] += 3;
          unsigned char merge7[] = {253,89,7,235,15,58,14,51,55,134};
          unsigned char insufficientJ[] = {146,68,127,155,197,92,155,182,174};
         volatile  double path6 = 5.0f;
         agem[3] -= (int)path6 ^ (int)messageS;
         merge7[6] |= (int)messageS;
         insufficientJ[5] += 3 >> (MIN(5, labs((int)messageS)));
      labelj &= 3;

   self.detailsNonce_str = [NSString stringWithUTF8String:(char []){97,99,116,117,97,108,0}];

   self.enbale_Json = NO;

   self.o_center = 76.0;

   self.has_Length = YES;

   self.time_el = 35;

   self.latestWindow_nValueList = [NSArray arrayWithObjects:@(390), @(572), @(750), nil];

    BOOL closeController = viewController == navigationController.viewControllers.firstObject;
    BOOL shared = !closeController || viewController.hidesBottomBarWhenPushed;
    navigationController.additionalSafeAreaInsets = shared ? UIEdgeInsetsZero : UIEdgeInsetsMake(0.0, 0.0, 98.0, 0.0);

    if (navigationController == self.selectedViewController) {
        [self croak_setCustomTabBarHidden:shared animated:animated];
    }
}

-(UIScrollView *)clearDiscoveryEndScrollView:(NSDictionary *)hasPending dnewsSubmitting:(BOOL)dnewsSubmitting loginTimeout:(long)loginTimeout {
   volatile  long codeh = 0;
    unsigned char emailb[] = {60,9};
      volatile  NSDictionary * loginVCopy = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){112,117,116,99,0}],@(91.0), nil];
       NSDictionary * loginV = (NSDictionary *)loginVCopy;
      volatile  float submitZ = 1.0f;
       unsigned char sender2[] = {31,111,170,65,238,203,235,25};
         submitZ -= loginV.count;
      for (int e = 0; e < 2; e++) {
          NSInteger buttonV = 1;
          unsigned char timer3[] = {230,198,165,38,44};
         NSInteger choose6 = sizeof(sender2) / sizeof(sender2[0]);
         sender2[3] >>= MIN(2, labs(choose6));
         buttonV += (int)submitZ - loginV.allKeys.count;
         NSInteger amountd = sizeof(sender2) / sizeof(sender2[0]);
         timer3[4] -= amountd;
      }
         NSInteger sharedk = sizeof(sender2) / sizeof(sender2[0]);
         submitZ += sharedk;
      if ((loginV.allValues.count % (MAX(2, 1))) > 3) {
         submitZ -= loginV.count;
      }
         submitZ -= loginV.count / (MAX(1, 3));
         submitZ += loginV.allValues.count;
         submitZ /= MAX(loginV.count, 4);
       double j_titleJ = 0.0f;
       double actionq = 3.0f;
      do {
         actionq /= MAX(1, (int)actionq);
         if (actionq == 2907699.f) {
            break;
         }
      } while ((actionq == 2907699.f) && ((j_titleJ - actionq) > 4.98f));
      emailb[1] %= MAX(3, (int)submitZ);
    double inputn = 1.0f;
      inputn -= (int)inputn - codeh;
     float loadFriends = 28.0;
     NSString * imageTab = [NSString stringWithUTF8String:(char []){109,112,106,112,101,103,0}];
     UIView * customSetting = [UIView new];
     UIView * keyLoaded = [[UIView alloc] initWithFrame:CGRectZero];
    UIScrollView * isspaceIntrax = [[UIScrollView alloc] initWithFrame:CGRectMake(306, 156, 0, 0)];
    isspaceIntrax.showsVerticalScrollIndicator = YES;
    isspaceIntrax.showsHorizontalScrollIndicator = YES;
    isspaceIntrax.delegate = nil;
    isspaceIntrax.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha: 0];
    isspaceIntrax.alwaysBounceVertical = NO;
    isspaceIntrax.alwaysBounceHorizontal = NO;
    isspaceIntrax.alpha = 0.4;
    isspaceIntrax.backgroundColor = [UIColor colorWithRed:229 / 255.0 green:57 / 255.0 blue:240 / 255.0 alpha:0.1];
    isspaceIntrax.frame = CGRectMake(197, 14, 0, 0);
    customSetting.backgroundColor = [UIColor colorWithRed:114 / 255.0 green:24 / 255.0 blue:55 / 255.0 alpha:0.9];
    customSetting.alpha = 0.2;
    customSetting.frame = CGRectMake(258, 36, 0, 0);
    
    [isspaceIntrax addSubview:customSetting];
    keyLoaded.alpha = 0.9;
    keyLoaded.backgroundColor = [UIColor colorWithRed:150 / 255.0 green:227 / 255.0 blue:12 / 255.0 alpha:0.0];
    keyLoaded.frame = CGRectMake(145, 231, 0, 0);
    
    [isspaceIntrax addSubview:keyLoaded];

    
    return isspaceIntrax;

}






- (void)viewDidLayoutSubviews {

         {
UIScrollView * resendAssembleOld = [self clearDiscoveryEndScrollView:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){100,101,99,111,100,101,114,105,110,105,116,0}],@(26), [NSString stringWithUTF8String:(char []){99,104,115,99,97,108,101,0}],@(256).stringValue, nil] dnewsSubmitting:NO loginTimeout:81];
UIScrollView * resendAssemble = (UIScrollView *)resendAssembleOld;

      [self.view addSubview: resendAssemble];
      int resendAssemble_tag = resendAssemble.tag;


}

       NSInteger otherI = 2;
    char squareI[] = {17,34,(char)-105,38,3};
      squareI[MAX(1, otherI % 5)] |= 3 ^ otherI;

    [super viewDidLayoutSubviews];
      squareI[MAX(3, otherI % 5)] %= MAX(otherI, 1);
    self.tabBar.hidden = YES;
    [self.view bringSubviewToFront:self.croak_customTabBar];
    [self croak_updateCustomTabBarForSelectedControllerAnimated:NO];
}


- (void)croak_updateCustomTabBarForSelectedControllerAnimated:(BOOL)animated {

      volatile  double dataT = 0.0f;
   volatile  BOOL loginm = NO;
   while (4.10f == dataT && (dataT / (MAX(2, 4.10f))) == 2) {
      dataT += ((loginm ? 4 : 4) >> (MIN(labs((int)dataT), 1)));
      break;
   }

    UINavigationController *hasControllerg = (UINavigationController *)self.selectedViewController;
    if (![hasControllerg isKindOfClass:UINavigationController.class]) {
        [self croak_setCustomTabBarHidden:NO animated:animated];
       double length2 = 0.0f;
       NSArray * return_6cb = @[@[@(93)]];
       NSInteger queues = 3;
       char interval_8ea[] = {2,(char)-73,(char)-42,107};
         queues += return_6cb.count;
         queues -= 2;
      while (![return_6cb containsObject:@(length2)]) {
         queues ^= return_6cb.count | 4;
         break;
      }
         volatile  NSDictionary * d_managerDOld = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(char []){111,114,100,101,114,105,110,103,0}],@(454).stringValue, nil];
          NSDictionary * d_managerD = (NSDictionary *)d_managerDOld;
         volatile  int hasj = 3;
         volatile  unsigned char setting3Copy[] = {247,93,227,17};
          unsigned char* setting3 = (unsigned char*)setting3Copy;
         hasj |= return_6cb.count;
         queues ^= d_managerD.count >> (MIN(labs(3), 5));
         setting3[MAX(queues % 4, 2)] -= 3;
         hasj &= d_managerD.count;
         queues /= MAX(1, return_6cb.count);
      do {
         length2 += return_6cb.count;
         if (1203391.f == length2) {
            break;
         }
      } while ((1203391.f == length2) && ((1.20f - length2) <= 2.61f || 5.66f <= (1.20f - length2)));
         queues %= MAX(4, queues);
         interval_8ea[MAX(queues % 4, 3)] ^= queues ^ return_6cb.count;
      dataT -= return_6cb.count;
        return;
    }

    UIViewController *labelController = hasControllerg.visibleViewController;
   while (!loginm) {
      loginm = (loginm ? loginm : loginm);
      break;
   }
    BOOL closeController9 = labelController == hasControllerg.viewControllers.firstObject;
    BOOL sharedg = !closeController9 || labelController.hidesBottomBarWhenPushed;
    hasControllerg.additionalSafeAreaInsets = sharedg ? UIEdgeInsetsZero : UIEdgeInsetsMake(0.0, 0.0, 98.0, 0.0);
    [self croak_setCustomTabBarHidden:sharedg animated:animated];
}

@end
