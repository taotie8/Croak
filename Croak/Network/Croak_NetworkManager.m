#import "Croak_NetworkManager.h"
#import "Croak_AESCrypto.h"
#import "Croak_API.h"

static NSString * const CroakNetworkErrorDomain = @"CroakNetworkErrorDomain";

typedef NS_ENUM(NSInteger, CroakNetworkErrorCode) {
    CroakNetworkErrorInvalidURL = -10001,
    CroakNetworkErrorInvalidResponse = -10002,
    CroakNetworkErrorHTTPStatus = -10003,
    CroakNetworkErrorJSONSerialization = -10004,
    CroakNetworkErrorMissingEncryptionKey = -10005,
    CroakNetworkErrorEncryption = -10006,
    CroakNetworkErrorDecryption = -10007,
};

@interface Croak_NetworkManager ()

@property (nonatomic, strong) NSURLSession *croak_session;

@end

@implementation Croak_NetworkManager

+ (instancetype)sharedManager {
    static Croak_NetworkManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[Croak_NetworkManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _croak_baseURL = [NSURL URLWithString:CroakAPIBaseURLString];
        _croak_timeoutInterval = 20.0;
        _croak_encryptionEnabled = YES;
        _croak_AES256GCMKey = [self croak_AES256GCMKeyDataWithBase64String:CroakAPIEncryptionKeyBase64];

        NSURLSessionConfiguration *configuration = NSURLSessionConfiguration.defaultSessionConfiguration;
        configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        _croak_session = [NSURLSession sessionWithConfiguration:configuration];
    }
    return self;
}

- (BOOL)croak_updateAES256GCMKeyWithBase64String:(NSString *)base64String {
    NSData *keyData = [self croak_AES256GCMKeyDataWithBase64String:base64String];
    if (keyData.length != 32) {
        return NO;
    }

    self.croak_AES256GCMKey = keyData;
    return YES;
}

- (BOOL)croak_updateAES256GCMKeyWithHexString:(NSString *)hexString {
    NSData *keyData = [self croak_AES256GCMKeyDataWithHexString:hexString];
    if (keyData.length != 32) {
        return NO;
    }

    self.croak_AES256GCMKey = keyData;
    return YES;
}

- (nullable NSURLSessionDataTask *)croak_GET:(NSString *)path
                                  parameters:(NSDictionary<NSString *,id> *)parameters
                                   completed:(CroakNetworkCompletion)completed {
    return [self croak_requestWithMethod:CroakHTTPMethodGET
                                    path:path
                              parameters:parameters
                               completed:completed];
}

- (nullable NSURLSessionDataTask *)croak_POST:(NSString *)path
                                   parameters:(NSDictionary<NSString *,id> *)parameters
                                    completed:(CroakNetworkCompletion)completed {
    return [self croak_requestWithMethod:CroakHTTPMethodPOST
                                    path:path
                              parameters:parameters
                               completed:completed];
}

- (nullable NSURLSessionDataTask *)croak_PUT:(NSString *)path
                                  parameters:(NSDictionary<NSString *,id> *)parameters
                                   completed:(CroakNetworkCompletion)completed {
    return [self croak_requestWithMethod:CroakHTTPMethodPUT
                                    path:path
                              parameters:parameters
                               completed:completed];
}

