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


#import "ProfileIncomingConnectionRequestFooterView.h"

#import "WAZUIMagicIOS.h"

#import "Button.h"
@import WireExtensionComponents;


@implementation ProfileIncomingConnectionRequestFooterView

- (id)init
{
    return[self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createViews];
        [self setupConstraints];
    }
    return self;
}

- (void)createViews
{
    self.acceptButton = [Button buttonWithStyleClass:@"dialogue-button-full"];
    [self.acceptButton setTitle:[NSLocalizedString(@"inbox.connection_request.connect_button_title", @"") transformStringWithMagicKey:@"connect.connect_button.text_transform"] forState:UIControlStateNormal];
    [self addSubview:self.acceptButton];
    
    self.ignoreButton = [Button buttonWithStyleClass:@"dialogue-button-empty"];;
    [self.ignoreButton setTitle:[NSLocalizedString(@"inbox.connection_request.ignore_button_title", @"") transformStringWithMagicKey:@"connect.ignore_button.text_transform"] forState:UIControlStateNormal];
    [self addSubview:self.ignoreButton];
}

- (void)setupConstraints
{
    self.acceptButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.acceptButton addConstraintForTopMargin:0 relativeToView:self];
    [self.acceptButton addConstraintForBottomMargin:[WAZUIMagic cgFloatForIdentifier:@"profile_temp.content_bottom_margin"] relativeToView:self];
    [self.acceptButton addConstraintForRightMargin:[WAZUIMagic cgFloatForIdentifier:@"profile_temp.content_right_margin"] relativeToView:self];
    [self.acceptButton addConstraintForHeight:[WAZUIMagic cgFloatForIdentifier:@"connect.connect_button.height"]];
    
    
    self.ignoreButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.ignoreButton addConstraintForTopMargin:0 relativeToView:self];
    [self.ignoreButton addConstraintForBottomMargin:[WAZUIMagic cgFloatForIdentifier:@"profile_temp.content_bottom_margin"] relativeToView:self];
    [self.ignoreButton addConstraintForLeftMargin:[WAZUIMagic cgFloatForIdentifier:@"profile_temp.content_left_margin"] relativeToView:self];
    [self.ignoreButton addConstraintForHeight:[WAZUIMagic cgFloatForIdentifier:@"connect.ignore_button.height"]];
    
    [self.acceptButton addConstraintForAligningLeftToRightOfView:self.ignoreButton distance:16];
    [self.acceptButton addConstraintForEqualWidthToView:self.ignoreButton];
}

@end
