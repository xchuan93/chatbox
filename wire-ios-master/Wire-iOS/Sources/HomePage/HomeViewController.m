//
//  ViewController.m
//  轮播图
//
//  Created by siping ruan on 16/9/27.
//  Copyright © 2016年 Rasping. All rights reserved.
//

#import "HomeViewController.h"
#import "ImagesPlayer.h"
#import "HomeTabCell.h"
#import "WebViewController.h"
#import <Masonry.h>
#import "UIColor+RGB.h"
#import "XCMenuViewController.h"
#import "MenuTableViewCell.h"
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kCarouselViewH 200

#define isIPhoneX [UIScreen mainScreen].bounds.size.height == 812
#define topMargin (isIPhoneX ? 44 : 0)
#define bottomMargin (isIPhoneX ? 34 : 0)

@interface HomeViewController ()<ImagesPlayerIndictorPattern, ImagesPlayerDelegae,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>{
    UITableView *_menuTableView;
    NSDictionary *_menuDic;
    NSMutableArray *_menuArray;
    NSMutableArray *_isExpandArray;
}

@property (weak, nonatomic) UILabel *lable;

@property (nonatomic, strong) ImagesPlayer *testview;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSDictionary *launchOptions;

@property (nonatomic, strong) AppRootViewController *rootVC;

@property (nonatomic, strong) UIButton *chatBtn;

@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, assign) BOOL select;

//更改
@property (nonatomic, strong) NSMutableArray *newsItem;
@property (nonatomic, strong) NSMutableArray *hotspot;
@property (nonatomic, strong) NSMutableArray *banner;
@property (nonatomic, strong) NSMutableArray *video;
@property (nonatomic, strong) NSMutableArray *technology;
@property (nonatomic, strong) NSMutableArray *bannerTitle;
@property (nonatomic, strong) NSMutableArray *dataItem;

@end

@implementation HomeViewController
- (NSMutableArray *)bannerTitle{
    if (!_bannerTitle) {
        _bannerTitle = @[].mutableCopy;
    }
    return _bannerTitle;
}
- (NSMutableArray *)dataItem{
    if (!_dataItem) {
        _dataItem = @[].mutableCopy;
    }
    return _dataItem;
}
- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.testview removeTimer];
    [_menuTableView removeFromSuperview];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64+topMargin, kScreenWidth, kScreenHeight - 64) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.sectionFooterHeight = 0;
        
        //        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHeader)];
        //        _tableView.mj_header.automaticallyChangeAlpha = YES;
        //        [_tableView.mj_header beginRefreshing];
        //        _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
        //        [_tableView.mj_header endRefreshing];
        //        [_tableView.mj_footer endRefreshing];
    }
    return _tableView;
}

- (UIButton *)chatBtn{
    if (!_chatBtn) {
        _chatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_chatBtn setBackgroundImage:[UIImage imageNamed:@"chatbox1"] forState:UIControlStateNormal];
        _chatBtn.backgroundColor = [UIColor redColor];
        [_chatBtn setBackgroundColor:UIControlStateNormal];
        //        _chatBtn.layer.cornerRadius = 20.f;
        //        _chatBtn.layer.borderColor = [UIColor orangeColor].CGColor;
        //        _chatBtn.layer.borderWidth = 1;
        //        _chatBtn.layer.masksToBounds = YES;
    }
    return _chatBtn;
}
- (void)chatBtnClick{
    NSLog(@"dianji");
    self.rootinit();
}

- (instancetype)init{
    if (self == [super init]) {
        _homeWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _homeWindow.rootViewController = self;
        [_homeWindow makeKeyWindow];
        [_homeWindow makeKeyAndVisible];
    }
    return self;
}

- (instancetype)initWithlaunchOptions:(NSDictionary *)launchOptions{
    if (self == [super init]) {
        self.launchOptions = launchOptions;
    }
    return self;
}

- (instancetype)initWithlaunchOptions:(NSDictionary *)launchOptions rootVC:(AppRootViewController *)rootVC{
    if (self == [super init]) {
        self.launchOptions = launchOptions;
        self.rootVC = rootVC;
    }
    return self;
}

