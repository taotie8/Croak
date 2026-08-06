
#import "Croak_DiamondsVC.h"
#import "Croak_AppDataStore.h"
#import "Croak_DiamondsCell.h"
#import "Croak_UserSession.h"
#import "Croak-Swift.h"
#import "SVProgressHUD.h"

static NSString * const CroakDiamondsCellIdentifier = @"Croak_DiamondsCell";
static NSString * const CroakDiamondsCellNibName = @"Croak_DiamondsCell";

@interface Croak_DiamondsVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *croak_headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *croak_titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_diamondsLabel;
@property (weak, nonatomic) IBOutlet UITableView *croak_tableView;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *croak_diamonds;
@property (nonatomic, assign) BOOL croak_isPurchasing;

@end

@implementation Croak_DiamondsVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    self.croak_titleLabel.text = @"Diamonds";
    self.croak_headerImageView.image = [UIImage imageNamed:@"croak_header"];
    self.croak_diamondsLabel.text = @"0";

    self.croak_diamonds = @[
        @{@"amount": @"50", @"price": @"$0.99", @"productId": @"uckpsjjkeafvnzsr"},
        @{@"amount": @"110", @"price": @"$1.99", @"productId": @"wfppvhdtwxkpucnu"},
        @{@"amount": @"300", @"price": @"$4.99", @"productId": @"jtbodclawvdrrkzq"},
        @{@"amount": @"650", @"price": @"$9.99", @"productId": @"zvwuvnsfwxjutwkl"},
        @{@"amount": @"1400", @"price": @"$19.99", @"productId": @"hzlqlfftsnomymai"},
        @{@"amount": @"2150", @"price": @"$29.99", @"productId": @"fkwpznqvhdxjrlme"},
        @{@"amount": @"3800", @"price": @"$49.99", @"productId": @"gjgdmzzfmgwllrqh"},
        @{@"amount": @"5600", @"price": @"$69.99", @"productId": @"qmxkzvptlhrwajdc"},
        @{@"amount": @"8000", @"price": @"$99.99", @"productId": @"ymzqfwyqwqfpbmlv"}
    ];

    [self.croak_tableView registerNib:[UINib nibWithNibName:CroakDiamondsCellNibName bundle:[NSBundle mainBundle]]
                forCellReuseIdentifier:CroakDiamondsCellIdentifier];
    self.croak_tableView.delegate = self;
    self.croak_tableView.dataSource = self;
    self.croak_tableView.rowHeight = 60.0;
    self.croak_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.croak_tableView reloadData];
    [self croak_loadStoreProducts];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self croak_loadDiamonds];
}

- (IBAction)croak_backAction:(id)sender {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.croak_diamonds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Croak_DiamondsCell *cell = [tableView dequeueReusableCellWithIdentifier:CroakDiamondsCellIdentifier];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:CroakDiamondsCellNibName owner:nil options:nil].firstObject;
    }

    NSDictionary<NSString *, id> *diamondsInfo = self.croak_diamonds[indexPath.row];
    [cell croak_configureWithAmount:[self croak_trimmedString:diamondsInfo[@"amount"]]
                               price:[self croak_trimmedString:diamondsInfo[@"price"]]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row >= self.croak_diamonds.count || self.croak_isPurchasing) {
        return;
    }

    NSDictionary<NSString *, id> *diamondsInfo = self.croak_diamonds[indexPath.row];
    NSString *productIdentifier = [self croak_trimmedString:diamondsInfo[@"productId"]];
    if (productIdentifier.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"Product is not available."];
        return;
    }

    [self croak_purchaseProductIdentifier:productIdentifier
                          fallbackAmount:[[self croak_trimmedString:diamondsInfo[@"amount"]] integerValue]];
}

