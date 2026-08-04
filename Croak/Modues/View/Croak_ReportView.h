//
//  Croak_ReportView.h
//  Croak
//
//  Created by Mac on 2026/7/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CroakReportViewAction) {
    CroakReportViewActionReport,
    CroakReportViewActionBlock,
    CroakReportViewActionDelete,
    CroakReportViewActionClose
};

@interface Croak_ReportView : UIView

@property (nonatomic, copy, nullable) void (^croak_actionHandler)(CroakReportViewAction action);

+ (instancetype)croak_reportView;
- (void)croak_showInView:(UIView *)view;
- (void)croak_dismiss;

@end

NS_ASSUME_NONNULL_END
