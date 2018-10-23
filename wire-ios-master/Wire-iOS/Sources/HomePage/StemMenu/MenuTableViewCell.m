//
//  MenuTableViewCell.m
//  FoldTableVIewText
//
//  Created by Apple on 2018/9/28.
//  Copyright © 2018年 co. All rights reserved.
//

#import "MenuTableViewCell.h"
#import <Masonry.h>

@interface MenuTableViewCell()


@property (nonatomic, strong) UIView *lineView;

@end

@implementation MenuTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self viewInit];
        [self frameInit];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewInit{
    self.menuLab = [UILabel new];
    _menuLab.textAlignment = NSTextAlignmentLeft;
    _menuLab.font = [UIFont systemFontOfSize:13];
    [self addSubview:_menuLab];
    
    self.lineView = [UIView new];
    _lineView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:_lineView];
}

- (void)frameInit{
    [_menuLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.mas_offset(0);
        make.left.mas_offset(30);
    }];
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.mas_offset(0);
        make.left.mas_offset(30);
        make.height.mas_equalTo(1);
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

