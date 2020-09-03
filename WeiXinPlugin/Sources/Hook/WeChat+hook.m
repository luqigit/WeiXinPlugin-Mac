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
#import "SwizzledHelper.h"
#import "LQIMContactsManager.h"

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
        hookMethod(objc_getClass("MessageService"), @selector(FFToNameFavChatZZ:sessionMsgList:), [self class], @selector(hook_FFToNameFavChatZZ:sessionMsgList:));
    }
    
    // 初始化
    hookMethod(objc_getClass("WeChat"), @selector(applicationDidFinishLaunching:), [self class], @selector(hook_applicationDidFinishLaunching:));
    
    //      微信消息同步
    hookMethod(objc_getClass("MessageService"), @selector(FFImgToOnFavInfoInfoVCZZ:isFirstSync:), [self class], @selector(hook_onReceivedMsg:isFirstSync:));
    
    
    // 修正沙盒路径
    rebind_symbols((struct rebinding[2]) {
        { "NSSearchPathForDirectoriesInDomains", swizzled_NSSearchPathForDirectoriesInDomains, (void *)&original_NSSearchPathForDirectoriesInDomains },
        { "NSHomeDirectory", swizzled_NSHomeDirectory, (void *)&original_NSHomeDirectory }
    }, 2);
}

#pragma mark - 撤回

- (void)hook_FFToNameFavChatZZ:(id)msgData sessionMsgList:(id)arg2
{
    if (![[WeChatConfig sharedConfig] preventRevokeEnable]) {
        [self hook_FFToNameFavChatZZ:msgData sessionMsgList:arg2];
        return;
    }
    
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
    [[WeChatPluginManager shareInstance] initMenuItems];
    [self hook_applicationDidFinishLaunching:arg1];
}

#pragma mark - 微信消息同步

- (void)hook_onReceivedMsg:(NSArray *)msgs isFirstSync:(BOOL)arg2 {
    [self hook_onReceivedMsg:msgs isFirstSync:arg2];
    
    [msgs enumerateObjectsUsingBlock:^(AddMsg *addMsg, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDate *now = [NSDate date];
        NSTimeInterval nowSecond = now.timeIntervalSince1970;
        if (nowSecond - addMsg.createTime > 180) {
            return;
        }
        [self analysisMsg:addMsg];
    }];
}


//MsgType字段解释：
//-1 // 异常返回，一般为长连接服务器本身给你们发的
//0 // 正常的消息返回，一般为登录的微信状态的推送，一般为长连接服务器本身给你们发的
//1 // 微信收到文字消息的推送，一般为微信服务器发过来，我们直接转发给你们的
//2 // 好友信息推送，包含好友，群，公众号信息
//3 // 收到图片消息
//34 // 语音消息
//35 // 用户头像buf
//37 // 收到好友请求消息
//42 // 名片消息
//47 // 表情消息
//48 // 定位消息
//49 // APP消息(文件 或者 链接 H5)
//62 // 小视频
//2000 // 转账消息
//2001 // 收到红包消息
//3000 // 群邀请
//10000 // 微信通知信息，一般为微信服务器发过来，我们直接转发给你们的 // 微信群信息变更通知，多为群名修改，进群，离群信息，不包含群内聊天信息，一般为微信服务器发过来，我们直接转发给你们的
//10002 // 撤回消息

