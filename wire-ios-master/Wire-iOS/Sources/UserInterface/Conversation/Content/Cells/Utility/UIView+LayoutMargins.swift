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


import UIKit


extension UITableViewCell {

    class var layoutDirectionAwareLayoutMargins: UIEdgeInsets {
        var left: CGFloat = CGFloat.nan
        var right: CGFloat = CGFloat.nan

        // keyWindow can be nil, in case when running tests or the view is not added to view hierachy
        switch (UIApplication.shared.keyWindow?.traitCollection.horizontalSizeClass) {
        case (.compact?):
            left = 56
            right = 16
        case (.regular?):
            left = 96
            right = 96
        default:
            left = 56
            right = 16
        }

        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            (left, right) = (right, left)
        }

        return UIEdgeInsets(top: 0, left: left, bottom: 0, right: right)
    }

}
