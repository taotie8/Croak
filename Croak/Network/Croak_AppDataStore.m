#import "Croak_AppDataStore.h"
#import "Croak_API.h"
#import "Croak_NetworkManager.h"
#import "Croak_UserSession.h"

static NSString * const CroakAppDataStoreErrorDomain = @"CroakAppDataStoreErrorDomain";
static NSString * const CroakAppDataStoreLocalChatMessagesDefaultsKey = @"CroakAppDataStoreLocalChatMessagesDefaultsKey";
static NSString * const CroakAppDataStoreBlockedUsersDefaultsKey = @"CroakAppDataStoreBlockedUsersDefaultsKey";

typedef NS_ENUM(NSInteger, CroakAppDataStoreErrorCode) {
    CroakAppDataStoreErrorInvalidInput = -20002,
    CroakAppDataStoreErrorInvalidCredential = -20003,
    CroakAppDataStoreErrorUserExists = -20004,
    CroakAppDataStoreErrorSaveFailed = -20005,
};

typedef NSArray<NSDictionary<NSString *, id> *> * _Nonnull (^CroakAppDataUsersBuilder)(NSString *trimmedAccount);

@interface Croak_AppDataStore ()

@property (nonatomic, strong, nullable) NSMutableDictionary<NSString *, id> *croak_dataLayer;
@property (nonatomic, assign, getter=croak_isLoaded) BOOL croak_loaded;
@property (nonatomic, assign, getter=croak_isLoading) BOOL croak_loading;
@property (nonatomic, strong, nullable) NSURLSessionDataTask *croak_fetchTask;
@property (nonatomic, strong, nullable) NSURLSessionDataTask *croak_saveTask;
@property (nonatomic, strong) NSMutableArray *croak_fetchCompletions;

@end

@implementation Croak_AppDataStore

+ (instancetype)sharedStore {
    static Croak_AppDataStore *store = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[Croak_AppDataStore alloc] init];
    });
    return store;
}

- (void)croak_fetchAllDataWithCompletion:(CroakAppDataCompletion)completion {
    if (completion) {
        if (!self.croak_fetchCompletions) {
            self.croak_fetchCompletions = [NSMutableArray array];
        }
        [self.croak_fetchCompletions addObject:[completion copy]];
    }

    if (self.croak_isLoading) {
        return;
    }

    self.croak_loading = YES;
    __weak typeof(self) weakSelf = self;
    self.croak_fetchTask = [[Croak_NetworkManager sharedManager] croak_GET:CroakAPIPathHomeData
                                                                parameters:nil
                                                                 completed:^(id responseObject, NSHTTPURLResponse *response, NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) {
            return;
        }

        self.croak_loading = NO;
        self.croak_fetchTask = nil;

        if (error) {
            [self croak_completePendingFetchesWithError:error];
            return;
        }

        [self croak_updateWithResponseObject:responseObject];
        [self croak_completePendingFetchesWithError:nil];
    }];
}

- (void)croak_completePendingFetchesWithError:(NSError *)error {
    NSArray *completions = [self.croak_fetchCompletions copy];
    [self.croak_fetchCompletions removeAllObjects];
    for (CroakAppDataCompletion completion in completions) {
        completion(error);
    }
}

- (void)croak_loginWithAccount:(NSString *)account
                       password:(NSString *)password
                     completion:(CroakAppDataUserCompletion)completion {
    NSString *trimmedAccount = [self croak_trimmedString:account];
    NSString *trimmedPassword = [self croak_trimmedString:password];
    NSError *inputError = [self croak_inputErrorWithAccount:trimmedAccount password:trimmedPassword];
    if (inputError) {
        if (completion) {
            completion(nil, inputError);
        }
        return;
    }

    [self croak_fetchAllDataWithCompletion:^(NSError *error) {
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }

        NSDictionary<NSString *, id> *userInfo = [self croak_userWithAccount:trimmedAccount];
        NSString *storedPassword = [self croak_passwordFromUserInfo:userInfo];
        if (!userInfo || ![storedPassword isEqualToString:trimmedPassword]) {
            if (completion) {
                completion(nil, [self croak_errorWithCode:CroakAppDataStoreErrorInvalidCredential
                                                  message:@"Account or password is incorrect."]);
            }
            return;
        }

        if (completion) {
            completion(userInfo, nil);
        }
    }];
}

- (void)croak_registerWithAccount:(NSString *)account
                          password:(NSString *)password
                        completion:(CroakAppDataUserCompletion)completion {
    NSString *trimmedAccount = [self croak_trimmedString:account];
    NSString *trimmedPassword = [self croak_trimmedString:password];
    NSError *inputError = [self croak_inputErrorWithAccount:trimmedAccount password:trimmedPassword];
    if (inputError) {
        if (completion) {
            completion(nil, inputError);
        }
        return;
    }

    [self croak_fetchAllDataWithCompletion:^(NSError *error) {
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }

        if ([self croak_userWithAccount:trimmedAccount]) {
            if (completion) {
                completion(nil, [self croak_errorWithCode:CroakAppDataStoreErrorUserExists
                                                  message:@"This user already exists."]);
            }
            return;
        }

        NSMutableArray<NSMutableDictionary<NSString *, id> *> *users = [self croak_mutableUsersArrayCreatingIfNeeded:YES];
        NSString *userId = NSUUID.UUID.UUIDString;
        NSMutableDictionary<NSString *, id> *newUser = [@{
            @"iif": userId,
            @"el": [self croak_ISO8601StringFromDate:NSDate.date],
            @"kewgxwk": trimmedAccount,
            @"sopvugh": trimmedPassword,
            @"kjvmvsaz": trimmedAccount,
            @"fsuv": @"croak_avatar"
        } mutableCopy];
        [users addObject:newUser];

        [self croak_saveDataLayerWithCompletion:^(NSError *saveError) {
            if (saveError) {
                [users removeObject:newUser];
                if (completion) {
                    completion(nil, saveError);
                }
                return;
            }

            if (completion) {
                completion(newUser, nil);
            }
        }];
    }];
}

- (void)croak_deleteAccount:(NSString *)account
                  completion:(CroakAppDataCompletion)completion {
    NSString *trimmedAccount = [self croak_trimmedString:account];
    if (trimmedAccount.length == 0) {
        if (completion) {
            completion([self croak_errorWithCode:CroakAppDataStoreErrorInvalidInput
                                         message:@"Please log in first."]);
        }
        return;
    }

    [self croak_fetchAllDataWithCompletion:^(NSError *error) {
        if (error) {
            if (completion) {
                completion(error);
            }
            return;
        }

        NSDictionary<NSString *, id> *userInfo = [self croak_userWithAccount:trimmedAccount];
        if (!userInfo) {
            if (completion) {
                completion([self croak_errorWithCode:CroakAppDataStoreErrorInvalidInput
                                             message:@"Account does not exist."]);
            }
            return;
        }

        NSString *userId = [self croak_userIdFromUserInfo:userInfo];
        NSMutableArray<NSMutableDictionary<NSString *, id> *> *users = [self croak_mutableUsersArrayCreatingIfNeeded:NO];
        NSMutableArray *removedUsers = [NSMutableArray array];
        for (NSInteger index = (NSInteger)users.count - 1; index >= 0; index--) {
            NSDictionary<NSString *, id> *candidate = users[(NSUInteger)index];
            NSString *candidateAccount = [[self croak_stringFromValue:candidate[@"kewgxwk"]] lowercaseString];
            NSString *candidateUserId = [self croak_userIdFromUserInfo:candidate];
            if ([candidateAccount isEqualToString:[trimmedAccount lowercaseString]] ||
                (userId.length > 0 && [candidateUserId isEqualToString:userId])) {
                [removedUsers addObject:candidate];
                [users removeObjectAtIndex:(NSUInteger)index];
            }
        }

        NSArray *removedRelations = [self croak_removeFollowRelationsForUserId:userId];

        [self croak_saveDataLayerWithCompletion:^(NSError *saveError) {
            if (saveError) {
                [users addObjectsFromArray:removedUsers];
                [self croak_restoreFollowRelations:removedRelations];
                if (completion) {
                    completion(saveError);
                }
                return;
            }

            if (completion) {
                completion(nil);
            }
        }];
    }];
}

