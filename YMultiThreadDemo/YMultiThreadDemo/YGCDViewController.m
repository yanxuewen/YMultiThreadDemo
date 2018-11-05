//
//  YGCDViewController.m
//  YMultiThreadDemo
//
//  Created by 云谷行 on 2018/11/2.
//  Copyright © 2018 YXW. All rights reserved.
//

#import "YGCDViewController.h"

static const void * const kDispatchQueueSpecificKey = "kDispatchQueueSpecificKey";

@interface YGCDViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic) NSMutableString *terminalOutputStr;

@property (copy, nonatomic) NSString *testStr;

@end

@implementation YGCDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"GCD";
    _testStr = @"GCD";
    _terminalOutputStr = @"".mutableCopy;
    __weak typeof(self) wself = self;
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_queue_t serialQueue = dispatch_queue_create("com.example.MyQueue",NULL);
    //serialQueue现在的优先级跟globalQueue的优先级一样
    dispatch_set_target_queue(serialQueue, globalQueue);
    
    
    dispatch_queue_t targetQueue = dispatch_queue_create("com.yxw.target_queue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue1 = dispatch_queue_create("com.yxw.queue1", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue2 = dispatch_queue_create("com.yxw.queue2", DISPATCH_QUEUE_CONCURRENT);
    dispatch_set_target_queue(queue1, targetQueue);
    dispatch_set_target_queue(queue2, targetQueue);
    dispatch_async(queue1, ^{
        NSLog(@"target do job1");
        dispatch_async(mainQueue, ^{
            [wself updateTextViewWith:@"target do job1"];
        });
        [NSThread sleepForTimeInterval:5.];
    });
    dispatch_async(queue2, ^{
        NSLog(@"target do job2");
        dispatch_async(mainQueue, ^{
            [wself updateTextViewWith:@"target do job2"];
        });
        [NSThread sleepForTimeInterval:2.];
    });
    dispatch_async(queue2, ^{
        NSLog(@"target do job3");
        dispatch_async(mainQueue, ^{
            [wself updateTextViewWith:@"target do job3"];
        });
        [NSThread sleepForTimeInterval:1.];
    });
    dispatch_async(targetQueue, ^{
        NSLog(@"target do job4");
        dispatch_async(mainQueue, ^{
            [wself updateTextViewWith:@"target do job4"];
        });
        [NSThread sleepForTimeInterval:2.];
    });
    

    dispatch_queue_t queue = dispatch_queue_create("com.yxw.queue", DISPATCH_QUEUE_SERIAL);
    dispatch_block_t block = dispatch_block_create(0, ^{
        NSLog(@"before block sleep");
        dispatch_async(mainQueue, ^{
            [wself updateTextViewWith:@"before block sleep"];
        });
        [NSThread sleepForTimeInterval:2.];
        NSLog(@"after block sleep");
        dispatch_async(mainQueue, ^{
            [wself updateTextViewWith:@"after block sleep"];
        });
    });
    dispatch_block_t block2 = dispatch_block_create(0, ^{
        NSLog(@"before block2 sleep");
        dispatch_async(mainQueue, ^{
            [wself updateTextViewWith:@"before block2 sleep"];
        });
        [NSThread sleepForTimeInterval:10.];
        NSLog(@"after block2 sleep");
        dispatch_async(mainQueue, ^{
            [wself updateTextViewWith:@"after block2 sleep"];
        });
    });
    dispatch_async(queue, block);
    dispatch_async(queue, block2);
    
    dispatch_async(globalQueue, ^{
        //等待block执行完毕
        dispatch_block_wait(block, DISPATCH_TIME_FOREVER);
        NSLog(@"block wait coutinue");
        dispatch_async(mainQueue, ^{
            [wself updateTextViewWith:@"block wait coutinue"];
        });
    });
    dispatch_block_notify(block, globalQueue, ^{
         NSLog(@"block notify coutinue");
        dispatch_async(mainQueue, ^{
            [wself updateTextViewWith:@"block notify coutinue"];
        });
    });
    
    dispatch_async(globalQueue, ^{
        [NSThread sleepForTimeInterval:0.5];
        dispatch_block_cancel(block2);
        dispatch_block_cancel(block);
    });
    
    dispatch_block_notify(block2, globalQueue, ^{
        NSLog(@"block2 notify coutinue");
        dispatch_async(mainQueue, ^{
            [wself updateTextViewWith:@"block2 notify coutinue"];
        });
    });
    
    dispatch_queue_t dbQueue = dispatch_queue_create("com.yxw.database", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(dbQueue, ^{
        NSLog(@"DB reading data1");
        dispatch_async(mainQueue, ^{
            [wself updateTextViewWith:@"DB reading data1"];
        });
        [NSThread sleepForTimeInterval:1.];
        NSLog(@"DB read data1 completed");
        dispatch_async(mainQueue, ^{
            [wself updateTextViewWith:@"DB read data1 completed"];
        });
    });
    dispatch_async(dbQueue, ^{
        NSLog(@"DB reading data2");
        dispatch_async(mainQueue, ^{
            [wself updateTextViewWith:@"DB reading data2"];
        });
        [NSThread sleepForTimeInterval:2.];
        NSLog(@"DB read data2 completed");
        dispatch_async(mainQueue, ^{
            [wself updateTextViewWith:@"DB read data2 completed"];
        });
    });
    dispatch_barrier_async(dbQueue, ^{
        NSLog(@"DB writing data1");
        dispatch_async(mainQueue, ^{
            [wself updateTextViewWith:@"DB writing data1"];
        });
        [NSThread sleepForTimeInterval:1.];
        NSLog(@"DB write data1 completed");
        dispatch_async(mainQueue, ^{
            [wself updateTextViewWith:@"DB write data1 completed"];
        });
    });
    dispatch_async(dbQueue, ^{
        NSLog(@"DB reading data3");
        dispatch_async(mainQueue, ^{
            [wself updateTextViewWith:@"DB reading data3"];
        });
        [NSThread sleepForTimeInterval:1.];
    });

    
    dispatch_queue_set_specific(queue, kDispatchQueueSpecificKey, (__bridge void *)self, NULL);
    YGCDViewController *specificVC =
    (__bridge id)dispatch_queue_get_specific(queue, kDispatchQueueSpecificKey);
    NSLog(@"get specific wself title %@",specificVC.navigationItem.title);
    [self updateTextViewWith:[NSString stringWithFormat:@"get specific wself title %@",specificVC.navigationItem.title]];
    
    
    dispatch_apply(5, serialQueue, ^(size_t i) {
        NSLog(@"apply run %zi times",i);
        dispatch_async(mainQueue, ^{
            [wself updateTextViewWith:[NSString stringWithFormat:@"apply run %zi times",i]];
        });
    });
    
    
    
    dispatch_block_t block3 = dispatch_block_create(0, ^{
        NSLog(@"before block3 sleep");
        dispatch_async(mainQueue, ^{
            [wself updateTextViewWith:@"before block3 sleep"];
        });
        [NSThread sleepForTimeInterval:1.];
        NSLog(@"after block3 sleep");
        dispatch_async(mainQueue, ^{
            [wself updateTextViewWith:@"after block3 sleep"];
        });
    });
    dispatch_async(globalQueue, block3);
    dispatch_block_notify(block3, globalQueue, ^{
        NSLog(@"block3 notify coutinue");
        dispatch_async(mainQueue, ^{
            [wself updateTextViewWith:@"block3 notify coutinue"];
        });
    });
    dispatch_async(globalQueue, ^{
        [NSThread sleepForTimeInterval:3.];
        block3();
    });
    
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group,globalQueue,^{ NSLog(@"group block1"); });
    dispatch_group_async(group,globalQueue,^{ NSLog(@"group block2"); });
    dispatch_async(globalQueue, ^{
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        NSLog(@"group wait done");
    });
    dispatch_group_notify(group, globalQueue, ^{
        NSLog(@"group notify done");
    });
    
    
    
}


- (void)updateTextViewWith:(NSString *)string {
    [_terminalOutputStr appendString:string];
    [_terminalOutputStr appendString:@"\n"];
    _textView.text = _terminalOutputStr;
}

static dispatch_queue_t YGetTestQueue() {

    static dispatch_queue_t queue;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ( [[UIDevice currentDevice].systemVersion floatValue] >= 8.0 ) {
            dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0);
            queue = dispatch_queue_create("com.yxw.demo", attr);
        } else {
            queue = dispatch_queue_create("com.yxw.demo", DISPATCH_QUEUE_SERIAL);
            dispatch_set_target_queue(queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
        }
    });
    
    return queue;
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
