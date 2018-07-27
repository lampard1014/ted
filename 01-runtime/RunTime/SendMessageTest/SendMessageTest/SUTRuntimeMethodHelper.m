//
//  SUTRuntimeMethodHelper.m
//  备用接受者测试
//
//  Created by 刘华健 on 15/7/18.
//  Copyright (c) 2015年 MK. All rights reserved.
//

#import "SUTRuntimeMethodHelper.h"

@implementation SUTRuntimeMethodHelper
- (void)method1{
    NSLog(@"方法1");
}

- (void)method2{
    NSLog(@"方法2");
}

- (void)method3:(NSInteger)index
{
    NSLog(@"method3 %ld",(long)index);
}
@end
