#import "Croak_NetworkManager.h"
#import "Croak_API.h"
#import "Croak_UserSession.h"

static NSString * const CroakNetworkErrorDomain = @"CroakNetworkErrorDomain";

typedef NS_ENUM(NSInteger, CroakNetworkErrorCode) {
    CroakNetworkErrorInvalidURL = -10001,
    CroakNetworkErrorInvalidResponse = -10002,
    CroakNetworkErrorHTTPStatus = -10003,
    CroakNetworkErrorJSONSerialization = -10004,
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

        NSURLSessionConfiguration *configuration = NSURLSessionConfiguration.defaultSessionConfiguration;
        configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        _croak_session = [NSURLSession sessionWithConfiguration:configuration];
    }
    return self;
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
    NSURL *URL = [self croak_URLWithPath:path parameters:method == CroakHTTPMethodGET ? parameters : nil];
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
    [request setValue:@"iOS" forHTTPHeaderField:@"X-Croak-Platform"];

    NSString *accessToken = Croak_UserSession.croak_accessToken;
    if (accessToken.length > 0) {
        [request setValue:[NSString stringWithFormat:@"Bearer %@", accessToken]
       forHTTPHeaderField:@"Authorization"];
    }

    if (method != CroakHTTPMethodGET && parameters.count > 0) {
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
        [self croak_completeOnMainWithObject:nil response:HTTPResponse error:error completed:completed];
        return;
    }

    if (!HTTPResponse) {
        NSError *responseError = [self croak_errorWithCode:CroakNetworkErrorInvalidResponse
                                                   message:@"Invalid server response."
                                                  response:nil
                                              responseBody:data];
        [self croak_completeOnMainWithObject:nil response:nil error:responseError completed:completed];
        return;
    }

    id responseObject = [self croak_responseObjectWithData:data];
    if (HTTPResponse.statusCode < 200 || HTTPResponse.statusCode >= 300) {
        NSString *message = [self croak_errorMessageFromResponseObject:responseObject] ?: @"Request failed.";
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

- (id)croak_responseObjectWithData:(NSData *)data {
    if (data.length == 0) {
        return nil;
    }

    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if (jsonObject) {
        return jsonObject;
    }

    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
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
