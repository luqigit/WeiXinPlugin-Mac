//
//  WeChatConfig.m
//  WeiXinPlugin
//
//  Created by luqi on 2020/9/1.
//  Copyright © 2020 lq. All rights reserved.
//

#import "WeChatConfig.h"

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

@end
