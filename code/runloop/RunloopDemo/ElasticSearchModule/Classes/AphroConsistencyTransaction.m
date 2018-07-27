//
//  AphroConsistencyTransaction.m
//  Paxos
//
//  Created by 余妙玉 on 2018/7/16.
//  Copyright © 2018年 Lampard Hong. All rights reserved.
//

#import "AphroConsistencyTransaction.h"
#import <CoreFoundation/CoreFoundation.h>
#import "AphroPaxos.h"
#import <mach/mach.h>

#pragma mark -
#pragma mark - source context
void(RunLoopSource0ScheduleRoutine)(void *info, CFRunLoopRef rl, CFRunLoopMode mode);
void(RunLoopSource0PerformRoutine)(void *info, CFRunLoopRef rl, CFRunLoopMode mode);
void(RunLoopSource0CancelRoutine)(void *info);

void (RunLoopSource1CFMachPortCallBack)(CFMachPortRef port, void *msg, CFIndex size, void *info);

const void *(RunLoopSource1Retain)(const void *info);
void    (RunLoopSource1Release)(const void *info);
mach_port_t    (RunLoopSource1getPort)(void *info);
void *    (RunLoopSource1perform)(void *msg, CFIndex size, CFAllocatorRef allocator, void *info);



#pragma mark - observe context
const void *(RunLoopObserverRetain)(const void *info);
void    (RunLoopObserverRelease)(const void *info);
#pragma mark - obserer callback
void (RunLoopObserverCallBack)(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info);


@implementation AphroConsistencyTransactionDelegate
- (void)handleMachMessage:(void *)msg;
{
    mach_msg_header_t *msg_t = msg;
    if (msg_t != NULL) {
        if (ACT_Msg_TokenSyncThreadInitCompleted == msg_t->msgh_id) {
            //工作线程初始化完毕
            NSLog(@"🍺[工作线程初始化完毕]");
            [self.parasitfer clusterSync];
        }
    }
    
}
@end


#pragma mark - transaction
@interface AphroConsistencyTransaction()

@property (nonatomic,assign)CFMachPortRef syncMachPort;

@end

@implementation AphroConsistencyTransaction

void myRunLoopObserver(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info);

static AphroConsistencyTransaction *shareInstance = nil;

+ (void)initialize;
{
    if (self == [AphroConsistencyTransaction self]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            shareInstance = [[self alloc]init];
            shareInstance.transactionDelegate = [[AphroConsistencyTransactionDelegate alloc]init];
            shareInstance.transactionDelegate.parasitfer = shareInstance;
        });
    }
}

+(void)startup;
{
    [shareInstance createTokenSyncThread];
//    [shareInstance clusterSync];
}



- (void)clusterSync;
{
    //监听广播的全局信息
    mach_msg_return_t error = [shareInstance
                               portCommunicationWithMsgId:(mach_msg_id_t)ACT_Msg_TokenSyncThreadStartListenGlobalSyncInfo];
    if (error == MACH_MSG_SUCCESS) {
        // ...
        NSLog(@"🍺[port 通信成功]准备监听全局信息广播");
    } else {
        NSLog(@"⚰️[port 通信失败]errorcode : %d" ,(int)error);

    }

    
//    [[shareInstance  syncMachPort]sendBeforeDate:[NSDate distantFuture] msgid:3232 components:[@[@"newssss"]mutableCopy] from:[shareInstance  syncMachPort] reserved:0];
    
}

#pragma mark -
#pragma mark - port

- (mach_msg_return_t)portCommunicationWithMsgId:(mach_msg_id_t)msg_id;
{
    //    natural_t data = 17777;
    mach_port_t port = CFMachPortGetPort(shareInstance.syncMachPort);
    
    struct {
        mach_msg_header_t header;
        mach_msg_body_t body;
        mach_msg_type_descriptor_t type;
    } message;
    
    message.header = (mach_msg_header_t) {
        .msgh_remote_port = port,
        .msgh_local_port = MACH_PORT_NULL,
        .msgh_bits = MACH_MSGH_BITS(MACH_MSG_TYPE_COPY_SEND, 0),
        .msgh_size = sizeof(message),
        .msgh_id = msg_id
    };
    
    message.body = (mach_msg_body_t) {
        .msgh_descriptor_count = 1
    };
    
    //    message.type = (mach_msg_type_descriptor_t) {
    //        .pad1 = data,
    //        .pad2 = sizeof(data)
    //    };
    
    mach_msg_return_t error = mach_msg_send(&message.header);
    
    return error;
}


- (NSThread *)createTTLThread;
{
    NSThread *ttlThread = nil;
    
    
    NSNetService *ttlService = [[NSNetService alloc]initWithDomain:@"local."
                                                                  type:@"_nodeTTLService._udp"
                                                                  name:@"xx"
                                                                  port:0];
    
    [ttlService publish];
    
    return ttlThread;
    
}

