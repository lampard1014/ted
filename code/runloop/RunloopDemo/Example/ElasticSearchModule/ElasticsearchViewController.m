//
//  ElasticsearchViewController.m
//  ElasticSearchModule
//
//  Created by fenglongsheng on 05/11/2018.
//  Copyright (c) 2018 fenglongsheng. All rights reserved.
//

#import "ElasticsearchViewController.h"
#import "AphroConsistencyTransaction.h"
#import <ElasticSearchModule/testObject.h>
@interface ElasticsearchViewController ()
@property (nonatomic, strong)testObject *to;
@end

@implementation ElasticsearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //[AphroConsistencyTransaction startup];
    testObject *to = [[testObject alloc]init];
    
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
