//
//  IAphroPaxos.h
//  Paxos
//
//  Created by 余妙玉 on 2018/6/26.
//  Copyright © 2018年 Lampard Hong. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IAphroPaxos,
IAphroPaxosRole,
IAphroPaxosProposer,
IAphroPaxosAcceptor,
IAphroPaxosProposal,
IAphroPaxosProposalID,
IAphroPaxosProposalValue;

/**
 abstract
 */
@protocol IAphroPaxos <NSObject>

@end

/**
 role
 */
@protocol IAphroPaxosRole <IAphroPaxos>
//Lamport 时间戳
@property (nonatomic,assign) NSTimeInterval lamportTimestamp;
@property (nonatomic,assign) NSTimeInterval roleTimestamp;

-(NSTimeInterval)fetchTimestamp;
@end

typedef NS_ENUM(NSInteger, IAphroPaxosStatus) {
    IAphroPaxosStatus_Prepare,
    IAphroPaxosStatus_Approve,
};

/**
 提议者
 */
@protocol IAphroPaxosProposer <IAphroPaxosRole>

@property (nonatomic,strong)id<IAphroPaxosProposal> proposal;

- (void)commitProposal:(id<IAphroPaxosProposal>)proposal;

- (void)tellLearner:(id<IAphroPaxosProposal>)proposal;

@end

/**
 复议者
 */
@protocol IAphroPaxosAcceptor <IAphroPaxosRole>

@property (nonatomic,weak)id<IAphroPaxosProposal> lastAcceptedProposal;

-(id<IAphroPaxosProposal>)prepare:(id<IAphroPaxosProposal>)proposal;

- (void)accept:(id<IAphroPaxosProposal>)proposal;

@end

@protocol IAphroPaxosLearner <IAphroPaxosRole>

@end

typedef NS_ENUM(NSInteger, IAphroPaxosProposalValueStatus) {
    IAphroPaxosProposalValueStatus_propersal,
    IAphroPaxosProposalValueStatus_chosen,
};

/**
 提案
 */
@protocol IAphroPaxosProposal <NSObject>

@property (nonatomic,strong)id<IAphroPaxosProposalID> proposalID;

@property (nonatomic, strong)id<IAphroPaxosProposalValue> value;

@end
/**
 提案内容
 */
@protocol IAphroPaxosProposalValue <NSObject>

@property (nonatomic,assign)IAphroPaxosProposalValueStatus status;

@property (nonatomic,strong)NSData *_data;

@end

/**
 提案编号,全序关系
 */
@protocol IAphroPaxosProposalID <NSObject>

@property (nonatomic,strong)NSUUID *pid;

-(NSComparisonResult)compareWithProposalNumber:(id<IAphroPaxosProposalID>)proposalNumber;

@end