- (nullable NSURLSessionDataTask *)croak_requestWithMethod:(CroakHTTPMethod)method
                                                      path:(NSString *)path
                                                parameters:(NSDictionary<NSString *,id> *)parameters
                                                 completed:(CroakNetworkCompletion)completed {
    BOOL shouldEncryptBody = self.croak_isEncryptionEnabled && (method != CroakHTTPMethodGET || parameters.count > 0);
    NSURL *URL = [self croak_URLWithPath:path parameters:(!shouldEncryptBody && method == CroakHTTPMethodGET) ? parameters : nil];
    if (!URL) {
        NSError *error = [self croak_errorWithCode:CroakNetworkErrorInvalidURL
                                           message:@"Invalid request URL."
                                          response:nil
                                      responseBody:nil];
        [self croak_completeOnMainWithObject:nil response:nil error:error completed:completed];
        return nil;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:self.croak_timeoutInterval];
    request.HTTPMethod = [self croak_methodStringWithMethod:method];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:CroakAPIAppId forHTTPHeaderField:@"X-App-Id"];
    [request setValue:@"iOS" forHTTPHeaderField:@"X-Croak-Platform"];

    if (shouldEncryptBody) {
        NSDictionary<NSString *, id> *bodyObject = parameters ?: @{};
        NSError *bodyError = nil;
        NSData *bodyData = [self croak_encryptedBodyDataWithObject:bodyObject error:&bodyError];
        if (bodyError || !bodyData) {
            [self croak_completeOnMainWithObject:nil response:nil error:bodyError completed:completed];
            return nil;
        }
        request.HTTPBody = bodyData;
    }
    else if (method != CroakHTTPMethodGET && parameters.count > 0) {
        NSError *jsonError = nil;
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:parameters
                                                           options:0
                                                             error:&jsonError];
        if (jsonError || !bodyData) {
            NSError *error = [self croak_errorWithCode:CroakNetworkErrorJSONSerialization
                                               message:@"Request parameters are not valid JSON."
                                              response:nil
                                          responseBody:nil];
            [self croak_completeOnMainWithObject:nil response:nil error:error completed:completed];
            return nil;
        }
        request.HTTPBody = bodyData;
    }

#if DEBUG
    [self croak_debugLogRequest:request parameters:parameters encrypted:shouldEncryptBody];
#endif

    NSURLSessionDataTask *task = [self.croak_session dataTaskWithRequest:request
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self croak_handleData:data response:response error:error completed:completed];
    }];
    [task resume];
    return task;
}

- (void)croak_handleData:(NSData *)data
                response:(NSURLResponse *)response
                   error:(NSError *)error
               completed:(CroakNetworkCompletion)completed {
    NSHTTPURLResponse *HTTPResponse = [response isKindOfClass:NSHTTPURLResponse.class] ? (NSHTTPURLResponse *)response : nil;
    if (error) {
#if DEBUG
        [self croak_debugLogResponse:HTTPResponse responseObject:nil rawData:data error:error];
#endif
        [self croak_completeOnMainWithObject:nil response:HTTPResponse error:error completed:completed];
        return;
    }

    if (!HTTPResponse) {
        NSError *responseError = [self croak_errorWithCode:CroakNetworkErrorInvalidResponse
                                                   message:@"Invalid server response."
                                                  response:nil
                                              responseBody:data];
#if DEBUG
        [self croak_debugLogResponse:nil responseObject:nil rawData:data error:responseError];
#endif
        [self croak_completeOnMainWithObject:nil response:nil error:responseError completed:completed];
        return;
    }

    NSError *decryptionError = nil;
    id responseObject = [self croak_responseObjectWithData:data decryptionError:&decryptionError];
#if DEBUG
    [self croak_debugLogResponse:HTTPResponse responseObject:responseObject rawData:data error:decryptionError];
#endif
    if (decryptionError && HTTPResponse.statusCode >= 200 && HTTPResponse.statusCode < 300) {
        [self croak_completeOnMainWithObject:nil response:HTTPResponse error:decryptionError completed:completed];
        return;
    }

    if (HTTPResponse.statusCode < 200 || HTTPResponse.statusCode >= 300) {
        NSString *message = [self croak_errorMessageForStatusCode:HTTPResponse.statusCode
                                                   responseObject:responseObject];
        NSError *statusError = [self croak_errorWithCode:CroakNetworkErrorHTTPStatus
                                                 message:message
                                                response:HTTPResponse
                                            responseBody:data];
        [self croak_completeOnMainWithObject:responseObject response:HTTPResponse error:statusError completed:completed];
        return;
    }

    [self croak_completeOnMainWithObject:responseObject response:HTTPResponse error:nil completed:completed];
}

