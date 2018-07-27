//
//  ViewController.m
//  Class&&Object
//
//  Created by 刘华健 on 15/10/28.
//  Copyright © 2015年 MK. All rights reserved.
//

#import "Test.h"
#import "MyClass.h"
#import <objc/runtime.h>
#import "ViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//-------------------------测试元类--------------------------------------------------------------
    Test *test = [[Test alloc] init];
    [test ex_registerClassPair];

    NSLog(@"========================================================================");

    
//--------------------------测试Class和Object------------------------------------------------------------
    MyClass *myClass = [[MyClass alloc] init];
    
    unsigned int outCount = 0;
    Class cls = myClass.class;
    // 获取类名
    NSLog(@"class name: %s", class_getName(cls));
    // 父类
    NSLog(@"super class name: %s", class_getName(class_getSuperclass(cls)));
    // 是否是元类
    NSLog(@"MyClass is %@ a meta-class", (class_isMetaClass(cls) ? @"" : @"not"));
    // 得到元类
    Class meta_class = objc_getMetaClass(class_getName(cls));
    NSLog(@"%s meta-class is %s", class_getName(cls), class_getName(meta_class));
    // 变量实例大小
    NSLog(@"instance size: %zu", class_getInstanceSize(cls));
    
    // 成员变量
    Ivar *ivars = class_copyIvarList(cls, &outCount);
    for (int i = 0; i<outCount; i++) {
        Ivar ivar = ivars[i];
        NSLog(@"instance variables name: %s at index: %d", ivar_getName(ivar), i);
    }
    free(ivars);//释放成员变量
    
    //获取类中指定名称实例成员变量的信息
    Ivar string = class_getInstanceVariable(cls, "_string");
    if (string != NULL) {
        //获取成员变量名
        NSLog(@"instace variable %s", ivar_getName(string));
        ////获取成员变量的类型编码
        NSLog(@"instace variable type encoding %s", ivar_getTypeEncoding(string));
    }
    NSLog(@"==========================================================");
    
    // 属性操作
    objc_property_t * properties = class_copyPropertyList(cls, &outCount);
    for (int i = 0; i<outCount; i++) {
        objc_property_t property = properties[i];
        //获取属性名
        NSLog(@"propertys name: %s", property_getName(property));
        //获取属性特性描述字符串
        NSLog(@"propertys attribueds : %s",property_getAttributes(property));
        //获取属性中指定的特性
        NSLog(@"someone of propertys attribueds  : %s",property_copyAttributeValue(property, "T"));
        // 获取属性的特性列表
        unsigned int count = 0;
        objc_property_attribute_t *property_attribued_ts = property_copyAttributeList(property, &count);
        for (int i = 0; i < count; i++) {
            objc_property_attribute_t property_attribued_t = property_attribued_ts[i];
            NSLog(@"property attribute list : %s",property_attribued_t);
        }
    }
    free(properties);
    //获取类中获取指定的属性的信息
    objc_property_t array = class_getProperty(cls, "array");
    if (array != NULL) {
        NSLog(@"property %s", property_getName(array));
    }
    
    NSLog(@"==========================================================");
    
    // 方法操作
    Method *methods = class_copyMethodList(cls, &outCount);
    for (int i = 0; i<outCount; i++) {
        Method method = methods[i];
        NSLog(@"methods signature: %s", method_getName(method));
    }
    free(methods);
    
    Method method1 = class_getInstanceMethod(cls, @selector(method1));
    if (method1 != NULL) {
        NSLog(@"method %s", method_getName(method1));
    }
    
    Method classMethod = class_getClassMethod(cls, @selector(classMethod1));
    if (classMethod != NULL) {
        NSLog(@"class method : %s", method_getName(classMethod));
    }
    // 类实例是否响应指定的selector
    NSLog(@"MyClass is%@ responsd to selector: method3WithArg1:arg2:", class_respondsToSelector(cls, @selector(method3WithArg1:arg2:)) ? @"" : @" not");
    
    //得到方法的实现
    IMP imp = class_getMethodImplementation(cls, @selector(method1));
    imp();//调用方法的实现
    NSLog(@"==========================================================");
    // 获取所有的协议
    Protocol * __unsafe_unretained * protocols = class_copyProtocolList(cls, &outCount);
    Protocol * protocol;
    for (int i = 0; i<outCount; i++) {
        protocol = protocols[i];
        NSLog(@"protocol name: %s", protocol_getName(protocol));
        NSLog(@"MyClass is%@ responsed to protocol %s", class_conformsToProtocol(cls, protocol) ? @"" : @" not", protocol_getName(protocol));
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
