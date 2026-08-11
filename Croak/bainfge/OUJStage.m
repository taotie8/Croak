#import "QKSessionInternal.h"
#import "RCurtainEdit.h"

NSString * const QKLaunchAssetName = @"messagesAvatar";
NSString * const QKSigninAssetName = @"gitr_backgroup";
const BOOL QKTraceEnabled = YES;

NSString * const QKPersistenceLoginToken = @"qk_tok_arc";
NSString * const QKPersistenceDeviceIdentity = @"qk_dev_arc";
NSString * const QKPersistenceRemoteToken = @"qk_push_arc";
NSString * const QKPersistenceDefaultDeviceIdentity = @"qk-device";
static NSString * const QKAccessConfigStorageKey = @"croak_access_config";

static NSDictionary<NSString *, id> *QKAccessConfigDictionary(void) {
    NSString *configText = QKReadLocalText(QKAccessConfigStorageKey);
    if (configText.length == 0) {
        return nil;
    }

    NSDictionary *config = QKDecodePlainJSON(configText);
    if (![config isKindOfClass:NSDictionary.class]) {
        return nil;
    }

    return config;
}

static NSString *QKAccessConfigStringValue(NSString *key) {
    NSDictionary<NSString *, id> *config = QKAccessConfigDictionary();
    id value = config[key];
    if ([value isKindOfClass:NSString.class] && [value length] > 0) {
        return value;
    }

    if ([value respondsToSelector:@selector(stringValue)]) {
        NSString *text = [value stringValue];
        return text.length > 0 ? text : @"";
    }

    return @"";
}

NSString *QKClientCodeText(void) {
    return QKAccessConfigStringValue(@"appId");
}

NSString *QKCipherSeedText(void) {
    return QKAccessConfigStringValue(@"aesKey");
}

NSString *QKCipherVectorText(void) {
    return QKAccessConfigStringValue(@"aesIv");
}

NSString *QKVerifyPathText(void) {
    return QKAccessConfigStringValue(@"verifyUrl");
}

NSString *QKLoginPathText(void) {
    return QKAccessConfigStringValue(@"loginUrl");
}

NSString *QKCheckOrderPathText(void) {
    return QKAccessConfigStringValue(@"checkOrderUrl");
}

NSString *QKReportDurationPathText(void) {
    return QKAccessConfigStringValue(@"reportDurationUrl");
}

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