- (NSArray<NSDictionary<NSString *, id> *> *)croak_friendsForAccount:(NSString *)account {
    NSString *trimmedAccount = [self croak_trimmedString:account];
    NSDictionary<NSString *, id> *currentUser = [self croak_userWithAccount:trimmedAccount];
    if (!currentUser) {
        return @[];
    }

    NSString *currentUserId = [self croak_userIdFromUserInfo:currentUser];
    if (currentUserId.length == 0) {
        return @[];
    }

    NSSet<NSString *> *friendIds = [self croak_friendUserIdsForUserId:currentUserId account:trimmedAccount];
    if (friendIds.count == 0) {
        return @[];
    }
    NSSet<NSString *> *blockedUserIds = [self croak_blockedUserIdsSetForAccount:trimmedAccount];

    NSMutableArray<NSDictionary<NSString *, id> *> *friends = [NSMutableArray array];
    for (NSDictionary<NSString *, id> *userInfo in [self croak_userRecords]) {
        if (![userInfo isKindOfClass:NSDictionary.class]) {
            continue;
        }

        NSString *candidateUserId = [self croak_userIdFromUserInfo:userInfo];
        if ([friendIds containsObject:candidateUserId] && ![blockedUserIds containsObject:candidateUserId]) {
            [friends addObject:userInfo];
        }
    }


    return friends;
}

- (void)croak_fetchFriendsForAccount:(NSString *)account
                           completion:(CroakAppDataUsersCompletion)completion {
    [self croak_fetchUsersResultForAccount:account
                                   builder:^NSArray<NSDictionary<NSString *,id> *> *(NSString *trimmedAccount) {
        return [self croak_friendsForAccount:trimmedAccount];
    } completion:completion];
}

- (NSArray<NSDictionary<NSString *, id> *> *)croak_searchUsersForAccount:(NSString *)account {
    NSString *trimmedAccount = [self croak_trimmedString:account];
    NSDictionary<NSString *, id> *currentUser = [self croak_userWithAccount:trimmedAccount];
    NSString *currentUserId = [self croak_userIdFromUserInfo:currentUser];
    if (currentUserId.length == 0) {
        return @[];
    }

    NSSet<NSString *> *blockedUserIds = [self croak_blockedUserIdsSetForAccount:trimmedAccount];
    NSMutableArray<NSDictionary<NSString *, id> *> *users = [NSMutableArray array];
    for (NSDictionary<NSString *, id> *userInfo in [self croak_userRecords]) {
        NSString *userId = [self croak_userIdFromUserInfo:userInfo];
        if (userId.length == 0 || [userId isEqualToString:currentUserId] || [blockedUserIds containsObject:userId]) {
            continue;
        }
        [users addObject:userInfo];
    }
    return users;
}

- (void)croak_fetchSearchUsersForAccount:(NSString *)account
                               completion:(CroakAppDataUsersCompletion)completion {
    [self croak_fetchUsersResultForAccount:account
                                   builder:^NSArray<NSDictionary<NSString *,id> *> *(NSString *trimmedAccount) {
        return [self croak_searchUsersForAccount:trimmedAccount];
    } completion:completion];
}

- (NSArray<NSDictionary<NSString *, id> *> *)croak_followBackRequestsForAccount:(NSString *)account {
    NSString *trimmedAccount = [self croak_trimmedString:account];
    NSDictionary<NSString *, id> *currentUser = [self croak_userWithAccount:trimmedAccount];
    NSString *currentUserId = [self croak_userIdFromUserInfo:currentUser];
    if (currentUserId.length == 0) {
        return @[];
    }

    NSMutableSet<NSString *> *followerIds = [NSMutableSet set];
    NSMutableSet<NSString *> *followingIds = [NSMutableSet set];
    for (NSDictionary<NSString *, id> *relationInfo in [self croak_followRelations]) {
        NSString *sourceUserId = [self croak_sourceUserIdFromRelationInfo:relationInfo];
        NSString *targetUserId = [self croak_targetUserIdFromRelationInfo:relationInfo];
        if (sourceUserId.length == 0 || targetUserId.length == 0) {
            continue;
        }

        if ([targetUserId isEqualToString:currentUserId]) {
            [followerIds addObject:sourceUserId];
        }
        if ([sourceUserId isEqualToString:currentUserId]) {
            [followingIds addObject:targetUserId];
        }
    }

    [followerIds minusSet:followingIds];
    [followerIds removeObject:currentUserId];
    [followerIds minusSet:[self croak_blockedUserIdsSetForAccount:trimmedAccount]];
    if (followerIds.count == 0) {
        return @[];
    }

    NSMutableArray<NSDictionary<NSString *, id> *> *requests = [NSMutableArray array];
    for (NSDictionary<NSString *, id> *userInfo in [self croak_userRecords]) {
        NSString *userId = [self croak_userIdFromUserInfo:userInfo];
        if ([followerIds containsObject:userId]) {
            [requests addObject:userInfo];
        }
    }
    return requests;
}

- (void)croak_fetchFollowBackRequestsForAccount:(NSString *)account
                                      completion:(CroakAppDataUsersCompletion)completion {
    [self croak_fetchUsersResultForAccount:account
                                   builder:^NSArray<NSDictionary<NSString *,id> *> *(NSString *trimmedAccount) {
        return [self croak_followBackRequestsForAccount:trimmedAccount];
    } completion:completion];
}

- (void)croak_followUser:(NSDictionary<NSString *, id> *)userInfo
                 account:(NSString *)account
              completion:(CroakAppDataCompletion)completion {
    NSString *trimmedAccount = [self croak_trimmedString:account];
    NSString *targetUserId = [self croak_userIdFromUserInfo:userInfo];
    if (trimmedAccount.length == 0) {
        if (completion) {
            completion([self croak_errorWithCode:CroakAppDataStoreErrorInvalidInput
                                         message:@"Please log in first."]);
        }
        return;
    }
    if (targetUserId.length == 0) {
        if (completion) {
            completion([self croak_errorWithCode:CroakAppDataStoreErrorInvalidInput
                                         message:@"User does not exist."]);
        }
        return;
    }

    [self croak_fetchAllDataWithCompletion:^(NSError *error) {
        if (error) {
            if (completion) {
                completion(error);
            }
            return;
        }

        NSDictionary<NSString *, id> *currentUser = [self croak_userWithAccount:trimmedAccount];
        NSString *currentUserId = [self croak_userIdFromUserInfo:currentUser];
        if (currentUserId.length == 0) {
            if (completion) {
                completion([self croak_errorWithCode:CroakAppDataStoreErrorInvalidInput
                                             message:@"Please log in first."]);
            }
            return;
        }
        if ([currentUserId isEqualToString:targetUserId]) {
            if (completion) {
                completion([self croak_errorWithCode:CroakAppDataStoreErrorInvalidInput
                                             message:@"You cannot add yourself."]);
            }
            return;
        }
        if (![self croak_userWithUserId:targetUserId]) {
            if (completion) {
                completion([self croak_errorWithCode:CroakAppDataStoreErrorInvalidInput
                                             message:@"User does not exist."]);
            }
            return;
        }

        NSMutableArray *relations = [self croak_mutableFollowRelationsArray];
        if (!relations) {
            relations = [NSMutableArray array];
            self.croak_dataLayer[@"tqdee"] = relations;
        }

        for (NSDictionary<NSString *, id> *relationInfo in relations) {
            NSString *sourceUserId = [self croak_sourceUserIdFromRelationInfo:relationInfo];
            NSString *followedUserId = [self croak_targetUserIdFromRelationInfo:relationInfo];
            if ([sourceUserId isEqualToString:currentUserId] && [followedUserId isEqualToString:targetUserId]) {
                if (completion) {
                    completion(nil);
                }
                return;
            }
        }

        NSDictionary<NSString *, id> *newRelation = @{
            @"fc": currentUserId,
            @"bmyiz": targetUserId
        };
        [relations addObject:[newRelation mutableCopy]];

        [self croak_saveDataLayerWithCompletion:^(NSError *saveError) {
            if (saveError) {
                [relations removeObject:newRelation];
                if (completion) {
                    completion(saveError);
                }
                return;
            }

            if (completion) {
                completion(nil);
            }
        }];
    }];
}

- (BOOL)croak_userInfo:(NSDictionary<NSString *, id> *)userInfo
    isFriendForAccount:(NSString *)account {
    NSString *trimmedAccount = [self croak_trimmedString:account];
    NSString *targetUserId = [self croak_userIdFromUserInfo:userInfo];
    NSDictionary<NSString *, id> *currentUser = [self croak_userWithAccount:trimmedAccount];
    NSString *currentUserId = [self croak_userIdFromUserInfo:currentUser];
    if (currentUserId.length == 0 || targetUserId.length == 0) {
        return NO;
    }

    return [[self croak_friendUserIdsForUserId:currentUserId account:trimmedAccount] containsObject:targetUserId];
}

