
//
//  UIWindow+noOperationTime.m
//  Misscandy
//
//  Created by chiyou on 15/8/7.
//  Copyright (c) 2015年 MK. All rights reserved.
//

#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "UIWindow+noOperationTime.h"
#define kApplicationnoOperationTimeInMinutes 0.05
@interface UIWindow ()
@property (nonatomic, strong) NSTimer *timer;
@end
static  char *timerKey;
@implementation UIWindow (noOperationTime)
void swizzle_method(Class class,SEL originalSelector,SEL swizzledSelector);
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        swizzle_method([self class],@selector(sendEvent:)
                       , @selector(swizzled_sendEvent:));
    });
#pragma clang diagnostic pop
}

#pragma mark -- setter getter
- (void)setTimer:(NSTimer *)timer
{
    objc_setAssociatedObject(self, &timerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimer *)timer
{
    return objc_getAssociatedObject(self, &timerKey);
}

#pragma mark -- 重置定时器
-(void)resetTimer {
    if (self.timer) {
        
        [self.timer invalidate];
        
    }
    //将超时时间由分钟转换成秒数
    int timeout =  kApplicationnoOperationTimeInMinutes * 60;
    self.timer = [NSTimer
                  scheduledTimerWithTimeInterval:timeout
                  target:self
                  selector:@selector(TimerExceeded)
                  userInfo:nil repeats:NO];//是否重复执行
}
#pragma mark -- 定时器执行的方法
-(void)TimerExceeded {
    NSLog(@"执行");
}

#pragma mark -- swizzled_sendEvent
- (void)swizzled_sendEvent:(UIEvent *)event
{
    
    if (!self.timer) {
        [self resetTimer];
    }
    NSSet *allTouches = [event allTouches];
    if ([allTouches count] > 0) {
        UITouchPhase phase= ((UITouch *)
        [allTouches anyObject]).phase;
        if (phase == UITouchPhaseEnded)
            [self resetTimer];
    }
    [self swizzled_sendEvent:event];
}
- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}
@end
