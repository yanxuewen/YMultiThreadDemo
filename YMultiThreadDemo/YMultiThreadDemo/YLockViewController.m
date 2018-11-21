//
//  YLockViewController.m
//  YMultiThreadDemo
//
//  Created by 云谷行 on 2018/11/12.
//  Copyright © 2018 YXW. All rights reserved.
//

#import "YLockViewController.h"
#import "NSObject+DLIntrospection.h"
#import <pthread.h>

static pthread_mutex_t mutex;

@interface YLockViewController ()

@property (copy, nonatomic) dispatch_semaphore_t signal;
@property (assign, nonatomic) NSInteger number;

@property (assign, nonatomic) NSInteger tickets;
@property (copy, nonatomic) NSTimer *timer;
@property (copy, nonatomic) NSTimer *timer2;
@property (assign, atomic) BOOL writeCompleted;
@property (assign, atomic) NSInteger conditionNum;
@end

@implementation YLockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    _number = 0;
    _tickets = 50;
    
    _signal = dispatch_semaphore_create(1);
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(globalQueue, ^{
//        [self funOne];
//    });
//    dispatch_async(globalQueue, ^{
//        [self funOne];
//    });
//    dispatch_async(globalQueue, ^{
//        [self funOne];
//    });
    
    dispatch_queue_t queue = dispatch_queue_create("com.yxw.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t queue2 = dispatch_queue_create("com.yxw.queue2", DISPATCH_QUEUE_CONCURRENT);
    __weak typeof(self) wself = self;
//    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        dispatch_async(queue, ^{
//            __strong typeof(wself) strongSelf = wself;
//            [strongSelf buyTicket];
//        });
//    }];
//
//    _timer2 = [NSTimer scheduledTimerWithTimeInterval:0.15 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        dispatch_async(queue2, ^{
//            __strong typeof(wself) strongSelf = wself;
//            [strongSelf buyTicket];
//        });
//    }];
    
    
    /// 递归锁
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);  // 定义锁的属性
    pthread_mutex_init(&mutex, &attr); // 创建锁
//    dispatch_async(globalQueue, ^{
//        [self funPerform:5];
//    });
    
    
    /// NSCondition
    dispatch_queue_t queue3 = dispatch_queue_create("com.yxw.queue3", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t queue4 = dispatch_queue_create("com.yxw.queue4", DISPATCH_QUEUE_CONCURRENT);
    NSCondition *condition = [[NSCondition alloc] init];
    dispatch_async(queue3, ^{
        [condition lock];
        if (!wself.writeCompleted) {
            [condition wait];
        }
        NSLog(@"write completed after");
        [NSThread sleepForTimeInterval:2.];
        [condition unlock];
    });
    dispatch_async(queue4, ^{
        NSLog(@"write begin");
        [NSThread sleepForTimeInterval:2.];
        wself.writeCompleted = YES;
        NSLog(@"write completed");
        [condition signal];
    });
    
    _conditionNum = 1;
    NSConditionLock *conditionLock = [[NSConditionLock alloc] initWithCondition:1];
    dispatch_async(queue3, ^{
        [NSThread sleepForTimeInterval:0.5];
        [conditionLock lockWhenCondition:1];
        NSLog(@"condition lock task： %zi",wself.conditionNum);
        [NSThread sleepForTimeInterval:1.];
        wself.conditionNum ++;
        [conditionLock unlockWithCondition:2];
    });
    dispatch_async(queue4, ^{
        [conditionLock lockWhenCondition:2];
        NSLog(@"condition lock task： %zi",wself.conditionNum);
        [NSThread sleepForTimeInterval:2.];
        wself.conditionNum ++;
        [conditionLock unlockWithCondition:3];
    });
    dispatch_async(globalQueue, ^{
        [conditionLock lockWhenCondition:3];
        NSLog(@"condition lock task： %zi",wself.conditionNum);
        [NSThread sleepForTimeInterval:2.];
        wself.conditionNum ++;
        [conditionLock unlockWithCondition:4];
    });
    
    
    dispatch_async(globalQueue, ^{
        @synchronized (wself) {
            NSLog(@"synchronized run 1 begin");
            [NSThread sleepForTimeInterval:2.];
            NSLog(@"synchronized run 1 end");
        }
    });
    dispatch_async(globalQueue, ^{
        @synchronized (wself) {
            NSLog(@"synchronized run 2");
        }
    });
    
}

- (void)funPerform:(NSInteger)num {
    
    NSInteger lockReturn = pthread_mutex_trylock(&mutex);
    NSLog(@"lock return: %zi",lockReturn);
    if (num > 0) {
        NSLog(@"fun perform %zi",num);
        [self funPerform:num - 1];
    }
    pthread_mutex_unlock(&mutex);
}

- (void)buyTicket {
    
    dispatch_semaphore_wait(_signal, DISPATCH_TIME_FOREVER);
//    pthread_mutex_lock(&mutex);
    if (_tickets <= 0) {
        return;
    }
    NSLog(@"start buy ticket ");
    [NSThread sleepForTimeInterval:0.2];
    NSLog(@"buy ticket %zi",_tickets);
    _tickets --;
    if (_tickets <= 0) {
        NSLog(@"Tickets has been sold out");
        if ([_timer isValid]) {
            [_timer invalidate];
            [_timer2 invalidate];
        }
    }
    _number++;
    NSLog(@"end buy ticket run %zi",_number);
    
    dispatch_semaphore_signal(_signal);
//    pthread_mutex_unlock(&mutex);
}

#pragma mark - 快速升序排序
- (void)quickAscendingOrderSort:(NSMutableArray *)arr leftIndex:(NSInteger)left rightIndex:(NSInteger)right
{
    if (left < right) {
        NSInteger temp = [self getMiddleIndex:arr leftIndex:left rightIndex:right];
        [self quickAscendingOrderSort:arr leftIndex:left rightIndex:temp - 1];
        [self quickAscendingOrderSort:arr leftIndex:temp + 1 rightIndex:right];
    }
    NSLog(@"快速升序排序结果：%@", arr);
}

- (NSInteger)getMiddleIndex:(NSMutableArray *)arr leftIndex:(NSInteger)left rightIndex:(NSInteger)right
{
    
    NSInteger tempValue = [arr[left] integerValue];
    while (left < right) {
        while (left < right && tempValue <= [arr[right] integerValue]) {
            right --;
        }
        if (left < right) {
            arr[left] = arr[right];
        }
        while (left < right && [arr[left] integerValue] <= tempValue) {
            left ++;
        }
        if (left < right) {
            arr[right] = arr[left];
        }
    }
    arr[left] = [NSNumber numberWithInteger:tempValue];
    
    return left;
}

- (void)funOne {
    dispatch_semaphore_wait(_signal, DISPATCH_TIME_FOREVER);
    NSLog(@"funOne before run %zi",_number);
    [NSThread sleepForTimeInterval:0.5];
    NSLog(@"funOne end run %zi",_number);
    _number++;
    dispatch_semaphore_signal(_signal);
}
    
    
- (void)dealloc {
    NSLog(@"%s",__func__);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
