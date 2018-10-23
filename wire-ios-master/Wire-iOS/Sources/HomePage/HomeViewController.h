//
//  ViewController.h
//  StemCells
//
//  Created by Apple on 2018/9/25.
//  Copyright © 2018年 XC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXNetworking.h"
#import "StemModel.h"
#import "MoreViewController.h"
#import "MBProgressHUD.h"

#define kHeaderHeight 100
#define NAVIGATION_HEIGHT (CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) + CGRectGetHeight(self.navigationController.navigationBar.frame))

typedef void(^RootInit)(void);

@class AppRootViewController;
@interface HomeViewController : UIViewController

- (instancetype)initWithlaunchOptions:(NSDictionary *)launchOptions;

- (instancetype)initWithlaunchOptions:(NSDictionary *)launchOptions rootVC:(AppRootViewController *)rootVC;

@property (nonatomic, strong) UIWindow *homeWindow;

@property (nonatomic, copy)RootInit rootinit;

@end

