//
//  main.m
//  WeiXinPlugin
//
//  Created by luqi on 2020/8/31.
//  Copyright © 2020 lq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeChat+hook.h"
static void __attribute__((constructor)) initialize(void) {
    NSLog(@"++++++++ WeiXin loaded ++++++++");
    [NSObject hookWeChat];
}
