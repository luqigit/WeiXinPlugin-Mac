//
//  WeChatDefine.h
//  WeiXinPlugin
//
//  Created by luqi on 2020/9/1.
//  Copyright © 2020 lq. All rights reserved.
//

#ifndef WeChatDefine_h
#define WeChatDefine_h

@interface XMLDictionaryParser : NSObject
+ (id)sharedInstance;
- (id)dictionaryWithString:(id)arg1;
@end

@interface MMServiceCenter : NSObject
+ (id)defaultCenter;
- (id)getService:(Class)arg1;
@end

@interface MessageService : NSObject
- (void)onAddMsg:(id)arg1 msgData:(id)arg2;
- (void)notifyAddMsgOnMainThread:(id)arg1 msgData:(id)arg2;
- (void)onRevokeMsg:(id)arg1;
- (void)FFToNameFavChatZZ:(id)arg1;
- (void)FFToNameFavChatZZ:(id)arg1 sessionMsgList:(id)arg2;
- (void)OnSyncBatchAddMsgs:(NSArray *)arg1 isFirstSync:(BOOL)arg2;
- (void)OnSyncBatchAddFunctionMsgs:(id)arg1 isFirstSync:(BOOL)arg2;
- (void)FFImgToOnFavInfoInfoVCZZ:(id)arg1 isFirstSync:(BOOL)arg2;
- (id)GetMsgListWithChatName:(id)arg1 fromCreateTime:(unsigned int)arg2 limitCnt:(NSInteger)arg3 hasMore:(char *)arg4 sortAscend:(BOOL)arg5;
- (id)SendTextMessage:(id)arg1 toUsrName:(id)arg2 msgText:(id)arg3 atUserList:(id)arg4;
- (id)SendImgMessage:(id)arg1 toUsrName:(id)arg2 thumbImgData:(id)arg3 midImgData:(id)arg4 imgData:(id)arg5 imgInfo:(id)arg6;
- (id)SendVideoMessage:(id)arg1 toUsrName:(id)arg2 videoInfo:(id)arg3 msgType:(unsigned int)arg4 refMesageData:(id)arg5;
- (id)SendLocationMsgFromUser:(id)arg1 toUser:(id)arg2 withLatitude:(double)arg3 longitude:(double)arg4 poiName:(id)arg5 label:(id)arg6;
- (id)SendNamecardMsgFromUser:(id)arg1 toUser:(id)arg2 containingContact:(id)arg3;
- (id)SendEmoticonMsgFromUsr:(id)arg1 toUsrName:(id)arg2 md5:(id)arg3 emoticonType:(unsigned int)arg4;
- (id)SendAppURLMessageFromUser:(id)arg1 toUsrName:(id)arg2 withTitle:(id)arg3 url:(id)arg4 description:(id)arg5 thumbnailData:(id)arg6;

- (id)GetMsgData:(id)arg1 svrId:(long)arg2;
- (void)AddLocalMsg:(id)arg1 msgData:(id)arg2;
- (void)TranscribeVoiceMessage:(id)arg1 completion:(void (^)(void))arg2;
- (BOOL)ClearUnRead:(id)arg1 FromID:(unsigned int)arg2 ToID:(unsigned int)arg3;
- (BOOL)ClearUnRead:(id)arg1 FromCreateTime:(unsigned int)arg2 ToCreateTime:(unsigned int)arg3;
- (BOOL)hasMsgInChat:(id)arg1;
- (id)GetMsgListWithChatName:(id)arg1 fromLocalId:(unsigned int)arg2 limitCnt:(NSInteger)arg3 hasMore:(char *)arg4 sortAscend:(BOOL)arg5;
- (id)GetMsgListWithChatName:(id)arg1 fromMinCreateTime:(unsigned int)arg2 localId:(unsigned long long)arg3 limitCnt:(unsigned int)arg4 hasMore:(char *)arg5;
- (id)GetMsgListWithChatName:(id)arg1 fromCreateTime:(unsigned int)arg2 localId:(unsigned long long)arg3 limitCnt:(unsigned int)arg4 hasMore:(char *)arg5 sortAscend:(BOOL)arg6;

