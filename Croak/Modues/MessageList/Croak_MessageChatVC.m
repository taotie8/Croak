
#import "Croak_MessageChatVC.h"
#import "Croak_MessageChatCell.h"
#import "Croak_MessageImageCell.h"

static NSString * const CroakMessageChatCellIdentifier = @"Croak_MessageChatCell";
static NSString * const CroakMessageImageCellIdentifier = @"Croak_MessageImageCell";
static NSString * const CroakMessageTypeText = @"text";
static NSString * const CroakMessageTypeImage = @"image";

@interface Croak_MessageChatVC () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *croak_nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *croak_avatarImageView;
@property (weak, nonatomic) IBOutlet UIView *croak_inputContentView;
@property (weak, nonatomic) IBOutlet UITextField *croak_inputTextField;
@property (weak, nonatomic) IBOutlet UITableView *croak_tableView;
@property (nonatomic, strong) NSMutableArray<NSDictionary<NSString *, NSString *> *> *croak_messages;

@end

@implementation Croak_MessageChatVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;

    NSString *name = self.croak_name.length > 0 ? self.croak_name : @"Ava";
    NSString *avatarName = self.croak_avatarName.length > 0 ? self.croak_avatarName : @"croak_avatar";
    self.croak_nameLabel.text = name;
    self.croak_avatarImageView.image = [UIImage imageNamed:avatarName];
    self.croak_avatarImageView.layer.cornerRadius = 16.0;
    self.croak_avatarImageView.layer.masksToBounds = YES;

    self.croak_inputContentView.layer.cornerRadius = 8.0;
    self.croak_inputContentView.layer.masksToBounds = YES;
    self.croak_inputTextField.delegate = self;

    self.croak_messages = [@[
        @{@"type": CroakMessageTypeText, @"message": @"Check-in done today. Nice!", @"avatar": avatarName},
        @{@"type": CroakMessageTypeImage, @"image": @"croak_avatar", @"avatar": avatarName},
        @{@"type": CroakMessageTypeText, @"message": @"Welcome to Croak.", @"avatar": avatarName}
    ] mutableCopy];

    [self.croak_tableView registerNib:[UINib nibWithNibName:CroakMessageChatCellIdentifier bundle:nil]
                forCellReuseIdentifier:CroakMessageChatCellIdentifier];
    [self.croak_tableView registerNib:[UINib nibWithNibName:CroakMessageImageCellIdentifier bundle:nil]
                forCellReuseIdentifier:CroakMessageImageCellIdentifier];
    self.croak_tableView.delegate = self;
    self.croak_tableView.dataSource = self;
    self.croak_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (IBAction)croak_backAction:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)croak_callAction:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)croak_sendAction:(id)sender {
    NSString *message = [self.croak_inputTextField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (message.length == 0) {
        return;
    }

    NSString *avatarName = self.croak_avatarName.length > 0 ? self.croak_avatarName : @"croak_avatar";
    [self.croak_messages addObject:@{@"type": CroakMessageTypeText, @"message": message, @"avatar": avatarName}];
    self.croak_inputTextField.text = @"";
    [self croak_reloadAndScrollToBottom];
}

- (IBAction)croak_voiceAction:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)croak_pictureAction:(id)sender {
    NSString *avatarName = self.croak_avatarName.length > 0 ? self.croak_avatarName : @"croak_avatar";
    [self.croak_messages addObject:@{@"type": CroakMessageTypeImage, @"image": @"croak_avatar", @"avatar": avatarName}];
    [self croak_reloadAndScrollToBottom];
}

- (void)croak_reloadAndScrollToBottom {
    [self.croak_tableView reloadData];

    if (self.croak_messages.count == 0) {
        return;
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.croak_messages.count - 1 inSection:0];
    [self.croak_tableView scrollToRowAtIndexPath:indexPath
                                atScrollPosition:UITableViewScrollPositionBottom
                                        animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.croak_messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary<NSString *, NSString *> *messageInfo = self.croak_messages[indexPath.row];
    NSString *type = messageInfo[@"type"];

    if ([type isEqualToString:CroakMessageTypeImage]) {
        Croak_MessageImageCell *cell = [tableView dequeueReusableCellWithIdentifier:CroakMessageImageCellIdentifier
                                                                       forIndexPath:indexPath];
        [cell croak_configureWithImageName:messageInfo[@"image"] avatarName:messageInfo[@"avatar"]];
        return cell;
    }

    Croak_MessageChatCell *cell = [tableView dequeueReusableCellWithIdentifier:CroakMessageChatCellIdentifier
                                                                  forIndexPath:indexPath];
    [cell croak_configureWithMessage:messageInfo[@"message"] avatarName:messageInfo[@"avatar"]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary<NSString *, NSString *> *messageInfo = self.croak_messages[indexPath.row];
    return [messageInfo[@"type"] isEqualToString:CroakMessageTypeImage] ? 88.0 : 80.0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self croak_sendAction:textField];
    return YES;
}

@end
