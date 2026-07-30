
#import "Croak_DiamondsCell.h"

@implementation Croak_DiamondsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = UIColor.clearColor;
    self.contentView.backgroundColor = UIColor.clearColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)croak_configureWithAmount:(NSString *)amount price:(NSString *)price {
    self.croak_amountLabel.text = amount;
    self.croak_priceLabel.text = price;
}

@end
