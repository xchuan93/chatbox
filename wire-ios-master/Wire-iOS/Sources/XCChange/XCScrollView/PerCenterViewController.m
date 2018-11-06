//
//  PerCenterViewController.m
//  drawer
//
//  Created by Apple on 2018/11/1.
//  Copyright © 2018年 XC. All rights reserved.
//

#import "PerCenterViewController.h"
#import <Masonry.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface PerCenterViewController ()

//@property (nonatomic, strong) UIView *subView;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIImageView *subView;
@property (nonatomic, strong) UIImageView *avartImg;
@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UILabel *subLab;
@property (nonatomic, strong) UIImageView *accountImg;
@property (nonatomic, strong) UIButton *accountBtn;
@property (nonatomic, strong) UIImageView *loginEquipmentImg;
@property (nonatomic, strong) UIButton *loginEquipmentBtn;
@property (nonatomic, strong) UIImageView *generalImg;
@property (nonatomic, strong) UIButton *generalBtn;
@property (nonatomic, strong) UIImageView *feedbackImg;
@property (nonatomic, strong) UIButton *feedbackBtn;
@property (nonatomic, strong) UIView *maskView;

@end

@implementation PerCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self layoutUI];
    [self layoutConstraints];
    [self setValue];
}

- (void)layoutUI{
    
    self.view.backgroundColor = [UIColor clearColor];
    self.maskView  = [UIView new];
    self.maskView.backgroundColor = UIColorFromRGB(0x050505);
    self.maskView.alpha = 0.5f;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [self.maskView addGestureRecognizer:tap];
    self.maskView.userInteractionEnabled = YES;
    [self.view addSubview:self.maskView];
    
    self.backView = [UIView new];
    self.backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backView];
    
    
    
    self.subView = [UIImageView new];
    self.subView.image = [UIImage imageNamed:@"XC设置页面背景"];
    [self.backView addSubview:self.subView];
    
    self.avartImg = [UIImageView new];
    self.avartImg.image = [UIImage imageNamed:@"XC默认头像设置"];
    self.avartImg.layer.cornerRadius = 67 / 2.0f;
    self.avartImg.layer.borderWidth = 0.1f;
    self.avartImg.layer.borderColor = [UIColor clearColor].CGColor;
    self.avartImg.layer.masksToBounds = YES;
    [self.subView addSubview:self.avartImg];
    
    self.nameLab = [UILabel new];
    self.nameLab.textColor = UIColorFromRGB(0xffffff);
    self.nameLab.font = [UIFont systemFontOfSize:27];
    self.nameLab.textAlignment = NSTextAlignmentLeft;
    [self.subView addSubview:self.nameLab];
    
    self.subLab = [UILabel new];
    self.subLab.textColor = UIColorFromRGB(0xffffff);
    self.subLab.font = [UIFont systemFontOfSize:13];
    self.subLab.textAlignment = NSTextAlignmentLeft;
    [self.subView addSubview:self.subLab];
    
    self.accountImg = [UIImageView new];
    
    [self.view addSubview:self.accountImg];
    
    self.accountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.accountBtn setTitle:@"账号" forState:UIControlStateNormal];
    [self.accountBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
    self.accountBtn.titleLabel.font = [UIFont systemFontOfSize:19];
    self.accountBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.backView addSubview:self.accountBtn];
    
    self.loginEquipmentImg = [UIImageView new];
    self.loginEquipmentImg.image = [UIImage imageNamed:@"XC登录设备"];
    [self.backView addSubview:self.loginEquipmentImg];
    
    self.loginEquipmentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loginEquipmentBtn setTitle:@"登录设备" forState:UIControlStateNormal];
    [self.loginEquipmentBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
    self.loginEquipmentBtn.titleLabel.font = [UIFont systemFontOfSize:19];
    self.loginEquipmentBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.backView addSubview:self.loginEquipmentBtn];
    
    self.generalImg = [UIImageView new];
    self.generalImg.image = [UIImage imageNamed:@"XC通用"];
    [self.backView addSubview:self.generalImg];
    
    self.generalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.generalBtn setTitle:@"通用" forState:UIControlStateNormal];
    [self.generalBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
    self.generalBtn.titleLabel.font = [UIFont systemFontOfSize:19];
    self.generalBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.backView addSubview:self.generalBtn];
    
    self.feedbackImg = [UIImageView new];
    self.feedbackImg.image = [UIImage imageNamed:@"XC反馈"];
    [self.backView addSubview:self.feedbackImg];
    
    self.feedbackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.feedbackBtn setTitle:@"反馈" forState:UIControlStateNormal];
    [self.feedbackBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
    self.feedbackBtn.titleLabel.font = [UIFont systemFontOfSize:19];
    self.feedbackBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.backView addSubview:self.feedbackBtn];
}

