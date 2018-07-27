//
//  ViewController.m
//  MethodSwizzling
//
//  Created by 刘华健 on 15/10/27.
//  Copyright © 2015年 MK. All rights reserved.
//

#import "ViewController.h"
#import "ViewController+Tracking.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    NSLog(@"1");
    [super viewDidLoad];//跳转到swizze_viewDidLoad中执行，swizze_viewDidLoad的实现
    NSLog(@"4");
    [self test];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)test {
    NSLog(@"123");
}


@end
