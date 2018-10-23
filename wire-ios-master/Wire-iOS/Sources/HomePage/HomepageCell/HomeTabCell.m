//
//  NewsTabCell.m
//  StemCells
//
//  Created by Apple on 2018/9/25.
//  Copyright © 2018年 XC. All rights reserved.
//

#import "HomeTabCell.h"
#import <Masonry.h>
#import "UIColor+RGB.h"
#import "UIImageView+WebCache.h"
@interface NewsTabCell()
@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *newsLab;
@end

@implementation NewsTabCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self viewInit];
        [self frameInit];
    }
    return self;
}

- (void)viewInit{
    self.leftImageView = [UIImageView new];
    //    _leftImageView.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:_leftImageView];
    
    self.titleLab = [UILabel new];
    _titleLab.textAlignment = NSTextAlignmentLeft;
    _titleLab.font = [UIFont systemFontOfSize:15];
    _titleLab.textColor = [UIColor colorWithRGB:5 g:5 b:5 alpha:1];
    [_titleLab sizeToFit];
    _titleLab.text = @"脂肪肝干细胞治疗脂肪肝干细胞治疗脂肪肝干细胞治疗";
    _titleLab.font = [UIFont systemFontOfSize:17];
    [self.contentView addSubview:_titleLab];
    
    self.newsLab = [UILabel new];
    _newsLab.textAlignment = NSTextAlignmentLeft;
    _newsLab.text = @"脂肪肝干细胞治疗脂肪肝干细胞治疗脂肪肝干细胞治疗脂肪肝干细胞治疗脂肪肝干细胞治疗脂肪肝干细胞治疗脂肪肝干细胞治疗脂肪肝干细胞治疗脂肪肝干细胞治疗";
    _newsLab.font = [UIFont systemFontOfSize:13];
    _newsLab.textColor = [UIColor colorWithRGB:5 g:5 b:5 alpha:1];
    _newsLab.numberOfLines = 0;
    _newsLab.lineBreakMode = NSLineBreakByWordWrapping;
    _newsLab.font = [UIFont systemFontOfSize:14];
    [_newsLab sizeToFit];
    [self.contentView addSubview:_newsLab];
}

- (void)frameInit{
    [_leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(15);
        make.top.mas_offset(20);
        make.bottom.mas_offset(0);
        make.width.mas_equalTo(120);
    }];
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_leftImageView.mas_top);
        make.left.equalTo(self->_leftImageView.mas_right).offset(20);
        make.right.mas_offset(-20);
        make.height.mas_lessThanOrEqualTo(17);
    }];
    [_newsLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self->_titleLab);
        make.top.equalTo(self->_titleLab.mas_bottom).offset(8);
        make.bottom.mas_offset(0);
        
    }];
}

- (void)setImageStr:(NSString *)imageStr title:(NSString *)title detail:(NSString *)detail{
    self.titleLab.text = title;
    self.newsLab.text = detail;
    //    [self.leftImageView sd_setImageWithURL:[NSURL URLWithString:imageStr]];
    [self.leftImageView sd_setImageWithURL:[NSURL URLWithString:imageStr] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.leftImageView.image = image;
    }];
}

@end

@interface VideoTableCell()

@property (nonatomic, strong) UIImageView *videoImageView;
@property (nonatomic, strong) UIImageView *playImageView;
@property (nonatomic, strong) UIView *markView;
@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation VideoTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self viewInit];
        [self frameInit];
    }
    return self;
}
- (void)viewInit{
    self.videoImageView = [UIImageView new];
    _videoImageView.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_videoImageView];
    
    self.playImageView = [UIImageView new];
    _playImageView.image = [UIImage imageNamed:@"play"];
    [self.contentView addSubview:_playImageView];
    
    self.markView = [UIView new];
    _markView.backgroundColor = [UIColor colorWithRGB:0 g:0 b:0 alpha:0.5];
    [self.contentView addSubview:_markView];
    
    self.titleLab = [UILabel new];
    _titleLab.text = @"sfjlsfhlkasfh;laskhflasf";
    _titleLab.font = [UIFont systemFontOfSize:15];
    _titleLab.textAlignment = NSTextAlignmentLeft;
    _titleLab.textColor = [UIColor colorWithRGB:255 g:255 b:255 alpha:1];
    [self.contentView addSubview:_titleLab];
}
- (void)frameInit{
    [_videoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(10);
        make.bottom.mas_offset(0);
        make.left.mas_offset(15);
        make.right.mas_offset(-15);
    }];
    [_playImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_offset(0);
        make.centerY.mas_offset(0);
        make.width.height.mas_equalTo(43);
    }];
    [_markView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self->_videoImageView);
        make.height.mas_equalTo(27);
    }];
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_markView.mas_left).offset(10);
        make.right.equalTo(self->_markView.mas_right).offset(-10);
        make.height.mas_equalTo(self->_markView.mas_height);
        make.centerY.mas_equalTo(self->_markView.mas_centerY);
    }];
}

- (void)setImageStr:(NSString *)imageStr title:(NSString *)title{
    self.titleLab.text = title;
    [self.videoImageView sd_setImageWithURL:[NSURL URLWithString:imageStr] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.videoImageView.image = image;
    }];
}

@end

@interface VideoTitleTableCell()

@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation VideoTitleTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self viewInit];
        [self frameInit];
    }
    return self;
}

