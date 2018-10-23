//
//  WebViewController.m
//  StemCells
//
//  Created by Apple on 2018/9/26.
//  Copyright © 2018年 XC. All rights reserved.
//

#import "WebViewController.h"

#import <WebKit/WebKit.h>
#import <Masonry.h>

@interface WebViewController ()<WKNavigationDelegate>

@property (nonatomic, strong) UIProgressView *xcProgressView;

@property (nonatomic, strong) WKWebView *xcWebView;

@property (nonatomic, strong) UILabel *moreTitleLab;

@property (nonatomic ,copy) NSString *more_title;
@property (nonatomic, copy) NSString *urlStr;

@end

@implementation WebViewController

- (void)setType:(NSString *)type title:(NSString *)title{
    self.more_title = title;
    self.moreTitleLab.text = title;
}
- (void)setType:(NSString *)type title:(NSString *)title urlStr:(NSString *)urlStr{
    self.more_title = title;
    self.moreTitleLab.text = title;
    self.urlStr = urlStr;
}

#pragma mark - getter and setter
- (UIProgressView *)xcProgressView
{
    if (_xcProgressView == nil) {
        _xcProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 65, [UIScreen mainScreen].bounds.size.width, 0)];
        _xcProgressView.tintColor = [UIColor blueColor];
        _xcProgressView.trackTintColor = [UIColor whiteColor];
    }
    
    return _xcProgressView;
}

- (void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addTitleView{
    UIView *maskView = [UIView new];
    maskView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bar"]];
    [self.view addSubview:maskView];
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_offset(0);
        make.height.mas_equalTo(64);
    }];
    UIImage *img = [UIImage imageNamed:@"back1"];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setBackgroundImage:img forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [maskView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_offset(5);
        make.left.mas_offset(15);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(25);
    }];
    self.moreTitleLab = [UILabel new];
    _moreTitleLab.font = [UIFont systemFontOfSize:17];
    _moreTitleLab.textColor = [UIColor whiteColor];
    _moreTitleLab.textAlignment = NSTextAlignmentCenter;
    [_moreTitleLab sizeToFit];
    [maskView addSubview:_moreTitleLab];
    [_moreTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_offset(5);
        make.centerX.mas_offset(0);
        make.width.mas_lessThanOrEqualTo(150);
        make.height.mas_equalTo(19);
    }];
    self.moreTitleLab.text = self.more_title;
}


#pragma mark - life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addTitleView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.xcWebView = [[WKWebView alloc] initWithFrame:CGRectZero];
    _xcWebView.opaque = NO;
    _xcWebView.multipleTouchEnabled = YES;
    [_xcWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    _xcWebView.navigationDelegate = self;
    _xcWebView.frame = self.view.bounds;
    [_xcWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]]];
    [self.view addSubview:_xcWebView];
    [self.view addSubview:self.xcProgressView];
    [_xcWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_offset(0);
        make.top.mas_offset(64);
    }];
}



#pragma mark - WKNavigationDelegate method
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if ([webView.URL.absoluteString hasPrefix:@"https://itunes.apple.com"]) {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:nil completionHandler:^(BOOL success) {
            
        }];
        decisionHandler(WKNavigationActionPolicyCancel);
    }else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

#pragma mark - event response
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.xcWebView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        self.xcProgressView.alpha = 1.0f;
        [self.xcProgressView setProgress:newprogress animated:YES];
        if (newprogress >= 1.0f) {
            [UIView animateWithDuration:0.3f
                                  delay:0.3f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.xcProgressView.alpha = 0.0f;
                             }
                             completion:^(BOOL finished) {
                                 [self.xcProgressView setProgress:0 animated:NO];
                             }];
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc
{
    [self.xcWebView removeObserver:self forKeyPath:@"estimatedProgress"];
}

@end