- (void)getmenuDataFromList{
    NSString *dataList = [[NSBundle mainBundle]pathForResource:@"menuData" ofType:@"plist"];
    _menuDic = [[NSDictionary alloc]initWithContentsOfFile:dataList];
    _menuArray = @[].mutableCopy;
    [_menuArray addObject:@"首页"];
    [_menuArray addObject:@"关于干细胞"];
    [_menuArray addObject:@"干细胞疗法"];
    [_menuArray addObject:@"会员中心"];
    for (NSInteger i = 0; i < _menuArray.count; i++) {
        [_isExpandArray addObject:@"0"];//0:没展开 1:展开
    }
}

- (void)initmenuTableView{
    _menuTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _menuTableView.sectionFooterHeight = 0;
    _menuTableView.delegate = self;
    _menuTableView.dataSource = self;
    _menuTableView.backgroundColor = [UIColor clearColor];
    //    _menuTableView.alpha = 0.5;
    _menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _menuTableView.alwaysBounceVertical=NO;
    _menuTableView.bounces=NO;
    [self.view addSubview:_menuTableView];
    [_menuTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_offset(0);
        make.top.mas_offset(64+topMargin);
    }];
    _menuTableView.tableFooterView = [UIView new];
    _menuTableView.tableFooterView.backgroundColor = [UIColor orangeColor];
    UIView *markView = [[UIView alloc] initWithFrame:CGRectZero];
    markView.backgroundColor = [UIColor lightGrayColor];
    markView.alpha = 0.5;
    [self.view addSubview:markView];
    [markView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self->_menuTableView);
        make.top.mas_equalTo(self->_menuTableView.tableFooterView.mas_top);
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuClick:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    markView.userInteractionEnabled = YES;
    [markView addGestureRecognizer:tap];
    UIPanGestureRecognizer *removeSelfView = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(removeSelfView:)];
    [markView addGestureRecognizer:removeSelfView];
    
}
- (void)removeSelfView:(UIPanGestureRecognizer *)gesture
{
    [gesture.view removeFromSuperview];
    [_menuTableView removeFromSuperview];
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
//    if ([touch.view isKindOfClass:[UITableView class]]) {
//        return YES;
//    }
//    return true;
//}

- (void)menuClick:(UITapGestureRecognizer *)tap{
    NSLog(@"dianji");
    self.select = !self.select;
    [tap.view removeFromSuperview];
    [_menuTableView removeFromSuperview];
}

- (void)menuInit{
    _isExpandArray = [[NSMutableArray alloc]init];
    [self getmenuDataFromList];
    [self initmenuTableView];
}
- (void)itemInit:(NSDictionary *)response{
    NSDictionary *dic = [response objectForKey:@"data"];
    [self.dataItem addObject:@"news"];
    [self.dataItem addObject:@"hotspot"];
    [self.dataItem addObject:@"technology"];
    [self.dataItem addObject:@"video"];
    //    [self.dataItem addObject:@"youth"];
    
    self.newsItem = dic[@"news"];
    self.hotspot = dic[@"hotspot"];
    self.banner = dic[@"banner"];
    self.video = dic[@"video"];
    self.technology = dic[@"technology"];
    NSLog(@"123");
}

- (void)loadHomeData{
    [LXNetworking getWithUrl:@"http://34.245.7.199:8888/api/HomePage/getHomepage" params:@{} success:^(id response) {
        NSLog(@"sucess");
        [self itemInit:response];
        [self loadImgplayView:self.banner];
        [self.tableView reloadData];
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } fail:^(NSError *error) {
        NSLog(@"error");
    } showHUD:NO];
}
- (void)loadImgplayView:(NSMutableArray *)bananer{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *netImages = @[].mutableCopy;
        for (NSDictionary *dic in bananer) {
            [self.bannerTitle addObject:dic[@"title"]];
            [netImages addObject:dic[@"thumbnail"]];
        }
        [self.testview addNetWorkImages:netImages placeholder:[UIImage imageNamed:@"1_launch"]];
        
    });
}

