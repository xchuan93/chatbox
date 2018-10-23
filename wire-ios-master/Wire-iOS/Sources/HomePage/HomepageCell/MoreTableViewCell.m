//
//  MoreTableViewCell.m
//  StemCells
//
//  Created by Apple on 2018/9/30.
//  Copyright © 2018年 XC. All rights reserved.
//

#import "MoreTableViewCell.h"
#import "UIColor+RGB.h"

#import <Masonry.h>

@interface MoreTableViewCell()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *timeLab;

@end

@implementation MoreTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self viewInit];
        [self frameInit];
    }
    return self;
}

- (void)viewInit{
    self.titleLab = [UILabel new];
    _titleLab.textAlignment = NSTextAlignmentLeft;
    _titleLab.textColor = [UIColor colorWithRGB:5 g:5 b:5 alpha:1];
    _titleLab.font = [UIFont systemFontOfSize:15];
    [self addSubview:_titleLab];
    
    self.timeLab = [UILabel new];
    _timeLab.textAlignment = NSTextAlignmentLeft;
    _timeLab.textColor = [UIColor colorWithRGB:5 g:5 b:5 alpha:1];
    _timeLab.font = [UIFont systemFontOfSize:13];
    [self addSubview:_timeLab];
}
- (void)frameInit{
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(15);
        make.top.mas_offset(10);
        make.right.mas_offset(-10);
        make.height.mas_equalTo(17);
    }];
    [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_titleLab.mas_left);
        make.top.equalTo(self->_titleLab.mas_bottom).offset(5);
        make.height.mas_equalTo(15);
        make.width.equalTo(self->_titleLab);
    }];
}

- (void)setTitle:(NSString *)title time:(NSString *)time{
    self.titleLab.text = title;
    self.timeLab.text = time;
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
