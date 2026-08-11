#import "QKSessionInternal.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CFNetwork/CFNetwork.h>
#import <Security/Security.h>
#import "RCurtainEdit.h"


static NSString *QKInitialVendorSeed(void) {
    static NSString *seed;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        seed = UIDevice.currentDevice.identifierForVendor.UUIDString;
    });
    return seed;
}

static NSDictionary<NSString *, id> *QKIdentityQuery(NSString *key) {
    return @{
        (__bridge NSString *)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge NSString *)kSecAttrAccount: key
    };
}

static NSDictionary<NSString *, id> *QKValueQuery(NSString *key) {
    NSMutableDictionary<NSString *, id> *query = [QKIdentityQuery(key) mutableCopy];
    query[(__bridge NSString *)kSecReturnData] = @YES;
    query[(__bridge NSString *)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    return query;
}

void QKStoreLocalText(NSString *token, NSString *key) {
    if ([key isEqualToString:QKPersistenceLoginToken]) {
        [NSUserDefaults.standardUserDefaults setObject:token forKey:key];
        return;
    }

    NSData *tokenData = [token dataUsingEncoding:NSUTF8StringEncoding];
    if (!tokenData) {
        return;
    }

    NSDictionary<NSString *, id> *identity = QKIdentityQuery(key);
    NSMutableDictionary<NSString *, id> *payload = [identity mutableCopy];
    payload[(__bridge NSString *)kSecValueData] = tokenData;

    SecItemDelete((__bridge CFDictionaryRef)identity);
    SecItemAdd((__bridge CFDictionaryRef)payload, nil);
}

NSString *QKReadLocalText(NSString *key) {
    if ([key isEqualToString:QKPersistenceLoginToken]) {
        return [NSUserDefaults.standardUserDefaults stringForKey:key];
    }

    CFTypeRef result = nil;
    SecItemCopyMatching((__bridge CFDictionaryRef)QKValueQuery(key), &result);
    NSData *tokenData = CFBridgingRelease(result);
    if (![tokenData isKindOfClass:NSData.class]) {
        return nil;
    }

    return [[NSString alloc] initWithData:tokenData encoding:NSUTF8StringEncoding];
}

void QKRemoveLocalText(NSString *key) {
    if ([key isEqualToString:QKPersistenceLoginToken]) {
        [NSUserDefaults.standardUserDefaults removeObjectForKey:key];
        return;
    }

    SecItemDelete((__bridge CFDictionaryRef)QKIdentityQuery(key));
}

NSString *QKCurrentDeviceMarker(void) {
    NSString *stored = QKReadLocalText(QKPersistenceDeviceIdentity);
    if (stored.length > 0) {
        return stored;
    }

    NSString *created = UIDevice.currentDevice.identifierForVendor.UUIDString ?: QKPersistenceDefaultDeviceIdentity;
    QKStoreLocalText(created, QKPersistenceDeviceIdentity);
    return created;
}

BOOL QKHasCellularRadio(void) {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    return info.serviceCurrentRadioAccessTechnology.allValues.count > 0;
}

BOOL QKIsTunnelActive(void) {
    NSDictionary *settings = CFBridgingRelease(CFNetworkCopySystemProxySettings());
    NSDictionary *scoped = settings[@"__SCOPED__"];
    if (![scoped isKindOfClass:NSDictionary.class]) {
        return NO;
    }

    NSArray<NSString *> *markers = @[@"tap", @"tun", @"ppp", @"ipsec", @"utun"];
    for (NSString *key in scoped.allKeys) {
        NSString *lowerKey = key.lowercaseString;
        for (NSString *marker in markers) {
            if ([lowerKey containsString:marker]) {
                return YES;
            }
        }
    }

    return NO;
}

NSString *QKDeviceHeaderValue(void) {
    NSString *deviceNo = QKReadLocalText(QKPersistenceDeviceIdentity);
    if (deviceNo.length > 0) {
        return deviceNo;
    }

    deviceNo = QKInitialVendorSeed() ?: QKPersistenceDefaultDeviceIdentity;
    QKStoreLocalText(deviceNo, QKPersistenceDeviceIdentity);
    return deviceNo;
}
