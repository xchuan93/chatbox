//
//  AppDelegate.h
//  StemCells
//
//  Created by Apple on 2018/9/28.
//  Copyright © 2018年 XC. All rights reserved.


#import "XCMenuViewController.h"
#import "MenuTableViewCell.h"
#import <Masonry.h>

@interface XCMenuViewController ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>{
    
    UITableView *_menuTableView;
    NSDictionary *_menuDic;
    NSArray *_menuArray;
    NSMutableArray *_isExpandArray;
    
}
@end

@implementation XCMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isExpandArray = [[NSMutableArray alloc]init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"首页";
    [self getmenuDataFromList];
    [self initmenuTableView];
}

- (void)getmenuDataFromList{
    NSString *dataList = [[NSBundle mainBundle]pathForResource:@"menuData" ofType:@"plist"];
    _menuDic = [[NSDictionary alloc]initWithContentsOfFile:dataList];
    _menuArray = [_menuDic allKeys];
    for (NSInteger i = 0; i < _menuArray.count; i++) {
        [_isExpandArray addObject:@"0"];//0:没展开 1:展开
    }
}

- (void)initmenuTableView{
    _menuTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _menuTableView.sectionFooterHeight = 0;
    _menuTableView.delegate = self;
    _menuTableView.dataSource = self;
    [self.view addSubview:_menuTableView];
    [_menuTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_offset(0);
        make.top.mas_offset(64);
    }];
}

#pragma -- mark tableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _menuArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([_isExpandArray[section]isEqualToString:@"1"]) {
        NSString *keymenu = _menuArray[section];
        NSArray *cityArray = [_menuDic objectForKey:keymenu];
        return  cityArray.count;
    }else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    UILabel *menuLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    menuLabel.textColor = [UIColor blackColor];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *iditifier = @"MenuCell";
    MenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iditifier];
    if (cell == nil) {
        cell = [[MenuTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:iditifier];
    }
    NSString *keyOfmenu = _menuArray[indexPath.section];
    NSArray *cityArray = [_menuDic objectForKey:keyOfmenu];
    cell.menuLab.text = cityArray[indexPath.row];
    return cell;
}

- (void)tapAction:(UITapGestureRecognizer *)tap{
    if ([_isExpandArray[tap.view.tag] isEqualToString:@"0"]) {
        [_isExpandArray replaceObjectAtIndex:tap.view.tag withObject:@"1"];
    }else{
        [_isExpandArray replaceObjectAtIndex:tap.view.tag withObject:@"0"];
        
    }
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:tap.view.tag];
    [_menuTableView reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"123");
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