- (BOOL)croak_userInfo:(NSDictionary<NSString *, id> *)userInfo
 isFollowingForAccount:(NSString *)account {
    NSString *trimmedAccount = [self croak_trimmedString:account];
    NSString *targetUserId = [self croak_userIdFromUserInfo:userInfo];
    NSDictionary<NSString *, id> *currentUser = [self croak_userWithAccount:trimmedAccount];
    NSString *currentUserId = [self croak_userIdFromUserInfo:currentUser];
    if (currentUserId.length == 0 || targetUserId.length == 0) {
        return NO;
    }

    for (NSDictionary<NSString *, id> *relationInfo in [self croak_followRelations]) {
        NSString *sourceUserId = [self croak_sourceUserIdFromRelationInfo:relationInfo];
        NSString *followedUserId = [self croak_targetUserIdFromRelationInfo:relationInfo];
        if ([sourceUserId isEqualToString:currentUserId] && [followedUserId isEqualToString:targetUserId]) {
            return YES;
        }
    }
    return NO;
}

- (NSArray<NSDictionary<NSString *, id> *> *)croak_friendPostsForAccount:(NSString *)account {
    NSString *trimmedAccount = [self croak_trimmedString:account];
    NSDictionary<NSString *, id> *currentUser = [self croak_userWithAccount:trimmedAccount];
    if (!currentUser) {
        return @[];
    }

    NSString *currentUserId = [self croak_userIdFromUserInfo:currentUser];
    if (currentUserId.length == 0) {
        return @[];
    }

    NSSet<NSString *> *friendIds = [self croak_friendUserIdsForUserId:currentUserId account:trimmedAccount];
    if (friendIds.count == 0) {
        return @[];
    }
    NSSet<NSString *> *blockedUserIds = [self croak_blockedUserIdsSetForAccount:trimmedAccount];

    NSMutableDictionary<NSString *, NSDictionary<NSString *, id> *> *usersById = [NSMutableDictionary dictionary];
    for (NSDictionary<NSString *, id> *userInfo in [self croak_userRecords]) {
        NSString *userId = [self croak_userIdFromUserInfo:userInfo];
        if (userId.length > 0) {
            usersById[userId] = userInfo;
        }
    }

    NSMutableArray<NSDictionary<NSString *, id> *> *friendPosts = [NSMutableArray array];
    for (NSDictionary<NSString *, id> *postInfo in [self croak_posts]) {
        NSString *postUserId = [self croak_postUserIdFromPostInfo:postInfo];
        if (![friendIds containsObject:postUserId] || [blockedUserIds containsObject:postUserId]) {
            continue;
        }

        NSDictionary<NSString *, id> *authorInfo = usersById[postUserId] ?: @{};
        [friendPosts addObject:@{@"post": postInfo, @"user": authorInfo}];
    }

    [friendPosts sortUsingComparator:^NSComparisonResult(NSDictionary<NSString *, id> *firstObject,
                                                         NSDictionary<NSString *, id> *secondObject) {
        NSString *firstDate = [self croak_postCreatedAtFromPostInfo:firstObject[@"post"]];
        NSString *secondDate = [self croak_postCreatedAtFromPostInfo:secondObject[@"post"]];
        return [secondDate compare:firstDate];
    }];


    return friendPosts;
}

- (void)croak_fetchFriendPostsForAccount:(NSString *)account
                               completion:(CroakAppDataUsersCompletion)completion {
    [self croak_fetchUsersResultForAccount:account
                                   builder:^NSArray<NSDictionary<NSString *,id> *> *(NSString *trimmedAccount) {
        return [self croak_friendPostsForAccount:trimmedAccount];
    } completion:completion];
}

- (NSArray<NSDictionary<NSString *, id> *> *)croak_chatSessionsForAccount:(NSString *)account {
    NSString *trimmedAccount = [self croak_trimmedString:account];
    NSDictionary<NSString *, id> *currentUser = [self croak_userWithAccount:trimmedAccount];
    NSString *currentUserId = [self croak_userIdFromUserInfo:currentUser];
    if (currentUserId.length == 0) {
        return @[];
    }

    NSMutableArray<NSDictionary<NSString *, id> *> *chatSessions = [NSMutableArray array];
    for (NSDictionary<NSString *, id> *sessionInfo in [self croak_chatSessionRecords]) {
        if (![self croak_chatSession:sessionInfo containsUserId:currentUserId]) {
            continue;
        }

        NSString *sessionId = [self croak_chatSessionIdFromSessionInfo:sessionInfo];
        NSArray<NSDictionary<NSString *, id> *> *messages = [self croak_chatMessagesForSessionId:sessionId
                                                                                 localOwnerUserId:currentUserId];
        NSDictionary<NSString *, id> *lastMessageInfo = messages.lastObject;
        NSString *otherUserId = [self croak_otherUserIdInChatSession:sessionInfo currentUserId:currentUserId];
        NSDictionary<NSString *, id> *otherUserInfo = [self croak_userWithUserId:otherUserId] ?: @{};
        NSString *lastMessage = [self croak_chatMessageContentFromMessageInfo:lastMessageInfo];
        if (lastMessage.length == 0) {
            lastMessage = [self croak_chatSessionLastMessageFromSessionInfo:sessionInfo];
        }
        NSString *lastMessageTime = [self croak_chatMessageSentAtFromMessageInfo:lastMessageInfo];
        if (lastMessageTime.length == 0) {
            lastMessageTime = [self croak_chatSessionLastMessageTimeFromSessionInfo:sessionInfo];
        }
        if (lastMessageTime.length == 0) {
            lastMessageTime = [self croak_chatSessionCreatedAtFromSessionInfo:sessionInfo];
        }

        NSMutableDictionary<NSString *, id> *chatItem = [NSMutableDictionary dictionary];
        chatItem[@"session"] = sessionInfo;
        chatItem[@"user"] = otherUserInfo;
        chatItem[@"messages"] = messages ?: @[];
        chatItem[@"lastMessage"] = lastMessage ?: @"";
        chatItem[@"lastMessageTime"] = lastMessageTime ?: @"";
        [chatSessions addObject:chatItem];
    }

    [chatSessions sortUsingComparator:^NSComparisonResult(NSDictionary<NSString *, id> *firstObject,
                                                          NSDictionary<NSString *, id> *secondObject) {
        NSString *firstDate = [self croak_stringFromValue:firstObject[@"lastMessageTime"]];
        NSString *secondDate = [self croak_stringFromValue:secondObject[@"lastMessageTime"]];
        return [secondDate compare:firstDate];
    }];


    return chatSessions;
}

- (void)croak_fetchChatSessionsForAccount:(NSString *)account
                               completion:(CroakAppDataUsersCompletion)completion {
    [self croak_fetchUsersResultForAccount:account
                                   builder:^NSArray<NSDictionary<NSString *,id> *> *(NSString *trimmedAccount) {
        return [self croak_chatSessionsForAccount:trimmedAccount];
    } completion:completion];
}

- (void)croak_fetchUsersResultForAccount:(NSString *)account
                                 builder:(CroakAppDataUsersBuilder)builder
                              completion:(CroakAppDataUsersCompletion)completion {
    NSString *trimmedAccount = [self croak_trimmedString:account];
    if (trimmedAccount.length == 0) {
        if (completion) {
            completion(@[], [self croak_errorWithCode:CroakAppDataStoreErrorInvalidInput
                                              message:@"Please log in first."]);
        }
        return;
    }

    [self croak_fetchAllDataWithCompletion:^(NSError *error) {
        if (error) {
            if (completion) {
                completion(@[], error);
            }
            return;
        }

        if (completion) {
            NSArray<NSDictionary<NSString *, id> *> *users = builder ? builder(trimmedAccount) : @[];
            completion(users ?: @[], nil);
        }
    }];
}

- (NSArray<NSDictionary<NSString *, id> *> *)croak_chatMessagesForSessionId:(NSString *)sessionId {
    return [self croak_chatMessagesForSessionId:sessionId localOwnerUserId:nil];
}

