#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CroakHTTPMethod) {
    CroakHTTPMethodGET,
    CroakHTTPMethodPOST,
    CroakHTTPMethodPUT,
};

typedef void (^CroakNetworkCompletion)(id _Nullable responseObject,
                                       NSHTTPURLResponse * _Nullable response,
                                       NSError * _Nullable error);

@interface Croak_NetworkManager : NSObject

@property (nonatomic, strong) NSURL *croak_baseURL;
@property (nonatomic, assign) NSTimeInterval croak_timeoutInterval;
@property (nonatomic, assign, getter=croak_isEncryptionEnabled) BOOL croak_encryptionEnabled;
@property (nullable, nonatomic, copy) NSData *croak_AES256GCMKey;

+ (instancetype)sharedManager;

- (BOOL)croak_updateAES256GCMKeyWithBase64String:(NSString *)base64String;
- (BOOL)croak_updateAES256GCMKeyWithHexString:(NSString *)hexString;

- (nullable NSURLSessionDataTask *)croak_GET:(NSString *)path
                                  parameters:(nullable NSDictionary<NSString *, id> *)parameters
                                   completed:(CroakNetworkCompletion)completed;

- (nullable NSURLSessionDataTask *)croak_POST:(NSString *)path
                                   parameters:(nullable NSDictionary<NSString *, id> *)parameters
                                    completed:(CroakNetworkCompletion)completed;

- (nullable NSURLSessionDataTask *)croak_PUT:(NSString *)path
                                  parameters:(nullable NSDictionary<NSString *, id> *)parameters
                                   completed:(CroakNetworkCompletion)completed;

- (nullable NSURLSessionDataTask *)croak_requestWithMethod:(CroakHTTPMethod)method
                                                      path:(NSString *)path
                                                parameters:(nullable NSDictionary<NSString *, id> *)parameters
                                                 completed:(CroakNetworkCompletion)completed;

@end

NS_ASSUME_NONNULL_END
