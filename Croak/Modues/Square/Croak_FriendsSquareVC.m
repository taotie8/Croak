
#import "Croak_FriendsSquareVC.h"
#import "Croak_SquareTableViewCell.h"
#import "Croak_SquareDetailsVC.h"
#import "Croak_PostSquareVC.h"

static NSString * const CroakSquareTableViewCellIdentifier = @"Croak_SquareTableViewCell";

@interface Croak_FriendsSquareVC ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *croak_headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *croak_titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_dayLabel;
@property (weak, nonatomic) IBOutlet UITableView *croak_tableView;

@end

@implementation Croak_FriendsSquareVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.croak_tableView registerNib:[UINib nibWithNibName:CroakSquareTableViewCellIdentifier bundle:nil]
                forCellReuseIdentifier:CroakSquareTableViewCellIdentifier];
    self.croak_tableView.delegate = self;
    self.croak_tableView.dataSource = self;
}

- (IBAction)croak_postAction:(id)sender {
    Croak_PostSquareVC *vc = [Croak_PostSquareVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Croak_SquareTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CroakSquareTableViewCellIdentifier
                                                                       forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Croak_SquareDetailsVC *vc = [Croak_SquareDetailsVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
