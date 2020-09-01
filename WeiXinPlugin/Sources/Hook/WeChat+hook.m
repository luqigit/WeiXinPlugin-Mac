//
//  WeChat+hook.m
//  wechatez-mac
//
//  Created by luqi on 2020/8/31.
//  Copyright © 2020 luqi. All rights reserved.
//

#import "WeChat+hook.h"
#import <objc/runtime.h>
#import "fishhook.h"
#import "WeChatPluginManager.h"
#import "WeChatConfig.h"
#import "WeChatDefine.h"
#import "LQWeChatMessageManager.h"

@implementation NSObject (WeChatHook)

#pragma mark - 修复 沙盒路径
static NSString *(*original_NSHomeDirectory)(void);

static NSArray<NSString *> *(*original_NSSearchPathForDirectoriesInDomains)(NSSearchPathDirectory directory, NSSearchPathDomainMask domainMask, BOOL expandTilde);

NSArray<NSString *> *swizzled_NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory directory, NSSearchPathDomainMask domainMask, BOOL expandTilde) {
    NSMutableArray<NSString *> *paths = [original_NSSearchPathForDirectoriesInDomains(directory, domainMask, expandTilde) mutableCopy];
    NSString *sandBoxPath = [NSString stringWithFormat:@"%@/Library/Containers/com.tencent.xinWeChat/Data",original_NSHomeDirectory()];
    
    [paths enumerateObjectsUsingBlock:^(NSString *filePath, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = [filePath rangeOfString:original_NSHomeDirectory()];
        if (range.length > 0) {
            NSMutableString *newFilePath = [filePath mutableCopy];
            [newFilePath replaceCharactersInRange:range withString:sandBoxPath];
            paths[idx] = newFilePath;
        }
    }];
    
    return paths;
}

NSString *swizzled_NSHomeDirectory(void) {
    return [NSString stringWithFormat:@"%@/Library/Containers/com.tencent.xinWeChat/Data",original_NSHomeDirectory()];
}


#pragma mark hookWeChat

+ (void)hookWeChat {
    
    NSDictionary *dict = [NSBundle mainBundle].infoDictionary;
    if ([dict[@"CFBundleShortVersionString"] compare:@"2.4.1" options:NSNumericSearch] == NSOrderedDescending) {
        // hook 撤回
        Method originalMethod = class_getInstanceMethod(objc_getClass("MessageService"), @selector(FFToNameFavChatZZ:sessionMsgList:));
        Method swizzledMethod = class_getInstanceMethod([self class], @selector(hook_FFToNameFavChatZZ:sessionMsgList:));
        if (originalMethod && swizzledMethod) {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    }
    
    // 初始化
        
    Method originalMethod = class_getInstanceMethod(objc_getClass("WeChat"), @selector(applicationDidFinishLaunching:));
    Method swizzledMethod = class_getInstanceMethod([self class], @selector(hook_applicationDidFinishLaunching:));
    if (originalMethod && swizzledMethod) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
        
    // 修正沙盒路径
    rebind_symbols((struct rebinding[2]) {
        { "NSSearchPathForDirectoriesInDomains", swizzled_NSSearchPathForDirectoriesInDomains, (void *)&original_NSSearchPathForDirectoriesInDomains },
        { "NSHomeDirectory", swizzled_NSHomeDirectory, (void *)&original_NSHomeDirectory }
    }, 2);
}

#pragma mark - 撤回

- (void)hook_FFToNameFavChatZZ:(id)msgData sessionMsgList:(id)arg2
{
    NSLog(@"hook_FFToNameFavChatZZ");
    if (![[WeChatConfig sharedConfig] preventRevokeEnable]) {
        [self hook_FFToNameFavChatZZ:msgData sessionMsgList:arg2];
        return;
    }
    
        NSLog(@"hook_FFToNameFavChatZZ22222");
    id msg = msgData;
    if ([msgData isKindOfClass:objc_getClass("MessageData")]) {
        msg = [msgData valueForKey:@"msgContent"];
    }
    
    if ([msg rangeOfString:@"<sysmsg"].length <= 0) return;

    //      转换群聊的 msg
    NSString *msgContent = [msg substringFromIndex:[msg rangeOfString:@"<sysmsg"].location];
    
    //      xml 转 dict
    XMLDictionaryParser *xmlParser = [objc_getClass("XMLDictionaryParser") sharedInstance];
    NSDictionary *msgDict = [xmlParser dictionaryWithString:msgContent];
    
    if (msgDict && msgDict[@"revokemsg"]) {
        NSString *newmsgid = msgDict[@"revokemsg"][@"newmsgid"];
        NSString *session =  msgDict[@"revokemsg"][@"session"];
        msgDict = nil;
        
        NSMutableSet *revokeMsgSet = [[WeChatConfig sharedConfig] revokeMsgSet];
        //      该消息已进行过防撤回处理
        if ([revokeMsgSet containsObject:newmsgid] || !newmsgid) {
            return;
        }
        [revokeMsgSet addObject:newmsgid];
        
        //      获取原始的撤回提示消息
        MessageService *msgService = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("MessageService")];
        MessageData *revokeMsgData = [msgService GetMsgData:session svrId:[newmsgid integerValue]];
                
        if ([revokeMsgData isSendFromSelf]&& ![[WeChatConfig sharedConfig] preventSelfRevokeEnable]) {
            
            [self hook_FFToNameFavChatZZ:msgData sessionMsgList:arg2];
            return;
        }
        NSString *msgContent = [[LQWeChatMessageManager shareManager] getMessageContentWithData:revokeMsgData];
        NSString *newMsgContent = [NSString stringWithFormat:@"%@ \n%@",@"拦截到一条撤回消息: ", msgContent];
        MessageData *newMsgData = ({
            MessageData *msg = [[objc_getClass("MessageData") alloc] initWithMsgType:0x2710];
            [msg setFromUsrName:revokeMsgData.toUsrName];
            [msg setToUsrName:revokeMsgData.fromUsrName];
            [msg setMsgStatus:4];
            [msg setMsgContent:newMsgContent];
            [msg setMsgCreateTime:[revokeMsgData msgCreateTime]];
            //   [msg setMesLocalID:[revokeMsgData mesLocalID]];
            
            msg;
        });
        
        [msgService AddLocalMsg:session msgData:newMsgData];
    }
    
    
    
    
}

#pragma mark - 菜单栏
- (void)hook_applicationDidFinishLaunching:(id)arg1 {
        NSLog(@"++++++++ initMenuItems init ++++++++");
    [[WeChatPluginManager shareInstance] initMenuItems];
    [self hook_applicationDidFinishLaunching:arg1];
}

@end


