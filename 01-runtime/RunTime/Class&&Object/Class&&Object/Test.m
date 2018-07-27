//
//  Test.m
//  Class&&Object
//
//  Created by 刘华健 on 15/10/28.
//  Copyright © 2015年 MK. All rights reserved.
//

#import "Test.h"
#import <objc/runtime.h>
void TestMetaClass(id self, SEL _cmd) {
    
    NSLog(@"This objcet is %p", self);
    NSLog(@"Class is %@, super class is %@", [self class], [self superclass]);
    
    Class currentClass = [self class];
    for (int i = 0; i < 4; i++) {
        NSLog(@"Following the isa pointer %d times gives %p", i, currentClass);//分析打印结果，可以看到最后指针指向的地址是0×0，即NSObject的meta-class的类地址。
        currentClass = objc_getClass((__bridge void *)currentClass);
    }
    
    NSLog(@"NSObject&#039;s class is %p", [NSObject class]);
    NSLog(@"NSObject&#039;s meta class is %p", objc_getClass((__bridge void *)[NSObject class]));
}

@implementation Test

#pragma mark -

- (void)ex_registerClassPair {
    
    //创建一个新类和元类
    Class newClass = objc_allocateClassPair([NSError class], "TestClass", 0);
    //为该类添加方法
    class_addMethod(newClass, @selector(testMetaClass), (IMP)TestMetaClass, "v@:");
    //注册新类
    objc_registerClassPair(newClass);
    
    id instance = [[newClass alloc] initWithDomain:@"some domain" code:0 userInfo:nil];
    [instance performSelector:@selector(testMetaClass)];
}


@end
