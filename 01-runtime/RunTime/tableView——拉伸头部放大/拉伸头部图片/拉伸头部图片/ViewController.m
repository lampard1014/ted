//
//  ViewController.m
//  拉伸头部图片
//
//  Created by 刘华健 on 15/7/21.
//  Copyright (c) 2015年 MK. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+headerStretch.h"
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIImageView *headerView;
    UITableView *testTableView;
}
@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    headerView = [[UIImageView alloc] init];
    headerView.backgroundColor = [UIColor redColor];
    headerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 200);
    headerView.image = [UIImage imageNamed:@"image"];
    
    testTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    testTableView.delegate = self;
    testTableView.dataSource = self;
    testTableView.showsVerticalScrollIndicator = NO;
    testTableView.showsHorizontalScrollIndicator = NO;
    testTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    testTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [testTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [testTableView addSubview:headerView];
    [self.view addSubview:testTableView];
    
    [self setHeaderStretchImageView:headerView withTableView:testTableView];//扩展方法
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    return cell;
}
@end
