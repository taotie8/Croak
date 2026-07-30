
#import "Croak_DiamondsVC.h"
#import "Croak_DiamondsCell.h"

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
    self.croak_diamondsLabel.text = @"1000";

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


@end
