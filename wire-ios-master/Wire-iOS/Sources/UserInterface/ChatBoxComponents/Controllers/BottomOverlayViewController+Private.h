// 
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
// 



#import <Foundation/Foundation.h>
#import "BottomOverlayViewController.h"



@interface BottomOverlayViewController ()

#pragma mark - Magic Values

@property (nonatomic) UIColor *overlayBackgroundColor;
@property (nonatomic) CGFloat overlayHeight;

//To be called in subclasses in this order
- (void)loadMagicValues __attribute__((objc_requires_super));
- (void)setupBottomOverlay __attribute__((objc_requires_super));
- (void)setupTopView __attribute__((objc_requires_super));
- (void)setupGestureRecognizers __attribute__((objc_requires_super));

@end
