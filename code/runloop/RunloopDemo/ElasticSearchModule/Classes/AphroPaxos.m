//
//  AphroPaxos.m
//  Paxos
//
//  Created by 余妙玉 on 2018/6/26.
//  Copyright © 2018年 Lampard Hong. All rights reserved.
//

#import "AphroPaxos.h"

#pragma mark -
#pragma mark - role

@implementation AphroPaxosProposers
@synthesize proposal,lamportTimestamp,roleTimestamp;

- (void)commitProposal:(id<IAphroPaxosProposal>)proposal;
{
    
}
- (void)tellLearner:(id<IAphroPaxosProposal>)proposal;
{
    
}
- (NSTimeInterval)fetchTimestamp {
    return lamportTimestamp++;
}

@end

@implementation AphroPaxosAcceptor
@synthesize lastAcceptedProposal,roleTimestamp,lamportTimestamp;
- (void)accept:(id<IAphroPaxosProposal>)proposal;
{
    
}

- (id<IAphroPaxosProposal>)prepare:(id<IAphroPaxosProposal>)proposal {
    return nil;
}

- (NSTimeInterval)fetchTimestamp {
    return (NSTimeInterval)MAX(roleTimestamp,lamportTimestamp);
}

@end

@implementation AphroPaxosLearner
@synthesize roleTimestamp,lamportTimestamp;

- (NSTimeInterval)fetchTimestamp {
    return (NSTimeInterval)MAX(roleTimestamp,lamportTimestamp);
}

@end

#pragma mark -
#pragma mark - prorosal

@implementation AphroPaxosProposal
@synthesize proposalID,value;
@end

@implementation AphroPaxosProposalValue
@synthesize status,_data;
@end

@implementation AphroPaxosProposalNumber
@synthesize pid;
-(NSComparisonResult)compareWithProposalNumber:(id<IAphroPaxosProposalID>)proposalNumber;
{
    uuid_t   this;
    uuid_t   that;
    
    [self.pid getUUIDBytes:this];
    [proposalNumber.pid getUUIDBytes:that];
    const int   r  = memcmp ( this, that, sizeof ( this ) );
    if ( r < 0 )
        return  NSOrderedAscending;
    if ( r > 0 )
        return  NSOrderedDescending;
    
    return  NSOrderedSame;
}
@end


@import Foundation;
@interface AphroPaxosService ()<NSNetServiceBrowserDelegate>{
    AphroPaxosProposers *_proposer;
    AphroPaxosAcceptor *_acceptor;
    AphroPaxosLearner *_learner;
}

@property (nonatomic,strong)NSNetServiceBrowser *testBrowser;
@property (nonatomic,strong)NSNetService *testService;

- (void)becomeProposer;
- (void)removeProposer;
- (void)becomeAcceptor;
- (void)removeAcceptor;
- (void)becomeLearner;
- (void)removeLearner;

@end

@implementation AphroPaxosService

static AphroPaxosService *paxosService = nil;
+ (instancetype)shareInstance;
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        paxosService = [[self alloc]init];
        paxosService.netServiceCollection = [NSMutableSet set];
    });
    return paxosService;
}


- (void)becomeProposer;
{
    self->_proposer = [[AphroPaxosProposers alloc]init];
}
- (void)becomeAcceptor;
{
    self->_acceptor = [[AphroPaxosAcceptor alloc]init];
}
- (void)becomeLearner;
{
    self->_learner = [[AphroPaxosLearner alloc]init];
}

- (void)removeProposer;
{
    self->_proposer = nil;
}
- (void)removeAcceptor;
{
    self->_acceptor = nil;
}
- (void)removeLearner;
{
    self->_learner = nil;
}

//节点的基本信息
- (NSDictionary *)nodeInfo;
{
    return @{
             @"identifier":[[NSProcessInfo processInfo]globallyUniqueString],
             @"name":[[NSProcessInfo processInfo]hostName],
             };
}

//节点的网络信息
- (NSDictionary *)s;
{
    return nil;
}


/**
 新节点加入集群
 */
- (void)publishNodeSpawn;
{
    NSNetService *service = [self boardcast:@{
                      @"xxx":@"111",
                      @"ttt":@"222"
                      } serviceType:APBoardcastServiceType_Sync];
    [paxosService.netServiceCollection addObject:service];

}

/**
 监听集群的信息(集群的机器数，当前的token等)
 */
- (void)listenClusterSyncInformation;
{
    [self searchServiceType:APBoardcastServiceType_Sync];
////    [paxosService.netServiceCollection addObject : browser];
//    paxosService.testBrowser = browser;
    
}

#pragma mark -
#pragma mark - boardcast
- (NSNetService *)boardcast:(NSDictionary *)info
                serviceType:(NSString *)serviceType;
{
    return [self boardcast:info
                    domain:APBoardcastLocalDomain
               serviceType:[@[@"_",serviceType,@"._tcp"]componentsJoinedByString:@""]
                      name:APBoardcastName_Sync
                      port:9721];
}

