#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LCPurchase : NSObject

+ (nullable NSDictionary<NSString *, NSString *> *)croak_encryptJSONObject:(id)object
                                                                    keyData:(NSData *)keyData
                                                                      error:(NSError **)error;

+ (nullable id)croak_decryptEnvelope:(NSDictionary<NSString *, id> *)envelope
                              keyData:(NSData *)keyData
                                error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
