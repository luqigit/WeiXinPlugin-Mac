//
//  WeChatPluginManager.m
//  WeiXinPlugin
//
//  Created by luqi on 2020/9/1.
//  Copyright © 2020 lq. All rights reserved.
//

#import "WeChatPluginManager.h"
#import "WeChatConfig.h"

@implementation WeChatPluginManager
+ (instancetype)shareInstance {
    static id share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[self alloc] init];
    });
    return share;
}

- (void)initMenuItems{
    NSMenuItem * preventRevokeItem = [[NSMenuItem alloc] initWithTitle:@"开启消息防撤回" action:@selector(onPreventRevoke:) keyEquivalent:@""];
    preventRevokeItem.target = self;
    preventRevokeItem.state = [[WeChatConfig sharedConfig] preventRevokeEnable];
    
    if ([[WeChatConfig sharedConfig] preventRevokeEnable]) {



        NSMenuItem * preventSelfRevokeItem = [[NSMenuItem alloc] initWithTitle:@"拦截自己撤回的消息" action:@selector(onPreventSelfRevoke:) keyEquivalent:@""];
        preventSelfRevokeItem.target = self;
        preventSelfRevokeItem.state = [[WeChatConfig sharedConfig] preventSelfRevokeEnable];
        
        NSMenu *subPreventMenu = [[NSMenu alloc] initWithTitle:@"开启消息防撤回"];
        [subPreventMenu addItem:preventSelfRevokeItem];
        preventRevokeItem.submenu = subPreventMenu;
        
    }
    
    // open 记录
    NSMenuItem * openFileItem = [[NSMenuItem alloc] initWithTitle:@"打开关键字记录" action:@selector(onOpenKeyWordLog:) keyEquivalent:@""];
    openFileItem.target = self;
    
    
    NSMenu *subMenu = [[NSMenu alloc] initWithTitle:@"微信小助手"];
    [subMenu addItem:preventRevokeItem];
    [subMenu addItem:openFileItem];
    
   
    NSMenuItem *menuItem = [[NSMenuItem alloc] init];
    [menuItem setSubmenu:subMenu];
    menuItem.target = self;
    
    [[[NSApplication sharedApplication] mainMenu] addItem:menuItem];
    
}

#pragma mark 消息放撤回
- (void)onPreventRevoke:(NSMenuItem *)item
{
    NSDictionary *dict = [NSBundle mainBundle].infoDictionary;
    if ([dict[@"CFBundleShortVersionString"] compare:@"2.4.2" options:NSNumericSearch] == NSOrderedAscending) {
        NSAlert * alert = [[NSAlert alloc]init];
        
         alert.messageText = @"不支持2.4.2以下的版本";
        [alert runModal];
        return;
    }
    item.state = !item.state;
    [[WeChatConfig sharedConfig] setPreventRevokeEnable:item.state];
    
    
    if (item.state) {
        NSMenuItem * preventSelfRevokeItem = [[NSMenuItem alloc] initWithTitle:@"拦截自己撤回的消息" action:@selector(onPreventSelfRevoke:) keyEquivalent:@""];
        preventSelfRevokeItem.target = self;
        preventSelfRevokeItem.state = [[WeChatConfig sharedConfig] preventSelfRevokeEnable];
        
        NSMenu *subPreventMenu = [[NSMenu alloc] initWithTitle:@"开启消息防撤回"];
        [subPreventMenu addItem:preventSelfRevokeItem];
        item.submenu = subPreventMenu;
    } else {
        item.submenu = nil;
    }
    
    
}

- (void)onPreventSelfRevoke:(NSMenuItem *)item
{
    item.state = !item.state;
    [[WeChatConfig sharedConfig] setPreventSelfRevokeEnable:item.state];
}

#pragma mark - 打开日志
- (void)onOpenKeyWordLog:(NSMenuItem *)item
{
    if(![WeChatConfig isLogin]){
        return;
    }
    
    [[NSWorkspace sharedWorkspace] openFile:[WeChatConfig getKeyWordLogSaveFile]];
}



@end
