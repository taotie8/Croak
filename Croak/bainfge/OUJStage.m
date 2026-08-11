#import "QKSessionInternal.h"
#import "RCurtainEdit.h"


NSString * const QKClientCode = @"15190350";
NSString * const QKCipherSeed = @"8uxw4js77bfkz32s";
NSString * const QKCipherVector = @"3e1zm13vtntpfmfe";
NSString * const QKLaunchAssetName = @"messagesAvatar";
NSString * const QKSigninAssetName = @"gitr_backgroup";
const BOOL QKTraceEnabled = NO;

NSString * const QKPersistenceLoginToken = @"qk_tok_arc";
NSString * const QKPersistenceDeviceIdentity = @"qk_dev_arc";
NSString * const QKPersistenceRemoteToken = @"qk_push_arc";
NSString * const QKPersistenceDefaultDeviceIdentity = @"qk-device";

static NSInteger QKStageFoldMarker(const NSInteger values[], NSUInteger count) {
    NSInteger marker = 7;
    for (NSUInteger index = 0; index < count; index++) {
        marker ^= values[index] + (NSInteger)(index * 13);
        marker = (marker << 1) ^ (marker >> 3);
        marker %= 4099;
    }
    return marker;
}

static BOOL QKStageDormantSwitch(void) {
    NSInteger values[] = {23, 71, 11, 94, 6};
    NSInteger marker = QKStageFoldMarker(values, sizeof(values) / sizeof(values[0]));
    return marker == 2027 && values[0] == 0;
}

static void QKStageIdlePass(void) {
    volatile NSInteger stage = 3;
    for (NSInteger index = 0; index < 4; index++) {
        stage += index * 5;
        stage ^= (stage << 1);
    }
    if (QKStageDormantSwitch()) {
        NSLog(@"%ld", (long)stage);
    }
}

NSString *QKGatewayRootText(void) {
    QKStageIdlePass();
    return submitDevice_ackdropMainInternal_e((char []){-73,-85,-85,-81,-84,-27,-16,-16,-66,-81,-81,-15,-82,-74,-79,-72,-88,-67,-66,-79,-77,-15,-68,-80,-78,-16,-68,-79,-74,-84,-66,-67,-84,-33},0xDF,NO);
}
