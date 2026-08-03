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

+ (instancetype)sharedManager;

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
