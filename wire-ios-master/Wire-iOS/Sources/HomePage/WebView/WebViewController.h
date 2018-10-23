//
//  WebViewController.h
//  StemCells
//
//  Created by Apple on 2018/9/26.
//  Copyright © 2018年 XC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property (nonatomic, copy) NSString *loadUrlStr;

- (void)setType:(NSString *)type title:(NSString *)title urlStr:(NSString *)urlStr;

@end