- (NSArray<NSDictionary<NSString *, id> *> *)croak_chatMessagesForSessionId:(NSString *)sessionId
                                                            localOwnerUserId:(NSString *)ownerUserId {
    NSString *targetSessionId = [self croak_stringFromValue:sessionId];
    if (targetSessionId.length == 0) {
        return @[];
    }

    NSMutableArray<NSDictionary<NSString *, id> *> *messages = [NSMutableArray array];
    for (NSDictionary<NSString *, id> *messageInfo in [self croak_chatMessageRecords]) {
        if ([[self croak_chatMessageSessionIdFromMessageInfo:messageInfo] isEqualToString:targetSessionId]) {
            [messages addObject:messageInfo];
        }
    }
    [messages addObjectsFromArray:[self croak_localChatMessagesForSessionId:targetSessionId
                                                               ownerUserId:ownerUserId]];

    [messages sortUsingComparator:^NSComparisonResult(NSDictionary<NSString *, id> *firstObject,
                                                      NSDictionary<NSString *, id> *secondObject) {
        NSString *firstDate = [self croak_chatMessageSentAtFromMessageInfo:firstObject];
        NSString *secondDate = [self croak_chatMessageSentAtFromMessageInfo:secondObject];
        return [firstDate compare:secondDate];
    }];
    return messages;
}

- (void)croak_saveLocalChatMessage:(NSString *)message
                          sessionId:(NSString *)sessionId
                       senderUserId:(NSString *)senderUserId
                          completion:(CroakAppDataMessageCompletion)completion {
    NSString *trimmedMessage = [self croak_stringFromValue:message];
    if (trimmedMessage.length == 0) {
        if (completion) {
            completion(nil, [self croak_errorWithCode:CroakAppDataStoreErrorInvalidInput
                                              message:@"Please enter a message."]);
        }
        return;
    }

    [self croak_saveLocalChatRecordWithContent:trimmedMessage
                                     imageName:nil
                                     localType:@"text"
                                     sessionId:sessionId
                                  senderUserId:senderUserId
                                    completion:completion];
}

- (void)croak_saveLocalChatImageName:(NSString *)imageName
                            sessionId:(NSString *)sessionId
                         senderUserId:(NSString *)senderUserId
                            completion:(CroakAppDataMessageCompletion)completion {
    NSString *targetImageName = [self croak_stringFromValue:imageName];
    if (targetImageName.length == 0) {
        if (completion) {
            completion(nil, [self croak_errorWithCode:CroakAppDataStoreErrorInvalidInput
                                              message:@"Image does not exist."]);
        }
        return;
    }

    [self croak_saveLocalChatRecordWithContent:@"[Image]"
                                     imageName:targetImageName
                                     localType:@"image"
                                     sessionId:sessionId
                                  senderUserId:senderUserId
                                    completion:completion];
}

- (void)croak_saveLocalChatRecordWithContent:(NSString *)content
                                   imageName:(NSString *)imageName
                                   localType:(NSString *)localType
                                   sessionId:(NSString *)sessionId
                                senderUserId:(NSString *)senderUserId
                                  completion:(CroakAppDataMessageCompletion)completion {
    NSString *targetContent = [self croak_stringFromValue:content];
    NSString *targetImageName = [self croak_stringFromValue:imageName];
    NSString *targetType = [self croak_stringFromValue:localType];
    NSString *targetSessionId = [self croak_stringFromValue:sessionId];
    NSString *normalizedSenderUserId = [self croak_normalizedIdFromValue:senderUserId];
    if (targetSessionId.length == 0) {
        if (completion) {
            completion(nil, [self croak_errorWithCode:CroakAppDataStoreErrorInvalidInput
                                              message:@"Chat session does not exist."]);
        }
        return;
    }
    if (normalizedSenderUserId.length == 0) {
        if (completion) {
            completion(nil, [self croak_errorWithCode:CroakAppDataStoreErrorInvalidInput
                                              message:@"Please log in first."]);
        }
        return;
    }

    NSString *sentAt = [self croak_ISO8601StringFromDate:NSDate.date];
    NSMutableDictionary<NSString *, id> *newMessage = [@{
        @"yvxcc": NSUUID.UUID.UUIDString,
        @"uvz": targetSessionId,
        @"jhrrdwm": normalizedSenderUserId,
        @"syuvoah": targetContent,
        @"orakb": @(NO),
        @"bhvw": sentAt,
        @"xteio": sentAt,
        @"croakLocalOwnerUserId": normalizedSenderUserId,
        @"croakLocalType": targetType
    } mutableCopy];
    if (targetImageName.length > 0) {
        newMessage[@"croakLocalImageName"] = targetImageName;
    }


    NSMutableArray<NSDictionary<NSString *, id> *> *localMessages = [[self croak_localChatMessageRecords] mutableCopy];
    [localMessages addObject:newMessage];
    [NSUserDefaults.standardUserDefaults setObject:localMessages forKey:CroakAppDataStoreLocalChatMessagesDefaultsKey];
    [NSUserDefaults.standardUserDefaults synchronize];

    if (completion) {
        completion(newMessage, nil);
    }
}

- (void)croak_toggleLikeForPost:(NSDictionary<NSString *, id> *)postInfo
                         account:(NSString *)account
                      completion:(CroakAppDataLikeCompletion)completion {
    NSString *trimmedAccount = [self croak_trimmedString:account];
    if (trimmedAccount.length == 0) {
        if (completion) {
            completion(nil, NO, [self croak_errorWithCode:CroakAppDataStoreErrorInvalidInput
                                                  message:@"Please log in first."]);
        }
        return;
    }

    [self croak_fetchAllDataWithCompletion:^(NSError *error) {
        if (error) {
            if (completion) {
                completion(nil, NO, error);
            }
            return;
        }

        NSDictionary<NSString *, id> *currentUser = [self croak_userWithAccount:trimmedAccount];
        NSString *currentUserId = [self croak_userIdFromUserInfo:currentUser];
        if (currentUserId.length == 0) {
            if (completion) {
                completion(nil, NO, [self croak_errorWithCode:CroakAppDataStoreErrorInvalidInput
                                                      message:@"Please log in first."]);
            }
            return;
        }

        NSMutableDictionary<NSString *, id> *mutablePostInfo = [self croak_mutablePostMatchingPostInfo:postInfo];
        if (!mutablePostInfo) {
            if (completion) {
                completion(nil, NO, [self croak_errorWithCode:CroakAppDataStoreErrorInvalidInput
                                                      message:@"Post does not exist."]);
            }
            return;
        }

        NSMutableArray *likedUserIds = [self croak_mutableLikedUserIdsInPostInfo:mutablePostInfo
                                                                creatingIfNeeded:YES];
        NSArray *originalLikedUserIds = [likedUserIds copy];
        BOOL didLike = ![self croak_likedUserIds:likedUserIds containsUserId:currentUserId];
        if (didLike) {
            [likedUserIds addObject:currentUserId];
        } else {
            [self croak_removeUserId:currentUserId fromLikedUserIds:likedUserIds];
        }


        [self croak_saveDataLayerWithCompletion:^(NSError *saveError) {
            if (saveError) {
                mutablePostInfo[@"ri"] = [originalLikedUserIds mutableCopy];
                if (completion) {
                    completion(mutablePostInfo, !didLike, saveError);
                }
                return;
            }

            if (completion) {
                completion(mutablePostInfo, didLike, nil);
            }
        }];
    }];
}

