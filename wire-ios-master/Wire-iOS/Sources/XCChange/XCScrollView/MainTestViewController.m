//
//  MainTestViewController.m
//  drawer
//
//  Created by Apple on 2018/11/1.
//  Copyright © 2018年 XC. All rights reserved.
//

#import "MainTestViewController.h"
#import "GKDYScrollView.h"
#import "TestViewController.h"
#import "PerCenterViewController.h"
#import <Masonry.h>

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface MainTestViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) GKDYScrollView    *mainScrolView;

@property (nonatomic, strong) NSArray           *childVCs;

@property (nonatomic, strong) TestViewController *testVC;
@property (nonatomic, strong) PerCenterViewController *pVC;

@end

@implementation MainTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    self.gk_navigationBar.hidden    = YES;
    
    [self.view addSubview:self.mainScrolView];
    
    self.childVCs = @[self.pVC,self.testVC];
    typeof(self)weakself = self;
    self.testVC.tipblock = ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakself.mainScrolView.contentOffset = CGPointMake(SCREEN_WIDTH - SCREEN_WIDTH, 0);
//            [weakself.pVC updateChange];
        });
    };
    
    CGFloat scrollW = SCREEN_WIDTH;
    CGFloat scrollH = SCREEN_HEIGHT;
    self.mainScrolView.frame = CGRectMake(0, 0, scrollW, scrollH);
    self.mainScrolView.contentSize = CGSizeMake(self.childVCs.count * scrollW, scrollH);
    
    [self.childVCs enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addChildViewController:vc];
        [self.mainScrolView addSubview:vc.view];
        
        vc.view.frame = CGRectMake(idx * scrollW, 0, scrollW, scrollH);
    }];
    
    self.mainScrolView.contentOffset = CGPointMake(scrollW, 0);
}



#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    self.gk_statusBarHidden = NO;
    
    // 右滑开始时暂停
    if (scrollView.contentOffset.x == SCREEN_WIDTH) {
//        [self.playerVC.videoView pause];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 滑动结束，如果是播放页则恢复播放
    if (scrollView.contentOffset.x == 0) {
//        self.gk_statusBarHidden = YES;
//
//        [self.playerVC.videoView resume];
//        self.mainScrolView.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    
    
}


#pragma mark - 懒加载
- (GKDYScrollView *)mainScrolView {
    if (!_mainScrolView) {
        _mainScrolView = [GKDYScrollView new];
        _mainScrolView.pagingEnabled = YES;
        _mainScrolView.showsHorizontalScrollIndicator = NO;
        _mainScrolView.showsVerticalScrollIndicator = NO;
        _mainScrolView.bounces = NO; // 禁止边缘滑动
        _mainScrolView.delegate = self;
        if (@available(iOS 11.0, *)) {
            _mainScrolView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
    }
    return _mainScrolView;
}

- (TestViewController *)testVC{
    if (!_testVC) {
        _testVC = [TestViewController new];
    }
    return _testVC;
}

- (PerCenterViewController *)pVC{
    if (!_pVC) {
        _pVC = [PerCenterViewController new];
    }
    return _pVC;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
