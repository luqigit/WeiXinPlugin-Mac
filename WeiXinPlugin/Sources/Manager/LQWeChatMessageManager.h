//
//  LQWeChatMessageManager.h
//  WeiXinPlugin
//
//  Created by luqi on 2020/9/1.
//  Copyright © 2020 lq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeChatDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface LQWeChatMessageManager : NSObject
+ (instancetype)shareManager;
- (NSString *)getMessageContentWithData:(MessageData *)msgData;
@end

NS_ASSUME_NONNULL_END
