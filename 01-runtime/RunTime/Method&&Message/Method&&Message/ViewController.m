//
//  ViewController.m
//  Method&&Message
//
//  Created by 刘华健 on 15/10/27.
//  Copyright © 2015年 MK. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//----------------------------------关于SEL的操作--------------------------//
    //1 获取选择器（SEL）
    SEL sel = @selector(test::);
    SEL sel2 = NSSelectorFromString(@"test::");
    const char *str = "test::";
    SEL sell = sel_registerName(str);
    NSLog(@"sel  == %p",sel);//打印的是内存地址
    NSLog(@"sel2 == %p",sel2);
    NSLog(@"sell == %p",sell);
    //2 返回给定选择器指定的方法的名称
    const char *name = sel_getName(sel);
    NSLog(@"name == %s",name);
    //3 比较两个选择器
    BOOL isEqual = sel_isEqual(sel, sel2);
    NSLog(@"isEqual == %d",isEqual);
    
//---------------------------------关于Method的操作-----------------------//
    //1 创建一个实例方法
    Method method = class_getInstanceMethod(self.class, sel);
    //2 获取方法名
    SEL sel3 = method_getName(method);
    NSLog(@"sel3 == %p",sel3);
    //3 返回方法的实现
    IMP imp = method_getImplementation(method);
    
    //4 获取描述方法参数和返回值类型的字符串
    const char *c = method_getTypeEncoding(method);
    NSLog(@"c == %s",c);
    //5 获取方法的返回值类型的字符串
    char *c2 = method_copyReturnType(method);
    NSLog(@"c2 == %s",c2);
    //6 获取方法的指定位置参数的类型字符串
    char *c3 = method_copyArgumentType(method, 2);
    NSLog(@"c3 == %s",c3); //从2开始才是参数的位置
    //7 返回方法的参数的个数
    unsigned int count = method_getNumberOfArguments(method);
    NSLog(@"count == %ud",count);
    //8 设置方法的实现
    SEL sel4 = @selector(test2);
    Method method2 = class_getInstanceMethod(self.class, sel4);
    IMP imp2 = method_getImplementation(method2);
    method_setImplementation(method, imp2); //返回值是method原来的imp
    [self test:YES :@""];//此时test::的实现变为test2的实现
    method_setImplementation(method2, imp);
    [self test2];
    //9 交换两个方法的实现
    method_exchangeImplementations(method, method2);
    [self test:YES :@""];
    [self test2];
    
}

- (void)test:(BOOL)isTest :(NSString *)title{
    NSLog(@"test");
}

- (void)test2 {
    NSLog(@"test2");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
