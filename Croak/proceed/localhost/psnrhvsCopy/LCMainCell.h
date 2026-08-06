
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LCMainCell : UITableViewCell


@property(nonatomic, assign)long  v_image;
@property(nonatomic, assign)double  addSpace;
@property(nonatomic, copy)NSString *  callPreview_string;
@property(nonatomic, copy)NSString *  unblockPostConstraintStr;




-(NSDictionary *)shouldDimensionIntermediateAmount:(NSInteger)baseTab;

-(UIView *)modalWideBannerFinishView;


@property (weak, nonatomic) IBOutlet UILabel *croak_amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_priceLabel;

- (void)croak_configureWithAmount:(NSString *)amount price:(NSString *)price;

@end

NS_ASSUME_NONNULL_END