- (void)viewInit{
    self.leftImageView = [UIImageView new];
    _leftImageView.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_leftImageView];
    
    self.titleLab = [UILabel new];
    _titleLab.textAlignment = NSTextAlignmentLeft;
    _titleLab.font = [UIFont systemFontOfSize:15];
    _titleLab.textColor = [UIColor colorWithRGB:5 g:5 b:5 alpha:1];
    _titleLab.text = @"ajshfkjsa;lfhldksjlhfaljhsdkjfhjkdshfksfg";
    [self.contentView addSubview:_titleLab];
    
    self.lineView = [UIView new];
    _lineView.backgroundColor = [UIColor colorWithRGB:221 g:221 b:221 alpha:1];
    [self.contentView addSubview:_lineView];
}
- (void)frameInit{
    UIImage *img = [UIImage imageNamed:@"content"];
    [_leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(15);
        make.centerY.mas_offset(0);
        make.width.mas_equalTo(img.size.width);
        make.height.mas_equalTo(img.size.height);
    }];
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_offset(0);
        make.left.equalTo(self->_leftImageView.mas_right).offset(8);
        make.right.mas_offset(-15);
        make.height.mas_equalTo(17);
    }];
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_leftImageView.mas_left);
        make.right.mas_offset(-15);
        make.top.mas_offset(0);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)setTitle:(NSString *)title{
    self.titleLab.text = title;
}

@end

@interface YouthTripTableCell()

@property (nonatomic, strong) UIImageView *midImageView;

@end

@implementation YouthTripTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self viewInit];
        [self frameInit];
    }
    return self;
}

- (void)viewInit{
    UIImage *img = [UIImage imageNamed:@"youth"];
    self.midImageView = [UIImageView new];
    self.midImageView.image = img;
    _midImageView.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:_midImageView];
}

- (void)frameInit{
    [_midImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(15);
        make.right.mas_offset(-15);
        //        make.height.equalTo(self.contentView.mas_height);
        make.top.mas_offset(20);
        make.bottom.mas_offset(-33);
    }];
}

@end

@interface HotTableCell()

@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *newsLab;
@property (nonatomic, strong) UILabel *timeLab;

@end

@implementation HotTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self viewInit];
        [self frameInit];
    }
    return self;
}

- (void)viewInit{
    self.leftImageView = [UIImageView new];
    //    _leftImageView.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:_leftImageView];
    
    self.titleLab = [UILabel new];
    _titleLab.textAlignment = NSTextAlignmentLeft;
    _titleLab.font = [UIFont systemFontOfSize:15];
    _titleLab.textColor = [UIColor colorWithRGB:5 g:5 b:5 alpha:1];
    [_titleLab sizeToFit];
    _titleLab.text = @"脂肪肝干细胞治疗脂肪肝干细胞治疗脂肪肝干细胞治疗";
    _titleLab.font = [UIFont systemFontOfSize:17];
    [self.contentView addSubview:_titleLab];
    
    self.newsLab = [UILabel new];
    _newsLab.textAlignment = NSTextAlignmentLeft;
    _newsLab.text = @"脂肪肝干细胞治疗脂肪肝干细胞治疗脂肪肝干细胞治疗脂肪肝干细胞治疗脂肪肝干细胞治疗脂肪肝干细胞治疗脂肪肝干细胞治疗脂肪肝干细胞治疗脂肪肝干细胞治疗";
    _newsLab.font = [UIFont systemFontOfSize:13];
    _newsLab.textColor = [UIColor colorWithRGB:5 g:5 b:5 alpha:1];
    _newsLab.numberOfLines = 0;
    _newsLab.lineBreakMode = NSLineBreakByWordWrapping;
    _newsLab.font = [UIFont systemFontOfSize:14];
    [_newsLab sizeToFit];
    [self.contentView addSubview:_newsLab];
    
    self.timeLab = [UILabel new];
    _timeLab.textAlignment = NSTextAlignmentLeft;
    _timeLab.font = [UIFont systemFontOfSize:11];
    _timeLab.textColor = [UIColor colorWithRGB:136 g:136 b:136 alpha:1];
    _timeLab.text = @"时间: 2018-09-17";
    [self.contentView addSubview:_timeLab];
}

- (void)frameInit{
    [_leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(15);
        make.top.mas_offset(20);
        make.bottom.mas_offset(0);
        make.width.mas_equalTo(120);
    }];
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_leftImageView.mas_top);
        make.left.equalTo(self->_leftImageView.mas_right).offset(20);
        make.right.mas_offset(-20);
        make.height.mas_lessThanOrEqualTo(17);
    }];
    [_timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_leftImageView.mas_right).offset(20);
        make.right.mas_offset(-15);
        make.bottom.mas_offset(0);
        make.height.mas_equalTo(15);
        
    }];
    [_newsLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self->_titleLab);
        make.top.equalTo(self->_titleLab.mas_bottom).offset(6);
        make.bottom.equalTo(self->_timeLab.mas_top).offset(-5);
        
    }];
}

- (void)setImageStr:(NSString *)imageStr title:(NSString *)title detail:(NSString *)detail time:(NSString *)time{
    self.titleLab.text = title;
    self.newsLab.text = detail;
    self.timeLab.text = time;
    [self.leftImageView sd_setImageWithURL:[NSURL URLWithString:imageStr] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.leftImageView.image = image;
    }];
}

@end