- (id)ForwardMessage:(id)arg1 toUser:(id)arg2 errMsg:(id *)arg3;
@end

@interface SendImageInfo : NSObject <NSCopying>
@property (nonatomic, assign) unsigned int m_uiOriginalHeight; // @synthesize m_uiOriginalHeight=_m_uiOriginalHeight;
@property (nonatomic, assign) unsigned int m_uiOriginalWidth; // @synthesize m_uiOriginalWidth=_m_uiOriginalWidth;
@property (nonatomic, assign) unsigned int m_uiThumbHeight; // @synthesize m_uiThumbHeight=_m_uiThumbHeight;
@property (nonatomic, assign) unsigned int m_uiThumbWidth; // @synthesize m_uiThumbWidth=_m_uiThumbWidth;
- (id)init;
@end

@interface MessageData : NSObject
- (id)initWithMsgType:(long long)arg1;
@property(retain, nonatomic) NSString *fromUsrName;
@property(retain, nonatomic) NSString *toUsrName;
@property(retain, nonatomic) NSString *msgContent;
@property(retain, nonatomic) NSString *msgPushContent;
@property(retain, nonatomic) NSString *msgRealChatUsr;
@property(retain, nonatomic) SendImageInfo *imageInfo;
@property(retain, nonatomic) id extendInfoWithMsgType;
@property(nonatomic) int messageType;
@property(nonatomic) int msgStatus;
@property(nonatomic) int msgCreateTime;
@property(nonatomic) int mesLocalID;
@property(nonatomic) long long mesSvrID;
@property(retain, nonatomic) NSString *msgVoiceText;
@property(copy, nonatomic) NSString *m_nsEmoticonMD5;
- (BOOL)isChatRoomMessage;
- (NSString *)groupChatSenderDisplayName;
- (id)getRealMessageContent;
- (id)getChatRoomUsrName;
- (BOOL)isSendFromSelf;
- (BOOL)isCustomEmojiMsg;
- (BOOL)isImgMsg;
- (BOOL)isVideoMsg;
- (BOOL)isVoiceMsg;
- (BOOL)canForward;
- (BOOL)IsPlayingSound;
- (id)summaryString:(BOOL)arg1;
- (BOOL)isEmojiAppMsg;
- (BOOL)isAppBrandMsg;
- (BOOL)IsUnPlayed;
- (void)SetPlayed;
@property(retain, nonatomic) NSString *m_nsTitle;
- (id)originalImageFilePath;
@property(retain, nonatomic) NSString *m_nsVideoPath;
@property (nonatomic, retain) NSString *m_nsVideoThumbPath;
@property(retain, nonatomic) NSString *m_nsFilePath;
@property(retain, nonatomic) NSString *m_nsAppMediaUrl;
@property(nonatomic) MessageData *m_refMessageData;
@property(nonatomic) unsigned int m_uiDownloadStatus;
- (void)SetPlayingSoundStatus:(BOOL)arg1;
@end

@interface CUtility : NSObject
+ (BOOL)HasWechatInstance;
+ (BOOL)FFSvrChatInfoMsgWithImgZZ;
+ (unsigned long long)getFreeDiskSpace;
+ (void)ReloadSessionForMsgSync;
+ (id)GetCurrentUserName;
@end

@interface MultiPlatformStatusSyncMgr : NSObject
- (void)markVoiceMessageAsRead:(id)arg1;
@end

@interface MMVoiceMessagePlayer : NSObject
+ (id)defaultPlayer;
- (void)playWithVoiceMessage:(id)arg1 isUnplayedBeforePlay:(BOOL)arg2;
- (void)stop;
@end

