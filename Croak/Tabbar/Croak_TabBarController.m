#import "Croak_TabBarController.h"
#import "Croak_MessageListVC.h"
#import "Croak_FriendsSquareVC.h"
#import "Croak_FriendsListVC.h"
#import "Croak_MineVC.h"

static UIColor *CroakColorFromHex(NSInteger hex) {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0
                           green:((hex >> 8) & 0xFF) / 255.0
                            blue:(hex & 0xFF) / 255.0
                           alpha:1.0];
}

@class Croak_CustomTabBar;

@protocol Croak_CustomTabBarDelegate <NSObject>

- (void)croak_customTabBar:(Croak_CustomTabBar *)tabBar didSelectIndex:(NSUInteger)index;

@end

@interface Croak_TabBarItemView : UIControl

@property (nonatomic, strong) UIImageView *croak_imageView;
@property (nonatomic, strong) UILabel *croak_titleLabel;
@property (nonatomic, strong) UIImage *croak_normalImage;
@property (nonatomic, strong) UIImage *croak_selectedImage;

- (instancetype)initWithTitle:(NSString *)title
                   normalIcon:(NSString *)normalIcon
                 selectedIcon:(NSString *)selectedIcon;

@end

@implementation Croak_TabBarItemView

- (instancetype)initWithTitle:(NSString *)title
                   normalIcon:(NSString *)normalIcon
                 selectedIcon:(NSString *)selectedIcon {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.accessibilityLabel = title;

        UIImage *normalImage = [UIImage imageNamed:normalIcon];
        UIImage *selectedImage = [UIImage imageNamed:selectedIcon];
        _croak_normalImage = [normalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _croak_selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

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
    [super layoutSubviews];

    CGFloat itemWidth = CGRectGetWidth(self.bounds);
    self.croak_imageView.frame = CGRectMake((itemWidth - 28.0) * 0.5, 9.0, 28.0, 28.0);
    self.croak_titleLabel.frame = CGRectMake(0.0, 41.0, itemWidth, 24.0);
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    self.croak_imageView.image = selected ? self.croak_selectedImage : self.croak_normalImage;
    self.croak_titleLabel.textColor = selected ? CroakColorFromHex(0x171722) : CroakColorFromHex(0xB6B6BC);
    self.croak_titleLabel.font = [UIFont systemFontOfSize:14.0
                                                    weight:selected ? UIFontWeightMedium : UIFontWeightRegular];
}

@end

@interface Croak_CustomTabBar : UIView

@property (nonatomic, weak) id<Croak_CustomTabBarDelegate> delegate;
@property (nonatomic, strong) UIView *croak_backgroundView;
@property (nonatomic, strong) NSArray<Croak_TabBarItemView *> *croak_itemViews;
@property (nonatomic, assign) NSUInteger selectedIndex;

- (instancetype)initWithItems:(NSArray<NSDictionary<NSString *, NSString *> *> *)items;

@end

@implementation Croak_CustomTabBar

- (instancetype)initWithItems:(NSArray<NSDictionary<NSString *, NSString *> *> *)items {
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

        NSMutableArray<Croak_TabBarItemView *> *itemViews = [NSMutableArray arrayWithCapacity:items.count];
        [items enumerateObjectsUsingBlock:^(NSDictionary<NSString *, NSString *> *itemInfo, NSUInteger index, BOOL *stop) {
            Croak_TabBarItemView *itemView = [[Croak_TabBarItemView alloc] initWithTitle:itemInfo[@"title"]
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
    [super layoutSubviews];

    self.croak_backgroundView.frame = self.bounds;
    self.croak_backgroundView.layer.cornerRadius = CGRectGetHeight(self.bounds) * 0.5;

    CGFloat itemWidth = CGRectGetWidth(self.bounds) / MAX(self.croak_itemViews.count, 1);
    [self.croak_itemViews enumerateObjectsUsingBlock:^(Croak_TabBarItemView *itemView, NSUInteger index, BOOL *stop) {
        itemView.frame = CGRectMake(itemWidth * index, 0.0, itemWidth, CGRectGetHeight(self.bounds));
    }];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    _selectedIndex = selectedIndex;

    [self.croak_itemViews enumerateObjectsUsingBlock:^(Croak_TabBarItemView *itemView, NSUInteger index, BOOL *stop) {
        itemView.selected = index == selectedIndex;
    }];
}

- (void)croak_tabItemTapped:(Croak_TabBarItemView *)sender {
    self.selectedIndex = sender.tag;
    [self.delegate croak_customTabBar:self didSelectIndex:sender.tag];
}

@end


@interface Croak_TabBarController () <Croak_CustomTabBarDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) Croak_CustomTabBar *croak_customTabBar;

@end

@implementation Croak_TabBarController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self croak_setupViewControllers];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = CroakColorFromHex(0xF7F7FA);
    self.tabBar.hidden = YES;
    [self croak_setupCustomTabBar];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tabBar.hidden = YES;
    [self.view bringSubviewToFront:self.croak_customTabBar];
    [self croak_updateCustomTabBarForSelectedControllerAnimated:NO];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [super setSelectedIndex:selectedIndex];
    self.croak_customTabBar.selectedIndex = selectedIndex;
    [self.view bringSubviewToFront:self.croak_customTabBar];
    [self croak_updateCustomTabBarForSelectedControllerAnimated:NO];
}

- (NSArray<NSDictionary<NSString *, NSString *> *> *)croak_tabItems {
    return @[
        @{@"title": @"Messages", @"normal": @"croak_message", @"selected": @"croak_message_s"},
        @{@"title": @"Square", @"normal": @"croak_square", @"selected": @"croak_square_s"},
        @{@"title": @"Friends", @"normal": @"croak_friends", @"selected": @"croak_friends_s"},
        @{@"title": @"Me", @"normal": @"croak_me", @"selected": @"croak_me_s"}
    ];
}

- (void)croak_setupViewControllers {
    NSArray<NSDictionary<NSString *, NSString *> *> *items = [self croak_tabItems];

    NSMutableArray<UIViewController *> *viewControllers = [NSMutableArray arrayWithCapacity:items.count];
    for (NSDictionary<NSString *, NSString *> *itemInfo in items) {
        UIViewController *viewController = [self croak_viewControllerWithTitle:itemInfo[@"title"]];
        [viewControllers addObject:viewController];
    }

    self.viewControllers = viewControllers;
    self.selectedIndex = 0;
}

- (void)croak_setupCustomTabBar {
    if (self.croak_customTabBar) {
        return;
    }

    Croak_CustomTabBar *customTabBar = [[Croak_CustomTabBar alloc] initWithItems:[self croak_tabItems]];
    customTabBar.translatesAutoresizingMaskIntoConstraints = NO;
    customTabBar.delegate = self;
    customTabBar.selectedIndex = self.selectedIndex;
    [self.view addSubview:customTabBar];
    self.croak_customTabBar = customTabBar;

    [NSLayoutConstraint activateConstraints:@[
        [customTabBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16.0],
        [customTabBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16.0],
        [customTabBar.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-9.0],
        [customTabBar.heightAnchor constraintEqualToConstant:70.0]
    ]];
}

- (UIViewController *)croak_viewControllerWithTitle:(NSString *)title {
    UIViewController *rootViewController = nil;
    if ([title isEqualToString:@"Messages"]) {
        rootViewController = [[Croak_MessageListVC alloc] init];
    }
    else if ([title isEqualToString:@"Square"]) {
        rootViewController = [[Croak_FriendsSquareVC alloc] init];
    }
    else if ([title isEqualToString:@"Friends"]) {
        rootViewController = [[Croak_FriendsListVC alloc] init];
    }
    else {
        rootViewController = [[Croak_MineVC alloc] init];
    }

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    navigationController.navigationBarHidden = YES;
    navigationController.additionalSafeAreaInsets = UIEdgeInsetsMake(0.0, 0.0, 98.0, 0.0);
    navigationController.delegate = self;
    return navigationController;
}

- (void)croak_customTabBar:(Croak_CustomTabBar *)tabBar didSelectIndex:(NSUInteger)index {
    self.selectedIndex = index;
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    BOOL isRootViewController = viewController == navigationController.viewControllers.firstObject;
    BOOL shouldHideCustomTabBar = !isRootViewController || viewController.hidesBottomBarWhenPushed;
    navigationController.additionalSafeAreaInsets = shouldHideCustomTabBar ? UIEdgeInsetsZero : UIEdgeInsetsMake(0.0, 0.0, 98.0, 0.0);

    if (navigationController == self.selectedViewController) {
        [self croak_setCustomTabBarHidden:shouldHideCustomTabBar animated:animated];
    }
}

- (void)croak_updateCustomTabBarForSelectedControllerAnimated:(BOOL)animated {
    UINavigationController *navigationController = (UINavigationController *)self.selectedViewController;
    if (![navigationController isKindOfClass:UINavigationController.class]) {
        [self croak_setCustomTabBarHidden:NO animated:animated];
        return;
    }

    UIViewController *visibleViewController = navigationController.visibleViewController;
    BOOL isRootViewController = visibleViewController == navigationController.viewControllers.firstObject;
    BOOL shouldHideCustomTabBar = !isRootViewController || visibleViewController.hidesBottomBarWhenPushed;
    navigationController.additionalSafeAreaInsets = shouldHideCustomTabBar ? UIEdgeInsetsZero : UIEdgeInsetsMake(0.0, 0.0, 98.0, 0.0);
    [self croak_setCustomTabBarHidden:shouldHideCustomTabBar animated:animated];
}

- (void)croak_setCustomTabBarHidden:(BOOL)hidden animated:(BOOL)animated {
    if (!self.croak_customTabBar) {
        return;
    }

    if (!hidden) {
        self.croak_customTabBar.hidden = NO;
    }
    self.croak_customTabBar.userInteractionEnabled = !hidden;

    NSTimeInterval duration = animated ? 0.25 : 0.0;
    [UIView animateWithDuration:duration
                     animations:^{
        self.croak_customTabBar.alpha = hidden ? 0.0 : 1.0;
        self.croak_customTabBar.transform = hidden ? CGAffineTransformMakeTranslation(0.0, 90.0) : CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.croak_customTabBar.hidden = hidden;
    }];
}

@end
