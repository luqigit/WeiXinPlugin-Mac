//
//  LQWeChatMessageManager.m
//  WeiXinPlugin
//
//  Created by luqi on 2020/9/1.
//  Copyright © 2020 lq. All rights reserved.
//

#import "LQWeChatMessageManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "WeChatConfig.h"

@interface LQWeChatMessageManager()
@property (nonatomic, strong) MessageService *service;
@end

@implementation LQWeChatMessageManager
+ (instancetype)shareManager
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (NSString *)getMessageContentWithData:(MessageData *)msgData
{
    if (!msgData) {
         return @"";
    }
    
    NSString *msgContent = [msgData summaryString:NO] ?: @"";
    if (msgData.m_nsTitle && (msgData.isAppBrandMsg || [msgContent isEqualToString:@"Message_type_unsupport"])) {
        NSString *content = msgData.m_nsTitle ?:@"";
        if (msgContent) {
            msgContent = [msgContent stringByAppendingString:content];
        }
    }
    
    if ([msgData respondsToSelector:@selector(isChatRoomMessage)] && msgData.isChatRoomMessage && msgData.groupChatSenderDisplayName) {
         if (msgData.groupChatSenderDisplayName.length > 0 && msgContent) {
            msgContent = [NSString stringWithFormat:@"%@：%@",msgData.groupChatSenderDisplayName, msgContent];
        }
    }
    
    return msgContent;
}

- (MessageService *)service
{
    if (!_service) {
        _service = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("MessageService")];
    }
    return _service;
}
@end