- (void)croak_deletePost:(NSDictionary<NSString *, id> *)postInfo
                 account:(NSString *)account
              completion:(CroakAppDataCompletion)completion {
    NSString *trimmedAccount = [self croak_trimmedString:account];
    if (trimmedAccount.length == 0) {
        if (completion) {
            completion([self croak_errorWithCode:CroakAppDataStoreErrorInvalidInput
                                         message:@"Please log in first."]);
        }
        return;
    }

    [self croak_fetchAllDataWithCompletion:^(NSError *error) {
        if (error) {
            if (completion) {
                completion(error);
            }
            return;
        }

        NSDictionary<NSString *, id> *currentUser = [self croak_userWithAccount:trimmedAccount];
        NSString *currentUserId = [self croak_userIdFromUserInfo:currentUser];
        if (currentUserId.length == 0) {
            if (completion) {
                completion([self croak_errorWithCode:CroakAppDataStoreErrorInvalidInput
                                             message:@"Please log in first."]);
            }
            return;
        }

        NSMutableArray *posts = [self croak_mutablePostsArray];
        if (![posts isKindOfClass:NSMutableArray.class]) {
            if (completion) {
                completion([self croak_errorWithCode:CroakAppDataStoreErrorInvalidInput
                                             message:@"Post does not exist."]);
            }
            return;
        }

        NSString *postId = [self croak_postIdFromPostInfo:postInfo];
        if (postId.length == 0) {
            if (completion) {
                completion([self croak_errorWithCode:CroakAppDataStoreErrorInvalidInput
                                             message:@"Post does not exist."]);
            }
            return;
        }

        NSInteger matchedIndex = NSNotFound;
        NSMutableDictionary<NSString *, id> *matchedPostInfo = nil;
        for (NSUInteger index = 0; index < posts.count; index++) {
            id candidate = posts[index];
            if (![candidate isKindOfClass:NSMutableDictionary.class]) {
                continue;
            }

            NSMutableDictionary<NSString *, id> *candidatePostInfo = candidate;
            NSString *candidatePostId = [self croak_postIdFromPostInfo:candidatePostInfo];
            if ([candidatePostId isEqualToString:postId]) {
                matchedIndex = (NSInteger)index;
                matchedPostInfo = candidatePostInfo;
                break;
            }
        }

        if (matchedIndex == NSNotFound || !matchedPostInfo) {
            if (completion) {
                completion([self croak_errorWithCode:CroakAppDataStoreErrorInvalidInput
                                             message:@"Post does not exist."]);
            }
            return;
        }

        NSString *postUserId = [self croak_postUserIdFromPostInfo:matchedPostInfo];
        if (postUserId.length == 0 || ![postUserId isEqualToString:currentUserId]) {
            if (completion) {
                completion([self croak_errorWithCode:CroakAppDataStoreErrorInvalidInput
                                             message:@"You can only delete your own post."]);
            }
            return;
        }

        NSDictionary<NSString *, id> *removedPostInfo = [matchedPostInfo copy];
        [posts removeObjectAtIndex:(NSUInteger)matchedIndex];


        [self croak_saveDataLayerWithCompletion:^(NSError *saveError) {
            if (saveError) {
                [posts insertObject:[removedPostInfo mutableCopy] atIndex:(NSUInteger)matchedIndex];
                if (completion) {
                    completion(saveError);
                }
                return;
            }

            if (completion) {
                completion(nil);
            }
        }];
    }];
}

- (void)croak_blockUser:(NSDictionary<NSString *, id> *)userInfo
                account:(NSString *)account
             completion:(CroakAppDataCompletion)completion {
    NSString *ownerAccount = [self croak_normalizedAccountKey:account];
    NSString *targetUserId = [self croak_userIdFromUserInfo:userInfo];
    if (ownerAccount.length == 0) {
        if (completion) {
            completion([self croak_errorWithCode:CroakAppDataStoreErrorInvalidInput
                                         message:@"Please log in first."]);
        }
        return;
    }
    if (targetUserId.length == 0) {
        if (completion) {
            completion([self croak_errorWithCode:CroakAppDataStoreErrorInvalidInput
                                         message:@"User does not exist."]);
        }
        return;
    }

    NSString *currentUserId = [self croak_userIdForAccount:ownerAccount];
    if (currentUserId.length > 0 && [currentUserId isEqualToString:targetUserId]) {
        if (completion) {
            completion([self croak_errorWithCode:CroakAppDataStoreErrorInvalidInput
                                         message:@"You cannot block yourself."]);
        }
        return;
    }

    NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *blockedUserIdsByAccount = [self croak_mutableBlockedUserIdsByAccount];
    NSMutableArray<NSString *> *blockedUserIds = blockedUserIdsByAccount[ownerAccount];
    if (![blockedUserIds isKindOfClass:NSMutableArray.class]) {
        blockedUserIds = [NSMutableArray array];
        blockedUserIdsByAccount[ownerAccount] = blockedUserIds;
    }
    if (![blockedUserIds containsObject:targetUserId]) {
        [blockedUserIds addObject:targetUserId];
    }

    [self croak_saveBlockedUserIdsByAccount:blockedUserIdsByAccount];
    if (completion) {
        completion(nil);
    }
}

- (void)croak_unblockUserId:(NSString *)userId
                    account:(NSString *)account
                 completion:(CroakAppDataCompletion)completion {
    NSString *ownerAccount = [self croak_normalizedAccountKey:account];
    NSString *targetUserId = [self croak_normalizedIdFromValue:userId];
    if (ownerAccount.length == 0) {
        if (completion) {
            completion([self croak_errorWithCode:CroakAppDataStoreErrorInvalidInput
                                         message:@"Please log in first."]);
        }
        return;
    }

    NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *blockedUserIdsByAccount = [self croak_mutableBlockedUserIdsByAccount];
    NSMutableArray<NSString *> *blockedUserIds = blockedUserIdsByAccount[ownerAccount];
    if ([blockedUserIds isKindOfClass:NSMutableArray.class] && targetUserId.length > 0) {
        [blockedUserIds removeObject:targetUserId];
    }

    [self croak_saveBlockedUserIdsByAccount:blockedUserIdsByAccount];
    if (completion) {
        completion(nil);
    }
}

- (NSArray<NSDictionary<NSString *, id> *> *)croak_blockedUsersForAccount:(NSString *)account {
    NSSet<NSString *> *blockedUserIds = [self croak_blockedUserIdsSetForAccount:account];
    if (blockedUserIds.count == 0) {
        return @[];
    }

    NSMutableArray<NSDictionary<NSString *, id> *> *blockedUsers = [NSMutableArray array];
    for (NSDictionary<NSString *, id> *userInfo in [self croak_userRecords]) {
        NSString *userId = [self croak_userIdFromUserInfo:userInfo];
        if ([blockedUserIds containsObject:userId]) {
            [blockedUsers addObject:userInfo];
        }
    }
    return blockedUsers;
}

- (NSString *)croak_likedUserNamesFromPostInfo:(NSDictionary<NSString *, id> *)postInfo
                                currentAccount:(NSString *)account {
    NSArray *likedUserIds = [self croak_likedUserIdsFromPostInfo:postInfo];
    if (likedUserIds.count == 0) {
        return @"";
    }

    NSString *currentUserId = [self croak_userIdForAccount:account];
    NSString *currentUserName = [self croak_displayNameForAccount:account];
    NSMutableArray<NSString *> *names = [NSMutableArray array];
    for (id likedUserId in likedUserIds) {
        NSString *normalizedUserId = [self croak_normalizedIdFromValue:likedUserId];
        NSString *name = [self croak_displayNameForUserId:normalizedUserId];
        if (name.length == 0 && currentUserId.length > 0 && [normalizedUserId isEqualToString:currentUserId]) {
            name = currentUserName;
        }
        if (name.length > 0 && ![names containsObject:name]) {
            [names addObject:name];
        }
    }


    return [names componentsJoinedByString:@", "];
}

- (NSString *)croak_displayNameForAccount:(NSString *)account {
    NSString *name = [self croak_displayNameFromUserInfo:[self croak_userWithAccount:account]];
    if (name.length > 0) {
        return name;
    }

    NSString *trimmedAccount = [self croak_trimmedString:account];
    NSRange atRange = [trimmedAccount rangeOfString:@"@"];
    if (atRange.location != NSNotFound && atRange.location > 0) {
        return [trimmedAccount substringToIndex:atRange.location];
    }
    return trimmedAccount;
}

- (NSDictionary<NSString *, id> *)croak_userInfoForAccount:(NSString *)account {
    return [self croak_userWithAccount:account];
}

- (NSDictionary<NSString *, id> *)croak_currentUserInfo {
    return [self croak_userInfoForAccount:Croak_UserSession.croak_currentAccount];
}

- (NSString *)croak_currentUserId {
    return [self croak_userIdForAccount:Croak_UserSession.croak_currentAccount];
}

- (NSString *)croak_avatarNameForAccount:(NSString *)account {
    NSDictionary<NSString *, id> *userInfo = [self croak_userWithAccount:account];
    return [self croak_imageNameFromValue:userInfo[@"fsuv"]];
}

- (NSString *)croak_currentAvatarName {
    return [self croak_avatarNameForAccount:Croak_UserSession.croak_currentAccount];
}

- (NSString *)croak_currentDisplayName {
    return [self croak_displayNameForAccount:Croak_UserSession.croak_currentAccount];
}

