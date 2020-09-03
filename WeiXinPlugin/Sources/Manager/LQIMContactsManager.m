//
//  LQIMContactsManager.m
//  WeiXinPlugin
//
//  Created by luqi on 2020/9/2.
//  Copyright © 2020 lq. All rights reserved.
//

#import "LQIMContactsManager.h"
#import <objc/runtime.h>

@implementation LQIMContactsManager
+ (instancetype)shareInstance{
    static id share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[self alloc] init];
    });
    return share;
}

+ (WCContactData *)getContactDataByWxId:(NSString *)wxid{
    ContactStorage *contactStorage = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("ContactStorage")];
    return [contactStorage GetContact:wxid];
}

+ (NSString *)getWeChatNickName:(NSString *)username{
    ContactStorage *contactStorage = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("ContactStorage")];
    WCContactData *contactData = [contactStorage GetContact:username];
    
    if(contactData){
        return contactData.m_nsNickName;
    }
    return nil;
}

+ (MMSessionInfo *)getSessionInfo:(NSString *)userName
{
    MMSessionMgr *sessionMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("MMSessionMgr")];
    __block MMSessionInfo *info = nil;
    [sessionMgr.m_arrSession enumerateObjectsUsingBlock:^(MMSessionInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.m_nsUserName isEqualToString:userName]) {
            info = obj;
        }
    }];
    return info;
}

+ (NSString *)getGroupNameById:(NSString *)groupId
{
    if ([groupId containsString:@"@chatroom"]) {
        MMSessionInfo *info = [LQIMContactsManager getSessionInfo:groupId];
        return info.m_packedInfo.m_contact.m_nsNickName;
    }
    
    return nil;
}

+ (NSString *)getGroupMemberNickName:(NSString *)username
{
    if (!username) {
        return nil;
    }
    GroupStorage *groupStorage = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("GroupStorage")];
    WCContactData *data = [groupStorage GetGroupMemberContact:username];
    return data.m_nsNickName;
}
@end
