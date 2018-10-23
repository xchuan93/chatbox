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


#import "CheckBoxButton.h"
#import "UIImage+ImageUtilities.h"
#import "UIImage+ZetaIconsNeue.h"


@implementation CheckBoxButton

- (void)toggleSelected:(id)sender
{
    [self setSelected:! self.isSelected];
}

- (void)setIcon:(ZetaIconType)icon withSize:(ZetaIconSize)iconSize color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state
{
    UIEdgeInsets iconInsets = UIEdgeInsetsMake(4, 4, 4, 4);
    [self setImage:[[UIImage imageForIcon:icon iconSize:iconSize color:color] imageWithInsets:iconInsets backgroundColor:backgroundColor] forState:state];
}

@end
