//
//  TestViewController.h
//  drawer
//
//  Created by Apple on 2018/11/1.
//  Copyright © 2018年 XC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AvertTip)(void);

@interface TestViewController : UIViewController

@property (nonatomic, copy) AvertTip tipblock;

@end
