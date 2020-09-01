//
//  WeChatPluginManager.h
//  WeiXinPlugin
//
//  Created by luqi on 2020/9/1.
//  Copyright © 2020 lq. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeChatPluginManager : NSObject

+ (instancetype)shareInstance;

- (void)initMenuItems;
@end

NS_ASSUME_NONNULL_END
