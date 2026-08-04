//
//  Croak_MessageChatVC.h
//  Croak
//
//  Created by JIAO on 2026/7/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Croak_MessageChatVC : UIViewController

@property (nonatomic, copy) NSString *croak_name;
@property (nonatomic, copy) NSString *croak_avatarName;
@property (nonatomic, copy) NSString *croak_sessionId;
@property (nonatomic, copy, nullable) NSString *croak_currentUserId;
@property (nonatomic, copy, nullable) NSString *croak_currentAvatarName;
@property (nonatomic, strong, nullable) NSArray<NSDictionary<NSString *, id> *> *croak_chatMessages;

@end

NS_ASSUME_NONNULL_END
