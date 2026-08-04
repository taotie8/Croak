
#import "Croak_DiamondsVC.h"
#import "Croak_AppDataStore.h"
#import "Croak_DiamondsCell.h"
#import "SVProgressHUD.h"

static NSString * const CroakDiamondsCellIdentifier = @"Croak_DiamondsCell";
static NSString * const CroakDiamondsCellNibName = @"Croak_DiamondsCell";

@interface Croak_DiamondsVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *croak_headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *croak_titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_diamondsLabel;
@property (weak, nonatomic) IBOutlet UITableView *croak_tableView;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSString *> *> *croak_diamonds;

@end

@implementation Croak_DiamondsVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    self.croak_titleLabel.text = @"Diamonds";
    self.croak_headerImageView.image = [UIImage imageNamed:@"croak_header"];
    self.croak_diamondsLabel.text = @"0";

    self.croak_diamonds = @[
        @{@"amount": @"60", @"price": @"$0.99"},
        @{@"amount": @"300", @"price": @"$4.99"},
        @{@"amount": @"680", @"price": @"$9.99"},
        @{@"amount": @"1280", @"price": @"$19.99"},
        @{@"amount": @"3280", @"price": @"$49.99"}
    ];

    [self.croak_tableView registerNib:[UINib nibWithNibName:CroakDiamondsCellNibName bundle:[NSBundle mainBundle]]
                forCellReuseIdentifier:CroakDiamondsCellIdentifier];
    self.croak_tableView.delegate = self;
    self.croak_tableView.dataSource = self;
    self.croak_tableView.rowHeight = 60.0;
    self.croak_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.croak_tableView reloadData];
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

    NSDictionary<NSString *, NSString *> *diamondsInfo = self.croak_diamonds[indexPath.row];
    [cell croak_configureWithAmount:diamondsInfo[@"amount"] price:diamondsInfo[@"price"]];
    return cell;
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
