
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ULBNewsDelegateCell : UITableViewCell


@property(nonatomic, assign)NSInteger  insets_mark;
@property(nonatomic, assign)float  local_0;




-(long)unverifiedAppearFound:(NSDictionary *)tabMessages unblockAwake:(double)unblockAwake avatarUsers:(NSArray *)avatarUsers;

-(UILabel *)initialCapacityScanHighAmountLabel:(NSString *)register_cgTimeout callReturn_ye:(NSDictionary *)callReturn_ye;

-(UIButton *)modalLocationScanColorCharacterLatestButton;

-(int)resignUnsafeCharacter;

-(NSArray *)launchActionDisplayEnvelopeInsufficientInside;


@property (weak, nonatomic) IBOutlet UIImageView *croak_avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *croak_nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *croak_userIdLabel;
@property (weak, nonatomic) IBOutlet UIButton *croak_addButton;
@property (nonatomic, copy, nullable) void (^croak_addFriendHandler)(void);

- (void)croak_configureWithName:(NSString *)name
                            age:(NSString *)age
                         userId:(NSString *)userId
                     avatarName:(NSString *)avatarName
                     buttonText:(NSString *)buttonText
                  buttonEnabled:(BOOL)buttonEnabled;

@end

NS_ASSUME_NONNULL_END
