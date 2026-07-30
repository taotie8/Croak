
#import "Croak_SquareDetailsVC.h"
#import "Croak_SquareDetailsCell.h"
#import "Croak_SquareCommentCell.h"

static NSString * const CroakSquareDetailsCellIdentifier = @"Croak_SquareDetailsCell";
static NSString * const CroakSquareCommentCellIdentifier = @"Croak_SquareCommentCell";

@interface Croak_SquareDetailsVC () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *croak_tableView;
@property (weak, nonatomic) IBOutlet UIView *croak_inputBarView;
@property (weak, nonatomic) IBOutlet UIView *croak_inputContentView;
@property (weak, nonatomic) IBOutlet UITextField *croak_commentTextField;
@property (nonatomic, assign) UIEdgeInsets croak_originalTableContentInset;
@property (nonatomic, assign) UIEdgeInsets croak_originalTableScrollIndicatorInsets;

@end

@implementation Croak_SquareDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.croak_tableView registerNib:[UINib nibWithNibName:CroakSquareDetailsCellIdentifier bundle:nil]
                forCellReuseIdentifier:CroakSquareDetailsCellIdentifier];
    [self.croak_tableView registerNib:[UINib nibWithNibName:CroakSquareCommentCellIdentifier bundle:nil]
                forCellReuseIdentifier:CroakSquareCommentCellIdentifier];
    self.croak_tableView.delegate = self;
    self.croak_tableView.dataSource = self;
//    self.croak_tableView.rowHeight = 594.0;
    self.croak_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.croak_tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.croak_originalTableContentInset = self.croak_tableView.contentInset;
    self.croak_originalTableScrollIndicatorInsets = self.croak_tableView.scrollIndicatorInsets;

    self.croak_inputContentView.layer.masksToBounds = YES;
    self.croak_commentTextField.delegate = self;
    self.croak_commentTextField.returnKeyType = UIReturnKeySend;

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(croak_dismissKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(croak_keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(croak_keyboardWillHide:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (IBAction)croak_backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)croak_moreAction:(id)sender {
    
}

- (IBAction)croak_sendAction:(id)sender {
    [self croak_submitCommentAndDismissKeyboard];
}

- (void)croak_keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect convertedKeyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
    CGFloat overlapHeight = MAX(0.0, CGRectGetMaxY(self.view.bounds) - CGRectGetMinY(convertedKeyboardFrame));
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = (UIViewAnimationOptions)([userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16);

    UIEdgeInsets contentInset = self.croak_originalTableContentInset;
    contentInset.bottom += overlapHeight;
    UIEdgeInsets indicatorInsets = self.croak_originalTableScrollIndicatorInsets;
    indicatorInsets.bottom += overlapHeight;

    [UIView animateWithDuration:duration
                          delay:0
                        options:options
                     animations:^{
        self.croak_inputBarView.transform = CGAffineTransformMakeTranslation(0, -overlapHeight);
        self.croak_tableView.contentInset = contentInset;
        self.croak_tableView.scrollIndicatorInsets = indicatorInsets;
    } completion:nil];
}

- (void)croak_keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = (UIViewAnimationOptions)([userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16);

    [UIView animateWithDuration:duration
                          delay:0
                        options:options
                     animations:^{
        self.croak_inputBarView.transform = CGAffineTransformIdentity;
        self.croak_tableView.contentInset = self.croak_originalTableContentInset;
        self.croak_tableView.scrollIndicatorInsets = self.croak_originalTableScrollIndicatorInsets;
    } completion:nil];
}

- (void)croak_dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)croak_submitCommentAndDismissKeyboard {
    NSString *comment = [self.croak_commentTextField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (comment.length > 0) {
        self.croak_commentTextField.text = @"";
    }
    [self croak_dismissKeyboard];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self croak_submitCommentAndDismissKeyboard];
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.croak_inputBarView]) {
        return NO;
    }
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        Croak_SquareDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:CroakSquareDetailsCellIdentifier
                                                                         forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    else {
        Croak_SquareCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CroakSquareCommentCellIdentifier
                                                                         forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    
}

@end