- (void)titleBarView{
    if (!_titleView) {
        self.titleView = [UIView new];
        _titleView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bar"]];
        [self.view addSubview:_titleView];
        [_titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            CGFloat count = topMargin;
            make.top.mas_offset(topMargin);
            make.left.right.mas_offset(0);
            make.height.mas_equalTo(64);
        }];
        UIImageView *gennesisView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GenesisLOGO"]];
        [_titleView addSubview:gennesisView];
        [gennesisView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_offset(0);
            make.left.mas_offset(15);
            make.width.mas_equalTo(94);
            make.height.mas_equalTo(23);
        }];
        UIButton *menuView = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuView setBackgroundImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
        [menuView addTarget:self action:@selector(menuBtn:) forControlEvents:UIControlEventTouchUpInside];
        menuView.layer.cornerRadius = 27/2.0f;
        menuView.layer.borderWidth = 1.0f;
        menuView.layer.borderColor = [UIColor whiteColor].CGColor;
        [_titleView addSubview:menuView];
        [menuView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_offset(0);
            make.right.mas_offset(-15);
            make.width.height.mas_equalTo(27);
        }];
    }
}
- (void)menuBtn:(UIButton *)sender{
    NSLog(@"click");
    self.select = !self.select;
    if (self.select) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self menuInit];
        });
    }else{
        [_menuTableView removeFromSuperview];
    }
}

