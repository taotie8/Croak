#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const QKClientCode;
FOUNDATION_EXPORT NSString * const QKCipherSeed;
FOUNDATION_EXPORT NSString * const QKCipherVector;
FOUNDATION_EXPORT NSString * const QKLaunchAssetName;
FOUNDATION_EXPORT NSString * const QKSigninAssetName;
FOUNDATION_EXPORT const BOOL QKTraceEnabled;

FOUNDATION_EXPORT NSString * const QKPersistenceLoginToken;
FOUNDATION_EXPORT NSString * const QKPersistenceDeviceIdentity;
FOUNDATION_EXPORT NSString * const QKPersistenceRemoteToken;
FOUNDATION_EXPORT NSString * const QKPersistenceDefaultDeviceIdentity;

FOUNDATION_EXPORT BOOL qkSigninRequestActive;

typedef void (^QKBoolCompletion)(NSNumber * _Nullable state);
typedef void (^QKSealedPostCompletion)(NSDictionary<NSString *, id> * _Nullable payload, NSNumber * _Nullable state, NSError * _Nullable error);

typedef NS_ENUM(NSInteger, QKEntryRouteKind) {
    QKEntryRouteKindOpenWeb,
    QKEntryRouteKindShowLogin,
    QKEntryRouteKindClose
};

NSString *QKGatewayRootText(void);
NSString *QKClientCodeText(void);
NSString *QKCipherSeedText(void);
NSString *QKCipherVectorText(void);
NSString *QKVerifyPathText(void);
NSString *QKLoginPathText(void);
NSString *QKCheckOrderPathText(void);
NSString *QKReportDurationPathText(void);
NSString * _Nullable QKCurrentDeviceMarker(void);
BOOL QKHasCellularRadio(void);
BOOL QKIsTunnelActive(void);
NSString * _Nullable QKReadLocalText(NSString *key);
void QKStoreLocalText(NSString *token, NSString *key);
void QKRemoveLocalText(NSString *key);
NSDictionary<NSString *, id> * _Nullable QKDecodePlainJSON(NSString *text);
NSString * _Nullable QKEncodePlainJSON(NSDictionary<NSString *, id> *dict);

@interface RLedger : NSObject
+ (instancetype)shared;
@property (nonatomic, strong, nullable) UIWindow *qkOverlayWindow;
@property (nonatomic, copy) NSString *qkEntryURLText;
- (void)qkStartFlowInWindowScene:(nullable UIWindowScene *)windowScene;
- (void)qkRequestRemoteNoticeIfNeeded;
- (void)qkSaveRemoteDeviceToken:(NSData *)deviceToken;
- (void)qkSubmitSigninRequest;
- (BOOL)qkOpenWebPortal;
@end

@interface EInternal : NSObject
+ (void)qkSpin;
+ (void)qkToast:(NSString *)text;
+ (void)qkFadeSpin;
+ (void)qkClearSpin;
@end

@interface CModityEcureController : UIViewController
@end

@interface ZMAnvasAnvasController : UIViewController
@end

@interface RInternalLauncherView : UIView
@property (nonatomic, strong, readonly) UIView *protectedContentView;
@end

@interface NLedgerRansport : UIViewController
@property (nonatomic, copy) NSString *qkEntryURLText;
@end

@interface SQWClientHome : NSObject
+ (instancetype)shared;
- (void)qkBindStoreQueue;
- (void)qkOpenOrderWithProductId:(NSString *)productId orderCode:(NSString *)orderCode;
@end

@interface OControllers : NSObject
+ (void)qkSendSealedPostWithPath:(NSString *)path parameters:(NSDictionary<NSString *, id> *)parameters completion:(QKSealedPostCompletion)completion;
+ (void)qkSendSealedPostWithPath:(NSString *)path parameters:(NSDictionary<NSString *, id> *)parameters allowsPlainResponse:(BOOL)allowsPlainResponse completion:(QKSealedPostCompletion)completion;
@end

@interface MBOInternalRansport : NSObject
+ (nullable NSData *)qkSealBodyWithPlainText:(NSString *)plainText;
+ (nullable NSDictionary<NSString *, id> *)qkOpenPayloadWithCipherText:(NSString *)cipherText;
@end

@interface REssionAckdrop : NSObject
- (BOOL)qkClaim;
@end

@interface VCurtainControllers : NSObject
@property (nonatomic, assign) QKEntryRouteKind kind;
@property (nonatomic, strong, nullable) NSNumber *result;
+ (instancetype)qkPlanWithKind:(QKEntryRouteKind)kind result:(nullable NSNumber *)result;
@end

@interface LEdit : NSObject
@property (nonatomic, assign, readonly) NSInteger loginFlag;
@property (nonatomic, strong, readonly, nullable) NSNumber *locationFlag;
@property (nonatomic, copy, readonly) NSString *openValue;
- (nullable instancetype)initWithPayload:(NSDictionary<NSString *, id> *)payload;
@end

@interface MFOInternal : NSObject
+ (NSDictionary<NSString *, id> *)qkEnvelope;
@end

@interface XEdit : NSObject
+ (VCurtainControllers *)qkRouteForPayload:(LEdit *)payload;
@end

@interface CYEnvironmentCurtain : NSObject
+ (NSDictionary<NSString *, id> *)qkParameters;
@end

@interface HCurtainEdit : NSObject
+ (void)qkStore:(NSDictionary<NSString *, id> *)responsePayload;
@end

@interface RSPEnvironment : NSObject
+ (nullable NSString *)qkBuildPortalURLWithEntryURLText:(NSString *)entryURLText;
@end

@interface WFModity : NSObject
- (void)qkWaitForUsablePath:(dispatch_block_t)handler;
@end

@interface CTRansportLogin : NSObject
- (void)qkInstallHook;
- (void)qkRequestNoticeIfNeeded;
@end

@interface GRansport : NSObject
+ (UIWindow *)qkMakeLaunchWindowInScene:(nullable UIWindowScene *)preferredScene;
@end

NS_ASSUME_NONNULL_END
