
#import "Croak_FriendsCenterVC.h"

@interface Croak_FriendsCenterVC ()

@property (weak, nonatomic) IBOutlet UITableView *croak_tableView;
@property (weak, nonatomic) IBOutlet UIImageView *croak_headerView;
@property (weak, nonatomic) IBOutlet UILabel *croak_name_label;
@property (weak, nonatomic) IBOutlet UILabel *croak_age_label;
@property (weak, nonatomic) IBOutlet UILabel *croak_id_label;

@end

@implementation Croak_FriendsCenterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)croak_navBackWithCallAndMoreAction:(UIButton *)sender {
    if (sender.tag == 1) {
        [self.navigationController popViewControllerAnimated:true];
    }
    else if (sender.tag == 2) {
        
    }
    else {
        
    }
}


- (IBAction)croak_gotoChatAction:(id)sender {
    
}

@end