- (void)testnet{
    [LXNetworking getWithUrl:@"http://34.245.7.199:8888/api/HomePage/getHomepage" params:@{} success:^(id response) {
        NSLog(@"1234sucess");
    } fail:^(NSError *error) {
        NSLog(@"1234error");
    } showHUD:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadHomeData];
    
    [self titleBarView];
    [self.view addSubview:self.tableView];
    self.select = NO;
    
    
    self.testview = [[ImagesPlayer alloc] init];
    self.testview.frame = CGRectMake(0, 0, kScreenWidth, kCarouselViewH);
    self.testview.backgroundColor = [UIColor whiteColor];
    self.testview.delegate = self;
    self.testview.hidePageControl = NO;
    self.testview.indicatorPattern = self;
    self.testview.scrollIntervalTime = 2.0;
    self.testview.autoScroll = NO;
    self.testview.titleLab.text = self.bannerTitle.firstObject;
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kCarouselViewH)];
    [tableHeaderView addSubview:self.testview];
    self.tableView.tableHeaderView = tableHeaderView;
    self.tableView.tableFooterView = [UIView new];
    
    [self.view addSubview:self.chatBtn];
    UIImage *image = [UIImage imageNamed:@"chatbox1"];
    [self.chatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-5);
        make.width.mas_equalTo(image.size.width);
        make.height.mas_equalTo(image.size.height);
        make.bottom.mas_offset(-40);
    }];
    [self.chatBtn addTarget:self action:@selector(chatBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

#pragma mark = ImagesPlayerIndictorPattern

- (UIView *)indicatorViewInImagesPlayer:(ImagesPlayer *)imagesPlayer
{
    CGFloat margin          = 5.0;
    UIView *view            = [[UIView alloc] init];
    CGFloat w               = 50;
    CGFloat h               = 20;
    CGFloat x               = CGRectGetWidth(imagesPlayer.frame) - w - margin;
    CGFloat y               = CGRectGetHeight(imagesPlayer.frame) - h - margin;
    view.frame              = CGRectMake(x, y, w, h);
    view.backgroundColor    = [UIColor blackColor];
    view.alpha              = 0.5;
    view.clipsToBounds      = YES;
    view.layer.cornerRadius = 5.0;
    UILabel *lable          = [[UILabel alloc] initWithFrame:view.bounds];
    lable.textAlignment     = NSTextAlignmentCenter;
    lable.textColor         = [UIColor whiteColor];
    self.lable              = lable;
    [view addSubview:lable];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)imagesPlayer:(ImagesPlayer *)imagesPlayer didChangedIndex:(NSInteger)index count:(NSInteger)count
{
    //    self.lable.text = [NSString stringWithFormat:@"%ld/%ld", index + 1, count];
    self.testview.titleLab.text = self.bannerTitle[index];
    
}

#pragma mark - ImagesPlayerDelegae

- (void)imagesPlayer:(ImagesPlayer *)player didSelectImageAtIndex:(NSInteger)index
{
    NSLog(@"点击了：%ld", (long)index);
}

#pragma mark UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == _menuTableView) {
        return _menuArray.count;
    }else{
        return self.dataItem.count;
    }
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (tableView == _menuTableView) {
        if ([_isExpandArray[section]isEqualToString:@"1"]) {
            NSString *keymenu = _menuArray[section];
            NSArray *cityArray = [_menuDic objectForKey:keymenu];
            return  cityArray.count;
        }else{
            return 0;
        }
    }
    if (section == 0) {
        return self.newsItem.count;
    }else if (section == 1){
        return self.video.count;
    }else if (section == 2){
        return self.technology.count;
    }else if (section == 3){
        return self.hotspot.count;
    }else if (section == 4){
        return 1;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == _menuTableView) {
        NSString *iditifier = @"MenuCell";
        MenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iditifier];
        if (cell == nil) {
            cell = [[MenuTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:iditifier];
            [cell.contentView setBackgroundColor:[UIColor whiteColor]];
        }
        NSString *keyOfmenu = _menuArray[indexPath.section];
        NSArray *cityArray = [_menuDic objectForKey:keyOfmenu];
        cell.menuLab.text = cityArray[indexPath.row];
        return cell;
    }else{
        if (indexPath.section == 0) {
            NewsTabCell *cell = [tableView dequeueReusableCellWithIdentifier:@"news"];
            if (!cell) {
                cell = [[NewsTabCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"news"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            if (self.newsItem.count) {
                NSDictionary *dic = self.newsItem[indexPath.row];
                [cell setImageStr:dic[@"thumbnail"] title:dic[@"title"] detail:dic[@"description"]];
            }
            return cell;
        }else if (indexPath.section == 1){
            VideoTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"video"];
            if (!cell) {
                cell = [[VideoTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"video"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            if (self.video.count) {
                NSDictionary *dic = self.video[indexPath.row];
                [cell setImageStr:dic[@"thumbnail"] title:dic[@"title"]];
            }
            return cell;
        }else if (indexPath.section == 2){
            HotTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"technology"];
            if (!cell) {
                cell = [[HotTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"technology"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            if (self.technology.count) {
                NSDictionary *dic = self.technology[indexPath.row];
                [cell setImageStr:dic[@"thumbnail"] title:dic[@"title"] detail:dic[@"description"] time:dic[@"time"]];
            }
            return cell;
        }else if (indexPath.section == 4){
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hot"];
            if (!cell) {
                cell = [[YouthTripTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"hot"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return cell;
        }else if (indexPath.section == 3){
            VideoTitleTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VideoTitleTableCell"];
            if (!cell) {
                cell = [[VideoTitleTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"VideoTitleTableCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            if (self.hotspot.count) {
                NSDictionary *dic = self.hotspot[indexPath.row];
                [cell setTitle:dic[@"title"]];
            }
            return cell;
        }
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"123"];
        cell.textLabel.text = @"12344";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == _menuTableView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (indexPath.section == 2) {
                switch (indexPath.row) {
                    case 0:
                    {
                        WebViewController *vc = [[WebViewController alloc] init];
                        [vc setType:@"" title:@"治疗疾病" urlStr:@"http://www.scrgen.com/cure/"];
                        [self presentViewController:vc animated:YES completion:nil];
                    }break;
                    case 1:{
                        WebViewController *vc = [[WebViewController alloc] init];
                        [vc setType:@"" title:@"美容抗衰老" urlStr:@"http://www.scrgen.com/anti_aging/"];
                        [self presentViewController:vc animated:YES completion:nil];
                    }break;
                    case 2:{
                        WebViewController *vc = [[WebViewController alloc] init];
                        [vc setType:@"" title:@"病症案例" urlStr:@"http://www.scrgen.com/case/"];
                        [self presentViewController:vc animated:YES completion:nil];
                    }break;
                    default:
                        break;
                }
            }else if (indexPath.section == 3){
                switch (indexPath.row) {
                    case 0:{
                        WebViewController *vc = [[WebViewController alloc] init];
                        [vc setType:@"" title:@"青春之旅" urlStr:@"http://www.scrgen.com/flow/"];
                        [self presentViewController:vc animated:YES completion:nil];
                    }break;
                    case 1:{
                        WebViewController *vc = [[WebViewController alloc] init];
                        [vc setType:@"" title:@"常见问题" urlStr:@"http://www.scrgen.com/faq/"];
                        [self presentViewController:vc animated:YES completion:nil];
                    }break;
                        
                    default:
                        break;
                }
            }
        });
        return ;
    }
    
    if (indexPath.section == 4) {
        return;
    }
    WebViewController *vc = [[WebViewController alloc] init];
    switch (indexPath.section) {
        case 0:
            //            [vc setType:@"news" title:@"新闻 NEWS"];
            if (self.newsItem.count) {
                NSDictionary *dic = self.newsItem[indexPath.row];
                [vc setType:@"news" title:@"新闻 NEWS" urlStr:dic[@"link"]];
            }
            break;
        case 1:
            //            [vc setType:@"video" title:@"视频资讯 VIDEO"];
            if (self.video.count) {
                NSDictionary *dic = self.video[indexPath.row];
                [vc setType:@"video" title:@"视频资讯 VIDEO" urlStr:dic[@"link"]];
            }
            break;
        case 2:
            if (self.hotspot.count) {
                NSDictionary *dic = self.hotspot[indexPath.row];
                [vc setType:@"hotspot" title:@"热门技术 HOT" urlStr:dic[@"link"]];
            }
            //            [vc setType:@"hotspot" title:@"热门技术 HOT"];
            break;
        case 3:
            if (self.technology.count) {
                NSDictionary *dic = self.technology[indexPath.row];
                [vc setType:@"technology" title:@"研究热门" urlStr:dic[@"link"]];
            }
            //            [vc setType:@"technology" title:@"研究热门"];
            break;
        default:
            break;
    }
    [self presentViewController:vc animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == _menuTableView) {
        return 40;
    }
    
    if (indexPath.section == 0) {
        return 100;
    }else if (indexPath.section == 1){
        return 247;
    }else if (indexPath.section == 2){
        return 100;
    }else if (indexPath.section == 3){
        return 50;
    }
    return 137;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == _menuTableView) {
        return 50;
    }
    return 50;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"ceshi";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (tableView == _menuTableView) {
        UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        headerView.backgroundColor = [UIColor whiteColor];
        UILabel *menuLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        menuLabel.textColor = [UIColor blackColor];
        menuLabel.font = [UIFont systemFontOfSize:15];
        menuLabel.text = _menuArray[section];
        [headerView addSubview:menuLabel];
        [menuLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(15);
            make.centerY.mas_offset(0);
            make.height.width.mas_equalTo(headerView);
        }];
        
        UIView *lineView = [UIView new];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [headerView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_offset(0);
            make.height.mas_equalTo(1);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        tap.delegate = self;
        [headerView addGestureRecognizer:tap];
        headerView.tag = section;
        return headerView;
    }
    
    UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
    tipView.backgroundColor = [UIColor colorWithRGB:255 g:255 b:255 alpha:1];
    
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    //    leftLabel.text = @"新闻 新闻新闻 新闻 新闻";
    leftLabel.font = [UIFont systemFontOfSize:17];
    leftLabel.textColor = [UIColor colorWithRGB:192 g:160 b:98 alpha:1];
    [leftLabel sizeToFit];
    [tipView addSubview:leftLabel];
    [leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(15);
        make.bottom.mas_offset(-2);
        make.height.mas_equalTo(18);
        make.width.mas_lessThanOrEqualTo(kScreenWidth - 150);
    }];
    
    UILabel *rightLab = [UILabel new];
    rightLab.textAlignment = NSTextAlignmentLeft;
    rightLab.textColor = [UIColor colorWithRGB:136 g:136 b:136 alpha:1];
    rightLab.font = [UIFont systemFontOfSize:15];
    [rightLab sizeToFit];
    [tipView addSubview:rightLab];
    [rightLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftLabel.mas_right).offset(7);
        //        make.top.mas_offset(0);
        make.height.mas_equalTo(16);
        make.bottom.equalTo(leftLabel.mas_bottom);
        make.width.mas_lessThanOrEqualTo(kScreenWidth - 150);
    }];
    UIImage *img = [UIImage imageNamed:@"tip"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
    [tipView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rightLab.mas_right).offset(3);
        make.bottom.equalTo(rightLab.mas_bottom);
        make.width.mas_equalTo(img.size.width);
        make.height.mas_equalTo(img.size.height);
    }];
    
    UIButton *moreview = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *moreImg = [UIImage imageNamed:@"more"];
    [moreview setBackgroundImage:moreImg forState:UIControlStateNormal];
    moreview.tag = section;
    [moreview addTarget:self action:@selector(moreClick:) forControlEvents:UIControlEventTouchUpInside];
    [tipView addSubview:moreview];
    [moreview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-15);
        make.bottom.mas_offset(-11);
        make.width.mas_equalTo(moreImg.size.width);
        make.height.mas_equalTo(moreImg.size.height);
    }];
    
    UIView *moreView = [UIView new];
    moreView.backgroundColor = [UIColor clearColor];
    [tipView addSubview:moreView];
    [moreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(0);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(tipView);
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    
    tap.numberOfTapsRequired = 1;
    //    tap.numberOfTouches = 1;
    moreView.userInteractionEnabled = YES;
    moreView.tag = section;
    [moreView addGestureRecognizer:tap];
    
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = [UIColor colorWithRGB:221 g:221 b:221 alpha:1];
    [tipView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(15);
        make.right.mas_offset(-15);
        make.bottom.mas_offset(0);
        make.height.mas_equalTo(0.5);
    }];
    
    UIView *bottomView = [UIView new];
    [tipView addSubview:bottomView];
    bottomView.backgroundColor = [UIColor colorWithRGB:192 g:160 b:98 alpha:1];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_offset(0);
        //        make.width.mas_equalTo(leftLabel.mas_width);
        make.right.equalTo(imageView.mas_right).offset(0);
        make.height.mas_equalTo(1);
        make.left.equalTo(leftLabel.mas_left).offset(0);
    }];
    
    if (section == 0) {
        leftLabel.text = @"新闻";
        rightLab.text = @"NEWS";
    }
    switch (section) {
        case 0:
        {
            leftLabel.text = @"新闻";
            rightLab.text = @"NEWS";
        }break;
        case 1:{
            leftLabel.text = @"视频资讯";
            rightLab.text = @"VIDEO";
        }break;
        case 2:{
            leftLabel.text = @"热门技术";
            rightLab.text = @"HOT";
        }break;
        case 3:{
            leftLabel.text = @"研究热门";
            rightLab.text = @"RESEARCH";
        }break;
        case 4:{
            leftLabel.text = @"青春之旅 ";
            rightLab.text = @"YOUTH JOURNEY";
            //            imageView.hidden = YES;
        }break;
            
        default:
            break;
    }
    
    
    return tipView;
}

