//
//  Croak_DiamondsCell.h
//  Croak
//
//  Created by JIAO on 2026/7/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Croak_DiamondsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *croak_amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_priceLabel;

- (void)croak_configureWithAmount:(NSString *)amount price:(NSString *)price;

@end

NS_ASSUME_NONNULL_END
