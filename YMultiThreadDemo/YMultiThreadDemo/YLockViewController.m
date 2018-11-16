//
//  YLockViewController.m
//  YMultiThreadDemo
//
//  Created by 云谷行 on 2018/11/12.
//  Copyright © 2018 YXW. All rights reserved.
//

#import "YLockViewController.h"

@interface YLockViewController ()

@property (copy, nonatomic) dispatch_semaphore_t signal;
@property (assign, nonatomic) NSInteger number;

@property (assign, nonatomic) NSInteger tickets;
@property (copy, nonatomic) NSTimer *timer;
@property (copy, nonatomic) NSTimer *timer2;
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
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        dispatch_async(queue, ^{
            __strong typeof(wself) strongSelf = wself;
            [strongSelf buyTicket];
        });
    }];
    
    _timer2 = [NSTimer scheduledTimerWithTimeInterval:0.15 repeats:YES block:^(NSTimer * _Nonnull timer) {
        dispatch_async(queue2, ^{
            __strong typeof(wself) strongSelf = wself;
            [strongSelf buyTicket];
        });
    }];
    
   
}


- (void)buyTicket {
    
    dispatch_semaphore_wait(_signal, DISPATCH_TIME_FOREVER);
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
