//
//  SwizzledHelper.m
//  WeiXinPlugin
//
//  Created by luqi on 2020/9/2.
//  Copyright © 2020 lq. All rights reserved.
//

#import "SwizzledHelper.h"
#import <objc/runtime.h>

@implementation SwizzledHelper

void hookMethod(Class originalClass, SEL originalSelector, Class swizzledClass, SEL swizzledSelector){
   
    Method originalMethod = class_getInstanceMethod(originalClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(swizzledClass, swizzledSelector);
    if (originalMethod && swizzledMethod) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

void hookClassMethod(Class originalClass, SEL originalSelector, Class swizzledClass, SEL swizzledSelector){
    Method originalMethod = class_getClassMethod(originalClass, originalSelector);
    Method swizzledMethod = class_getClassMethod(swizzledClass, swizzledSelector);
    if (originalMethod && swizzledMethod) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
