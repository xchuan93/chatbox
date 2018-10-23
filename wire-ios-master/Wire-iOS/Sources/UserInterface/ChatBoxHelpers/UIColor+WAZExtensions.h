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


#import <UIKit/UIKit.h>

#import <WireSyncEngine/WireSyncEngine.h>


@interface UIColor (WAZExtensions)

/// Set override accent color. Can set to ZMAccentColorUndefined to remove override.
+ (void)setAccentOverrideColor:(ZMAccentColor)overrideColor;

/// Set accent color on self user to this index.
+ (void)setAccentColor:(ZMAccentColor)accentColor;

+ (instancetype)accentColor;
+ (ZMAccentColor)indexedAccentColor;

+ (UIColor *)colorForZMAccentColor:(ZMAccentColor)accentColor;

- (BOOL)isEqualTo:(id)object;

@end
