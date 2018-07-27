//
//  AphroPaxos.h
//  Paxos
//
//  Created by 余妙玉 on 2018/6/26.
//  Copyright © 2018年 Lampard Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAphroPaxos.h"

#pragma mark -
#pragma mark - role

@interface AphroPaxosProposers : NSObject<IAphroPaxosProposer>
@end

@interface AphroPaxosAcceptor : NSObject<IAphroPaxosAcceptor>
@end

@interface AphroPaxosLearner : NSObject<IAphroPaxosLearner>
@end

#pragma mark -
#pragma mark - prorosal

@interface AphroPaxosProposal : NSObject<IAphroPaxosProposal>

@end

@interface AphroPaxosProposalValue :NSObject<IAphroPaxosProposalValue>
@end

@interface AphroPaxosProposalNumber:NSObject<IAphroPaxosProposalID>
@end


@interface AphroPaxosService:NSObject

+ (instancetype)shareInstance;

/**
 新节点加入集群
 */
- (void)publishNodeSpawn;

/**
 监听集群的信息(集群的机器数，当前的token等)
 */
- (void)listenClusterSyncInformation;

//+ (void)preparePropersal:(id<AphroPaxosProposal>)proposal;
//
//+ (NSUUID *)generalProposalNumber;


#pragma mark - boardcast
@property (nonatomic,strong)NSMutableSet *netServiceCollection;
- (NSNetService *)boardcast:(NSDictionary *)info
                serviceType:(NSString *)serviceType;

- (NSNetService *)boardcast:(NSDictionary *)infof
                     domain:(NSString *)domain
                serviceType:(NSString *)serviceType
                       name:(NSString *)name
                       port:(int)port;

- (NSNetServiceBrowser *)searchServiceType:(NSString *)serviceType;

- (NSNetServiceBrowser *)searchServiceType:(NSString *)serviceType
                                    domain:(NSString *)domain;


FOUNDATION_EXPORT NSString * const APBoardcastTXTDataKey;
@end

#pragma mark -
#pragma mark - const

FOUNDATION_EXPORT NSString * const APBoardcastLocalDomain;

FOUNDATION_EXPORT NSString * const APBoardcastServiceType_Sync;
FOUNDATION_EXPORT NSString * const APBoardcastName_Sync;