- (NSThread *)createTokenSyncThread;
{
    NSThread *tokenSyncThread = nil;
    NSPort *myPort = [NSMachPort port];
    if (myPort) {
        [myPort setDelegate:shareInstance.transactionDelegate];
        [[NSRunLoop currentRunLoop] addPort:myPort forMode:NSDefaultRunLoopMode];
        //创建一个工作线程 用于同步
        
        tokenSyncThread = [[NSThread alloc]initWithTarget:shareInstance
                                                 selector:@selector(launchTokenSyncThreadWithPort:)
                                                   object:myPort];
        
        
        
        tokenSyncThread.name = AphroTokenSyncThreadName;
        tokenSyncThread.qualityOfService = NSQualityOfServiceUtility;
        [tokenSyncThread start];
        
    }
    return tokenSyncThread;
}

-(void)launchTokenSyncThreadWithPort:(NSPort *)port;
{
    //子线程增加一个source1
    CFRunLoopRef rlRef = CFRunLoopGetCurrent();

    CFRunLoopObserverContext observerContext = {0,(__bridge void *)(self),
        &RunLoopObserverRetain,
        &RunLoopObserverRelease,
        NULL};
    
    CFRunLoopObserverRef observerRef = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                                            kCFRunLoopAllActivities,
                                                            YES,
                                                            0,
                                                            &RunLoopObserverCallBack,
                                                            &observerContext);

    if (observerRef) {
        CFRunLoopAddObserver(rlRef, observerRef, kCFRunLoopDefaultMode);
    }
    
//    CFRunLoopSourceContext context0 = {0,NULL,NULL,NULL,NULL,NULL,NULL,
//        &RunLoopSource0ScheduleRoutine,
//        &RunLoopSource0PerformRoutine,
//        &RunLoopSource0CancelRoutine};
//    CFRunLoopSourceRef source0 = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context0);
//    CFRunLoopAddSource(rlRef, source0, kCFRunLoopDefaultMode);

    CFMachPortContext context1 = {0,
        ACT_Msg_TokenSyncThreadWakeUp,
        &RunLoopSource1Retain,
        &RunLoopSource1Release,
        NULL};
    
    Boolean shouldFreeInfo = false;
    CFMachPortRef machPortRef = CFMachPortCreate(kCFAllocatorDefault,
                                                 &RunLoopSource1CFMachPortCallBack,
                                                 &context1,
                                                 &shouldFreeInfo);
    
    CFRunLoopSourceRef source1 = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, machPortRef, 0);
    CFRunLoopAddSource(rlRef, source1, kCFRunLoopDefaultMode);
    
//    shareInstance.syncMachPort =  (__bridge_transfer NSMachPort *)machPortRef;

    shareInstance.syncMachPort = machPortRef;
    
    BOOL success = [port sendBeforeDate:[NSDate distantFuture] msgid:ACT_Msg_TokenSyncThreadInitCompleted
                             components:nil
                                   from:port
                               reserved:0];
    
    if (success) {
        NSLog(@"🍺[runloop 初始化成功]");
    } else {
        NSLog(@"⚰️[runloop 初始化失败]");
    }
    CFRunLoopRun();
}


@end

#pragma mark -
#pragma mark - cfrunloop
#pragma mark - observe context
                                                            
                                                            
const void *(RunLoopObserverRetain)(const void *info)
{
    NSLog(@"");
    return NULL;
}
void (RunLoopObserverRelease)(const void *info)
{
    NSLog(@"funx _%s",__func__);
}

#pragma mark - obserer callback
void (RunLoopObserverCallBack)(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    NSLog(@"activity %ld",activity);
}

void(RunLoopSource0ScheduleRoutine)(void *info, CFRunLoopRef rl, CFRunLoopMode mode)
{
    NSLog(@"");
}
void(RunLoopSource0PerformRoutine)(void *info, CFRunLoopRef rl, CFRunLoopMode mode)
{
    NSLog(@"");
    NSLog(@"do some thing");
}
void(RunLoopSource0CancelRoutine)(void *info)
{
    NSLog(@"");
}


const void *(RunLoopSource1Retain)(const void *info)
{
    
    NSLog(@"xxx");
//    ;    [[AphroPaxosService shareInstance]listenClusterSyncInformation];

    return NULL;
}
void (RunLoopSource1Release)(const void *info)
{
    NSLog(@"xxx");
}

void (RunLoopSource1CFMachPortCallBack)(CFMachPortRef port, void *msg, CFIndex size, void *info)
{
    mach_msg_header_t  *m =  (mach_msg_header_t *)msg;
    if (m) {
        NSUInteger msgid = (NSUInteger)m->msgh_id;
        if (ACT_Msg_TokenSyncThreadStartListenGlobalSyncInfo == msgid) {
            [[AphroPaxosService shareInstance]listenClusterSyncInformation];
            [[AphroPaxosService shareInstance]publishNodeSpawn];
        }
    }
}

mach_port_t    (RunLoopSource1getPort)(void *info)
{
    return 123;
}
void *    (RunLoopSource1perform)(void *msg, CFIndex size, CFAllocatorRef allocator, void *info)
{
    return NULL;
}


#pragma mark -
#pragma mark - const
NSString * const AphroTokenSyncThreadName = @"com.lampard.thread.tokenSync";

NSString * const ACT_Msg_TokenSyncThreadWakeUp = @"com.lampard.thread.tokenSync.wakeUp";

NSUInteger const ACT_Msg_TokenSyncThreadInitCompleted = 710000;

NSUInteger const ACT_Msg_TokenSyncThreadStartListenGlobalSyncInfo = 710001;
