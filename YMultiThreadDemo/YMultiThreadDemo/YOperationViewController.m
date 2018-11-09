//
//  YOperationViewController.m
//  YMultiThreadDemo
//
//  Created by 云谷行 on 2018/11/8.
//  Copyright © 2018 YXW. All rights reserved.
//

#import "YOperationViewController.h"

@interface YOperationViewController ()

@end

@implementation YOperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSLog(@"queue maxConcurrentOperationCount:%zi  activeProcessorCount:%zi",queue.maxConcurrentOperationCount,[NSProcessInfo processInfo].activeProcessorCount);

    
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"block Operation before");
        [NSThread sleepForTimeInterval:2.];
        NSLog(@"block Operation end");
    }];
    [blockOperation addExecutionBlock:^{
        NSLog(@"block2 Operation before");
        [NSThread sleepForTimeInterval:1.];
        NSLog(@"block2 Operation end");
    }];
    [blockOperation addExecutionBlock:^{
        NSLog(@"block3 Operation before");
        [NSThread sleepForTimeInterval:3.];
        NSLog(@"block3 Operation end");
    }];
    [queue addOperation:blockOperation];
    
    dispatch_async(globalQueue, ^{
        NSLog(@"block Operation wait");
        [blockOperation waitUntilFinished];
        NSLog(@"block all Operation done");
    });
    
    NSString *string = @"abcdefg";
    NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(changeString:) object:string];
    [queue addOperation:invocationOperation];
    dispatch_async(globalQueue, ^{
        [invocationOperation waitUntilFinished];
        NSLog(@"invocation Operation result:%@",invocationOperation.result);
    });
    
}

- (NSString *)changeString:(NSString *)string{
    NSLog(@"changeString before");
    [NSThread sleepForTimeInterval:1.];
    NSLog(@"changeString end");
    return string.capitalizedString;
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
