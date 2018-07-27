//
//  ViewController.m
//  RunTime消息转发测试
//
//  Created by 刘华健 on 15/7/22.
//  Copyright (c) 2015年 MK. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "SUTRuntimeMethodHelper.h"
@interface ViewController ()
{
    SUTRuntimeMethodHelper *_helper;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _helper = [[SUTRuntimeMethodHelper alloc] init];//创建响应消息的对象
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(10, 50, CGRectGetWidth(self.view.frame) - 20, 100);
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"动态解析测试" forState:UIControlStateNormal];
    button.tag = 1;
    [button addTarget:self action:@selector(button:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake(10, 170, CGRectGetWidth(self.view.frame) - 20, 100);
    button2.tag = 2;
    button2.backgroundColor = [UIColor redColor];
    
    [button2 addTarget:self action:@selector(button:) forControlEvents:UIControlEventTouchUpInside];
    [button2 setTitle:@"备用接收者测试" forState:UIControlStateNormal];
    [self.view addSubview:button2];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    button3.frame = CGRectMake(10, 290, CGRectGetWidth(self.view.frame) - 20, 100);
    button3.tag = 3;
    button3.backgroundColor = [UIColor redColor];
    
    [button3 addTarget:self action:@selector(button:) forControlEvents:UIControlEventTouchUpInside];
    [button3 setTitle:@"完整的消息转发测试" forState:UIControlStateNormal];
    [self.view addSubview:button3];
    
    
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
    button4.frame = CGRectMake(10, 410, CGRectGetWidth(self.view.frame) - 20, 100);
    button4.tag = 4;
    button4.backgroundColor = [UIColor redColor];
    
    [button4 addTarget:self action:@selector(button:) forControlEvents:UIControlEventTouchUpInside];
    [button4 setTitle:@"NSInvocation测试" forState:UIControlStateNormal];
    [self.view addSubview:button4];
    
    
    
}

- (void)button:(UIButton *)sender
{
    
    if(sender.tag == 1 ) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [self performSelector:@selector(method)];
#pragma clang diagnostic pop
        
    }
    
    if (sender.tag == 2) {
        [self performSelector:@selector(method1)];
        
    }
    
    if (sender.tag == 3) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [self performSelector:@selector(method2)];
#pragma clang diagnostic pop
        
    }
    
    if (sender.tag == 4) {
        //NSInvocation需要知道发送的消息,接收消息的对象(谁是发送消息的对象呢?我理解为系统,或者是self).
        NSInteger index = arc4random();
        NSMethodSignature *methodSignature = [_helper methodSignatureForSelector:@selector(method3:)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setTarget:_helper];
        [invocation setSelector:@selector(method3:)];
        [invocation setArgument:&index atIndex:2];
        [invocation invoke];
        
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- 动态解析测试 (动态的创建消息)
/* 1 调用未创建的method方法(未知消息)
 2 在resolveInstanceMethod或者resolveClassMethod方法中,我们有机会为未知的消息增加处理方法
 3 使用mehod方法的前提是我们已经实现了该”处理方法”，只需要在运行时通过class_addMethod函数动态添加到类里面就可以了
 */

void functionForMethod(id _self, SEL __cmd) {//方法的实现IMP
    NSLog(@"方法0");
}

//不能处理消息,最后调用
- (void)doesNotRecognizeSelector:(SEL)aSelector {
    
}
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    NSString *selectorString = NSStringFromSelector(sel);
    if ([selectorString isEqualToString:@"method"]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        class_addMethod(self.class, @selector(method), (IMP)functionForMethod, "@:");
#pragma clang diagnostic pop
        return YES;

    }
    return [super resolveInstanceMethod:sel];
}

//消息转发测试


#pragma mark -- 消息转发测试
/*
 1 如果在上一步无法处理消息，则Runtime会继续调forwardingTargetForSelector方法
 2 如果一个对象实现了这个方法，并返回一个非nil的结果，则这个对象会作为消息的新接收者，且消息会被分发到这个对象。
 3 当然这个对象不能是self自身，否则就是出现无限循环。
 4 当然，如果我们没有指定相应的对象来处理aSelector，则应该调用父类的实现来返回结果。
 5 这样在对象外部看来，还是由该对象亲自处理了这一消息。
 */
- (id)forwardingTargetForSelector:(SEL)aSelector {

    NSString *selectorString = NSStringFromSelector(aSelector);
    // 将消息转发给_helper来处理
    if ([selectorString isEqualToString:@"method1"]) {
        return _helper;
    }

    return [super forwardingTargetForSelector:aSelector];
}

#pragma mark -- 完整的消息转发机制
/*
 1 如果在上一步还不能处理未知消息，则唯一能做的就是启用完整的消息转发机制了。此时会调用以下方法：forwardInvocation(未处理消息的细节都封装在其中)
 2 forwardInvocation的作用:定位能够处理该未知消息的对象 使用anInvocation作为参数，将消息发送给选中的对象,并将结果返回给消息发送者
 3 我们必须重写以下方法 methodSignatureForSelector:消息转发机制使用从这个方法中获取的信息来创建NSInvocation对象。因此我们必须重写这个方法，为给定的selector提供一个合适的方法签名。
 */
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        if ([SUTRuntimeMethodHelper instancesRespondToSelector:aSelector]) {
            signature = [SUTRuntimeMethodHelper instanceMethodSignatureForSelector:aSelector];
        }
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([SUTRuntimeMethodHelper instancesRespondToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:_helper];
    }
}
//后两个只需实现一个即可 最好实现最后一个,因为具有通用性
@end
