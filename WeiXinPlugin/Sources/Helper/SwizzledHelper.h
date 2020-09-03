//
//  SwizzledHelper.h
//  WeiXinPlugin
//
//  Created by luqi on 2020/9/2.
//  Copyright © 2020 lq. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SwizzledHelper : NSObject

void hookMethod(Class originalClass, SEL originalSelector, Class swizzledClass, SEL swizzledSelector);

void hookClassMethod(Class originalClass, SEL originalSelector, Class swizzledClass, SEL swizzledSelector);

@end

NS_ASSUME_NONNULL_END