- (NSSet<NSString *> *)croak_friendUserIdsForUserId:(NSString *)currentUserId account:(NSString *)account {
    NSArray<NSDictionary<NSString *, id> *> *relations = [self croak_followRelations];
    if (relations.count == 0) {
        return [NSSet set];
    }

    NSMutableSet<NSString *> *followingIds = [NSMutableSet set];
    NSMutableSet<NSString *> *followerIds = [NSMutableSet set];
    for (NSDictionary<NSString *, id> *relationInfo in relations) {
        NSString *sourceUserId = [self croak_sourceUserIdFromRelationInfo:relationInfo];
        NSString *targetUserId = [self croak_targetUserIdFromRelationInfo:relationInfo];
        if (sourceUserId.length == 0 || targetUserId.length == 0) {
            continue;
        }

        if ([sourceUserId isEqualToString:currentUserId]) {
            [followingIds addObject:targetUserId];
        }
        if ([targetUserId isEqualToString:currentUserId]) {
            [followerIds addObject:sourceUserId];
        }
    }

    NSMutableSet<NSString *> *friendIds = [followingIds mutableCopy];
    [friendIds intersectSet:followerIds];
    if (friendIds.count == 0) {
        return [NSSet set];
    }

    return [friendIds copy];
}

- (void)croak_saveDataLayerWithCompletion:(CroakAppDataCompletion)completion {
    if (!self.croak_dataLayer) {
        self.croak_dataLayer = [NSMutableDictionary dictionary];
    }

    __weak typeof(self) weakSelf = self;
    self.croak_saveTask = [[Croak_NetworkManager sharedManager] croak_PUT:CroakAPIPathHomeData
                                                                parameters:self.croak_dataLayer
                                                                 completed:^(id responseObject, NSHTTPURLResponse *response, NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) {
            return;
        }

        self.croak_saveTask = nil;
        if (error) {
            if (completion) {
                completion([self croak_errorWithCode:CroakAppDataStoreErrorSaveFailed
                                             message:error.localizedDescription ?: @"Failed to save data."]);
            }
            return;
        }

        if ([self croak_responseObjectContainsDataLayer:responseObject]) {
            [self croak_updateWithResponseObject:responseObject];
        }
        if (completion) {
            completion(nil);
        }
    }];
}

- (void)croak_updateWithResponseObject:(id)responseObject {
    self.croak_dataLayer = [self croak_mutableDataLayerFromResponseObject:responseObject];
    if (!self.croak_dataLayer) {
        self.croak_dataLayer = [NSMutableDictionary dictionary];
    }
    self.croak_loaded = YES;

}

- (NSMutableDictionary<NSString *, id> *)croak_mutableDataLayerFromResponseObject:(id)responseObject {
    if (![responseObject isKindOfClass:NSDictionary.class]) {
        return nil;
    }

    NSDictionary *dictionary = responseObject;
    id data = dictionary[@"data"];
    if ([data isKindOfClass:NSDictionary.class]) {
        return [self croak_mutableJSONObjectFromObject:data];
    }

    return [self croak_mutableJSONObjectFromObject:dictionary];
}

- (NSMutableDictionary *)croak_mutableJSONObjectFromObject:(NSDictionary *)object {
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithCapacity:object.count];
    [object enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        if ([value isKindOfClass:NSDictionary.class]) {
            mutableDictionary[key] = [self croak_mutableJSONObjectFromObject:value];
        }
        else if ([value isKindOfClass:NSArray.class]) {
            NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[value count]];
            for (id item in value) {
                if ([item isKindOfClass:NSDictionary.class]) {
                    [mutableArray addObject:[self croak_mutableJSONObjectFromObject:item]];
                } else {
                    [mutableArray addObject:item];
                }
            }
            mutableDictionary[key] = mutableArray;
        }
        else if (value) {
            mutableDictionary[key] = value;
        }
    }];
    return mutableDictionary;
}

- (BOOL)croak_responseObjectContainsDataLayer:(id)responseObject {
    if (![responseObject isKindOfClass:NSDictionary.class]) {
        return NO;
    }

    NSDictionary *dictionary = responseObject;
    if ([dictionary[@"data"] isKindOfClass:NSDictionary.class]) {
        return YES;
    }

    NSArray<NSString *> *dataKeys = @[@"hok", @"tqdee", @"fcfmx", @"zfbo", @"lcknfxsa"];
    for (NSString *key in dataKeys) {
        if (dictionary[key]) {
            return YES;
        }
    }

    return NO;
}

- (NSArray<NSDictionary<NSString *, id> *> *)croak_dictionaryRecordsForKey:(NSString *)key {
    id records = self.croak_dataLayer[key];
    if (![records isKindOfClass:NSArray.class]) {
        return @[];
    }

    NSMutableArray<NSDictionary<NSString *, id> *> *validRecords = [NSMutableArray array];
    for (id record in (NSArray *)records) {
        if ([record isKindOfClass:NSDictionary.class]) {
            [validRecords addObject:record];
        }
    }
    return validRecords;
}

- (NSArray<NSDictionary<NSString *, id> *> *)croak_localDictionaryRecordsForKey:(NSString *)key {
    id records = [NSUserDefaults.standardUserDefaults objectForKey:key];
    if (![records isKindOfClass:NSArray.class]) {
        return @[];
    }

    NSMutableArray<NSDictionary<NSString *, id> *> *validRecords = [NSMutableArray array];
    for (id record in (NSArray *)records) {
        if ([record isKindOfClass:NSDictionary.class]) {
            [validRecords addObject:record];
        }
    }
    return validRecords;
}

- (NSDictionary<NSString *, id> *)croak_userWithAccount:(NSString *)account {
    NSString *targetAccount = [[self croak_trimmedString:account] lowercaseString];
    if (targetAccount.length == 0) {
        return nil;
    }

    for (NSDictionary<NSString *, id> *userInfo in [self croak_userRecords]) {
        NSString *value = [[self croak_stringFromValue:userInfo[@"kewgxwk"]] lowercaseString];
        if ([value isEqualToString:targetAccount]) {
            return userInfo;
        }
    }

    return nil;
}

- (NSArray<NSDictionary<NSString *, id> *> *)croak_userRecords {
    return [self croak_dictionaryRecordsForKey:@"hok"];
}

- (NSMutableArray<NSMutableDictionary<NSString *, id> *> *)croak_mutableUsersArrayCreatingIfNeeded:(BOOL)createIfNeeded {
    if (!self.croak_dataLayer && createIfNeeded) {
        self.croak_dataLayer = [NSMutableDictionary dictionary];
    }

    id users = self.croak_dataLayer[@"hok"];
    if ([users isKindOfClass:NSMutableArray.class]) {
        return users;
    }
    if ([users isKindOfClass:NSArray.class]) {
        NSMutableArray *mutableUsers = [users mutableCopy];
        self.croak_dataLayer[@"hok"] = mutableUsers;
        return mutableUsers;
    }
    if (createIfNeeded) {
        NSMutableArray *mutableUsers = [NSMutableArray array];
        self.croak_dataLayer[@"hok"] = mutableUsers;
        return mutableUsers;
    }
    return nil;
}

- (NSString *)croak_passwordFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    return [self croak_stringFromValue:userInfo[@"sopvugh"]];
}

- (NSArray<NSDictionary<NSString *, id> *> *)croak_followRelations {
    return [self croak_dictionaryRecordsForKey:@"tqdee"];
}

- (NSArray<NSDictionary<NSString *, id> *> *)croak_posts {
    return [self croak_dictionaryRecordsForKey:@"fcfmx"];
}

- (NSArray<NSDictionary<NSString *, id> *> *)croak_chatSessionRecords {
    return [self croak_dictionaryRecordsForKey:@"zfbo"];
}

- (NSArray<NSDictionary<NSString *, id> *> *)croak_chatMessageRecords {
    return [self croak_dictionaryRecordsForKey:@"lcknfxsa"];
}

- (NSArray<NSDictionary<NSString *, id> *> *)croak_localChatMessageRecords {
    return [self croak_localDictionaryRecordsForKey:CroakAppDataStoreLocalChatMessagesDefaultsKey];
}

- (NSString *)croak_postUserIdFromPostInfo:(NSDictionary<NSString *, id> *)postInfo {
    return [self croak_normalizedIdFromValue:postInfo[@"fegg"]];
}

- (NSString *)croak_postCreatedAtFromPostInfo:(NSDictionary<NSString *, id> *)postInfo {
    return [self croak_stringFromValue:postInfo[@"jumog"]];
}

- (NSString *)croak_postIdFromPostInfo:(NSDictionary<NSString *, id> *)postInfo {
    return [self croak_stringFromValue:postInfo[@"uxicmgnb"]];
}

- (NSString *)croak_chatSessionIdFromSessionInfo:(NSDictionary<NSString *, id> *)sessionInfo {
    return [self croak_stringFromValue:sessionInfo[@"cwkxbxdk"]];
}

