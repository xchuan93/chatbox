//
//  NewsTabCell.h
//  StemCells
//
//  Created by Apple on 2018/9/25.
//  Copyright © 2018年 XC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsTabCell : UITableViewCell

- (void)setImageStr:(NSString *)imageStr title:(NSString *)title detail:(NSString *)detail;

@end

@interface VideoTableCell : UITableViewCell
- (void)setImageStr:(NSString *)imageStr title:(NSString *)title;
@end

@interface VideoTitleTableCell : UITableViewCell

- (void)setTitle:(NSString *)title;

@end

@interface YouthTripTableCell : UITableViewCell

@end

@interface HotTableCell : UITableViewCell

- (void)setImageStr:(NSString *)imageStr title:(NSString *)title detail:(NSString *)detail time:(NSString *)time;

@end
