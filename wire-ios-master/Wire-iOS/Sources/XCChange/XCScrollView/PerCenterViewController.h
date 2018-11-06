//
//  PerCenterViewController.h
//  drawer
//
//  Created by Apple on 2018/11/1.
//  Copyright © 2018年 XC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DismissPer)(void);

@interface PerCenterViewController : UIViewController

- (void)updateChange;

@property (nonatomic, copy) DismissPer dismissBlock;

@end

