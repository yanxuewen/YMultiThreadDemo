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
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSLog(@"queue maxConcurrentOperationCount:%zi  activeProcessorCount:%zi",queue.maxConcurrentOperationCount,[NSProcessInfo processInfo].activeProcessorCount);
    NSLog(@"queue name %@",queue.name);
    NSLog(@"queue name %@",queue.underlyingQueue);
    queue.underlyingQueue = dispatch_queue_create("com.yxw.queue1", DISPATCH_QUEUE_SERIAL);
    NSLog(@"queue name %@",queue.underlyingQueue);
    
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
