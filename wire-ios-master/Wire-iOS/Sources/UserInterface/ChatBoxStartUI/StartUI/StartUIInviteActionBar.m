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


#import "StartUIInviteActionBar.h"
#import "IconButton.h"
#import "UIColor+WR_ColorScheme.h"
@import PureLayout;
#import <Classy/Classy.h>
@import WireExtensionComponents;
#import "Wire-Swift.h"

@interface StartUIInviteActionBar ()

@property (nonatomic, readwrite) Button *inviteButton;
@property (nonatomic) NSLayoutConstraint *bottomEdgeConstraint;
@property (nonatomic) UIView *lineView;

@end


@implementation StartUIInviteActionBar

static const CGFloat padding = 12;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setOpaque:NO];
        self.backgroundColor = [UIColor clearColor];

        [self createLineView];
        [self createInviteButton];
        [self createConstraints];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardFrameWillChange:)
                                                     name:UIKeyboardWillChangeFrameNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createInviteButton
{
    self.inviteButton = [Button buttonWithStyle:ButtonStyleEmpty variant:ColorSchemeVariantDark];
    self.inviteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.inviteButton];
    [self.inviteButton setTitle:NSLocalizedString(@"peoplepicker.invite_more_people", @"") forState:UIControlStateNormal];
}

- (void)createLineView
{
    self.lineView = [[UIView alloc] initForAutoLayout];
    self.lineView.backgroundColor = [UIColor wr_colorFromColorScheme:ColorSchemeColorSeparator variant:ColorSchemeVariantDark];
    [self addSubview:self.lineView];
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    [self invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, (self.hidden) ? 0 : 56.0f);
}

- (void)createConstraints
{
    [self.inviteButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset: padding];
    [self.inviteButton autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset: padding*2];
    [self.inviteButton autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset: padding*2];
    [self.inviteButton autoSetDimension:ALDimensionHeight toSize:28];
    self.bottomEdgeConstraint = [self.inviteButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset: padding + UIScreen.safeArea.bottom];
    
    [self.lineView autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.lineView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.lineView autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [self.lineView autoSetDimension:ALDimensionHeight toSize:0.5];
}

#pragma mark - UIKeyboard notifications

- (void)keyboardFrameWillChange:(NSNotification *)notification
{
    CGFloat beginOrigin = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin.y;
    CGFloat endOrigin = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    CGFloat diff = beginOrigin - endOrigin;
    [UIView animateWithKeyboardNotification:notification inView:self animations:^(CGRect keyboardFrameInView) {
        self.bottomEdgeConstraint.constant = -padding - (diff > 0 ? 0 : UIScreen.safeArea.bottom);
        [self layoutIfNeeded];
    } completion:nil];
}

@end