- (NSString *)croak_chatSessionCreatedAtFromSessionInfo:(NSDictionary<NSString *, id> *)sessionInfo {
    return [self croak_stringFromValue:sessionInfo[@"jlyh"]];
}

- (NSString *)croak_chatSessionUserIdFromSessionInfo:(NSDictionary<NSString *, id> *)sessionInfo {
    return [self croak_normalizedIdFromValue:sessionInfo[@"ztbp"]];
}

- (NSString *)croak_chatSessionTargetUserIdFromSessionInfo:(NSDictionary<NSString *, id> *)sessionInfo {
    return [self croak_normalizedIdFromValue:sessionInfo[@"cy"]];
}

- (NSArray<NSString *> *)croak_chatSessionParticipantIdsFromSessionInfo:(NSDictionary<NSString *, id> *)sessionInfo {
    id participantIds = sessionInfo[@"bwaayooy"];
    if (![participantIds isKindOfClass:NSArray.class]) {
        return @[];
    }

    NSMutableArray<NSString *> *normalizedIds = [NSMutableArray array];
    for (id participantId in (NSArray *)participantIds) {
        NSString *userId = [self croak_normalizedIdFromValue:participantId];
        if (userId.length > 0) {
            [normalizedIds addObject:userId];
        }
    }
    return normalizedIds;
}

- (NSArray<NSDictionary<NSString *, id> *> *)croak_localChatMessagesForSessionId:(NSString *)sessionId
                                                                     ownerUserId:(NSString *)ownerUserId {
    NSString *targetSessionId = [self croak_stringFromValue:sessionId];
    if (targetSessionId.length == 0) {
        return @[];
    }

    NSString *targetOwnerUserId = [self croak_normalizedIdFromValue:ownerUserId];
    NSMutableArray<NSDictionary<NSString *, id> *> *messages = [NSMutableArray array];
    for (NSDictionary<NSString *, id> *messageInfo in [self croak_localChatMessageRecords]) {
        if (![[self croak_chatMessageSessionIdFromMessageInfo:messageInfo] isEqualToString:targetSessionId]) {
            continue;
        }

        NSString *messageOwnerUserId = [self croak_normalizedIdFromValue:messageInfo[@"croakLocalOwnerUserId"]];
        if (targetOwnerUserId.length > 0 && ![messageOwnerUserId isEqualToString:targetOwnerUserId]) {
            continue;
        }

        [messages addObject:messageInfo];
    }
    return messages;
}

- (BOOL)croak_chatSession:(NSDictionary<NSString *, id> *)sessionInfo containsUserId:(NSString *)userId {
    NSString *targetUserId = [self croak_normalizedIdFromValue:userId];
    if (targetUserId.length == 0) {
        return NO;
    }

    if ([[self croak_chatSessionUserIdFromSessionInfo:sessionInfo] isEqualToString:targetUserId] ||
        [[self croak_chatSessionTargetUserIdFromSessionInfo:sessionInfo] isEqualToString:targetUserId]) {
        return YES;
    }

    return [[self croak_chatSessionParticipantIdsFromSessionInfo:sessionInfo] containsObject:targetUserId];
}

- (NSString *)croak_otherUserIdInChatSession:(NSDictionary<NSString *, id> *)sessionInfo
                                currentUserId:(NSString *)currentUserId {
    NSString *normalizedCurrentUserId = [self croak_normalizedIdFromValue:currentUserId];
    NSString *sessionUserId = [self croak_chatSessionUserIdFromSessionInfo:sessionInfo];
    NSString *targetUserId = [self croak_chatSessionTargetUserIdFromSessionInfo:sessionInfo];
    if (sessionUserId.length > 0 && ![sessionUserId isEqualToString:normalizedCurrentUserId]) {
        return sessionUserId;
    }
    if (targetUserId.length > 0 && ![targetUserId isEqualToString:normalizedCurrentUserId]) {
        return targetUserId;
    }

    for (NSString *participantId in [self croak_chatSessionParticipantIdsFromSessionInfo:sessionInfo]) {
        if (![participantId isEqualToString:normalizedCurrentUserId]) {
            return participantId;
        }
    }
    return @"";
}

- (NSString *)croak_chatSessionLastMessageFromSessionInfo:(NSDictionary<NSString *, id> *)sessionInfo {
    return [self croak_stringFromValue:sessionInfo[@"lqoh"]];
}

- (NSString *)croak_chatSessionLastMessageTimeFromSessionInfo:(NSDictionary<NSString *, id> *)sessionInfo {
    return [self croak_stringFromValue:sessionInfo[@"xhzj"]];
}

- (NSString *)croak_chatMessageSessionIdFromMessageInfo:(NSDictionary<NSString *, id> *)messageInfo {
    return [self croak_stringFromValue:messageInfo[@"uvz"]];
}

- (NSString *)croak_chatMessageContentFromMessageInfo:(NSDictionary<NSString *, id> *)messageInfo {
    return [self croak_stringFromValue:messageInfo[@"syuvoah"]];
}

- (NSString *)croak_chatMessageSentAtFromMessageInfo:(NSDictionary<NSString *, id> *)messageInfo {
    NSString *sentAt = [self croak_stringFromValue:messageInfo[@"xteio"]];
    if (sentAt.length == 0) {
        sentAt = [self croak_stringFromValue:messageInfo[@"bhvw"]];
    }
    return sentAt;
}

- (NSMutableDictionary<NSString *, id> *)croak_mutablePostMatchingPostInfo:(NSDictionary<NSString *, id> *)postInfo {
    NSString *postId = [self croak_postIdFromPostInfo:postInfo];
    if (postId.length == 0) {
        return nil;
    }

    for (NSMutableDictionary<NSString *, id> *candidatePostInfo in [self croak_mutablePostsArray]) {
        if (![candidatePostInfo isKindOfClass:NSMutableDictionary.class]) {
            continue;
        }

        if ([[self croak_postIdFromPostInfo:candidatePostInfo] isEqualToString:postId]) {
            return candidatePostInfo;
        }
    }

    return nil;
}

- (NSMutableArray *)croak_mutablePostsArray {
    id posts = self.croak_dataLayer[@"fcfmx"];
    if ([posts isKindOfClass:NSMutableArray.class]) {
        return posts;
    }
    if ([posts isKindOfClass:NSArray.class]) {
        NSMutableArray *mutablePosts = [posts mutableCopy];
        self.croak_dataLayer[@"fcfmx"] = mutablePosts;
        return mutablePosts;
    }
    return nil;
}

- (NSArray *)croak_likedUserIdsFromPostInfo:(NSDictionary<NSString *, id> *)postInfo {
    id likedUserIds = postInfo[@"ri"];
    return [likedUserIds isKindOfClass:NSArray.class] ? likedUserIds : @[];
}

- (NSMutableArray *)croak_mutableLikedUserIdsInPostInfo:(NSMutableDictionary<NSString *, id> *)postInfo
                                       creatingIfNeeded:(BOOL)createIfNeeded {
    id likedUserIds = postInfo[@"ri"];
    if ([likedUserIds isKindOfClass:NSMutableArray.class]) {
        return likedUserIds;
    }
    if ([likedUserIds isKindOfClass:NSArray.class]) {
        NSMutableArray *mutableLikedUserIds = [likedUserIds mutableCopy];
        postInfo[@"ri"] = mutableLikedUserIds;
        return mutableLikedUserIds;
    }
    if (createIfNeeded) {
        NSMutableArray *mutableLikedUserIds = [NSMutableArray array];
        postInfo[@"ri"] = mutableLikedUserIds;
        return mutableLikedUserIds;
    }
    return nil;
}

- (BOOL)croak_likedUserIds:(NSArray *)likedUserIds containsUserId:(NSString *)userId {
    for (id likedUserId in likedUserIds) {
        if ([[self croak_normalizedIdFromValue:likedUserId] isEqualToString:userId]) {
            return YES;
        }
    }
    return NO;
}

- (void)croak_removeUserId:(NSString *)userId fromLikedUserIds:(NSMutableArray *)likedUserIds {
    for (NSInteger index = (NSInteger)likedUserIds.count - 1; index >= 0; index--) {
        if ([[self croak_normalizedIdFromValue:likedUserIds[(NSUInteger)index]] isEqualToString:userId]) {
            [likedUserIds removeObjectAtIndex:(NSUInteger)index];
        }
    }
}

