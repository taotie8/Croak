//
//  Croak_SearchVC.m
//  Croak
//
//  Created by JIAO on 2026/7/29.
//

#import "Croak_SearchVC.h"
#import "Croak_SearchViewCell.h"
#import "Croak_MessageChatVC.h"

static NSString * const CroakSearchCellIdentifier = @"Croak_SearchViewCell";

@interface Croak_SearchVC () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *croak_titleLabel;
@property (weak, nonatomic) IBOutlet UIView *croak_searchContentView;
@property (weak, nonatomic) IBOutlet UITextField *croak_searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *croak_searchButton;
@property (weak, nonatomic) IBOutlet UITableView *croak_tableView;
@property (weak, nonatomic) IBOutlet UIImageView *croak_emptyImageView;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSString *> *> *croak_friends;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSString *> *> *croak_filterFriends;

@end

@implementation Croak_SearchVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    self.croak_titleLabel.text = @"Search";
    self.croak_searchContentView.layer.cornerRadius = 8.0;
    self.croak_searchContentView.layer.masksToBounds = YES;
    self.croak_searchTextField.delegate = self;
    [self.croak_searchTextField addTarget:self
                                   action:@selector(croak_searchTextDidChange:)
                         forControlEvents:UIControlEventEditingChanged];

    self.croak_friends = @[
        @{@"name": @"Ava", @"time": @"09:30", @"message": @"Check-in done today. Nice!"},
        @{@"name": @"Mia", @"time": @"Yesterday", @"message": @"Welcome to Croak."},
        @{@"name": @"Leo", @"time": @"Mon", @"message": @"Tap to open the chat."},
        @{@"name": @"Noah", @"time": @"Tue", @"message": @"Let us meet later."}
    ];
    self.croak_filterFriends = self.croak_friends;

    [self.croak_tableView registerNib:[UINib nibWithNibName:CroakSearchCellIdentifier bundle:nil]
                forCellReuseIdentifier:CroakSearchCellIdentifier];
    self.croak_tableView.delegate = self;
    self.croak_tableView.dataSource = self;
    self.croak_tableView.rowHeight = 68.0;
    self.croak_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self croak_reloadSearchResult];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.croak_searchTextField becomeFirstResponder];
}

- (IBAction)croak_backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
        self.croak_filterFriends = self.croak_friends;
        [self croak_reloadSearchResult];
        return;
    }

    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary<NSString *, NSString *> *friendInfo, NSDictionary *bindings) {
        NSString *name = friendInfo[@"name"];
        NSString *message = friendInfo[@"message"];
        return [name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ||
               [message rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound;
    }];
    self.croak_filterFriends = [self.croak_friends filteredArrayUsingPredicate:predicate];
    [self croak_reloadSearchResult];
}

- (void)croak_reloadSearchResult {
    BOOL hasResult = self.croak_filterFriends.count > 0;
    self.croak_tableView.hidden = !hasResult;
    self.croak_emptyImageView.hidden = hasResult;
    [self.croak_tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.croak_filterFriends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Croak_SearchViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CroakSearchCellIdentifier
                                                                       forIndexPath:indexPath];
    NSDictionary<NSString *, NSString *> *friendInfo = self.croak_filterFriends[indexPath.row];
    [cell croak_configureWithName:friendInfo[@"name"]
                             time:friendInfo[@"time"]
                          message:friendInfo[@"message"]
                       avatarName:@"croak_avatar"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary<NSString *, NSString *> *friendInfo = self.croak_filterFriends[indexPath.row];
    Croak_MessageChatVC *chatVC = [[Croak_MessageChatVC alloc] init];
    chatVC.croak_name = friendInfo[@"name"];
    chatVC.croak_avatarName = @"croak_avatar";
    chatVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self croak_searchAction:textField];
    return YES;
}

@end