@interface SKBuiltinString_t : NSObject
@property(retain, nonatomic, setter=SetString:) NSString *string; // @synthesize string;
@end

@interface SKBuiltinBuffer_t : NSObject
@property (nonatomic, strong) NSData *buffer;
@end

@interface AddMsg : NSObject
+ (id)parseFromData:(id)arg1;
@property(retain, nonatomic, setter=SetPushContent:) NSString *pushContent;
@property(readonly, nonatomic) BOOL hasPushContent;
@property(retain, nonatomic, setter=SetMsgSource:) NSString *msgSource;
@property(readonly, nonatomic) BOOL hasMsgSource;
@property(readonly, nonatomic) BOOL hasCreateTime;
@property(readonly, nonatomic) BOOL hasImgBuf;
@property(nonatomic, setter=SetImgStatus:) unsigned int imgStatus;
@property(readonly, nonatomic) BOOL hasImgStatus;
@property(nonatomic, setter=SetStatus:) unsigned int status;

@property(retain, nonatomic, setter=SetContent:) SKBuiltinString_t *content;
@property(retain, nonatomic, setter=SetFromUserName:) SKBuiltinString_t *fromUserName;
@property(nonatomic, setter=SetMsgType:) int msgType;
@property(retain, nonatomic, setter=SetToUserName:) SKBuiltinString_t *toUserName;
@property (nonatomic, assign) unsigned int createTime;
@property(nonatomic, setter=SetNewMsgId:) long long newMsgId;
@property (nonatomic, strong) SKBuiltinBuffer_t *imgBuf;
@end

#pragma mark - 通讯录

@interface GroupStorage : NSObject
{
    NSMutableDictionary *m_dictGroupContacts;
}
- (id)GetAllGroups;
- (id)GetGroupMemberContact:(id)arg1;
- (void)UpdateGroupMemberDetailIfNeeded:(id)arg1 withCompletion:(id)arg2;
- (BOOL)IsGroupContactExist:(id)arg1;
- (BOOL)IsGroupMemberContactExist:(id)arg1;
- (id)GetGroupContactList:(unsigned int)arg1 ContactType:(unsigned int)arg2;
- (BOOL)AddGroupMembers:(id)arg1 withGroupUserName:(id)arg2 completion:(id)arg3;
- (void)CreateGroupChatWithTopic:(id)arg1 groupMembers:(id)arg2 completion:(id)arg3;
- (void)addChatMemberNeedVerifyMsg:(id)arg1 ContactList:(id)arg2;
- (BOOL)QuitGroup:(id)arg1 completion:(id)arg2;
- (BOOL)UIQuitGroup:(id)arg1;
- (BOOL)UIQuitGroup:(id)arg1 withConfirm:(BOOL)arg2 completion:(id)arg3;
@end

@interface ContactStorage : NSObject
- (id)GetSelfContact;
- (id)GetContact:(id)arg1;
- (id)GetAllBrandContacts;
- (id)GetAllFavContacts;
- (id)GetAllFriendContacts;
- (id)GetContactWithUserName:(id)arg1 updateIfNeeded:(BOOL)arg2;
- (id)getContactCache:(id)arg1;
- (id)GetContactsWithUserNames:(id)arg1;
- (id)GetGroupMemberContact:(id)arg1;
- (id)GetGroupContact:(id)arg1;
- (id)GetAllGroups;
- (id)GetGroupContactList:(id)arg1 ContactType:(id)arg2;
@end

@interface ChatRoomData : NSObject
@property(retain, nonatomic) NSMutableDictionary *m_dicData;
@end