- (void)layoutConstraints{
    
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_offset(0);
        make.right.mas_offset(-[UIScreen mainScreen].bounds.size.width * 0.2f);
    }];
    
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_offset(0);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
    }];
    
    [self.subView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_offset(0);
        make.height.mas_equalTo(233);
    }];
    [self.avartImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(20);
        make.bottom.mas_offset(-73);
        make.width.height.mas_equalTo(67);
    }];
    [self.nameLab sizeToFit];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avartImg.mas_right).offset(20);
        make.top.equalTo(self.avartImg.mas_top).offset(12);
        make.width.mas_lessThanOrEqualTo(150);
        make.height.mas_lessThanOrEqualTo(29);
    }];
    [self.subLab sizeToFit];
    [self.subLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLab.mas_left);
        make.top.equalTo(self.nameLab.mas_bottom).offset(10);
        make.width.mas_lessThanOrEqualTo(150);
        make.height.mas_lessThanOrEqualTo(13);
    }];
    UIImage *img = [UIImage imageNamed:@"XC帐号"];
    self.accountImg.image = img;
    [self.accountImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(39);
        make.top.equalTo(self.subView.mas_bottom).offset(30);
        make.width.mas_equalTo(img.size.width);
        make.height.mas_equalTo(img.size.height);
    }];
    [self.accountBtn.titleLabel sizeToFit];
    [self.accountBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.accountImg.mas_right).offset(17);
        make.centerY.equalTo(self.accountImg);
        make.width.mas_lessThanOrEqualTo(100);
        make.height.equalTo(self.accountImg);
    }];
    [self.loginEquipmentImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.accountImg);
        make.top.equalTo(self.accountImg.mas_bottom).offset(39);
        make.width.mas_equalTo(self.loginEquipmentImg.image.size.width);
        make.height.mas_equalTo(self.loginEquipmentImg.image.size.height);
    }];
    [self.loginEquipmentBtn.titleLabel sizeToFit];
    [self.loginEquipmentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.accountBtn);
        make.centerY.equalTo(self.loginEquipmentImg);
        make.width.mas_lessThanOrEqualTo(100);
        make.height.equalTo(self.accountImg);
    }];
    [self.generalImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.accountImg);
        make.top.equalTo(self.loginEquipmentImg.mas_bottom).offset(39);
        make.width.mas_equalTo(self.generalImg.image.size.width);
        make.height.mas_equalTo(self.generalImg.image.size.height);
    }];
    [self.generalBtn.titleLabel sizeToFit];
    [self.generalBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.accountBtn);
        make.centerY.equalTo(self.generalImg);
        make.width.mas_lessThanOrEqualTo(100);
        make.height.equalTo(self.accountImg);
    }];
    [self.feedbackImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.accountImg);
        make.top.equalTo(self.generalImg.mas_bottom).offset(39);
        make.width.mas_equalTo(self.feedbackImg.image.size.width);
        make.height.mas_equalTo(self.feedbackImg.image.size.height);
    }];
    [self.feedbackBtn.titleLabel sizeToFit];
    [self.feedbackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.accountBtn);
        make.centerY.equalTo(self.feedbackImg);
        make.width.mas_lessThanOrEqualTo(100);
        make.height.equalTo(self.accountImg);
    }];
}

- (void)setValue{
    self.nameLab.text = @"Susan";
    self.subLab.text = @"@sushine";
}

- (void)tapClick{
    self.dismissBlock();
}

- (void)updateChange{
    
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