- (NSNetService *)boardcast:(NSDictionary *)info
                     domain:(NSString *)domain
                serviceType:(NSString *)serviceType
                       name:(NSString *)name
                       port:(int)port;
{
    NSNetService *service = [[NSNetService alloc]initWithDomain:domain
                                                           type:serviceType
                                                           name:name
                                                           port:port];

    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    
    
    BOOL isSuccess = [service setTXTRecordData:[NSNetService dataFromTXTRecordDictionary:@{APBoardcastTXTDataKey:jsonData}]];
    
    [service scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    service.delegate = self;
    [service publish];
    return service;
}

- (NSNetServiceBrowser *)searchServiceType:(NSString *)serviceType;
{
    return [self searchServiceType:[@[@"_",serviceType,@"._tcp"]componentsJoinedByString:@""]
                            domain:APBoardcastLocalDomain];
}

- (NSNetServiceBrowser *)searchServiceType:(NSString *)serviceType
                                    domain:(NSString *)domain;
{
    NSNetServiceBrowser *browser = [[NSNetServiceBrowser alloc]init];
    [paxosService.netServiceCollection addObject : browser];
    browser.delegate = paxosService;
    [browser scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [browser searchForServicesOfType:serviceType inDomain:domain];
    return browser;
}


#pragma mark -
#pragma mark - protocol NSNetServiceDelegate
- (void)netServiceWillPublish:(NSNetService *)sender;
{
    NSLog(@"_%d",FUNCTION_DECLSPEC);
}

- (void)netServiceDidPublish:(NSNetService *)sender;
{
    
    NSData *x = [NSNetService dictionaryFromTXTRecordData:[sender TXTRecordData]][APBoardcastTXTDataKey];
    id data = [NSJSONSerialization JSONObjectWithData:x
                                              options:NSJSONReadingMutableContainers
                                                error:nil];
    
    NSLog(@"_%d sss %@",FUNCTION_DECLSPEC,data);
    //发布成功就删掉
//    [paxosService.netServiceCollection removeAllObjects];
    
//    [paxosService.testBrowser removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    NSLog(@"");
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary<NSString *, NSNumber *> *)errorDict;
{
    NSLog(@"_%d",FUNCTION_DECLSPEC);
}

- (void)netServiceWillResolve:(NSNetService *)sender;
{
    NSLog(@"_%d",FUNCTION_DECLSPEC);
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender;
{
    NSLog(@"_%d",FUNCTION_DECLSPEC);
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary<NSString *, NSNumber *> *)errorDict;
{
    NSLog(@"_%d",FUNCTION_DECLSPEC);
}

- (void)netServiceDidStop:(NSNetService *)sender;
{
    NSLog(@"_%d",FUNCTION_DECLSPEC);
}

- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data;
{
    NSLog(@"_%d",FUNCTION_DECLSPEC);

}

- (void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream;
{
    NSLog(@"_%d",FUNCTION_DECLSPEC);
}
#pragma mark - protocol NSNetServiceBrowserDelegate
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser;
{
    NSLog(@"_%d",FUNCTION_DECLSPEC);
}
- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser;
{
    NSLog(@"_%d",FUNCTION_DECLSPEC);
}
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary<NSString *, NSNumber *> *)errorDict;
{
    NSLog(@"_%d",FUNCTION_DECLSPEC);
}
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing;
{
    NSLog(@"_%d",FUNCTION_DECLSPEC);
}
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing;
{
    NSLog(@"_%d",FUNCTION_DECLSPEC);
}
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveDomain:(NSString *)domainString moreComing:(BOOL)moreComing;
{
    NSLog(@"_%d",FUNCTION_DECLSPEC);
}
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing;
{
    NSLog(@"_%d",FUNCTION_DECLSPEC);
}



#pragma mark -
#pragma mark - public
+ (void)PreparePropersal:(id<IAphroPaxosProposal>)proposal;
{
    //选择一个propersal
    
    id<IAphroPaxosProposalID> number = proposal.proposalID;
    
    
}

#pragma mark -
#pragma mark - private
+ (void)sendPrepareRequeset:(id<IAphroPaxosProposal>)proposal
                 toMajority:(NSOrderedSet<id<IAphroPaxosAcceptor>> *)acceptors;
{
    for (id<IAphroPaxosAcceptor>acceptor in acceptors) {
        [acceptor prepare:proposal];
    }
}

+ (NSUUID *)generalProposalNumber;
{
    return [NSUUID UUID];
}
@end

#pragma mark -
#pragma mark - const
NSString * const APBoardcastTXTDataKey = @"[AP][Boardcast]TXTDataKey";

NSString * const APBoardcastLocalDomain = @"local.";
NSString * const APBoardcastServiceType_Sync = @"apservice-sync";
NSString * const APBoardcastName_Sync = @"";