@interface WCContactData : NSObject
@property(retain, nonatomic) NSString *m_nsUsrName; // @synthesize m_nsUsrName;
@property(nonatomic) unsigned int m_uiFriendScene;  // @synthesize m_uiFriendScene;
@property(retain, nonatomic) NSString *m_nsNickName;    // 用户昵称
@property(retain, nonatomic) NSString *m_nsRemark;      // 备注
@property(retain, nonatomic) NSString *m_nsHeadImgUrl;  // 头像
@property(retain, nonatomic) NSString *m_nsHeadHDImgUrl;
@property(retain, nonatomic) NSString *m_nsHeadHDMd5;
@property(retain, nonatomic) NSString *m_nsAliasName;
@property(retain, nonatomic) NSString *avatarCacheKey;
@property(retain, nonatomic) NSString *msgFromNickName;
@property(retain, nonatomic) NSString *m_nsOwner;
@property(retain, nonatomic) NSString *m_nsChatRoomMemList;
@property(retain, nonatomic) ChatRoomData *m_chatRoomData;
@property(nonatomic) unsigned int m_uiSex;
@property(nonatomic) BOOL m_isShowRedDot;
- (BOOL)isBrandContact;
- (BOOL)isSelf;
- (id)getGroupDisplayName;
- (id)getContactDisplayUsrName;
- (BOOL)isGroupChat;
- (BOOL)isMMChat;
- (BOOL)isMMContact;
@end

#pragma mark - MMSessionInfo

@interface MMSessionInfoPackedInfo: NSObject
@property(retain, nonatomic) WCContactData *m_contact;
@property(retain, nonatomic) MessageData *m_msgData;
@end

@interface MMSessionInfo : NSObject
@property(nonatomic) BOOL m_bIsTop; // @synthesize m_bIsTop;
@property(nonatomic) BOOL m_bShowUnReadAsRedDot;
@property(nonatomic) BOOL m_isMentionedUnread; // @synthesize
@property(retain, nonatomic) NSString *m_nsUserName; // @synthesize m_nsUserName;
@property(retain, nonatomic) MMSessionInfoPackedInfo *m_packedInfo;
@property(nonatomic) unsigned int m_uUnReadCount;
@end

@interface MMSessionMgr : NSObject
@property(retain, nonatomic) NSMutableArray *m_arrSession;
@property(retain) NSString *m_currentSessionName; // @synthesize m_currentSessionName=_m_currentSessionName;
- (id)getAllSessions;
- (id)GetAllSessions;
- (id)GetSessionAtIndex:(unsigned long long)arg1;//2.3.24废弃
- (id)sessionInfoByUserName:(id)arg1;
- (void)MuteSessionByUserName:(id)arg1;
- (void)muteSessionByUserName:(id)arg1 syncToServer:(BOOL)arg2;
- (void)onUnReadCountChange:(id)arg1;
//- (void)TopSessionByUserName:(id)arg1;
- (void)processOnEnterSession:(id)arg1 isFromLocal:(BOOL)arg2;
- (void)UnmuteSessionByUserName:(id)arg1;
- (void)unmuteSessionByUserName:(id)arg1 syncToServer:(BOOL)arg2;
- (void)untopSessionByUserName:(id)arg1 syncToServer:(BOOL)arg2;
- (void)deleteSessionWithoutSyncToServerWithUserName:(id)arg1;
- (void)storageDeleteSessionInfo:(id)arg1;
- (void)changeSessionUnreadCountWithUserName:(id)arg1 to:(unsigned int)arg2;
- (void)removeSessionOfUser:(id)arg1 isDelMsg:(BOOL)arg2;
- (void)sortSessions;
- (void)FFDataSvrMgrSvrFavZZ;
- (id)getContact:(id)arg1;
- (id)getSessionContact:(id)arg1;
- (void)onEnterSession:(id)arg1;
- (void)loadExtendedMsgData;
- (void)loadBrandSessionData;
- (void)loadSessionData;
- (void)loadData;
@end

#pragma mark - WeChat
@interface WeChat : NSObject
+ (id)sharedInstance;
- (BOOL)isLoggedIn;
@end

#endif /* WeChatDefine_h */
