


//
//  UIScrollView+headerStretch.m
//  拉伸头部图片
//
//  Created by 刘华健 on 15/8/19.
//  Copyright (c) 2015年 MK. All rights reserved.
//
#import <objc/runtime.h>
#import "UIScrollView+headerStretch.h"
@interface UIScrollView ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *headerImageView;
@end
static char  *tableViewKey;
static char  *headerImageViewKey;
@implementation UIScrollView (headerStretch)

#pragma -- 外部调用
- (void)setHeaderStretchImageView:(UIImageView *)imageView withTableView:(UITableView *)tableView
{
    tableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(imageView.frame), 0, 0, 0);
    imageView.frame =  CGRectMake(imageView.frame.origin.x, -CGRectGetHeight(imageView.frame), CGRectGetWidth(imageView.frame), CGRectGetHeight(imageView.frame));
    self.tableView = tableView;
    self.headerImageView = imageView;
}

#pragma mark --  tableView setter getter
- (void)setTableView:(UITableView *)tableView
{
    objc_setAssociatedObject(self, &tableViewKey, tableView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UITableView *)tableView
{
    return objc_getAssociatedObject(self, &tableViewKey);
}
#pragma mark --  headerImageView setter getter
- (void)setHeaderImageView:(UIImageView *)headerImageView
{
    objc_setAssociatedObject(self, &headerImageViewKey, headerImageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImageView *)headerImageView
{
    return objc_getAssociatedObject(self, &headerImageViewKey);
}
#pragma mark -- UIScrollViewDelegate
/**
 * 注意:在子类化的视图控制器中,不要实现scrollViewDidScroll代理方法,否则这个方法会被覆盖导致没有效果.
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    //    NSLog(@"contentOffset ==%@",NSStringFromCGPoint(scrollView.contentOffset));
    NSLog(@"frame ==%@",NSStringFromCGRect(scrollView.frame));
    
    //    NSLog(@"contentInset ==%@",NSStringFromUIEdgeInsets(scrollView.contentInset));
    
    if (self.headerImageView) {
        if (scrollView == self.tableView) {
            float yOffset = scrollView.contentOffset.y+self.tableView.contentInset.top;
            if (yOffset < 0) {
                float height = self.tableView.contentInset.top;
                float width = CGRectGetWidth(self.bounds);
                float factor = (ABS(yOffset)+height)/height;//ABC(x)得到x的绝对值
                CGRect headerFrame = CGRectMake((1-factor)*width/2, -height+(1-factor)*height, width*factor, height*factor);
                self.headerImageView.frame = headerFrame;
            }
        }
    }
}

@end
