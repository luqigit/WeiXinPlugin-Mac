//
//  WeChatConfig.h
//  WeiXinPlugin
//
//  Created by luqi on 2020/9/1.
//  Copyright © 2020 lq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GVUserDefaults.h"

NS_ASSUME_NONNULL_BEGIN

@interface WeChatConfig : GVUserDefaults
@property (nonatomic) BOOL preventRevokeEnable;                 /**<    是否开启防撤回    */
@property (nonatomic) BOOL preventSelfRevokeEnable;             /**<    是否防撤回自己    */

@property (nonatomic, strong) NSMutableSet *revokeMsgSet;                /**<    撤回的消息集合    */
+ (instancetype)sharedConfig;

@end

NS_ASSUME_NONNULL_END
