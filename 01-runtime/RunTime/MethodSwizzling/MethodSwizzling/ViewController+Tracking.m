

//
//  UIViewController+Tracking.m
//  MethodSwizzling
//
//  Created by 刘华健 on 15/10/27.
//  Copyright © 2015年 MK. All rights reserved.
//
#import <objc/runtime.h>
#import "ViewController+Tracking.h"

void swizzle_method(Class class,SEL originalSelector,SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

    //将originalSelector对应的方法实现换成swizzledMethod
    BOOL didSwizzleMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (didSwizzleMethod) {
        //将swizzledSelector对应的方法实现换成originalMethod
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        //直接交换两个方法实现
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@implementation ViewController (Tracking)

//类加载的时候调用
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzle_method(self.class, @selector(viewDidLoad), @selector(swizze_viewDidLoad));
        swizzle_method(self.class, @selector(test), @selector(swizze_test));

    });
}

- (void)swizze_viewDidLoad {
    NSLog(@"2");
    NSLog(@"%@",NSStringFromClass(self.class));
    NSLog(@"3");
    [self swizze_viewDidLoad];//将会把这个函数内的代码执行完，再跳转执行ViewDidLoad中的剩余的代码（所以一般应该放到最后一行）
}

- (void)swizze_test {
    NSLog(@"111");
    [self swizze_test];
    NSLog(@"2222");

}
@end
