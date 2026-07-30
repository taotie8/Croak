
#import "Croak_SearchUserVC.h"
#import "Croak_SearchUserCell.h"

static NSString * const CroakSearchUserCellIdentifier = @"Croak_SearchUserCell";
static NSString * const CroakSearchUserCellNibName = @"Croak_SearchUserCell";

@interface Croak_SearchUserVC () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *croak_titleLabel;
@property (weak, nonatomic) IBOutlet UIView *croak_searchContentView;
@property (weak, nonatomic) IBOutlet UITextField *croak_searchTextField;
@property (weak, nonatomic) IBOutlet UITableView *croak_tableView;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSString *> *> *croak_users;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSString *> *> *croak_filterUsers;

@end

@implementation Croak_SearchUserVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    self.croak_titleLabel.text = @"Add Friend";

    self.croak_searchContentView.layer.cornerRadius = 8.0;
    self.croak_searchContentView.layer.masksToBounds = YES;
    self.croak_searchTextField.delegate = self;
    [self.croak_searchTextField addTarget:self
                                   action:@selector(croak_searchTextDidChange:)
                         forControlEvents:UIControlEventEditingChanged];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(croak_dismissKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];

    self.croak_users = @[
        @{@"name": @"Ava", @"age": @"23", @"userId": @"123456", @"avatar": @"croak_avatar"},
        @{@"name": @"Mia", @"age": @"21", @"userId": @"234567", @"avatar": @"croak_avatar"},
        @{@"name": @"Leo", @"age": @"25", @"userId": @"345678", @"avatar": @"croak_avatar"},
        @{@"name": @"Noah", @"age": @"24", @"userId": @"456789", @"avatar": @"croak_avatar"}
    ];
    self.croak_filterUsers = self.croak_users;

    [self.croak_tableView registerNib:[UINib nibWithNibName:CroakSearchUserCellNibName bundle:[NSBundle mainBundle]]
                forCellReuseIdentifier:CroakSearchUserCellIdentifier];
    self.croak_tableView.delegate = self;
    self.croak_tableView.dataSource = self;
    self.croak_tableView.rowHeight = 68.0;
    self.croak_tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.croak_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.croak_tableView reloadData];
}

- (IBAction)croak_backAction:(id)sender {
    [self.view endEditing:YES];
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)croak_searchAction:(id)sender {
    [self.view endEditing:YES];
    [self croak_filterWithKeyword:self.croak_searchTextField.text];
}

- (void)croak_searchTextDidChange:(UITextField *)textField {
    [self croak_filterWithKeyword:textField.text];
}

- (void)croak_filterWithKeyword:(NSString *)keyword {
    NSString *searchText = [keyword stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (searchText.length == 0) {
        self.croak_filterUsers = self.croak_users;
        [self.croak_tableView reloadData];
        return;
    }

    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary<NSString *, NSString *> *userInfo, NSDictionary *bindings) {
        NSString *name = userInfo[@"name"];
        NSString *userId = userInfo[@"userId"];
        return [name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ||
               [userId rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound;
    }];
    self.croak_filterUsers = [self.croak_users filteredArrayUsingPredicate:predicate];
    [self.croak_tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.croak_filterUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Croak_SearchUserCell *cell = [tableView dequeueReusableCellWithIdentifier:CroakSearchUserCellIdentifier];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:CroakSearchUserCellNibName owner:nil options:nil].firstObject;
    }

    NSDictionary<NSString *, NSString *> *userInfo = self.croak_filterUsers[indexPath.row];
    [cell croak_configureWithName:userInfo[@"name"]
                              age:userInfo[@"age"]
                           userId:userInfo[@"userId"]
                       avatarName:userInfo[@"avatar"]];
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self croak_searchAction:textField];
    return YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.croak_searchTextField]) {
        return NO;
    }
    return YES;
}

- (void)croak_dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


@end
