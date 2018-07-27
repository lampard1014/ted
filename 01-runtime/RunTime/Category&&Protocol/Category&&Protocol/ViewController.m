//
//  ViewController.m
//  Category&&Protocol
//
//  Created by 刘华健 on 15/10/27.
//  Copyright © 2015年 MK. All rights reserved.
//

#import <objc/runtime.h>
#import "ViewController.h"
#import "RuntimeCategoryClass.h"
#import "RuntimeCategoryClass+Category.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"测试objc_class中的方法列表是否包含分类中的方法");
    unsigned int outCount = 0;
    //返回指向方法数组的指针
    Method *methodList = class_copyMethodList(NSClassFromString(@"RuntimeCategoryClass"), &outCount);
    for (int i = 0; i < outCount; i++) {
        Method method = methodList[i];
        // 返回选择器
        SEL sel = method_getName(method);
        //得到方法名
        const char *name = sel_getName(sel);
        //转化为字符串类型
        NSString *str = [[NSString alloc] initWithUTF8String:name];
        NSLog(@"RuntimeCategoryClass&#039;s method: %s", name);
        NSLog(@"str = %@",str);
        //比较常量字符是否相等
        if (strcmp(name, sel_getName(@selector(method2)))) {
            NSLog(@"分类方法method2在objc_class的方法列表中");
        }
    }

    //1 返回指定的协议
    Protocol *protocol = objc_getProtocol("RuntimeCategoryClassDelegate");
    //2 获取运行时所知道的所有协议的数组
    //Protocol ** objc_copyProtocolList ( unsigned int *outCount );
    
    //3 创建新的协议实例
    Protocol *protocol2 =  objc_allocateProtocol ("MyProtocol");
    //4 在运行时中注册新创建的协议
    objc_registerProtocol(protocol2);
    
    //5 为协议添加方法
    protocol_addMethodDescription (protocol2, @selector(test), NULL, YES, YES);
    
    // 添加一个已注册的协议到协议中
    protocol_addProtocol (protocol,protocol2);
    
    
    // 为协议添加属性
//    void protocol_addProperty ( Protocol, "name", const objc_property_attribute_t *attributes, unsigned int attributeCount, BOOL isRequiredProperty, BOOL isInstanceProperty );
    
//    // 返回协议名
//    const char * protocol_getName ( Protocol *p );
//    
//    // 测试两个协议是否相等
//    BOOL protocol_isEqual ( Protocol *proto, Protocol *other );
//    
//    // 获取协议中指定条件的方法的方法描述数组
//    struct objc_method_description * protocol_copyMethodDescriptionList ( Protocol *p, BOOL isRequiredMethod, BOOL isInstanceMethod, unsigned int *outCount );
//    
//    // 获取协议中指定方法的方法描述
//    struct objc_method_description protocol_getMethodDescription ( Protocol *p, SEL aSel, BOOL isRequiredMethod, BOOL isInstanceMethod );
//    
//    // 获取协议中的属性列表
//    objc_property_t * protocol_copyPropertyList ( Protocol *proto, unsigned int *outCount );
//    
//    // 获取协议的指定属性
//    objc_property_t protocol_getProperty ( Protocol *proto, const char *name, BOOL isRequiredProperty, BOOL isInstanceProperty );
//    
//    // 获取协议采用的协议
//    Protocol ** protocol_copyProtocolList ( Protocol *proto, unsigned int *outCount );
//    
//    // 查看协议是否采用了另一个协议
//    BOOL protocol_conformsToProtocol ( Protocol *proto, Protocol *other );
//
//
}


- (void)test
{
    NSLog(@"test");
}

@end
