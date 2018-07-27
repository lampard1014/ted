//
//  MyClass.h
//  Class&&Object
//
//  Created by 刘华健 on 15/10/28.
//  Copyright © 2015年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MyClassDelegate <NSObject>

- (void)testProtocol;

@end

@interface MyClass : NSObject
<MyClassDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *array;
@property (nonatomic, copy) NSString *string;

- (void)method1;

- (void)method2;

+ (void)classMethod1;
@end