- (NSURL *)croak_URLWithPath:(NSString *)path parameters:(NSDictionary<NSString *,id> *)parameters {
    if (path.length == 0) {
        return nil;
    }

    NSURL *URL = [NSURL URLWithString:path];
    if (!URL.scheme.length) {
        NSString *baseURLString = self.croak_baseURL.absoluteString;
        NSString *trimmedBaseURLString = [baseURLString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
        NSString *trimmedPath = [path stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", trimmedBaseURLString, trimmedPath]];
    }

    if (!parameters.count) {
        return URL;
    }

    NSURLComponents *components = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    NSMutableArray<NSURLQueryItem *> *queryItems = [components.queryItems mutableCopy] ?: [NSMutableArray array];
    NSArray<NSString *> *sortedKeys = [parameters.allKeys sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *key in sortedKeys) {
        id value = parameters[key];
        if (!value || value == NSNull.null) {
            continue;
        }
        [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:[self croak_queryValueWithObject:value]]];
    }
    components.queryItems = queryItems;
    return components.URL;
}

- (NSString *)croak_methodStringWithMethod:(CroakHTTPMethod)method {
    switch (method) {
        case CroakHTTPMethodGET:
            return @"GET";
        case CroakHTTPMethodPOST:
            return @"POST";
        case CroakHTTPMethodPUT:
            return @"PUT";
    }
}

- (NSString *)croak_queryValueWithObject:(id)object {
    if ([object isKindOfClass:NSString.class]) {
        return object;
    }
    if ([object isKindOfClass:NSNumber.class]) {
        return [object stringValue];
    }
    if ([NSJSONSerialization isValidJSONObject:object]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:object options:0 error:nil];
        if (data.length > 0) {
            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
    return [object description];
}

- (NSData *)croak_encryptedBodyDataWithObject:(id)object error:(NSError **)error {
    NSData *keyData = [self croak_currentAES256GCMKeyData];
    if (keyData.length != 32) {
        if (error) {
            *error = [self croak_errorWithCode:CroakNetworkErrorMissingEncryptionKey
                                       message:@"Missing AES-256-GCM key."
                                      response:nil
                                  responseBody:nil];
        }
        return nil;
    }

    NSError *cryptoError = nil;
    NSDictionary<NSString *, NSString *> *envelope = [Croak_AESCrypto croak_encryptJSONObject:object
                                                                                      keyData:keyData
                                                                                        error:&cryptoError];
    if (cryptoError || !envelope) {
        if (error) {
            *error = [self croak_errorWithCode:CroakNetworkErrorEncryption
                                       message:cryptoError.localizedDescription ?: @"Request encryption failed."
                                      response:nil
                                  responseBody:nil];
        }
        return nil;
    }

    NSError *jsonError = nil;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:envelope options:0 error:&jsonError];
    if (jsonError || !bodyData) {
        if (error) {
            *error = [self croak_errorWithCode:CroakNetworkErrorJSONSerialization
                                       message:@"Encrypted request body is not valid JSON."
                                      response:nil
                                  responseBody:nil];
        }
        return nil;
    }

    return bodyData;
}

- (id)croak_responseObjectWithData:(NSData *)data decryptionError:(NSError **)decryptionError {
    if (data.length == 0) {
        return nil;
    }

    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if (jsonObject) {
        if (!self.croak_isEncryptionEnabled) {
            return jsonObject;
        }

        if (![jsonObject isKindOfClass:NSDictionary.class]) {
            if (decryptionError) {
                *decryptionError = [self croak_errorWithCode:CroakNetworkErrorDecryption
                                                     message:@"Encrypted response is not a JSON object."
                                                    response:nil
                                                responseBody:data];
            }
            return jsonObject;
        }

        NSDictionary<NSString *, id> *envelope = (NSDictionary<NSString *, id> *)jsonObject;
        if (![envelope[@"iv"] isKindOfClass:NSString.class] ||
            ![envelope[@"data"] isKindOfClass:NSString.class]) {
            if (decryptionError) {
                *decryptionError = [self croak_errorWithCode:CroakNetworkErrorDecryption
                                                     message:@"Encrypted response is missing iv or data."
                                                    response:nil
                                                responseBody:data];
            }
            return jsonObject;
        }

        NSData *keyData = [self croak_currentAES256GCMKeyData];
        if (keyData.length != 32) {
            if (decryptionError) {
                *decryptionError = [self croak_errorWithCode:CroakNetworkErrorMissingEncryptionKey
                                                     message:@"Missing AES-256-GCM key."
                                                    response:nil
                                                responseBody:data];
            }
            return nil;
        }

        NSError *cryptoError = nil;
        id decryptedObject = [Croak_AESCrypto croak_decryptEnvelope:envelope keyData:keyData error:&cryptoError];
        if (cryptoError) {
            if (decryptionError) {
                *decryptionError = [self croak_errorWithCode:CroakNetworkErrorDecryption
                                                     message:cryptoError.localizedDescription ?: @"Response decryption failed."
                                                    response:nil
                                                responseBody:data];
            }
            return jsonObject;
        }

        return decryptedObject;
    }

    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSData *)croak_currentAES256GCMKeyData {
    if (self.croak_AES256GCMKey.length == 32) {
        return self.croak_AES256GCMKey;
    }

    NSData *keyData = [self croak_AES256GCMKeyDataWithBase64String:CroakAPIEncryptionKeyBase64];
    if (keyData.length == 32) {
        self.croak_AES256GCMKey = keyData;
    }
    return self.croak_AES256GCMKey;
}

- (NSData *)croak_AES256GCMKeyDataWithBase64String:(NSString *)base64String {
    NSString *trimmedString = [base64String stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (trimmedString.length == 0) {
        return nil;
    }

    return [[NSData alloc] initWithBase64EncodedString:trimmedString
                                               options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

- (NSData *)croak_AES256GCMKeyDataWithHexString:(NSString *)hexString {
    NSString *trimmedString = [[hexString stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] lowercaseString];
    NSMutableString *cleanString = [NSMutableString stringWithCapacity:trimmedString.length];
    NSCharacterSet *hexCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdef"];
    for (NSUInteger index = 0; index < trimmedString.length; index++) {
        unichar character = [trimmedString characterAtIndex:index];
        if ([hexCharacterSet characterIsMember:character]) {
            [cleanString appendFormat:@"%C", character];
        }
    }

    if (cleanString.length == 0 || cleanString.length % 2 != 0) {
        return nil;
    }

    NSMutableData *data = [NSMutableData dataWithCapacity:cleanString.length / 2];
    for (NSUInteger index = 0; index < cleanString.length; index += 2) {
        NSString *byteString = [cleanString substringWithRange:NSMakeRange(index, 2)];
        unsigned int byteValue = 0;
        NSScanner *scanner = [NSScanner scannerWithString:byteString];
        if (![scanner scanHexInt:&byteValue]) {
            return nil;
        }
        UInt8 byte = (UInt8)byteValue;
        [data appendBytes:&byte length:sizeof(byte)];
    }

    return data;
}

- (NSString *)croak_errorMessageForStatusCode:(NSInteger)statusCode responseObject:(id)responseObject {
    NSString *message = [self croak_errorMessageFromResponseObject:responseObject];
    if (message.length > 0 && ![self croak_stringLooksLikeHTML:message]) {
        return message;
    }

    if (statusCode == 502) {
        return @"Server is temporarily unavailable. Please try again later. (502)";
    }
    if (statusCode == 404) {
        return @"Request path was not found. (404)";
    }
    if (statusCode >= 500) {
        return [NSString stringWithFormat:@"Server error. Please try again later. (%ld)", (long)statusCode];
    }
    if (statusCode >= 400) {
        return [NSString stringWithFormat:@"Request failed. (%ld)", (long)statusCode];
    }
    return @"Request failed.";
}

- (NSString *)croak_errorMessageFromResponseObject:(id)responseObject {
    if ([responseObject isKindOfClass:NSDictionary.class]) {
        NSDictionary *dictionary = responseObject;
        id message = dictionary[@"message"] ?: dictionary[@"error"] ?: dictionary[@"msg"];
        if ([message isKindOfClass:NSString.class] && [message length] > 0) {
            return message;
        }
    }
    if ([responseObject isKindOfClass:NSString.class] && [responseObject length] > 0) {
        return responseObject;
    }
    return nil;
}

- (BOOL)croak_stringLooksLikeHTML:(NSString *)string {
    NSString *trimmedString = [[string stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] lowercaseString];
    return [trimmedString hasPrefix:@"<html"] ||
           [trimmedString hasPrefix:@"<!doctype html"] ||
           [trimmedString containsString:@"<body"] ||
           [trimmedString containsString:@"</html>"];
}

#if DEBUG
- (void)croak_debugLogRequest:(NSURLRequest *)request
                   parameters:(NSDictionary<NSString *, id> *)parameters
                    encrypted:(BOOL)encrypted {
    NSMutableDictionary<NSString *, NSString *> *headers = [request.allHTTPHeaderFields mutableCopy] ?: [NSMutableDictionary dictionary];
    [headers removeObjectForKey:@"Authorization"];

    NSString *bodyString = [self croak_debugStringFromData:request.HTTPBody] ?: @"(empty)";
    NSString *parameterString = [self croak_debugStringFromObject:parameters ?: @{}];

    NSLog(@"\n[Croak API Request]\nmethod: %@\nurl: %@\nencrypted: %@\nheaders: %@\nparameters: %@\nbody: %@",
          request.HTTPMethod,
          request.URL.absoluteString,
          encrypted ? @"YES" : @"NO",
          [self croak_debugStringFromObject:headers],
          parameterString,
          bodyString);
}

- (void)croak_debugLogResponse:(NSHTTPURLResponse *)response
                responseObject:(id)responseObject
                       rawData:(NSData *)rawData
                         error:(NSError *)error {
    NSString *rawBodyString = [self croak_debugStringFromData:rawData] ?: @"(empty)";
    NSString *responseString = [self croak_debugStringFromObject:responseObject];

    NSLog(@"\n[Croak API Response]\nstatus: %ld\nurl: %@\nerror: %@\ndecrypted: %@\nrawBody: %@",
          (long)response.statusCode,
          response.URL.absoluteString ?: @"(unknown)",
          error.localizedDescription ?: @"(none)",
          responseString,
          rawBodyString);
}

- (NSString *)croak_debugStringFromObject:(id)object {
    if (!object || object == NSNull.null) {
        return @"(null)";
    }

    if ([object isKindOfClass:NSString.class]) {
        return object;
    }

    if ([NSJSONSerialization isValidJSONObject:object]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
        if (data.length > 0) {
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (string.length > 0) {
                return string;
            }
        }
    }

    return [object description];
}

- (NSString *)croak_debugStringFromData:(NSData *)data {
    if (data.length == 0) {
        return nil;
    }

    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (jsonObject) {
        return [self croak_debugStringFromObject:jsonObject];
    }

    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (string.length > 0) {
        return string;
    }

    return [NSString stringWithFormat:@"<%lu bytes>", (unsigned long)data.length];
}
#endif

- (NSError *)croak_errorWithCode:(NSInteger)code
                         message:(NSString *)message
                        response:(NSHTTPURLResponse *)response
                    responseBody:(NSData *)responseBody {
    NSMutableDictionary<NSErrorUserInfoKey, id> *userInfo = [@{
        NSLocalizedDescriptionKey: message ?: @"Network request failed."
    } mutableCopy];

    if (response) {
        userInfo[@"statusCode"] = @(response.statusCode);
    }
    if (responseBody.length > 0) {
        userInfo[@"responseBody"] = responseBody;
    }

    return [NSError errorWithDomain:CroakNetworkErrorDomain code:code userInfo:userInfo];
}

- (void)croak_completeOnMainWithObject:(id)responseObject
                              response:(NSHTTPURLResponse *)response
                                 error:(NSError *)error
                             completed:(CroakNetworkCompletion)completed {
    if (!completed) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        completed(responseObject, response, error);
    });
}

@end