- (NSSet<NSString *> *)croak_blockedUserIdsSetForAccount:(NSString *)account {
    NSString *ownerAccount = [self croak_normalizedAccountKey:account];
    if (ownerAccount.length == 0) {
        return [NSSet set];
    }

    id storedValue = [NSUserDefaults.standardUserDefaults objectForKey:CroakAppDataStoreBlockedUsersDefaultsKey];
    if (![storedValue isKindOfClass:NSDictionary.class]) {
        return [NSSet set];
    }

    NSDictionary<NSString *, NSArray<NSString *> *> *blockedUserIdsByAccount = storedValue;
    NSArray<NSString *> *blockedUserIds = [blockedUserIdsByAccount[ownerAccount] isKindOfClass:NSArray.class] ? blockedUserIdsByAccount[ownerAccount] : @[];
    NSMutableSet<NSString *> *normalizedUserIds = [NSMutableSet set];
    for (id userId in blockedUserIds) {
        NSString *normalizedUserId = [self croak_normalizedIdFromValue:userId];
        if (normalizedUserId.length > 0) {
            [normalizedUserIds addObject:normalizedUserId];
        }
    }
    return [normalizedUserIds copy];
}

- (NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *)croak_mutableBlockedUserIdsByAccount {
    NSDictionary *storedValue = [NSUserDefaults.standardUserDefaults objectForKey:CroakAppDataStoreBlockedUsersDefaultsKey];
    NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *mutableValue = [NSMutableDictionary dictionary];
    if (![storedValue isKindOfClass:NSDictionary.class]) {
        return mutableValue;
    }

    [storedValue enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *ownerAccount = [self croak_normalizedAccountKey:key];
        if (ownerAccount.length == 0 || ![value isKindOfClass:NSArray.class]) {
            return;
        }

        NSMutableArray<NSString *> *blockedUserIds = [NSMutableArray array];
        for (id userId in (NSArray *)value) {
            NSString *normalizedUserId = [self croak_normalizedIdFromValue:userId];
            if (normalizedUserId.length > 0 && ![blockedUserIds containsObject:normalizedUserId]) {
                [blockedUserIds addObject:normalizedUserId];
            }
        }
        mutableValue[ownerAccount] = blockedUserIds;
    }];
    return mutableValue;
}

- (void)croak_saveBlockedUserIdsByAccount:(NSDictionary<NSString *, NSArray<NSString *> *> *)blockedUserIdsByAccount {
    [NSUserDefaults.standardUserDefaults setObject:blockedUserIdsByAccount forKey:CroakAppDataStoreBlockedUsersDefaultsKey];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (NSString *)croak_normalizedAccountKey:(id)value {
    return [[self croak_trimmedString:value] lowercaseString];
}

- (NSArray *)croak_removeFollowRelationsForUserId:(NSString *)userId {
    if (userId.length == 0) {
        return @[];
    }

    NSMutableArray *relations = [self croak_mutableFollowRelationsArray];
    if (!relations) {
        return @[];
    }

    NSMutableArray *removedRelations = [NSMutableArray array];
    for (NSInteger index = (NSInteger)relations.count - 1; index >= 0; index--) {
        id relationInfo = relations[(NSUInteger)index];
        if (![relationInfo isKindOfClass:NSDictionary.class]) {
            continue;
        }

        NSString *sourceUserId = [self croak_sourceUserIdFromRelationInfo:relationInfo];
        NSString *targetUserId = [self croak_targetUserIdFromRelationInfo:relationInfo];
        if ([sourceUserId isEqualToString:userId] || [targetUserId isEqualToString:userId]) {
            [removedRelations addObject:relationInfo];
            [relations removeObjectAtIndex:(NSUInteger)index];
        }
    }
    return removedRelations;
}

- (NSMutableArray *)croak_mutableFollowRelationsArray {
    id relations = self.croak_dataLayer[@"tqdee"];
    if ([relations isKindOfClass:NSMutableArray.class]) {
        return relations;
    }
    if ([relations isKindOfClass:NSArray.class]) {
        NSMutableArray *mutableRelations = [relations mutableCopy];
        self.croak_dataLayer[@"tqdee"] = mutableRelations;
        return mutableRelations;
    }
    return nil;
}

- (void)croak_restoreFollowRelations:(NSArray *)relations {
    if (relations.count == 0) {
        return;
    }

    NSMutableArray *mutableRelations = [self croak_mutableFollowRelationsArray];
    if (!mutableRelations) {
        mutableRelations = [NSMutableArray array];
        self.croak_dataLayer[@"tqdee"] = mutableRelations;
    }
    [mutableRelations addObjectsFromArray:relations];
}

- (NSString *)croak_userIdFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    return [self croak_normalizedIdFromValue:userInfo[@"iif"]];
}

- (NSString *)croak_userIdForAccount:(NSString *)account {
    NSDictionary<NSString *, id> *userInfo = [self croak_userWithAccount:account];
    return [self croak_userIdFromUserInfo:userInfo];
}

- (NSDictionary<NSString *, id> *)croak_userWithUserId:(NSString *)userId {
    NSString *targetUserId = [self croak_normalizedIdFromValue:userId];
    if (targetUserId.length == 0) {
        return nil;
    }

    for (NSDictionary<NSString *, id> *userInfo in [self croak_userRecords]) {
        if ([[self croak_userIdFromUserInfo:userInfo] isEqualToString:targetUserId]) {
            return userInfo;
        }
    }
    return nil;
}

- (NSString *)croak_displayNameForUserId:(NSString *)userId {
    NSString *targetUserId = [self croak_normalizedIdFromValue:userId];
    if (targetUserId.length == 0) {
        return @"";
    }

    for (NSDictionary<NSString *, id> *userInfo in [self croak_userRecords]) {
        NSString *candidateUserId = [self croak_userIdFromUserInfo:userInfo];
        if ([candidateUserId isEqualToString:targetUserId]) {
            return [self croak_displayNameFromUserInfo:userInfo];
        }
    }
    return @"";
}

- (NSString *)croak_displayNameFromUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSString *name = [self croak_stringFromValue:userInfo[@"kjvmvsaz"]];
    if (name.length == 0) {
        name = [self croak_stringFromValue:userInfo[@"kewgxwk"]];
    }
    return name;
}

- (NSString *)croak_sourceUserIdFromRelationInfo:(NSDictionary<NSString *, id> *)relationInfo {
    return [self croak_normalizedIdFromValue:relationInfo[@"fc"]];
}

- (NSString *)croak_targetUserIdFromRelationInfo:(NSDictionary<NSString *, id> *)relationInfo {
    return [self croak_normalizedIdFromValue:relationInfo[@"bmyiz"]];
}

- (NSString *)croak_normalizedIdFromValue:(id)value {
    return [[self croak_stringFromValue:value] lowercaseString];
}

- (NSString *)croak_ISO8601StringFromDate:(NSDate *)date {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    });
    return [formatter stringFromDate:date ?: NSDate.date];
}

- (NSError *)croak_inputErrorWithAccount:(NSString *)account password:(NSString *)password {
    if (account.length == 0) {
        return [self croak_errorWithCode:CroakAppDataStoreErrorInvalidInput
                                 message:@"Please enter your account."];
    }

    if (password.length == 0) {
        return [self croak_errorWithCode:CroakAppDataStoreErrorInvalidInput
                                 message:@"Please enter your password."];
    }

    return nil;
}

- (NSString *)croak_trimmedString:(NSString *)string {
    if (![string isKindOfClass:NSString.class]) {
        return @"";
    }
    return [string stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
}

- (NSString *)croak_stringFromValue:(id)value {
    if (!value || value == NSNull.null) {
        return @"";
    }
    if ([value isKindOfClass:NSString.class]) {
        return [self croak_trimmedString:value];
    }
    if ([value isKindOfClass:NSNumber.class]) {
        return [value stringValue];
    }
    return [[value description] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
}

- (NSString *)croak_imageNameFromValue:(id)value {
    NSString *rawName = @"";
    if ([value isKindOfClass:NSString.class]) {
        rawName = (NSString *)value;
    } else if ([value isKindOfClass:NSNumber.class]) {
        rawName = [(NSNumber *)value stringValue];
    }
    return [[self croak_trimmedString:rawName] length] > 0 ? rawName : @"";
}

- (NSError *)croak_errorWithCode:(NSInteger)code message:(NSString *)message {
    return [NSError errorWithDomain:CroakAppDataStoreErrorDomain
                               code:code
                           userInfo:@{NSLocalizedDescriptionKey: message ?: @"Operation failed."}];
}

@end
