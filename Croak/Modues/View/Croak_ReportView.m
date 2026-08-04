//
//  Croak_ReportView.m
//  Croak
//
//  Created by Mac on 2026/7/29.
//

#import "Croak_ReportView.h"

@implementation Croak_ReportView

+ (instancetype)croak_reportView {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil];
    for (id view in views) {
        if ([view isKindOfClass:self]) {
            return view;
        }
    }
    return [[self alloc] initWithFrame:CGRectZero];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self croak_configureView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self croak_configureView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self croak_configureView];
}

- (void)croak_configureView {
    self.backgroundColor = UIColor.clearColor;
    for (UIButton *button in [self croak_buttonsInView:self]) {
        [button removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
        NSString *title = [button titleForState:UIControlStateNormal];
        if ([title isEqualToString:@"Report"]) {
            [button addTarget:self action:@selector(croak_reportAction:) forControlEvents:UIControlEventTouchUpInside];
        } else if ([title isEqualToString:@"Block"]) {
            [button addTarget:self action:@selector(croak_blockAction:) forControlEvents:UIControlEventTouchUpInside];
        } else if ([title isEqualToString:@"Delete"]) {
            [button addTarget:self action:@selector(croak_deleteAction:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [button addTarget:self action:@selector(croak_closeAction:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)croak_showInView:(UIView *)view {
    self.frame = view.bounds;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.alpha = 0.0;
    [view addSubview:self];

    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1.0;
    }];
}

- (void)croak_dismiss {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)croak_reportAction:(id)sender {
    [self croak_performAction:CroakReportViewActionReport];
}

- (void)croak_blockAction:(id)sender {
    [self croak_performAction:CroakReportViewActionBlock];
}

- (void)croak_deleteAction:(id)sender {
    [self croak_performAction:CroakReportViewActionDelete];
}

- (void)croak_closeAction:(id)sender {
    [self croak_performAction:CroakReportViewActionClose];
}

- (void)croak_performAction:(CroakReportViewAction)action {
    [self croak_dismiss];
    if (self.croak_actionHandler) {
        self.croak_actionHandler(action);
    }
}

- (NSArray<UIButton *> *)croak_buttonsInView:(UIView *)view {
    NSMutableArray<UIButton *> *buttons = [NSMutableArray array];
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:UIButton.class]) {
            [buttons addObject:(UIButton *)subview];
        }
        [buttons addObjectsFromArray:[self croak_buttonsInView:subview]];
    }
    return buttons;
}

@end
