//
//  ViewController.m
//  YMultiThreadDemo
//
//  Created by 云谷行 on 2018/11/2.
//  Copyright © 2018 YXW. All rights reserved.
//

#import "ViewController.h"
#import "YGCDViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (copy, nonatomic) NSArray *dataArr;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Multi Thread";
    _dataArr = @[@"GCD"];
    
   
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = _dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        YGCDViewController *gcdVC = [[YGCDViewController alloc] init];
        [self.navigationController pushViewController:gcdVC animated:YES];
    }
}

@end