- (void)tapClick:(UITapGestureRecognizer *)tap{
    dispatch_async(dispatch_get_main_queue(), ^{
        MoreViewController *vc = [[MoreViewController alloc] init];
        switch (tap.view.tag) {
            case 0:
                [vc setType:@"news" title:@"新闻 NEWS"];
                break;
            case 1:
                [vc setType:@"video" title:@"视频资讯 VIDEO"];
                break;
            case 2:
                [vc setType:@"hotspot" title:@"热门技术 HOT"];
                break;
            case 3:
                [vc setType:@"technology" title:@"研究热门"];
                break;
            default:
                break;
        }
        [self presentViewController:vc animated:NO completion:nil];
    });
}

- (void)tapAction:(UITapGestureRecognizer *)tap{
    if ([_isExpandArray[tap.view.tag] isEqualToString:@"0"]) {
        [_isExpandArray replaceObjectAtIndex:tap.view.tag withObject:@"1"];
    }else{
        [_isExpandArray replaceObjectAtIndex:tap.view.tag withObject:@"0"];
        
    }
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:tap.view.tag];
    [_menuTableView reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        switch (tap.view.tag) {
            case 0:
            {
                WebViewController *vc = [[WebViewController alloc] init];
                [vc setType:@"" title:@"首页" urlStr:@"http://www.scrgen.com/"];
                [self presentViewController:vc animated:YES completion:nil];
            }break;
            case 1:{
                WebViewController *vc = [[WebViewController alloc] init];
                [vc setType:@"" title:@"干细胞" urlStr:@"http://www.scrgen.com/about/"];
                [self presentViewController:vc animated:YES completion:nil];
            }
                break;
                
            default:
                break;
        }
        
    });
    
}

- (void)moreClick:(UIButton *)sender{
    NSLog(@"click");
    dispatch_async(dispatch_get_main_queue(), ^{
        MoreViewController *vc = [[MoreViewController alloc] init];
        switch (sender.tag) {
            case 0:
                [vc setType:@"news" title:@"新闻 NEWS"];
                break;
            case 1:
                [vc setType:@"video" title:@"视频资讯 VIDEO"];
                break;
            case 2:
                [vc setType:@"hotspot" title:@"热门技术 HOT"];
                break;
            case 3:
                [vc setType:@"technology" title:@"研究热门"];
                break;
            default:
                break;
        }
        [self presentViewController:vc animated:NO completion:nil];
    });
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"%f",_menuTableView.contentOffset.y);
    if (_menuTableView.contentOffset.y <= 0)
    {
        _menuTableView.bounces = NO;
        NSLog(@"禁止下拉");
        
    }else if (_menuTableView.contentOffset.y >= 0){
        _menuTableView.bounces = YES;
        NSLog(@"允许上拉");
        
    }
}

@end

