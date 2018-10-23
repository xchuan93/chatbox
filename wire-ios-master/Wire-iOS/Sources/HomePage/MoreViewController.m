//
//  MoreViewController.m
//  StemCells
//
//  Created by Apple on 2018/9/30.
//  Copyright © 2018年 XC. All rights reserved.
//

#import "MoreViewController.h"
#import "MoreTableViewCell.h"
#import "LXNetworking.h"
#import "WebViewController.h"
#import "MJRefresh.h"
#import "MBProgressHUD.h"
#import <Masonry.h>


#define isIPhoneX [UIScreen mainScreen].bounds.size.height == 812
#define topMargin (isIPhoneX ? 44 : 0)
#define bottomMargin (isIPhoneX ? 34 : 0)

@interface MoreViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tabView;
@property (nonatomic, strong) NSMutableArray *sourceItem;

@property (nonatomic, strong) UILabel *moreTitleLab;

@property (nonatomic ,copy) NSString *more_title;
@property (nonatomic, copy) NSString *type;

@end

@implementation MoreViewController

//- (NSMutableArray *)sourceItem{
//    if (!_sourceItem) {
//        _sourceItem = @[].mutableCopy;
//    }
//    return _sourceItem;
//}

- (void)setType:(NSString *)type title:(NSString *)title{
    self.more_title = title;
    self.moreTitleLab.text = title;
    self.type = type;
}

- (void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addTitleView{
    UIView *maskView = [UIView new];
    maskView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bar"]];
    [self.view addSubview:maskView];
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(topMargin);
        make.left.right.mas_offset(0);
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

- (void)loadHomeData{
    
    [LXNetworking postWithUrl:@"http://34.245.7.199:8888/api/HomePage/getArticleList" params:@{@"type":self.type,@"page":@"1",@"limit":@"20"} success:^(id response) {
        NSLog(@"sucee");
        NSMutableArray *arr;
        if ([self.type isEqualToString:@"news"]) {
            arr = [[response objectForKey:@"data"] objectForKey:@"news_list"];
        }else if ([self.type isEqualToString:@"video"]){
            arr = [[response objectForKey:@"data"] objectForKey:@"video_list"];
        }else if ([self.type isEqualToString:@"hotspot"]){
            arr = [[response objectForKey:@"data"] objectForKey:@"hotspot_list"];
        }else if ([self.type isEqualToString:@"technology"]){
            arr = [[response objectForKey:@"data"] objectForKey:@"technology_list"];
        }
        //        NSMutableArray *arr = [[response objectForKey:@"data"] objectForKey:@"news_list"];
        self.sourceItem = arr.mutableCopy;
        [self.tabView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } fail:^(NSError *error) {
        NSLog(@"error");
    } showHUD:NO];
}

- (void)refreshHeader{
    //    [self loadHomeData];
    [LXNetworking postWithUrl:@"http://34.245.7.199:8888/api/HomePage/getArticleList" params:@{@"type":self.type,@"page":@"1",@"limit":@"20"} success:^(id response) {
        NSLog(@"sucee");
        NSMutableArray *arr;
        if ([self.type isEqualToString:@"news"]) {
            arr = [[response objectForKey:@"data"] objectForKey:@"news_list"];
        }else if ([self.type isEqualToString:@"video"]){
            arr = [[response objectForKey:@"data"] objectForKey:@"video_list"];
        }else if ([self.type isEqualToString:@"hotspot"]){
            arr = [[response objectForKey:@"data"] objectForKey:@"hotspot_list"];
        }else if ([self.type isEqualToString:@"technology"]){
            arr = [[response objectForKey:@"data"] objectForKey:@"technology_list"];
        }
        //        NSMutableArray *arr = [[response objectForKey:@"data"] objectForKey:@"news_list"];
        self.sourceItem = arr.mutableCopy;
        [self.tabView reloadData];
        [self.tabView.mj_header endRefreshing];
    } fail:^(NSError *error) {
        NSLog(@"error");
        [self.tabView.mj_header endRefreshing];
    } showHUD:NO];
}

- (void)refreshFooter{
    static NSInteger count = 2;
    [LXNetworking postWithUrl:@"http://34.245.7.199:8888/api/HomePage/getArticleList" params:@{@"type":self.type,@"page":[NSNumber numberWithInteger:count++],@"limit":@"20"} success:^(id response) {
        NSLog(@"sucee");
        NSMutableArray *arr;
        if ([self.type isEqualToString:@"news"]) {
            arr = [[response objectForKey:@"data"] objectForKey:@"news_list"];
        }else if ([self.type isEqualToString:@"video"]){
            arr = [[response objectForKey:@"data"] objectForKey:@"video_list"];
        }else if ([self.type isEqualToString:@"hotspot"]){
            arr = [[response objectForKey:@"data"] objectForKey:@"hotspot_list"];
        }else if ([self.type isEqualToString:@"technology"]){
            arr = [[response objectForKey:@"data"] objectForKey:@"technology_list"];
        }
        //        NSMutableArray *arr = [[response objectForKey:@"data"] objectForKey:@"news_list"];
        //        [self.sourceItem addObject:arr.mutableCopy];
        [self.sourceItem addObjectsFromArray:arr];
        [self.tabView reloadData];
        [self.tabView.mj_footer endRefreshing];
    } fail:^(NSError *error) {
        NSLog(@"error");
        [self.tabView.mj_footer endRefreshing];
    } showHUD:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadHomeData];
    
    [self addTitleView];
    
    self.tabView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tabView.delegate = self;
    self.tabView.dataSource = self;
    
    _tabView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHeader)];
    //            _tabView.mj_header.automaticallyChangeAlpha = YES;
    //            [_tabView.mj_header beginRefreshing];
    _tabView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
    //            [_tabView.mj_header endRefreshing];
    //            [_tabView.mj_footer endRefreshing];
    [self.view addSubview:_tabView];
    [_tabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_offset(0);
        make.top.mas_offset(64+topMargin);
    }];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sourceItem.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[MoreTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (self.sourceItem.count) {
        NSDictionary *dic = self.sourceItem[indexPath.row];
        [cell setTitle:dic[@"title"] time:dic[@"pubdate"]];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.sourceItem.count) {
        NSDictionary *dic = self.sourceItem[indexPath.row];
        WebViewController *web = [[WebViewController alloc] init];
        [web setType:self.type title:self.more_title urlStr:dic[@"url"]];
        [self presentViewController:web animated:YES completion:nil];
    }
    
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

