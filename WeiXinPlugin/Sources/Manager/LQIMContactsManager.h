//
//  LQIMContactsManager.h
//  WeiXinPlugin
//
//  Created by luqi on 2020/9/2.
//  Copyright © 2020 lq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeChatDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface LQIMContactsManager : NSObject
+ (instancetype)shareInstance;
+ (NSString *)getWeChatNickName:(NSString *)username;
+ (NSString *)getGroupNameById:(NSString *)groudId;
+ (MMSessionInfo *)getSessionInfo:(NSString *)userName;
+ (WCContactData *)getContactDataByWxId:(NSString *)wxid;
+ (NSString *)getGroupMemberNickName:(NSString *)username;
@end

NS_ASSUME_NONNULL_END
