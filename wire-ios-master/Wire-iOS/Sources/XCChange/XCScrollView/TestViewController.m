//
//  TestViewController.m
//  drawer
//
//  Created by Apple on 2018/11/1.
//  Copyright © 2018年 XC. All rights reserved.
//

#import "TestViewController.h"
#import <Masonry.h>

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor orangeColor];
    
    UIButton *userBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [userBtn setBackgroundColor:[UIColor redColor]];
    [userBtn addTarget:self action:@selector(userBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:userBtn];
    [userBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(15);
        make.top.mas_offset(15);
        make.width.height.mas_equalTo(100);
    }];
    
}

- (void)userBtn:(UIButton *)sender{
    self.tipblock();
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