- (void)croak_loadStoreProducts {
    [[Croak_StoreKitPurchaseManager croak_sharedManager] croak_fetchProductIdentifiers:[self croak_productIdentifiers]
                                                                            completion:^(NSArray<Croak_StoreKitPurchaseProduct *> *products, NSError *error) {
        if (error || products.count == 0) {
            return;
        }

        NSMutableDictionary<NSString *, Croak_StoreKitPurchaseProduct *> *productsByIdentifier = [NSMutableDictionary dictionary];
        for (Croak_StoreKitPurchaseProduct *product in products) {
            if (product.croak_productIdentifier.length > 0) {
                productsByIdentifier[product.croak_productIdentifier] = product;
            }
        }

        NSMutableArray<NSDictionary<NSString *, id> *> *updatedDiamonds = [NSMutableArray arrayWithCapacity:self.croak_diamonds.count];
        for (NSDictionary<NSString *, id> *diamondsInfo in self.croak_diamonds) {
            NSMutableDictionary<NSString *, id> *updatedInfo = [diamondsInfo mutableCopy];
            NSString *productIdentifier = [self croak_trimmedString:diamondsInfo[@"productId"]];
            Croak_StoreKitPurchaseProduct *product = productsByIdentifier[productIdentifier];
            if (product.croak_displayPrice.length > 0) {
                updatedInfo[@"price"] = product.croak_displayPrice;
            }
            [updatedDiamonds addObject:updatedInfo];
        }

        self.croak_diamonds = updatedDiamonds;
        [self.croak_tableView reloadData];
    }];
}

- (NSArray<NSString *> *)croak_productIdentifiers {
    NSMutableArray<NSString *> *productIdentifiers = [NSMutableArray arrayWithCapacity:self.croak_diamonds.count];
    for (NSDictionary<NSString *, id> *diamondsInfo in self.croak_diamonds) {
        NSString *productIdentifier = [self croak_trimmedString:diamondsInfo[@"productId"]];
        if (productIdentifier.length > 0) {
            [productIdentifiers addObject:productIdentifier];
        }
    }
    return productIdentifiers;
}

- (void)croak_purchaseProductIdentifier:(NSString *)productIdentifier fallbackAmount:(NSInteger)fallbackAmount {
    NSString *account = [self croak_trimmedString:Croak_UserSession.croak_currentAccount];
    if (account.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"Please log in first."];
        return;
    }

    self.croak_isPurchasing = YES;
    [SVProgressHUD showWithStatus:@"Purchasing..."];
    [[Croak_StoreKitPurchaseManager croak_sharedManager] croak_purchaseProductIdentifier:productIdentifier
                                                                              completion:^(Croak_StoreKitPurchaseResult *purchaseResult, NSError *error) {
        if (error) {
            self.croak_isPurchasing = NO;
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }
        if (!purchaseResult) {
            self.croak_isPurchasing = NO;
            [SVProgressHUD dismiss];
            return;
        }

        NSInteger diamonds = fallbackAmount;
        [SVProgressHUD showWithStatus:@"Saving..."];
        [[Croak_AppDataStore sharedStore] croak_addDiamonds:diamonds
                                                    account:account
                                                 completion:^(NSDictionary<NSString *,id> *userInfo, NSError *saveError) {
            if (saveError) {
                self.croak_isPurchasing = NO;
                [SVProgressHUD showErrorWithStatus:saveError.localizedDescription];
                return;
            }

            [[Croak_StoreKitPurchaseManager croak_sharedManager] croak_finishTransactionIdentifier:purchaseResult.croak_transactionIdentifier
                                                                                        completion:^(NSError *finishError) {
                self.croak_isPurchasing = NO;
                [self croak_updateDiamonds];
                if (finishError) {
                    [SVProgressHUD showErrorWithStatus:finishError.localizedDescription];
                    return;
                }
                [SVProgressHUD showSuccessWithStatus:@"Purchase successful."];
            }];
        }];
    }];
}

- (void)croak_loadDiamonds {
    if ([Croak_AppDataStore sharedStore].croak_isLoaded) {
        [self croak_updateDiamonds];
        return;
    }

    [SVProgressHUD showWithStatus:@"Loading..."];
    [[Croak_AppDataStore sharedStore] croak_fetchAllDataWithCompletion:^(NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        [self croak_updateDiamonds];
    }];
}

- (void)croak_updateDiamonds {
    NSDictionary<NSString *, id> *userInfo = [[Croak_AppDataStore sharedStore] croak_currentUserInfo];
    NSString *diamonds = [self croak_trimmedString:userInfo[@"yin"]];
    self.croak_diamondsLabel.text = diamonds.length > 0 ? diamonds : @"0";
}

- (NSString *)croak_trimmedString:(id)value {
    if ([value isKindOfClass:NSString.class]) {
        return [value stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    }
    if ([value isKindOfClass:NSNumber.class]) {
        return [[value stringValue] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    }
    return @"";
}

@end
