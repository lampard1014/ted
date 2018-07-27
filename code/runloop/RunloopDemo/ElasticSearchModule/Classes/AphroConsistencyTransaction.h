//
//  AphroConsistencyTransaction.h
//  Paxos
//
//  Created by 余妙玉 on 2018/7/16.
//  Copyright © 2018年 Lampard Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AphroConsistencyTransaction,AphroPaxosService;

#pragma mark - delegate NSMachPortDelegate
@interface AphroConsistencyTransactionDelegate:NSObject<NSMachPortDelegate>
@property (nonatomic,weak)AphroConsistencyTransaction *parasitfer;
@end

@interface AphroConsistencyTransaction : NSObject
@property (nonatomic,strong)AphroConsistencyTransactionDelegate *transactionDelegate;
//初始化
+(void)startup;
//同步集群
- (void)clusterSync;


@end

#pragma mark -
#pragma mark - const
FOUNDATION_EXPORT NSString * const AphroTokenSyncThreadName;

FOUNDATION_EXPORT NSString * const ACT_Msg_TokenSyncThreadWakeUp;

FOUNDATION_EXPORT NSUInteger const ACT_Msg_TokenSyncThreadInitCompleted;

FOUNDATION_EXPORT NSUInteger const ACT_Msg_TokenSyncThreadStartListenGlobalSyncInfo;
