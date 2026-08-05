#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^CroakAppDataCompletion)(NSError * _Nullable error);
typedef void (^CroakAppDataUserCompletion)(NSDictionary<NSString *, id> * _Nullable userInfo,
                                           NSError * _Nullable error);
typedef void (^CroakAppDataUsersCompletion)(NSArray<NSDictionary<NSString *, id> *> *users,
                                            NSError * _Nullable error);
typedef void (^CroakAppDataLikeCompletion)(NSDictionary<NSString *, id> * _Nullable postInfo,
                                           BOOL liked,
                                           NSError * _Nullable error);
typedef void (^CroakAppDataMessageCompletion)(NSDictionary<NSString *, id> * _Nullable messageInfo,
                                              NSError * _Nullable error);
typedef void (^CroakAppDataCommentCompletion)(NSDictionary<NSString *, id> * _Nullable commentInfo,
                                              NSDictionary<NSString *, id> * _Nullable postInfo,
                                              NSError * _Nullable error);

@interface Croak_AppDataStore : NSObject

@property (nonatomic, strong, readonly, nullable) NSMutableDictionary<NSString *, id> *croak_dataLayer;
@property (nonatomic, assign, readonly, getter=croak_isLoaded) BOOL croak_loaded;
@property (nonatomic, assign, readonly, getter=croak_isLoading) BOOL croak_loading;

+ (instancetype)sharedStore;

- (void)croak_fetchAllDataWithCompletion:(CroakAppDataCompletion)completion;

- (void)croak_loginWithAccount:(NSString *)account
                       password:(NSString *)password
                     completion:(CroakAppDataUserCompletion)completion;

- (void)croak_registerWithAccount:(NSString *)account
                          password:(NSString *)password
                        completion:(CroakAppDataUserCompletion)completion;

- (void)croak_updateCurrentUserWithDisplayName:(NSString *)displayName
                                      birthday:(nullable NSDate *)birthday
                                    completion:(CroakAppDataUserCompletion)completion;

- (void)croak_deleteAccount:(NSString *)account
                  completion:(CroakAppDataCompletion)completion;

- (void)croak_fetchFriendsForAccount:(NSString *)account
                           completion:(CroakAppDataUsersCompletion)completion;

- (void)croak_fetchSearchUsersForAccount:(NSString *)account
                               completion:(CroakAppDataUsersCompletion)completion;

- (void)croak_fetchFollowBackRequestsForAccount:(NSString *)account
                                      completion:(CroakAppDataUsersCompletion)completion;

- (void)croak_followUser:(NSDictionary<NSString *, id> *)userInfo
                 account:(NSString *)account
              completion:(CroakAppDataCompletion)completion;

- (BOOL)croak_userInfo:(NSDictionary<NSString *, id> *)userInfo
    isFriendForAccount:(NSString *)account;

- (BOOL)croak_userInfo:(NSDictionary<NSString *, id> *)userInfo
 isFollowingForAccount:(NSString *)account;

- (void)croak_fetchFriendPostsForAccount:(NSString *)account
                               completion:(CroakAppDataUsersCompletion)completion;

- (NSArray<NSDictionary<NSString *, id> *> *)croak_chatSessionsForAccount:(NSString *)account;

- (void)croak_fetchChatSessionsForAccount:(NSString *)account
                               completion:(CroakAppDataUsersCompletion)completion;

- (NSArray<NSDictionary<NSString *, id> *> *)croak_chatMessagesForSessionId:(NSString *)sessionId;

- (void)croak_saveLocalChatMessage:(NSString *)message
                          sessionId:(NSString *)sessionId
                       senderUserId:(NSString *)senderUserId
                          completion:(CroakAppDataMessageCompletion)completion;

- (void)croak_saveLocalChatImageName:(NSString *)imageName
                            sessionId:(NSString *)sessionId
                         senderUserId:(NSString *)senderUserId
                            completion:(CroakAppDataMessageCompletion)completion;

- (void)croak_toggleLikeForPost:(NSDictionary<NSString *, id> *)postInfo
                         account:(NSString *)account
                      completion:(CroakAppDataLikeCompletion)completion;

- (void)croak_deletePost:(NSDictionary<NSString *, id> *)postInfo
                 account:(NSString *)account
              completion:(CroakAppDataCompletion)completion;

- (NSArray<NSDictionary<NSString *, id> *> *)croak_commentsForPost:(NSDictionary<NSString *, id> *)postInfo;

- (void)croak_saveComment:(NSString *)comment
                  forPost:(NSDictionary<NSString *, id> *)postInfo
                  account:(NSString *)account
               completion:(CroakAppDataCommentCompletion)completion;

- (void)croak_blockUser:(NSDictionary<NSString *, id> *)userInfo
                account:(NSString *)account
             completion:(CroakAppDataCompletion)completion;

- (void)croak_unblockUserId:(NSString *)userId
                    account:(NSString *)account
                 completion:(CroakAppDataCompletion)completion;

- (NSArray<NSDictionary<NSString *, id> *> *)croak_blockedUsersForAccount:(NSString *)account;

- (NSString *)croak_likedUserNamesFromPostInfo:(NSDictionary<NSString *, id> *)postInfo
                                currentAccount:(nullable NSString *)account;

- (NSString *)croak_displayNameForAccount:(nullable NSString *)account;

- (nullable NSDictionary<NSString *, id> *)croak_currentUserInfo;
- (NSString *)croak_currentUserId;
- (NSString *)croak_currentAvatarName;
- (NSString *)croak_currentDisplayName;

@end

NS_ASSUME_NONNULL_END
