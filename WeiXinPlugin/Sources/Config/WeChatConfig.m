//
//  WeChatConfig.m
//  WeiXinPlugin
//
//  Created by luqi on 2020/9/1.
//  Copyright © 2020 lq. All rights reserved.
//

#import "WeChatConfig.h"
#import "WeChatDefine.h"
#import <objc/runtime.h>

@implementation WeChatConfig

@dynamic preventRevokeEnable;
@dynamic preventSelfRevokeEnable;

+ (instancetype)sharedConfig{
    static WeChatConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [WeChatConfig standardUserDefaults];
    });
    return config;
}

#pragma mark - 撤回的消息集合
- (NSMutableSet *)revokeMsgSet
{
    if (!_revokeMsgSet) {
        _revokeMsgSet = [NSMutableSet set];
    }
    return _revokeMsgSet;
}

#pragma mark - 是不是已经登陆
+ (BOOL) isLogin{
    return [[objc_getClass("WeChat") sharedInstance] isLoggedIn];
}

#pragma mark - 获得路径
+ (NSString *)getSandboxFilePathWithName:(NSString *)name
{
    if(![WeChatConfig isLogin]){
        return nil;
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *currentUserName = [objc_getClass("CUtility") GetCurrentUserName];
    
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *wechatPluginDirectory = [documentDirectory stringByAppendingFormat:@"/WeiXinPlugin/%@/",currentUserName];
    NSString *plistFilePath = [wechatPluginDirectory stringByAppendingPathComponent:name];
    if ([manager fileExistsAtPath:plistFilePath]) {
        return plistFilePath;
    }
    
    [manager createDirectoryAtPath:wechatPluginDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    BOOL isSuccess = [manager createFileAtPath:plistFilePath contents:nil attributes:nil];
    if(isSuccess){
        return plistFilePath;
    }
    
    return plistFilePath;
}

+ (NSString *)getKeyWordLogSaveFile{
    return [self getSandboxFilePathWithName:@"keyWorld.txt"];
}

@end