-(void) analysisMsg:(AddMsg *) addMsg{
    
    //    @interface AddMsg : NSObject
    //    + (id)parseFromData:(id)arg1;
    //    @property(retain, nonatomic, setter=SetPushContent:) NSString *pushContent;
    //    @property(readonly, nonatomic) BOOL hasPushContent;
    //    @property(retain, nonatomic, setter=SetMsgSource:) NSString *msgSource;
    //    @property(readonly, nonatomic) BOOL hasMsgSource;
    //    @property(readonly, nonatomic) BOOL hasCreateTime;
    //    @property(readonly, nonatomic) BOOL hasImgBuf;
    //    @property(nonatomic, setter=SetImgStatus:) unsigned int imgStatus;
    //    @property(readonly, nonatomic) BOOL hasImgStatus;
    //    @property(nonatomic, setter=SetStatus:) unsigned int status;
    //
    //    @property(retain, nonatomic, setter=SetContent:) SKBuiltinString_t *content;
    //    @property(retain, nonatomic, setter=SetFromUserName:) SKBuiltinString_t *fromUserName;
    //    @property(nonatomic, setter=SetMsgType:) int msgType;
    //    @property(retain, nonatomic, setter=SetToUserName:) SKBuiltinString_t *toUserName;
    //    @property (nonatomic, assign) unsigned int createTime;
    //    @property(nonatomic, setter=SetNewMsgId:) long long newMsgId;
    //    @property (nonatomic, strong) SKBuiltinBuffer_t *imgBuf;
    //    @end
    
    if (addMsg.msgType == 1) {
        //        NSString *currentUserName = [objc_getClass("CUtility") GetCurrentUserName];
        //        if ([addMsg.fromUserName.string isEqualToString:currentUserName] &&
        //            [addMsg.toUserName.string isEqualToString:currentUserName]) {
        //        }
        
        MMSessionMgr *sessionMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("MMSessionMgr")];
        
        WCContactData* fromContactData = [sessionMgr getSessionContact:addMsg.fromUserName.string];

        if(!fromContactData){
            return;
        }
        
        if([fromContactData isBrandContact]){
            return;
        }

//        NSLog(@"------");
//        NSLog(@" msg fromUserName %@",addMsg.fromUserName.string);
//        NSLog(@" msg toUserName %@",addMsg.toUserName.string);
//        NSLog(@" msg content %@",addMsg.content.string);
        if([addMsg.content.string containsString:@"点餐1024"]){
            NSLog(@"包含关键字");
            NSString *showName = @"";
            NSString *saveText = @"";
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            //设置格式：zzz表示时区
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            //NSDate转NSString
            NSString *currentDateString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:addMsg.createTime]];
            
            if([fromContactData isGroupChat]){// 群聊
                NSArray *contents = [addMsg.content.string componentsSeparatedByString:@":\n"];
                NSString *groupMemberWxid = contents[0];
                MessageService *msgService = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("MessageService")];
                MessageData *msgData = [msgService GetMsgData:addMsg.fromUserName.string svrId:addMsg.newMsgId];
//                NSLog(@"%@", msgData.groupChatSenderDisplayName);
//                NSString *desc = @"";
                NSString *groupMemberNickName = msgData.groupChatSenderDisplayName.length > 0
                ? msgData.groupChatSenderDisplayName : [LQIMContactsManager getGroupMemberNickName:groupMemberWxid];
//                desc = [desc stringByAppendingFormat:@"群聊【%@】里用户【%@】发来一条消息", fromContactData.m_nsNickName, groupMemberNickName];
//                NSLog(@"%@",desc);
                 
                saveText =[NSString stringWithFormat:@"%@-群聊-%@--%@-%@\n",currentDateString,
                           fromContactData.m_nsNickName, groupMemberNickName,contents[1]];
                
            }else{
                if(fromContactData.m_nsRemark != nil){
                    showName = fromContactData.m_nsRemark;
                }else {
                    showName = fromContactData.m_nsNickName;
                }

                saveText =[NSString stringWithFormat:@"%@-私聊-%@-%@\n",currentDateString,showName, addMsg.content.string];
            }
            
            NSString *keyWorldFilePath = [WeChatConfig getKeyWordLogSaveFile];
            NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:keyWorldFilePath];
            [fileHandler seekToEndOfFile];
            [fileHandler writeData:[saveText dataUsingEncoding:NSUTF8StringEncoding]];
            [fileHandler closeFile];
            
        }
    }
    
}

@end


